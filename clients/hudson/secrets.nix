{ username, ... }:
{
  ststefanix.vaultUserSecrets = {
    secrets = {
      age_keys = {
        vault_secret = "kv/data/users/stefan/age_keys";
        vault_secret_key = "private_keys";
        destination = ".config/sops/age/keys.txt";
      };
    };
  };
}
