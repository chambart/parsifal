open TlsEnums
open Tls

(* TODO: add KX methods/AU methods/ENC methods/MAC methods here *)
(*       and a simple interface? The SKE content should be there? *)

let mk_csdescr cs kx au enc mac prf exp min max =
  let desc = {
    suite_name = cs;
    kx = kx; au = au;
    enc = enc; mac = mac;
    prf = prf;
    export = exp; min_version = min; max_version = max;
  } in
  Hashtbl.replace ciphersuite_descriptions cs desc


let hash_fun_of_name = function
  | HF_MD5 -> TlsCrypto.hmac_md5, 16
  | HF_SHA1 -> TlsCrypto.hmac_sha1, 20
  | HF_SHA256 -> TlsCrypto.hmac_sha256, 32
  | HF_SHA384 -> Parsifal.not_implemented "SHA384", 48


let enrich_suite_hash () =
  mk_csdescr TLS_NULL_WITH_NULL_NULL KX_Unknown AU_Null ENC_Null MAC_Unknown PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_NULL_MD5 KX_RSA AU_RSA ENC_Null (MAC_HMAC HF_MD5) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_NULL_SHA KX_RSA AU_RSA ENC_Null (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_EXPORT_WITH_RC4_40_MD5 KX_RSA AU_RSA (ENC_Stream (SC_RC4, 40)) (MAC_HMAC HF_MD5) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_RSA_WITH_RC4_128_MD5 KX_RSA AU_RSA (ENC_Stream (SC_RC4, 128)) (MAC_HMAC HF_MD5) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_RC4_128_SHA KX_RSA AU_RSA (ENC_Stream (SC_RC4, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5 KX_RSA AU_RSA (ENC_CBC (BC_RC2, 40)) (MAC_HMAC HF_MD5) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_RSA_WITH_IDEA_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_IDEA, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_EXPORT_WITH_DES40_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_DES, 40)) (MAC_HMAC HF_SHA1) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_RSA_WITH_DES_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_DES, 56)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_3DES_EDE_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_DSS_EXPORT_WITH_DES40_CBC_SHA KX_DH AU_DSS (ENC_CBC (BC_DES, 40)) (MAC_HMAC HF_SHA1) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_DH_DSS_WITH_DES_CBC_SHA KX_DH AU_DSS (ENC_CBC (BC_DES, 56)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA KX_DH AU_DSS (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_RSA_EXPORT_WITH_DES40_CBC_SHA KX_DH AU_RSA (ENC_CBC (BC_DES, 40)) (MAC_HMAC HF_SHA1) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_DH_RSA_WITH_DES_CBC_SHA KX_DH AU_RSA (ENC_CBC (BC_DES, 56)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA KX_DH AU_RSA (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA KX_DHE AU_DSS (ENC_CBC (BC_DES, 40)) (MAC_HMAC HF_SHA1) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_DHE_DSS_WITH_DES_CBC_SHA KX_DHE AU_DSS (ENC_CBC (BC_DES, 56)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA KX_DHE AU_DSS (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA KX_DHE AU_RSA (ENC_CBC (BC_DES, 40)) (MAC_HMAC HF_SHA1) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_DHE_RSA_WITH_DES_CBC_SHA KX_DHE AU_RSA (ENC_CBC (BC_DES, 56)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA KX_DHE AU_RSA (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_anon_EXPORT_WITH_RC4_40_MD5 KX_DH AU_Null (ENC_Stream (SC_RC4, 40)) (MAC_HMAC HF_MD5) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_DH_anon_WITH_RC4_128_MD5 KX_DH AU_Null (ENC_Stream (SC_RC4, 128)) (MAC_HMAC HF_MD5) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_anon_EXPORT_WITH_DES40_CBC_SHA KX_DH AU_Null (ENC_CBC (BC_DES, 40)) (MAC_HMAC HF_SHA1) PRF_Default true 0x0300 0x0302;
  mk_csdescr TLS_DH_anon_WITH_DES_CBC_SHA KX_DH AU_Null (ENC_CBC (BC_DES, 56)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_anon_WITH_3DES_EDE_CBC_SHA KX_DH AU_Null (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_AES_128_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_AES_128_CBC_SHA KX_DH AU_DSS (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_AES_128_CBC_SHA KX_DH AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_AES_128_CBC_SHA KX_DHE AU_DSS (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_AES_128_CBC_SHA KX_DHE AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_anon_WITH_AES_128_CBC_SHA KX_DH AU_Null (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_AES_256_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_AES_256_CBC_SHA KX_DH AU_DSS (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_AES_256_CBC_SHA KX_DH AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_AES_256_CBC_SHA KX_DHE AU_DSS (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_AES_256_CBC_SHA KX_DHE AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_anon_WITH_AES_256_CBC_SHA KX_DH AU_Null (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_NULL_SHA256 KX_RSA AU_RSA ENC_Null (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_AES_128_CBC_SHA256 KX_RSA AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_AES_256_CBC_SHA256 KX_RSA AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_AES_128_CBC_SHA256 KX_DH AU_DSS (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_AES_128_CBC_SHA256 KX_DH AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_AES_128_CBC_SHA256 KX_DHE AU_DSS (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_CAMELLIA_128_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_CAMELLIA_128_CBC_SHA KX_DH AU_DSS (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_CAMELLIA_128_CBC_SHA KX_DH AU_RSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA KX_DHE AU_DSS (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA KX_DHE AU_RSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA KX_DH AU_Null (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 KX_DHE AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_AES_256_CBC_SHA256 KX_DH AU_DSS (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_AES_256_CBC_SHA256 KX_DH AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_AES_256_CBC_SHA256 KX_DHE AU_DSS (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_AES_256_CBC_SHA256 KX_DHE AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_AES_128_CBC_SHA256 KX_DH AU_Null (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_AES_256_CBC_SHA256 KX_DH AU_Null (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_CAMELLIA_256_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_CAMELLIA_256_CBC_SHA KX_DH AU_DSS (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_CAMELLIA_256_CBC_SHA KX_DH AU_RSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA KX_DHE AU_DSS (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA KX_DHE AU_RSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA KX_DH AU_Null (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_SEED_CBC_SHA KX_RSA AU_RSA (ENC_CBC (BC_SEED, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_SEED_CBC_SHA KX_DH AU_DSS (ENC_CBC (BC_SEED, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_SEED_CBC_SHA KX_DH AU_RSA (ENC_CBC (BC_SEED, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_SEED_CBC_SHA KX_DHE AU_DSS (ENC_CBC (BC_SEED, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_SEED_CBC_SHA KX_DHE AU_RSA (ENC_CBC (BC_SEED, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_DH_anon_WITH_SEED_CBC_SHA KX_DH AU_Null (ENC_CBC (BC_SEED, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_RSA_WITH_AES_128_GCM_SHA256 KX_RSA AU_RSA (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_AES_256_GCM_SHA384 KX_RSA AU_RSA (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_AES_128_GCM_SHA256 KX_DHE AU_RSA (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_AES_256_GCM_SHA384 KX_DHE AU_RSA (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_AES_128_GCM_SHA256 KX_DH AU_RSA (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_AES_256_GCM_SHA384 KX_DH AU_RSA (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_AES_128_GCM_SHA256 KX_DHE AU_DSS (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_AES_256_GCM_SHA384 KX_DHE AU_DSS (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_AES_128_GCM_SHA256 KX_DH AU_DSS (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_AES_256_GCM_SHA384 KX_DH AU_DSS (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_AES_128_GCM_SHA256 KX_DH AU_Null (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_AES_256_GCM_SHA384 KX_DH AU_Null (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_CAMELLIA_128_CBC_SHA256 KX_RSA AU_RSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_CAMELLIA_128_CBC_SHA256 KX_DH AU_DSS (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_CAMELLIA_128_CBC_SHA256 KX_DH AU_RSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA256 KX_DHE AU_DSS (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256 KX_DHE AU_RSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA256 KX_DH AU_Null (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_CAMELLIA_256_CBC_SHA256 KX_RSA AU_RSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_CAMELLIA_256_CBC_SHA256 KX_DH AU_DSS (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_CAMELLIA_256_CBC_SHA256 KX_DH AU_RSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA256 KX_DHE AU_DSS (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA256 KX_DHE AU_RSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA256 KX_DH AU_Null (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_NULL_SHA KX_ECDH AU_ECDSA ENC_Null (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_RC4_128_SHA KX_ECDH AU_ECDSA (ENC_Stream (SC_RC4, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA KX_ECDH AU_ECDSA (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA KX_ECDH AU_ECDSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA KX_ECDH AU_ECDSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_NULL_SHA KX_ECDHE AU_ECDSA ENC_Null (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_RC4_128_SHA KX_ECDHE AU_ECDSA (ENC_Stream (SC_RC4, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA KX_ECDHE AU_ECDSA (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA KX_ECDHE AU_ECDSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA KX_ECDHE AU_ECDSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_NULL_SHA KX_ECDH AU_RSA ENC_Null (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_RC4_128_SHA KX_ECDH AU_RSA (ENC_Stream (SC_RC4, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA KX_ECDH AU_RSA (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_AES_128_CBC_SHA KX_ECDH AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_AES_256_CBC_SHA KX_ECDH AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_NULL_SHA KX_ECDHE AU_RSA ENC_Null (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_RC4_128_SHA KX_ECDHE AU_RSA (ENC_Stream (SC_RC4, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA KX_ECDHE AU_RSA (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA KX_ECDHE AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA KX_ECDHE AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_anon_WITH_NULL_SHA KX_ECDH AU_Null ENC_Null (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_anon_WITH_RC4_128_SHA KX_ECDH AU_Null (ENC_Stream (SC_RC4, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA KX_ECDH AU_Null (ENC_CBC (BC_3DES, 168)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_anon_WITH_AES_128_CBC_SHA KX_ECDH AU_Null (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDH_anon_WITH_AES_256_CBC_SHA KX_ECDH AU_Null (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA1) PRF_Default false 0x0300 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256 KX_ECDHE AU_ECDSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384 KX_ECDHE AU_ECDSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256 KX_ECDH AU_ECDSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384 KX_ECDH AU_ECDSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 KX_ECDHE AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 KX_ECDHE AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256 KX_ECDH AU_RSA (ENC_CBC (BC_AES, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384 KX_ECDH AU_RSA (ENC_CBC (BC_AES, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 KX_ECDHE AU_ECDSA (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 KX_ECDHE AU_ECDSA (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256 KX_ECDH AU_ECDSA (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384 KX_ECDH AU_ECDSA (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 KX_ECDHE AU_RSA (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 KX_ECDHE AU_RSA (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256 KX_ECDH AU_RSA (ENC_GCM (BC_AES, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384 KX_ECDH AU_RSA (ENC_GCM (BC_AES, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_ARIA_128_CBC_SHA256 KX_RSA AU_RSA (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_ARIA_256_CBC_SHA384 KX_RSA AU_RSA (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_ARIA_128_CBC_SHA256 KX_DH AU_DSS (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_ARIA_256_CBC_SHA384 KX_DH AU_DSS (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_ARIA_128_CBC_SHA256 KX_DH AU_RSA (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_ARIA_256_CBC_SHA384 KX_DH AU_RSA (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_ARIA_128_CBC_SHA256 KX_DHE AU_DSS (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_ARIA_256_CBC_SHA384 KX_DHE AU_DSS (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_ARIA_128_CBC_SHA256 KX_DHE AU_RSA (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_ARIA_256_CBC_SHA384 KX_DHE AU_RSA (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_ARIA_128_CBC_SHA256 KX_DH AU_Null (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_ARIA_256_CBC_SHA384 KX_DH AU_Null (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_ARIA_128_CBC_SHA256 KX_ECDHE AU_ECDSA (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_ARIA_256_CBC_SHA384 KX_ECDHE AU_ECDSA (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_ARIA_128_CBC_SHA256 KX_ECDH AU_ECDSA (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_ARIA_256_CBC_SHA384 KX_ECDH AU_ECDSA (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_ARIA_128_CBC_SHA256 KX_ECDHE AU_RSA (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_ARIA_256_CBC_SHA384 KX_ECDHE AU_RSA (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_ARIA_128_CBC_SHA256 KX_ECDH AU_RSA (ENC_CBC (BC_ARIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_ARIA_256_CBC_SHA384 KX_ECDH AU_RSA (ENC_CBC (BC_ARIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_ARIA_128_GCM_SHA256 KX_RSA AU_RSA (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_ARIA_256_GCM_SHA384 KX_RSA AU_RSA (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_ARIA_128_GCM_SHA256 KX_DHE AU_RSA (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_ARIA_256_GCM_SHA384 KX_DHE AU_RSA (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_ARIA_128_GCM_SHA256 KX_DH AU_RSA (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_ARIA_256_GCM_SHA384 KX_DH AU_RSA (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_ARIA_128_GCM_SHA256 KX_DHE AU_DSS (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_ARIA_256_GCM_SHA384 KX_DHE AU_DSS (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_ARIA_128_GCM_SHA256 KX_DH AU_DSS (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_ARIA_256_GCM_SHA384 KX_DH AU_DSS (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_ARIA_128_GCM_SHA256 KX_DH AU_Null (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_ARIA_256_GCM_SHA384 KX_DH AU_Null (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_ARIA_128_GCM_SHA256 KX_ECDHE AU_ECDSA (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_ARIA_256_GCM_SHA384 KX_ECDHE AU_ECDSA (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_ARIA_128_GCM_SHA256 KX_ECDH AU_ECDSA (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_ARIA_256_GCM_SHA384 KX_ECDH AU_ECDSA (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_ARIA_128_GCM_SHA256 KX_ECDHE AU_RSA (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_ARIA_256_GCM_SHA384 KX_ECDHE AU_RSA (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_ARIA_128_GCM_SHA256 KX_ECDH AU_RSA (ENC_GCM (BC_ARIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_ARIA_256_GCM_SHA384 KX_ECDH AU_RSA (ENC_GCM (BC_ARIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_CBC_SHA256 KX_ECDHE AU_ECDSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_CBC_SHA384 KX_ECDHE AU_ECDSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_CAMELLIA_128_CBC_SHA256 KX_ECDH AU_ECDSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_CAMELLIA_256_CBC_SHA384 KX_ECDH AU_ECDSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_CAMELLIA_128_CBC_SHA256 KX_ECDHE AU_RSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_CAMELLIA_256_CBC_SHA384 KX_ECDHE AU_RSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_CAMELLIA_128_CBC_SHA256 KX_ECDH AU_RSA (ENC_CBC (BC_CAMELLIA, 128)) (MAC_HMAC HF_SHA256) PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_CAMELLIA_256_CBC_SHA384 KX_ECDH AU_RSA (ENC_CBC (BC_CAMELLIA, 256)) (MAC_HMAC HF_SHA384) PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_CAMELLIA_128_GCM_SHA256 KX_RSA AU_RSA (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_RSA_WITH_CAMELLIA_256_GCM_SHA384 KX_RSA AU_RSA (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_CAMELLIA_128_GCM_SHA256 KX_DHE AU_RSA (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_RSA_WITH_CAMELLIA_256_GCM_SHA384 KX_DHE AU_RSA (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_CAMELLIA_128_GCM_SHA256 KX_DH AU_RSA (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_RSA_WITH_CAMELLIA_256_GCM_SHA384 KX_DH AU_RSA (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_CAMELLIA_128_GCM_SHA256 KX_DHE AU_DSS (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DHE_DSS_WITH_CAMELLIA_256_GCM_SHA384 KX_DHE AU_DSS (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_CAMELLIA_128_GCM_SHA256 KX_DH AU_DSS (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_DSS_WITH_CAMELLIA_256_GCM_SHA384 KX_DH AU_DSS (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_CAMELLIA_128_GCM_SHA256 KX_DH AU_Null (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_DH_anon_WITH_CAMELLIA_256_GCM_SHA384 KX_DH AU_Null (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_GCM_SHA256 KX_ECDHE AU_ECDSA (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_GCM_SHA384 KX_ECDHE AU_ECDSA (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_CAMELLIA_128_GCM_SHA256 KX_ECDH AU_ECDSA (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_ECDSA_WITH_CAMELLIA_256_GCM_SHA384 KX_ECDH AU_ECDSA (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_CAMELLIA_128_GCM_SHA256 KX_ECDHE AU_RSA (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDHE_RSA_WITH_CAMELLIA_256_GCM_SHA384 KX_ECDHE AU_RSA (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_CAMELLIA_128_GCM_SHA256 KX_ECDH AU_RSA (ENC_GCM (BC_CAMELLIA, 128)) MAC_AEAD PRF_SHA256 false 0x0303 0xffff;
  mk_csdescr TLS_ECDH_RSA_WITH_CAMELLIA_256_GCM_SHA384 KX_ECDH AU_RSA (ENC_GCM (BC_CAMELLIA, 256)) MAC_AEAD PRF_SHA384 false 0x0303 0xffff;
  ();;
