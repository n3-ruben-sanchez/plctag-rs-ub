{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs, }:
    let
      localSystem = "x86_64-linux";

      pkgsLoader = crossSystem:
        (import nixpkgs { inherit localSystem crossSystem; });

      CI = builtins.getEnv "CI";
      ciVariables = if CI == "true" then {
        inherit CI;
        N3_PRE_RELEASE = builtins.getEnv "N3_PRE_RELEASE";
        N3_BUILD_DATE = builtins.getEnv "N3_BUILD_DATE";
        N3_COMMIT_SHA = builtins.getEnv "N3_COMMIT_SHA";
        N3_COMMIT_SHORT_SHA = builtins.getEnv "N3_COMMIT_SHORT_SHA";
        N3_COMMIT_DATE = builtins.getEnv "N3_COMMIT_DATE";
      } else
        { };

      build = { crossSystem, pkgs ? "pkgs" }:
        let loadedPkgs = pkgsLoader crossSystem;
        in loadedPkgs.${pkgs}.callPackage ./. {
          inherit ciVariables;
          inherit (loadedPkgs.buildPackages) binutils;
          libplctag = loadedPkgs.${pkgs}.callPackage ./libplctag { };
        };

    in {
      packages = {
        x86_64-windows = {
          default = self.packages.x86_64-windows.gnu;
          gnu = build {
            crossSystem = nixpkgs.lib.systems.examples.mingwW64 // {
              rustc.config = "x86_64-pc-windows-gnu";
            };
          };
        };

        x86_64-linux = {
          default = self.packages.x86_64-linux.musl;

          gnu = build { crossSystem = nixpkgs.lib.systems.examples.gnu64; };
          musl = build {
            crossSystem = nixpkgs.lib.systems.examples.musl64;
            pkgs = "pkgsStatic";
          };
        };

        aarch64-linux = {
          default = self.packages.aarch64-linux.musl;
          gnu = build {
            crossSystem = nixpkgs.lib.systems.examples.aarch64-multiplatform;
          };
          musl = build {
            crossSystem =
              nixpkgs.lib.systems.examples.aarch64-multiplatform-musl;
            pkgs = "pkgsStatic";
          };
        };
      };

      devShells.x86_64-linux.default =
        nixpkgs.legacyPackages.${localSystem}.mkShell (let
          loadedPkgs = pkgsLoader localSystem;
          libplctag = loadedPkgs.callPackage ./libplctag { };
        in {
          packages = with loadedPkgs.pkgs; [ tokio-console ];
          nativeBuildInputs = with loadedPkgs.pkgs; [
            cmake
            rustPlatform.bindgenHook
          ];
          LIBPLCTAG_PATH = "${libplctag.outPath}/";
        });
    };
}
