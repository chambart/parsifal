let int_size = function
  | IT_UInt8 -> 8
  | IT_UInt16 -> 16
  | IT_UInt24 -> 24
  | IT_UInt32 -> 32

let mk_module_prefix = function
  | None -> ""
  | Some module_name -> module_name ^ "."

let rec ocaml_type_of_field_type = function
  | FT_Char -> "char"
  | FT_Integer _ -> "int"
  | FT_Enum (_, module_name, type_name) -> module_name ^ "." ^ type_name
  | FT_IPv4 | FT_IPv6 -> "string"
  | FT_String _ -> "string"
  | FT_List (_, subtype) ->
    "(" ^ (ocaml_type_of_field_type subtype) ^ ") list"
  | FT_Container (_, subtype) -> ocaml_type_of_field_type subtype
  | FT_Custom (module_name, type_name, _) -> (mk_module_prefix module_name) ^ type_name

let ocaml_type_of_field_type_and_options t optional =
  let type_string = ocaml_type_of_field_type t in
  if optional
  then Printf.sprintf "(%s) option" type_string
  else type_string

let rec parse_fun_of_field_type name = function
  | FT_Char -> "parse_char"
  | FT_Integer it ->
    Printf.sprintf "parse_uint%d" (int_size it)

  | FT_Enum (int_type, module_name, type_name) ->
    Printf.sprintf "%s.parse_%s parse_uint%d" module_name type_name (int_size int_type)

  | FT_IPv4 -> "parse_string 4"
  | FT_IPv6 -> "parse_string 16"
  | FT_String (FixedLen n, _) -> "parse_string " ^ (string_of_int n)
  | FT_String (VarLen int_t, _) ->
    Printf.sprintf "parse_varlen_string \"%s\" parse_uint%d" name (int_size int_t)
  | FT_String (Remaining, _) -> "parse_rem_string"

  | FT_List (FixedLen n, subtype) ->
    Printf.sprintf "parse_list %d (%s)" n (parse_fun_of_field_type name subtype)
  | FT_List (VarLen int_t, subtype) ->
    Printf.sprintf "parse_varlen_list \"%s\" parse_uint%d (%s)" name (int_size int_t) (parse_fun_of_field_type name subtype)
  | FT_List (Remaining, subtype) ->
    Printf.sprintf "parse_rem_list (%s)" (parse_fun_of_field_type name subtype)
  | FT_Container (int_t, subtype) ->
    Printf.sprintf "parse_container \"%s\" parse_uint%d (%s)" name (int_size int_t) (parse_fun_of_field_type name subtype)

  | FT_Custom (module_name, type_name, parse_fun_args) ->
    String.concat " " (((mk_module_prefix module_name) ^ "parse_" ^ type_name)::parse_fun_args)

let rec dump_fun_of_field_type = function
  | FT_Char -> "dump_char"
  | FT_Integer it -> Printf.sprintf "dump_uint%d" (int_size it)

  | FT_Enum (int_type, module_name, type_name) ->
    Printf.sprintf "%s.dump_%s dump_uint%d" module_name type_name (int_size int_type)

  | FT_String (VarLen int_t, _) ->
    Printf.sprintf "dump_varlen_string dump_uint%d" (int_size int_t)
  | FT_IPv4
  | FT_IPv6
  | FT_String _ -> "dump_string"

  | FT_List (VarLen int_t, subtype) ->
    Printf.sprintf "dump_varlen_list dump_uint%d (%s)" (int_size int_t) (dump_fun_of_field_type subtype)
  | FT_List (_, subtype) ->
    Printf.sprintf "dump_list (%s)" (dump_fun_of_field_type subtype)
  | FT_Container (int_t, subtype) ->
    Printf.sprintf "dump_container dump_uint%d (%s)" (int_size int_t) (dump_fun_of_field_type subtype)

  | FT_Custom (module_name, type_name, _) -> (mk_module_prefix module_name) ^ "dump_" ^ type_name

