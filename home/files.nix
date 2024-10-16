{ username, useremail,  hostname, ... }:

{
  home = {
    # Manage files in home dir. They will be symlinked to nix store.
    # Will not be overwritten if they exist. If undeclared, they will be removed.
    file = {
      ".test".text =
      ''
        [[${username}]]
        ${useremail}
        ${hostname}
        cp foo $out/bin
        echo "Hello World" > $out/etc/foo.conf
        ${if hostname == "x" then "cp bar $out/bin" else ""}
      '';

      "test/a".text = "aha\n";
    };
  };
}
