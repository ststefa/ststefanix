# The client inventory. All managed clients must be supplied with their properties
#
# Required client properties:
#
#     client - The hostname of the client. Has to match `hostname -s`
#     os - The OS of the client, one of "darwin", "linux", or "windows" (WSL)
#     system - The processor architecture of the client, matching [aarch64|x86_64]-[darwin|linux]
#     username - The username of the main user account
#     useremail - The email of that user
#     cores - The number of cores of the client

{
  hudson = {
    client = "hudson";
    os = "darwin";
    system = "aarch64-darwin";
    username = "steinert";
    useremail = "ststefa@heldenzeit.net";
    cores = 10;
  };

  "bwpm-L454QQVWM2" = {
    client = "bwpm";
    os = "darwin";
    system = "aarch64-darwin";
    username = "stefansteinert";
    useremail = "stefan.steinert-extern@deutschebahn.com";
    cores = 8;
  };

  luna = {
    client = "luna";
    os = "linux";
    system = "x86_64-linux";
    username = "linus";
    useremail = "luna@example.invalid";
    cores = 8;
  };

  winni = {
    client = "winni";
    os = "windows";
    # WSL target runs on a Linux userland.
    system = "x86_64-linux";
    username = "bill";
    useremail = "bill@example.invalid";
    cores = 8;
  };
}
