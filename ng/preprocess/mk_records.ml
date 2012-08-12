open Camlp4
open Camlp4.PreCast
open Camlp4.PreCast.Ast
open Syntax


(* Common camlp4 functions *)

let uid_of_ident = function
  | IdUid (_, id) -> id
  | i -> Loc.raise (loc_of_ident i) (Failure "uppercase identifier expected")

let lid_of_ident = function
  | IdLid (_, id) -> id
  | i -> Loc.raise (loc_of_ident i) (Failure "lowercase identifier expected")

let lid_of_expr = function
  | <:expr< $lid:id$ >> -> id
  | e -> Loc.raise (loc_of_expr e) (Failure "lowercase identifier expected")

let pat_lid _loc name = <:patt< $lid:name$ >>
let pat_uid _loc name = <:patt< $uid:name$ >>
let exp_int _loc i = <:expr< $int:i$ >>
let exp_str _loc s = <:expr< $str:s$ >>
let exp_lid _loc name = <:expr< $lid:name$ >>
let exp_uid _loc name = <:expr< $uid:name$ >>
let ctyp_uid _loc name = <:ctyp< $uid:name$ >>

let exp_qname _loc m n = match m with
  | None -> <:expr< $lid:n$ >>
  | Some module_name -> <:expr< $uid:module_name$.$lid:n$ >>

let rec exp_of_list _loc = function
  | [] -> <:expr< $uid:"[]"$ >>
  | e::r -> <:expr< $uid:"::"$ $e$ $exp_of_list _loc r$ >>


let rec _list_of_com_expr = function
  | Ast.ExNil _loc -> []
  | Ast.ExCom (_loc, e, r) -> e::(_list_of_com_expr r)
  | e -> [e]

let list_of_com_expr = function
  | Ast.ExTup (_loc, e) -> _list_of_com_expr e
  | e -> [e]


let rec list_of_sem_expr = function
  | Ast.ExNil _loc -> []
  | Ast.ExSem (_loc, e, r) -> e::(list_of_sem_expr r)
  | e -> [e]


let rec apply_exprs _loc e = function
  | [] -> e
  | a::r -> apply_exprs _loc <:expr< $e$ $a$ >> r

let mk_multiple_args_fun _loc fname argnames body =
  let rec _mk_multiple_args_fun = function
    | [] -> body
    | arg::r -> <:expr< fun $pat:pat_lid _loc arg$ -> $exp:_mk_multiple_args_fun r$ >>
  in
  <:binding< $pat:pat_lid _loc fname$ = $exp:_mk_multiple_args_fun argnames$ >>


(* Internal type definitions *)

type record_option =
  | DoLwt
  | ExactParser
  | Param of string list

type field_len =
  | FixedLen of int    (* size in bytes of the field *)
  | VarLen of string   (* name of the integer type used *)
  | Remaining

(* TODO: Add options for lists (AtLeast, AtMost) and for options *)
type field_type =
  | FT_Empty
  | FT_Char
  | FT_Int of string                        (* name of the integer type *)
  | FT_IPv4
  | FT_IPv6
  | FT_String of field_len * bool
  | FT_List of field_len * field_type
  | FT_Container of string * field_type     (* the string corresponds to the integer type for the field length *)
  | FT_Custom of (string option) * string * Ast.expr list  (* the expr list is the list of args to apply to parse funs *)

type record_description = {
  rname : string;
  fields : (Loc.t * string * field_type * bool) list;
  rdo_lwt : bool;
  rdo_exact : bool;
  rparse_params : string list;
}

let mk_params opts =
  let rec _mk_params = function
    | [] -> [["input"]]
    | (Param l)::r -> l::(_mk_params r)
    | _::r -> _mk_params r
  in List.concat (_mk_params opts)

let mk_record_desc n f o = {
  rname = n; fields = f;
  rdo_lwt = List.mem DoLwt o;
  rdo_exact = List.mem ExactParser o;
  rparse_params = mk_params o;
}





(* To-be-processed file parsing *)

