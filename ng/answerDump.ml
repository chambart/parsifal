record_def answer_dump [top] = {
  ip : ipv4;
  port : uint16;
  name : string(uint16);
  client_hello_type : uint8;
  msg_type : uint8;
  content : binstring(uint32)
}
