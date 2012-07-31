open Lwt
open Unix

open ParsingEngine
open DumpingEngine
open LwtParsingEngine
open TlsEnums
open Tls


(* TODO: Handle exceptions in lwt code, and add timers *)

let rec _really_write o s p l =
  Lwt_unix.write o s p l >>= fun n ->
  if l = n then
    Lwt.return ()
  else
    _really_write o s (p + n) (l - n)

let really_write o s = _really_write o s 0 (String.length s)

let write_record o record =
  let s = dump_tls_record record in
  really_write o s


let rec print_msgs i =
  lwt_parse_tls_record i >>= fun record ->
  print_string (print_tls_record "" "Record" record);
  print_msgs i

let expect_clienthello s =
  let input = input_of_fd "Socket" s in
  lwt_parse_tls_record input >>= fun record ->
  match record.record_content with
  | Handshake {handshake_content = ClientHello ch} ->
    let sh = HT_ServerHello, ServerHello {
      server_version = ch.client_version;
      server_random = ch.client_random;
      server_session_id = "";
      ciphersuite = TLS_RSA_WITH_RC4_128_MD5;
      compression_method = CM_Null;
      server_extensions = None;
    }
    and certs = HT_Certificate, Certificate { certificate_list = ["\x30\x82\x03\x30\x30\x82\x02\x18\xa0\x03\x02\x01\x02\x02\x01\x02\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x0b\x05\x00\x30\x40\x31\x0b\x30\x09\x06\x03\x55\x04\x06\x13\x02\x46\x52\x31\x0f\x30\x0d\x06\x03\x55\x04\x08\x13\x06\x46\x72\x61\x6e\x63\x65\x31\x0f\x30\x0d\x06\x03\x55\x04\x0a\x13\x06\x50\x46\x20\x53\x53\x4c\x31\x0f\x30\x0d\x06\x03\x55\x04\x03\x13\x06\x41\x43\x20\x52\x53\x41\x30\x1e\x17\x0d\x31\x32\x30\x37\x30\x34\x32\x31\x34\x33\x30\x36\x5a\x17\x0d\x31\x32\x30\x38\x30\x33\x32\x31\x34\x33\x30\x36\x5a\x30\x46\x31\x0b\x30\x09\x06\x03\x55\x04\x06\x13\x02\x46\x52\x31\x0f\x30\x0d\x06\x03\x55\x04\x08\x13\x06\x46\x72\x61\x6e\x63\x65\x31\x0f\x30\x0d\x06\x03\x55\x04\x0a\x13\x06\x50\x46\x20\x53\x53\x4c\x31\x15\x30\x13\x06\x03\x55\x04\x03\x13\x0c\x77\x77\x77\x2e\x74\x6f\x74\x6f\x2e\x6f\x72\x67\x30\x82\x01\x22\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x01\x05\x00\x03\x82\x01\x0f\x00\x30\x82\x01\x0a\x02\x82\x01\x01\x00\xb1\xaa\x2f\xe2\x75\x14\x5e\x54\x22\x1a\xf5\x6a\xaf\xdb\xfb\xe1\xcb\x69\x67\xce\xb0\x96\x92\x32\x34\x26\xc5\x4c\xb3\x1d\x30\x47\x4f\xa8\x0e\x26\x9c\xd8\xc2\x7e\xde\x0b\x6b\x38\x16\xcc\x92\xcf\x1b\x9c\xc1\xb7\x9f\x5f\xb5\x9f\xc9\x79\x16\x81\x9d\x84\x2f\x74\x10\x7b\xe0\x51\xc1\x3c\xf6\xdf\xf2\x75\x0d\x02\xfc\x70\x70\x38\xfa\x31\xa1\x78\x5f\xb4\x1c\x89\x43\x75\xc9\xb7\x27\x7b\x2a\x60\xd6\xe5\xd3\x8b\x20\x0c\xd1\x0e\xf3\x73\x99\x95\xfc\x07\x85\xc2\x9c\x33\xe1\x52\x24\xf9\x75\x7f\x3b\xdf\x6a\x11\x43\xe9\x07\xd6\xdb\x7c\x08\x31\x2e\x7d\x40\xcc\x45\xed\x94\x39\xd3\x17\xbd\x36\x2c\xf3\xfd\x63\xd1\x20\xe6\x26\xda\x1b\x5d\x0b\x6f\x29\x81\xa4\x21\xc0\xc8\x3e\x74\xdf\x17\xca\xa8\x65\x61\xdc\x9d\x2d\xee\x95\x69\xe4\xf1\x81\xda\x5b\xd9\x7a\x3a\xe2\xcd\xe5\x63\x30\xb9\xe7\x22\xb5\xd4\x50\x71\x4b\x61\xb1\xfc\xc2\x1e\xe0\xdc\x78\x00\x43\x1b\x02\x98\xf7\xda\xef\x54\x93\x33\x9c\x5c\xaf\xcb\x2b\x72\x64\x40\x55\xd5\x0e\x2a\x99\xc4\x60\x6d\xb1\xf1\xdc\xe8\xfc\x2d\xf0\x27\x16\xed\x38\xdb\x3f\xff\x55\x73\x5e\x55\x04\x44\xc9\x55\x07\x02\x03\x01\x00\x01\xa3\x2f\x30\x2d\x30\x09\x06\x03\x55\x1d\x13\x04\x02\x30\x00\x30\x0b\x06\x03\x55\x1d\x0f\x04\x04\x03\x02\x05\xa0\x30\x13\x06\x03\x55\x1d\x25\x04\x0c\x30\x0a\x06\x08\x2b\x06\x01\x05\x05\x07\x03\x01\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x0b\x05\x00\x03\x82\x01\x01\x00\x45\x92\xa6\xb0\x6a\x12\x87\xc9\xf2\x90\x3c\x85\xda\x24\x93\x4a\x28\x1c\xc2\xf9\x04\xf3\xd1\x18\x8a\x41\x57\x4b\xe5\x43\x54\x58\xa4\x7c\xf5\x31\xa6\xf0\x42\xa0\xf3\x37\xba\x2c\x72\x06\xe6\xac\xc9\xe1\x2d\xce\x42\xbf\xa9\x6e\x8d\xe2\x5d\xfe\x43\x8f\xde\xd0\xd7\xb0\x09\x13\xc9\xb5\xb1\x70\xbb\x17\xe0\xf1\x7d\x49\x8d\x67\x5d\xe5\x6a\x54\x0c\x49\x72\x75\xb7\x50\x18\x96\x15\xcc\x0b\xd0\xf5\xb9\xa0\x51\xf0\x96\xb4\x6d\x55\xc7\xd6\xd9\x98\x51\x07\x7f\x38\xf2\x97\x02\xfc\x53\xcb\x4d\x90\xaa\x2e\xb0\x77\xc9\x36\x5f\xce\x37\x5f\x01\x5e\xf8\x75\xc4\x14\xbe\x7a\x86\xdf\x16\x78\x9a\x4b\x80\x18\x96\xcb\x5b\xad\xce\x5d\x59\xbc\x69\xc9\x41\x35\x02\xb9\x1a\x4b\x87\xd1\x8c\x1d\xa3\x4a\xfe\x95\x78\x7b\xf4\xda\xe5\xb1\x53\xa8\x97\x9c\x99\x03\x50\x26\xb2\x0d\xc9\xb9\x45\x28\xd4\x3e\x8e\xae\xc0\x26\xb1\x00\xc7\x9e\x81\x92\x41\x40\x23\xfa\x6f\xe4\xff\x0e\xd1\x12\xc4\xf5\x7e\x33\x52\x2b\x7a\x9b\x98\x20\x6a\xbb\xe4\x0f\xb1\x5f\x57\x4b\xa5\x76\x40\x75\x6d\x17\x4f\xe5\xac\x92\xba\x2d\x0a\x37\x54\x96\xcd\xde\xe8\x18\x0a\x49\x21\x5c\x4f"] }
    and shd = HT_ServerHelloDone, ServerHelloDone ()
    in
    let send (t, content) = 
      let r = {
	content_type = CT_Handshake;
	record_version = ch.client_version;
	record_content = Handshake {
	  handshake_type = t;
	  handshake_content = content;
	}
      } in
      write_record s r
    in
    Lwt_list.iter_s send [sh; certs; shd] >>= fun () ->
    print_msgs input
  | _ -> fail (Failure "ClientHello expected")


let new_socket () =
  Lwt_unix.socket Unix.PF_INET Unix.SOCK_STREAM 0
let local_addr =
  Unix.ADDR_INET (Unix.inet_addr_any, 8080)

let catcher = function
  | ParsingException (e, i) ->
    Printf.printf "%s in %s\n" (ParsingEngine.print_parsing_exception e)
      (ParsingEngine.print_string_input i); flush Pervasives.stdout; return ()
  | e -> print_endline (Printexc.to_string e); flush Pervasives.stdout; return ()



let rec accept sock =
  Lwt_unix.accept sock >>= fun (s, _) ->
  catch (fun () -> expect_clienthello s) catcher >>= fun () ->
  ignore (Lwt_unix.close s);
  accept sock

let _ =
  enrich_record_content := true;
  let socket = new_socket () in
  Lwt_unix.setsockopt
  socket Unix.SO_REUSEADDR true;
  Lwt_unix.bind socket local_addr;
  Lwt_unix.listen socket 1024;
  Lwt_unix.run (accept socket)