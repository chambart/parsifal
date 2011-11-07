open ParsingEngine
open Tls
open TlsRecord


let record_string = "\x16\x03\x00\x00\x86\x01\x00\x00\x82\x03\x00\x4e\x97\x15\xc9\x4d\x53\x29\xfb\x6b\x2f\xbe\xaf\x38\xcd\x50\xb5\x12\xc5\x6f\x28\x39\xbe\xd2\xff\x6f\xe6\x3f\x91\x15\x3b\x0e\x6b\x00\x00\x5a\xc0\x14\xc0\x0a\x00\x39\x00\x38\x00\x88\x00\x87\xc0\x0f\xc0\x05\x00\x35\x00\x84\xc0\x12\xc0\x08\x00\x16\x00\x13\xc0\x0d\xc0\x03\x00\x0a\xc0\x13\xc0\x09\x00\x33\x00\x32\x00\x9a\x00\x99\x00\x45\x00\x44\xc0\x0e\xc0\x04\x00\x2f\x00\x96\x00\x41\xc0\x11\xc0\x07\xc0\x0c\xc0\x02\x00\x05\x00\x04\x00\x15\x00\x12\x00\x09\x00\x14\x00\x11\x00\x08\x00\x06\x00\x03\x00\xff\x02\x01\x00"

