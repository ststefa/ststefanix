{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # add overlays to make updated derivations of existing modules

      #k3d = prev.k3d.overrideAttrs (oldAttrs: rec {
      #  version = "5.7.3";
      #  src = prev.fetchFromGitHub {
      #    owner = "k3d-io";
      #    repo = "k3d";
      #    rev = "refs/tags/v${version}";
      #    hash = "sha256-G9z4yJ7Oa2zmxYTRIMCiXlBPLlc3vGPUqUOoIohDKU8=";
      #  };
      #});

      #uv = prev.uv.overrideAttrs (oldAttrs: rec {
      #  version = "0.4.4";
      #  src = prev.fetchFromGitHub {
      #    owner = "astral-sh";
      #    repo = "uv";
      #    rev = version;
      #    hash = "sha256-PhLatO4XeYFrv0DqPc0NlSGXJvLkem0pqxEcoVZddZw=";
      #  };
      #});

      #ruff = prev.ruff.overrideAttrs (oldAttrs: rec {
      #  version = "0.5.0";
      #  src = prev.fetchFromGitHub {
      #    owner = "astral-sh";
      #    repo = "ruff";
      #    rev = version;
      #    hash = "";
      #  };
      #});

      #ruff = prev.ruff.override {
      #  version = "0.5.0";
      #};

      libnbd = if prev.stdenv.isDarwin then null else prev.libnbd;

      fio =
        if prev.stdenv.isDarwin then
          prev.fio.overrideAttrs (
            old:
            let
              oldFlags = old.configureFlags or [ ];
              newFlags = builtins.filter (f: f != "--enable-libnbd") oldFlags;
            in
            {
              configureFlags = newFlags;
            }
          )
        else
          prev.fio;

      python313 = prev.python313.override {
        packageOverrides = pyFinal: pyPrev: {
          twisted = pyPrev.twisted.overrideAttrs (_old: {
            doCheck = false;
            doInstallCheck = false;
            pythonImportsCheck = [ ];
          });

          rapidfuzz = pyPrev.rapidfuzz.overridePythonAttrs (old: {
            nativeBuildInputs = [ prev.clang-tools ] ++ (old.nativeBuildInputs or [ ]);
            cmakeFlags = (old.cmakeFlags or [ ]) ++ [
              "-DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS=${prev.clang-tools}/bin/clang-scan-deps"
            ];
          });
        };
      };

      python313Packages = final.python313.pkgs;
    })
  ];
}