let rec print_fun_of_field_type = function
  | FT_Char -> "print_char"
  | FT_Integer it -> Printf.sprintf "print_uint %d" (int_size it)

  | FT_Enum (int_type, module_name, type_name) ->
    Printf.sprintf "%s.print_%s %d" module_name type_name ((int_size int_type) / 4)

  | FT_String (_, true) -> "print_binstring"
  | FT_String (_, false) -> "print_string"

  | FT_IPv4 -> "print_ipv4"
  | FT_IPv6 -> "print_ipv6"

  | FT_List (_, subtype) ->
    Printf.sprintf "print_list (%s)" (print_fun_of_field_type subtype)

  | FT_Container (_, subtype) -> print_fun_of_field_type subtype

  | FT_Custom (module_name, type_name, _) -> (mk_module_prefix module_name) ^ "print_" ^ type_name


let mk_desc_type (name, fields) =
  if fields = []
  then Printf.printf "type %s = unit\n" name
  else begin
    Printf.printf "type %s = {\n" name;
    let aux (fn, ft, fo) =
      Printf.printf "  %s : %s;\n" fn (ocaml_type_of_field_type_and_options ft fo)
    in
    List.iter aux fields;
    print_endline "}\n\n"
  end

let mk_parse_fun (name, fields) =
  if fields = []
  then Printf.printf "let parse_%s input = ()\n" name
  else begin
    Printf.printf "let parse_%s input =\n" name;
    let parse_aux (fn, ft, fo) =
      if fo
      then begin
	Printf.printf "  let _%s = if eos input then None\n" fn;
	Printf.printf "            else Some (%s input) in\n" (parse_fun_of_field_type fn ft)
      end
      else Printf.printf "  let _%s = %s input in\n" fn (parse_fun_of_field_type fn ft)
    in
    let mkrec_aux (fn, _, _) = Printf.printf "    %s = _%s;\n" fn fn in
    List.iter parse_aux fields;
    print_endline "  {";
    List.iter mkrec_aux fields;
    print_endline "  }\n"
  end

let mk_dump_fun (name, fields) =
  if fields = []
  then Printf.printf "let dump_%s input = \"\"\n" name
  else begin
    Printf.printf "let dump_%s %s =\n" name name;
    let dump_aux (fn, ft, fo) =
      if fo
      then begin
	(Printf.sprintf "  begin\n") ^
	(Printf.sprintf "    match %s.%s with\n" name fn) ^
	(Printf.sprintf "      | None -> \"\"\n") ^
	(Printf.sprintf "      | Some x -> %s x\n" (dump_fun_of_field_type ft)) ^
	(Printf.sprintf "  end")
      end
      else Printf.sprintf "  %s %s.%s" (dump_fun_of_field_type ft) name fn
    in
    print_endline (String.concat " ^ \n" (List.map dump_aux fields));
    print_endline "\n"
  end

let mk_print_fun (name, fields) =
  if fields = []
  then begin
    Printf.printf "let print_%s indent name %s =\n" name name;
    print_endline "  (Printf.sprintf \"%s%s\\n\" indent name)\n";
  end else begin
    let print_aux (fn, ft, fo) =
      if fo
      then begin
	(Printf.sprintf "  begin\n") ^
        (Printf.sprintf "    match %s.%s with\n" name fn) ^
	(Printf.sprintf "      | None -> \"\"\n") ^
        (Printf.sprintf "      | Some x -> %s new_indent \"%s\" x\n" (print_fun_of_field_type ft) fn) ^
        (Printf.sprintf "  end")
      end
      else Printf.sprintf "  (%s new_indent \"%s\" %s.%s)" (print_fun_of_field_type ft) fn name fn
    in
    Printf.printf "let print_%s indent name %s =\n" name name;
    print_endline "  let new_indent = indent ^ \"  \" in";
    print_endline "  (Printf.sprintf \"%s%s {\\n\" indent name) ^";
    print_endline ((String.concat " ^\n" (List.map print_aux fields)) ^ " ^");
    print_endline "  (Printf.sprintf \"%s}\\n\" indent)\n"
  end


let handle_desc (desc : description) =
  mk_desc_type desc;
  mk_parse_fun desc;
  mk_dump_fun desc;
  mk_print_fun desc;
  print_newline ()


let _ =
  print_endline "open ParsingEngine";
  print_endline "open DumpingEngine";
  print_endline "open PrintingEngine\n";
  List.iter handle_desc descriptions