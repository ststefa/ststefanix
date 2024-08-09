# https://nix.dev/manual/nix/2.19/language/import-from-derivation#example
# nix-instantiate test.nix --eval --read-write-mode

let
  pkgs = import <nixpkgs> {};
  drv = derivation {
    name = "hello";
    builder = "/bin/sh";
    args = [ "-c" "echo -n hello $(/bin/hostname -s) > $out" ];
    system = builtins.currentSystem;
    #myfile = builtins.readFile "path:./myfile.txt"; # error: string 'path:./myfile.txt' doesn't represent an absolute path
    myfile = builtins.readFile "/var/folders/tv/qq04_6kn29v309152k3v8sj40000gn/T/tmp.u7rBdTKI8X";
  };
in "${builtins.readFile drv} world ${drv.system} ${drv.myfile}"
#in pkgs.stdenv.mkDerivation {
#  name = "foo";
#  src = builtins.path { path = ./.; name = "myfile.txt"; };
#  ${builtins.readFile drv} 'world' ${drv.system} ${drv.myfile};
#}