let rec field_type_of_ident name decorator subtype =
  match name, decorator, subtype with
    | <:ident< $lid:"empty"$ >>,  None, None -> FT_Empty
    | <:ident< $lid:"char"$ >>,   None, None -> FT_Char
    | <:ident< $lid:("uint8"|"uint16"|"uint24"|"uint32" as int_t)$ >>, None, None -> FT_Int int_t
    | <:ident< $lid:"ipv4"$ >>,   None, None -> FT_IPv4
    | <:ident< $lid:"ipv6"$ >>,   None, None -> FT_IPv6

    | <:ident< $lid:"list"$ >>,   None, Some t ->
      FT_List (Remaining, t)
    | <:ident< $lid:"list"$ >>,   Some <:expr< $int: i$ >>, Some t ->
      FT_List (FixedLen (int_of_string i), t)
    | <:ident< $lid:"list"$ >>,   Some <:expr< $lid:("uint8"|"uint16"|"uint24"|"uint32" as int_t)$ >>, Some t ->
      FT_List (VarLen int_t, t)
    | <:ident< $lid:"list"$ >> as i,   _, _ ->
      Loc.raise (loc_of_ident i) (Failure "invalid list type")

    | <:ident< $lid:"container"$ >>, Some <:expr< $lid:("uint8"|"uint16"|"uint24"|"uint32" as int_t)$ >>,
      Some t -> FT_Container (int_t, t)
    | <:ident< $lid:"container"$ >> as i, _, _ ->
      Loc.raise (loc_of_ident i) (Failure "invalid container type")

    | <:ident< $lid:"string"$ >>,    None, None-> FT_String (Remaining, false)
    | <:ident< $lid:"binstring"$ >>, None, None -> FT_String (Remaining, true)
    | <:ident< $lid:"string"$ >>,    Some <:expr< $int:i$ >>, None ->
      FT_String (FixedLen (int_of_string i), false)
    | <:ident< $lid:"binstring"$ >>, Some <:expr< $int:i$ >>, None ->
      FT_String (FixedLen (int_of_string i), true)
    | <:ident< $lid:"string"$ >>,    Some <:expr< $lid:("uint8"|"uint16"|"uint24"|"uint32" as int_t)$ >>, None ->
      FT_String (VarLen int_t, false)
    | <:ident< $lid:"binstring"$ >>, Some <:expr< $lid:("uint8"|"uint16"|"uint24"|"uint32" as int_t)$ >>, None ->
      FT_String (VarLen int_t, true)
    | <:ident< $lid:("string" | "binstring")$ >> as i, _, _ ->
      Loc.raise (loc_of_ident i) (Failure "invalid string type")

    | <:ident< $lid:custom_t$ >>, None, None ->
      FT_Custom (None, custom_t, [])
    | <:ident< $lid:custom_t$ >>, Some e, None ->
      FT_Custom (None, custom_t, list_of_com_expr e)
    | <:ident< $uid:module_name$.$lid:custom_t$ >>, None, None ->
      FT_Custom (Some module_name, custom_t, [])
    | <:ident< $uid:module_name$.$lid:custom_t$ >>, Some e, None ->
      FT_Custom (Some module_name, custom_t, list_of_com_expr e)

    | i, _, _ -> Loc.raise (loc_of_ident i) (Failure "invalid identifier for a type")


let rec opts_of_exprs = function
  | [] -> []
  | <:expr< $lid:"with_lwt"$ >> :: r -> DoLwt::(opts_of_exprs r)
  | <:expr< $lid:"with_exact"$ >> :: r -> ExactParser::(opts_of_exprs r)
  | <:expr< $lid:"top"$ >> :: r -> DoLwt::ExactParser::(opts_of_exprs r)
  | <:expr< $lid:"param"$ $e$ >> :: r -> (Param (List.map lid_of_expr (list_of_com_expr e)))::(opts_of_exprs r)
  | e::r -> Loc.raise (loc_of_expr e) (Failure "unknown option")



(* Type creation *)

let rec _ocaml_type_of_field_type _loc = function
  | FT_Empty -> <:ctyp< $lid:"unit"$ >>
  | FT_Char -> <:ctyp< $lid:"char"$ >>
  | FT_Int _ -> <:ctyp< $lid:"int"$ >>
  | FT_IPv4 | FT_IPv6 -> <:ctyp< $lid:"string"$ >>
  | FT_String _ -> <:ctyp< $lid:"string"$ >>
  | FT_List (_, subtype) -> <:ctyp< list $_ocaml_type_of_field_type _loc subtype$ >>
  | FT_Container (_, subtype) -> _ocaml_type_of_field_type _loc subtype
  | FT_Custom (None, n, _) -> <:ctyp< $lid:n$ >>
  | FT_Custom (Some m, n, _) -> <:ctyp< $uid:m$.$lid:n$ >>


