{ ... }:
{
  ststefanix.vaultUserSecrets = {
    secrets = {
      age_keys = {
        vault_secret = "kv/data/ststefanix/age_keys";
        vault_secret_key = "private_key";
        destination = ".config/sops/age/keys.txt";
      };
    };
  };
}
