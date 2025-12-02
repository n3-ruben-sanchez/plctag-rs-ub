{ stdenv, rustPlatform, libplctag, binutils, ciVariables, }:
let cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
in rustPlatform.buildRustPackage ({
  inherit (cargoToml.package) name version;

  src = ./.;
  cargoLock = {
    lockFile = ./Cargo.lock;
    extraRegistries = {
      "sparse+http://crates.ad.n3uron.com:8000/api/v1/crates/" =
        "http://crates.ad.n3uron.com:8000/api/v1/crates/dl";
    };
  };

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  doCheck = stdenv.hostPlatform.system == stdenv.targetPlatform.system;

  postInstall = "${binutils.outPath}/bin/*strip $out/bin/*";

  LIBPLCTAG_PATH = "${libplctag.outPath}/";
  LIBPLCTAG_STATIC = 1;
} // ciVariables)
