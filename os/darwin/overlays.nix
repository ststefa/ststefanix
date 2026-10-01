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

      # 2026-02-20 upstream hash broken, remove overlay asap
      # 2026-05-03 overlay disabled, upstream was fixed
      #argocd = prev.argocd.overrideAttrs (old: {
      #  ui = old.ui.overrideAttrs (_uiOld: {
      #    offlineCache = prev.fetchYarnDeps {
      #      yarnLock = "${old.src}/ui/yarn.lock";
      #      hash = "sha256-kqBolkQiwZUBic0f+Ek5HwYsOmro1+FStkDLXAre79o=";
      #    };
      #  });
      #});

      # 2026-04-25 d2 0.7.x in nixpkgs pulls Linux-only GBM/Playwright runtime deps
      # on Darwin, which drags in unsupported libdrm/mesa packages on aarch64-darwin.
      # 2026-05-03 overlay disabled, upstream was fixed
      #d2 = prev.d2.overrideAttrs (old: {
      #  buildInputs = [ ];
      #  postInstall = ''
      #    installManPage ci/release/template/man/d2.1
      #  '';
      #});

      # 2025-12 fio cannot be built due to libbnd deps, disable it
      # 2026-05-03 overlay disabled, upstream was fixed
      #libnbd = if prev.stdenv.hostPlatform.isDarwin then null else prev.libnbd;
      #fio =
      #  if prev.stdenv.hostPlatform.isDarwin then
      #    prev.fio.overrideAttrs (
      #      old:
      #      let
      #        oldFlags = old.configureFlags or [ ];
      #        newFlags = builtins.filter (f: f != "--enable-libnbd") oldFlags;
      #      in
      #      {
      #        configureFlags = newFlags;
      #      }
      #    )
      #  else
      #    prev.fio;

      # 2025-12 twisted fails build due to excessive testsuite, disable it
      # 2026-05-03 overlay disabled, upstream was fixed
      #python313 = prev.python313.override {
      #  packageOverrides = pyFinal: pyPrev: {
      #    twisted = pyPrev.twisted.overrideAttrs (_old: {
      #      doCheck = false;
      #      doInstallCheck = false;
      #      pythonImportsCheck = [ ];
      #    });
      #    rapidfuzz = pyPrev.rapidfuzz.overridePythonAttrs (old: {
      #      nativeBuildInputs = [ prev.clang-tools ] ++ (old.nativeBuildInputs or [ ]);
      #      cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      #        "-DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS=${prev.clang-tools}/bin/clang-scan-deps"
      #      ];
      #    });
      #  };
      #};
      #python313Packages = final.python313.pkgs;

      # 2026-07-25 poetry fails due to some failing unit tests. Disable only
      # the affected pytest cases and keep the rest of the test suite enabled.
      # The installed package currently comes from python3.14, so override the
      # top-level package instead of a specific Python package set.
      # 2026-08-08 overlay disabled, upstream was fixed
      #poetry = prev.poetry.overridePythonAttrs (old: {
      #  disabledTests = (old.disabledTests or [ ]) ++ [
      #    "test_execute_executes_a_batch_of_operations"
      #    "test_execute_prints_warning_for_yanked_package"
      #  ];
      #  pythonImportsCheck = [ ];
      #});

      # 2026-10-01 recode 3.7.16 segfaults in its Darwin test suite, which
      # breaks fortune-mod. Keep fortune installed and only skip recode checks.
      recode = prev.recode.overrideAttrs (_old: {
        doCheck = false;
      });

    })
  ];
}
