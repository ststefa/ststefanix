{ username, ... }:
{
  ststefanix.baoUserSecrets = {
    secrets = {
      age_keys = {
        bao_secret = "kv/data/users/stefan/age_keys";
        bao_secret_key = "private_keys";
        destination = ".config/sops/age/keys.txt";
      };
      arq2024 = {
        bao_secret = "kv/data/users/stefan/ssh/arq2024";
        bao_secret_key = "priv";
        destination = ".ssh/arq2024";
      };
      arq2024_pub = {
        bao_secret = "kv/data/users/stefan/ssh/arq2024";
        bao_secret_key = "pub";
        destination = ".ssh/arq2024.pub";
      };
      id_rsa = {
        bao_secret = "kv/data/users/stefan/ssh/id_rsa";
        bao_secret_key = "priv";
        destination = ".ssh/id_rsa";
      };
      id_rsa_pub = {
        bao_secret = "kv/data/users/stefan/ssh/id_rsa";
        bao_secret_key = "pub";
        destination = ".ssh/id_rsa.pub";
      };
      id_ed25519 = {
        bao_secret = "kv/data/users/stefan/ssh/id_ed25519";
        bao_secret_key = "priv";
        destination = ".ssh/id_ed25519";
      };
      id_ed25519_pub = {
        bao_secret = "kv/data/users/stefan/ssh/id_ed25519";
        bao_secret_key = "pub";
        destination = ".ssh/id_ed25519.pub";
      };
      pq = {
        bao_secret = "kv/data/users/stefan/ssh/pq";
        bao_secret_key = "priv";
        destination = ".ssh/pq";
      };
      pq_pub = {
        bao_secret = "kv/data/users/stefan/ssh/pq";
        bao_secret_key = "pub";
        destination = ".ssh/pq.pub";
      };
    };
  };
}