let ocaml_type_of_field_type _loc t opt =
  let real_t = _ocaml_type_of_field_type _loc t in
  if opt then <:ctyp< option $real_t$ >> else real_t

let mk_record_type _loc record =
  let ctyp_fields = List.map (fun (_loc, n, t, optional) -> <:ctyp< $lid:n$ : $ocaml_type_of_field_type _loc t optional$ >> ) record.fields in
  <:str_item< type $lid:record.rname$ = { $list:ctyp_fields$ } >>


(* Parse function *)

let rec parse_fun_of_field_type _loc name t =
  let mk_pf fname = <:expr< $uid:"ParsingEngine"$.$lid:fname$ >> in
  match t with
    | FT_Empty -> mk_pf "parse_empty"
    | FT_Char -> mk_pf "parse_char"
    | FT_Int int_t -> mk_pf  ("parse_" ^ int_t)
    | FT_IPv4 -> <:expr< $mk_pf "parse_string"$ $exp_int _loc "4"$ >>
    | FT_IPv6 -> <:expr< $mk_pf "parse_string"$ $exp_int _loc "16"$ >>

    | FT_String (FixedLen n, _) -> <:expr< $mk_pf "parse_string"$ $exp_int _loc (string_of_int n)$ >>
    | FT_String (VarLen int_t, _) ->
      <:expr< $mk_pf "parse_varlen_string"$ $exp_str _loc name$ $mk_pf ("parse_" ^ int_t)$ >>
    | FT_String (Remaining, _) -> mk_pf "parse_rem_string"

    | FT_List (FixedLen n, subtype) ->
      <:expr< $mk_pf "parse_list"$ $exp_int _loc (string_of_int n)$ $parse_fun_of_field_type _loc name subtype$ >>
    | FT_List (VarLen int_t, subtype) ->
      <:expr< $mk_pf "parse_varlen_list"$ $exp_str _loc name$ $mk_pf ("parse_" ^ int_t)$ $parse_fun_of_field_type _loc name subtype$ >>
    | FT_List (Remaining, subtype) ->
      <:expr< $mk_pf "parse_rem_list"$ $parse_fun_of_field_type _loc name subtype$ >>
    | FT_Container (int_t, subtype) ->
      <:expr< $mk_pf "parse_container"$ $exp_str _loc name$ $mk_pf ("parse_" ^ int_t)$ $parse_fun_of_field_type _loc name subtype$ >>

    | FT_Custom (m, n, e) -> apply_exprs _loc (exp_qname _loc m ("parse_" ^ n)) e


let mk_record_parse_fun _loc record =
  let rec mk_body = function
    | [] ->
      let field_assigns = List.map (fun (_loc, n, _, _) ->
	<:rec_binding< $lid:n$ = $exp:exp_lid _loc ("_" ^ n)$ >> ) record.fields
      in <:expr< { $list:field_assigns$ } >>
    | (_loc, n, t, false)::r ->
      let tmp = mk_body r in
      <:expr< let $lid:("_" ^ n)$ = $parse_fun_of_field_type _loc n t$ input in $tmp$ >>
    | (_loc, n, t, true)::r ->
      let tmp = mk_body r in
      <:expr< let $lid:("_" ^ n)$ = ParsingEngine.try_parse $parse_fun_of_field_type _loc n t$ input in $tmp$ >>
  in

  let body = mk_body record.fields in
  <:str_item< value $mk_multiple_args_fun _loc ("parse_" ^ record.rname) record.rparse_params body$ >>


(* Lwt Parse function *)

