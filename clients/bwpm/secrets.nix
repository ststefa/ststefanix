{ ... }:
{
  ststefanix.baoUserSecrets = {
    secrets = {
      age_keys = {
        bao_secret = "kv/data/ststefanix/age_keys";
        bao_secret_key = "private_key";
        destination = ".config/sops/age/keys.txt";
      };
    };
  };
}
