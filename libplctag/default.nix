{ lib, stdenv, cmake, pkg-config, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "libplctag";
  version = "2.6.12";

  src = fetchFromGitHub {
    owner = "libplctag";
    repo = "libplctag";
    rev = "v${version}";
    sha256 = "sha256-4NaFHJDx3GsdB6rljWQVjyeXTAHhyAaQvgxthXOoiBI=";
  };

  patches = [ ./patches/2.6.12-0001-Fix-windows-uppercase-imports.patch ];

  nativeBuildInputs = [ cmake pkg-config ];

  cmakeFlags =
    [ "-DCMAKE_BUILD_TYPE=MinSizeRel" "-DBUILD_TESTS=0" "-DBUILD_EXAMPLES=0" ];

  NIX_CFLAGS_COMPILE = [ "-U__MINGW32__" "-U__MINGW64__" ] ++ lib.lists.optional
    (stdenv.targetPlatform.isAarch64 && stdenv.targetPlatform.isMusl)
    "-mno-outline-atomics";

  NIX_LDFLAGS = lib.lists.optional stdenv.targetPlatform.isMusl "-no-pie";

  fixupPhase = ''
    rm -rf $out/bin/libplctag.dll
    rm -rf $out/lib/libplctag.dll.a
    mv $out/lib/libplctag_static.a $out/lib/libplctag.a
  '';

  meta = with lib; {
    homepage = "https://github.com/libplctag/libplctag";
    description =
      "Library that uses EtherNet/IP or Modbus TCP to read and write tags in PLCs";
    license = with licenses; [ lgpl2Plus mpl20 ];
    maintainers = with maintainers; [ petterstorvik ];
    platforms = platforms.all;
  };
}