let server_answer = "\x16\x03\x01\x00\x4a\x02\x00\x00\x46\x03\x01\x4c\x3f\x48\xa7\x21\x66\x27\x04\x17\x14\x2b\xcf\x5f\xbf\xf7\x7d\x59\x44\x54\xd7\x73\x60\xcf\x00\x8c\x76\x67\xf8\xc0\x18\x4f\x54\x20\xb6\xf5\x80\x89\xd9\x47\x43\x27\x7c\xc0\xc5\x86\xcd\x4a\x8b\x59\x84\x31\x4d\x65\x54\xf4\xce\xf6\x6f\xfd\x99\x01\x1c\x7b\xcc\xee\x00\x0a\x00\x16\x03\x01\x02\x7a\x0b\x00\x02\x76\x00\x02\x73\x00\x02\x70\x30\x82\x02\x6c\x30\x82\x01\xd5\xa0\x03\x02\x01\x02\x02\x01\x02\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x05\x05\x00\x30\x7c\x31\x1a\x30\x18\x06\x03\x55\x04\x03\x13\x11\x30\x30\x3a\x32\x32\x3a\x36\x62\x3a\x33\x64\x3a\x34\x65\x3a\x32\x39\x31\x0e\x30\x0c\x06\x03\x55\x04\x0b\x13\x05\x52\x56\x30\x38\x32\x31\x1b\x30\x19\x06\x03\x55\x04\x0a\x13\x12\x43\x69\x73\x63\x6f\x2d\x4c\x69\x6e\x6b\x73\x79\x73\x2c\x20\x4c\x4c\x43\x31\x0b\x30\x09\x06\x03\x55\x04\x06\x13\x02\x55\x53\x31\x0f\x30\x0d\x06\x03\x55\x04\x07\x13\x06\x49\x72\x76\x69\x6e\x65\x31\x13\x30\x11\x06\x03\x55\x04\x04\x13\x0a\x43\x61\x6c\x69\x66\x6f\x72\x6e\x69\x61\x30\x1e\x17\x0d\x30\x36\x30\x37\x30\x38\x31\x37\x32\x33\x30\x33\x5a\x17\x0d\x31\x36\x30\x37\x30\x35\x31\x37\x32\x33\x30\x33\x5a\x30\x7c\x31\x1a\x30\x18\x06\x03\x55\x04\x03\x13\x11\x30\x30\x3a\x32\x32\x3a\x36\x62\x3a\x33\x64\x3a\x34\x65\x3a\x32\x39\x31\x0e\x30\x0c\x06\x03\x55\x04\x0b\x13\x05\x52\x56\x30\x38\x32\x31\x1b\x30\x19\x06\x03\x55\x04\x0a\x13\x12\x43\x69\x73\x63\x6f\x2d\x4c\x69\x6e\x6b\x73\x79\x73\x2c\x20\x4c\x4c\x43\x31\x0b\x30\x09\x06\x03\x55\x04\x06\x13\x02\x55\x53\x31\x0f\x30\x0d\x06\x03\x55\x04\x07\x13\x06\x49\x72\x76\x69\x6e\x65\x31\x13\x30\x11\x06\x03\x55\x04\x04\x13\x0a\x43\x61\x6c\x69\x66\x6f\x72\x6e\x69\x61\x30\x81\x9f\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x01\x05\x00\x03\x81\x8d\x00\x30\x81\x89\x02\x81\x81\x00\xc1\xbd\x31\xd3\xcf\x2b\xc8\x1f\x22\xdf\xac\x80\x89\x49\x68\x68\x9f\x87\x92\x9a\xee\x14\xcf\x76\x0a\x92\x39\xb0\x9b\x56\xcc\x45\x18\xd6\xba\xc8\x9f\xbe\xa9\xed\x50\x95\xd6\x78\x2d\x34\x75\x5a\x81\xe4\xe7\xa1\x03\x07\x02\x76\x4d\xc2\x18\xf8\xc1\x6c\xdd\x6c\x92\xad\x4c\x8e\x47\xd4\x98\x33\xcc\xc1\x70\xbf\x7b\x62\x74\xc2\x2a\xc1\xcf\x09\x0d\x6f\x99\xad\x38\xfc\xe1\xe1\xe7\x5c\xe6\x35\xa7\x6b\x99\xc8\xe1\x16\x2a\xbe\xc6\xc9\xa1\xbc\x59\x67\x0d\x62\xc6\xcc\x36\x98\x13\x33\x34\xb3\x1b\xe4\x59\x05\x0d\xa0\xba\xd1\x02\x03\x01\x00\x01\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x05\x05\x00\x03\x81\x81\x00\x77\x06\x20\xb5\xa4\x68\xbc\x93\x40\xee\x76\xf4\x7f\x44\x5c\xdc\x7d\xd8\x32\xcc\x0d\xa3\x9b\xd4\x52\x95\x21\x20\x64\xc8\x96\x5e\xa3\x20\xbb\xa3\xef\x2f\x30\xaa\x7b\xa0\xa6\xeb\x78\x06\xcc\xf0\x58\xd3\x7f\xa6\xd3\xd3\x11\x62\x09\x8d\x41\x6b\x2b\x33\xfd\xea\xc7\xed\x7a\xdd\x31\xeb\x4a\x17\x8f\xe9\x39\xd5\xda\x7c\x63\x26\x9e\xf9\x46\xbe\xc7\xac\xf6\x76\xfe\xee\x39\xa6\x12\x6d\xe1\xb7\x00\x20\xa0\x11\x16\x67\x72\x66\xbb\x62\x35\xb0\x56\xe2\xf2\x0b\x7d\x2f\x83\xfe\xad\x9c\x2c\x9a\xd9\x6f\x8a\x0c\x0d\xda\x93\xa6\x16\x03\x01\x00\x04\x0e\x00\x00\x00"



let show_records title str =
  let pstate = pstate_of_string (Some title) str in

  print_endline title;
  let records, _ = TlsLib.shallow_parse_records pstate in
  List.iter (fun r -> print_endline (String.concat "\n" (RecordParser.to_string r))) records;
  let merged_records = RecordParser.merge records in
  if merged_records <> records then begin
    print_endline "Merged version:";
    List.iter (fun r -> print_endline (String.concat "\n" (RecordParser.to_string r))) merged_records
  end


let _ =
  try
    show_records "Client Hello" (record_string);
    show_records "Server answer" (server_answer)
  with
    | OutOfBounds s ->
      output_string stderr ("Fatal (out of bounds in " ^ s ^ ")")
    | ParsingError (err, sev, pstate) ->
      output_string stderr ((string_of_parsing_error "Fatal" err sev pstate) ^ "\n")