let rec lwt_parse_fun_of_field_type _loc name t =
  let mk_pf fname = <:expr< $uid:"LwtParsingEngine"$.$lid:fname$ >> in
  match t with
  | FT_Empty -> mk_pf "lwt_parse_empty"
  | FT_Char -> mk_pf "lwt_parse_char"
  | FT_Int int_t -> mk_pf ("lwt_parse_" ^ int_t)
  | FT_IPv4 -> <:expr< $mk_pf "lwt_parse_string"$ $exp_int _loc "4"$ >>
  | FT_IPv6 -> <:expr< $mk_pf "lwt_parse_string"$ $exp_int _loc "16"$ >>

  | FT_String (FixedLen n, _) -> <:expr< $mk_pf "lwt_parse_string"$ $exp_int _loc (string_of_int n)$ >>
  | FT_String (VarLen int_t, _) ->
    <:expr< $mk_pf "lwt_parse_varlen_string"$ $exp_str _loc name$ $mk_pf ("lwt_parse_" ^ int_t)$ >>
  | FT_String (Remaining, _) -> mk_pf "lwt_parse_rem_string"

  | FT_List (FixedLen n, subtype) ->
    <:expr< $mk_pf "lwt_parse_list"$ $exp_int _loc (string_of_int n)$ $lwt_parse_fun_of_field_type _loc name subtype$ >>
  | FT_List (VarLen int_t, subtype) ->
    <:expr< $mk_pf "lwt_parse_varlen_list"$ $exp_str _loc name$ $mk_pf ("lwt_parse_" ^ int_t)$
                                                   $lwt_parse_fun_of_field_type _loc name subtype$ >>
  | FT_List (Remaining, subtype) ->
    <:expr< $mk_pf "lwt_parse_rem_list"$ $lwt_parse_fun_of_field_type _loc name subtype$ >>
  | FT_Container (int_t, subtype) ->
    <:expr< $mk_pf "lwt_parse_container"$ $exp_str _loc name$ $mk_pf ("lwt_parse_" ^ int_t)$
                                                 $lwt_parse_fun_of_field_type _loc name subtype$ >>

  | FT_Custom (m, n, e) -> apply_exprs _loc (exp_qname _loc m ("lwt_parse_" ^ n)) e

let mk_record_lwt_parse_fun _loc record =
  let rec mk_body = function
    | [] ->
      let field_assigns = List.map (fun (_loc, n, _, _) ->
	<:rec_binding< $lid:n$ = $exp:exp_lid _loc ("_" ^ n)$ >> ) record.fields
      in <:expr< Lwt.return { $list:field_assigns$ } >>
    | (_loc, n, t, false)::r ->
      let tmp = mk_body r in
      <:expr< Lwt.bind ($lwt_parse_fun_of_field_type _loc n t$ input) (fun $lid:("_" ^ n)$ -> $tmp$ ) >>
    | (_loc, n, t, true)::r ->
      let tmp = mk_body r in
      <:expr< Lwt.bind (LwtParsingEngine.try_lwt_parse $lwt_parse_fun_of_field_type _loc n t$ input) (fun $lid:("_" ^ n)$ -> $tmp$ ) >>
  in

  let body = mk_body record.fields in
  <:str_item< value $mk_multiple_args_fun _loc ("lwt_parse_" ^ record.rname) record.rparse_params body$ >>


(* Exact parse *)

let mk_exact_parse_fun _loc record =
  let rec all_but_least = function [] | [_] -> [] | x::r -> (exp_lid _loc x)::(all_but_least r) in
  let parse_fun = apply_exprs _loc (exp_qname _loc None ("parse_" ^ record.rname)) (all_but_least record.rparse_params) in
  let body = <:expr< $parse_fun$ input >> in
  <:str_item< value $mk_multiple_args_fun _loc ("exact_parse_" ^ record.rname) record.rparse_params body$ >>


(* Dump function *)

let rec dump_fun_of_field_type _loc t =
  let mk_df fname = <:expr< $uid:"DumpingEngine"$.$lid:fname$ >> in
  match t with
    | FT_Empty -> mk_df "dump_empty"
    | FT_Char -> mk_df "dump_char"
    | FT_Int int_t -> mk_df  ("dump_" ^ int_t)

    | FT_String (VarLen int_t, _) ->
      <:expr< $mk_df "dump_varlen_string"$ $mk_df ("dump_" ^ int_t)$ >>
    | FT_IPv4
    | FT_IPv6
    | FT_String _ -> mk_df "dump_string"

    | FT_List (VarLen int_t, subtype) ->
      <:expr< $mk_df "dump_varlen_list"$ $mk_df ("dump_" ^ int_t)$ $dump_fun_of_field_type _loc subtype$ >>
    | FT_List (_, subtype) ->
      <:expr< $mk_df "dump_list"$ $dump_fun_of_field_type _loc subtype$ >>
    | FT_Container (int_t, subtype) ->
      <:expr< $mk_df "dump_container"$ $mk_df ("dump_" ^ int_t)$ $dump_fun_of_field_type _loc subtype$ >>

    | FT_Custom (m, n, _) -> exp_qname _loc m ("dump_" ^ n)


