{ username, ... }:
{
  ststefanix.baoUserSecrets = {
    secrets = {
      age_keys = {
        bao_secret = "kv/data/users/stefan/age_keys";
        bao_secret_key = "private_keys";
        destination = ".config/sops/age/keys.txt";
      };
      aws_credentials = {
        bao_secret = "kv/data/users/stefan/aws/credentials";
        bao_secret_key = "keys";
        destination = ".aws/credentials";
      };
      aws_mfaconfig = {
        bao_secret = "kv/data/users/stefan/aws/mfaconfig";
        bao_secret_key = "config";
        destination = ".aws/mfa-config";
      };
      openstack_secure_yaml = {
        bao_secret = "kv/data/users/stefan/openstack/secure_yaml";
        bao_secret_key = "secure_yaml";
        destination = ".config/openstack/secure.yaml";
      };
      pushover_conf = {
        bao_secret = "kv/data/users/stefan/pushover_conf";
        bao_secret_key = "conf";
        destination = ".config/pushover.conf";
      };
      ssh_arq2024 = {
        bao_secret = "kv/data/users/stefan/ssh/arq2024";
        bao_secret_key = "priv";
        destination = ".ssh/arq2024";
      };
      ssh_arq2024_pub = {
        bao_secret = "kv/data/users/stefan/ssh/arq2024";
        bao_secret_key = "pub";
        destination = ".ssh/arq2024.pub";
      };
      ssh_id_rsa = {
        bao_secret = "kv/data/users/stefan/ssh/id_rsa";
        bao_secret_key = "priv";
        destination = ".ssh/id_rsa";
      };
      ssh_id_rsa_pub = {
        bao_secret = "kv/data/users/stefan/ssh/id_rsa";
        bao_secret_key = "pub";
        destination = ".ssh/id_rsa.pub";
      };
      ssh_id_ed25519 = {
        bao_secret = "kv/data/users/stefan/ssh/id_ed25519";
        bao_secret_key = "priv";
        destination = ".ssh/id_ed25519";
      };
      ssh_id_ed25519_pub = {
        bao_secret = "kv/data/users/stefan/ssh/id_ed25519";
        bao_secret_key = "pub";
        destination = ".ssh/id_ed25519.pub";
      };
      ssh_pq = {
        bao_secret = "kv/data/users/stefan/ssh/pq";
        bao_secret_key = "priv";
        destination = ".ssh/pq";
      };
      ssh_pq_pub = {
        bao_secret = "kv/data/users/stefan/ssh/pq";
        bao_secret_key = "pub";
        destination = ".ssh/pq.pub";
      };
    };
  };
}