let mk_record_dump_fun _loc record =
  let dump_one_field = function
      (_loc, n, t, false) ->
      <:expr< $dump_fun_of_field_type _loc t$ $lid:record.rname$.$lid:n$ >>
    | (_loc, n, t, true) ->
      <:expr< DumpingEngine.try_dump $dump_fun_of_field_type _loc t$ $lid:record.rname$.$lid:n$ >>
  in
  let fields_dumped_expr = exp_of_list _loc (List.map dump_one_field record.fields) in
  let body =
    <:expr< let $lid:"fields_dumped"$ = $fields_dumped_expr$ in
	    String.concat "" fields_dumped >>
  in
  <:str_item< value $ <:binding< $pat:pat_lid _loc ("dump_" ^ record.rname)$ $pat_lid _loc record.rname$ = $exp:body$ >> $ >>


(* Print function *)

let rec print_fun_of_field_type _loc t =
  let mk_pf fname = <:expr< $uid:"PrintingEngine"$.$lid:fname$ >> in
  match t with
    | FT_Empty -> mk_pf "print_empty"
    | FT_Char -> mk_pf "print_char"
    | FT_Int int_t -> mk_pf  ("print_" ^ int_t)

    | FT_String (_, false) -> mk_pf "print_string"
    | FT_String (_, true) -> mk_pf "print_binstring"
    | FT_IPv4 -> mk_pf "print_ipv4"
    | FT_IPv6 -> mk_pf "print_ipv6"

    | FT_List (_, subtype) ->
      <:expr< $mk_pf "print_list"$ $print_fun_of_field_type _loc subtype$ >>
    | FT_Container (_, subtype) -> print_fun_of_field_type _loc subtype
    | FT_Custom (m, n, _) -> exp_qname _loc m ("print_" ^ n)


let mk_record_print_fun _loc record =
  let print_one_field = function
      (_loc, n, t, false) ->
	<:expr< $print_fun_of_field_type _loc t$ new_indent $str:n$ $lid:record.rname$.$lid:n$ >>
    | (_loc, n, t, true) ->
	<:expr< PrintingEngine.try_print $print_fun_of_field_type _loc t$ new_indent $str:n$ $lid:record.rname$.$lid:n$ >>
  in
  let fields_printed_expr = exp_of_list _loc (List.map print_one_field record.fields) in
  let body =
    <:expr< let new_indent = indent ^ "  " in
	    let $lid:"fields_printed"$ = $fields_printed_expr$ in
	    indent ^ name ^ " {\\n" ^
	    (String.concat "" fields_printed) ^
	    indent ^ "}\\n" >>
  in
  <:str_item< value $ <:binding< $pat:pat_lid _loc ("print_" ^ record.rname)$ indent name $pat_lid _loc record.rname$ = $exp:body$ >> $ >>


EXTEND Gram
  GLOBAL: expr ctyp str_item;

  field_type_d: [[
    "("; t = SELF; ")" -> t
  | type_name = ident; e = OPT [ "("; _e = expr; ")" -> _e ]; t = OPT [ "of"; _t = field_type_d -> _t ] ->
    field_type_of_ident type_name e t
  ]];

  field_desc: [[
    optional = OPT [ "optional" -> () ]; name = ident; ":"; field = field_type_d  ->
    (_loc, lid_of_ident name, field, optional != None)
  ]];

  option_list: [[
    -> []
  | "["; "]" -> []
  | "["; _opts = expr; "]" -> opts_of_exprs (list_of_sem_expr _opts)
  ]];

  str_item: [[
    "record_def"; record_name = ident; opts = option_list; "="; "{"; fields = LIST1 field_desc SEP ";"; "}" ->
      let record = mk_record_desc (lid_of_ident record_name) fields opts in
      let si1 = mk_record_type _loc record
      and si2 = mk_record_parse_fun _loc record
      and si3 =
	if record.rdo_lwt
	then mk_record_lwt_parse_fun _loc record
	else <:str_item< >>
      and si4 =
	if record.rdo_exact
	then mk_exact_parse_fun _loc record
	else <:str_item< >>
      and si5 = mk_record_dump_fun _loc record
      and si6 = mk_record_print_fun _loc record
      in
      <:str_item< $si1$; $si2$; $si3$; $si4$; $si5$; $si6$ >>
  ]];
END
;;