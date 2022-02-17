{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, glib, zlib, pcre, mysql80, openssl }:

let inherit (lib) getDev; in

stdenv.mkDerivation rec {
  version = "0.11.5-2";
  pname = "mydumper";

  src = fetchFromGitHub {
    owner  = "mydumper";
    repo   = "mydumper";
    rev    = "v${version}";
    sha256 = "0hwcas689hbf5a6qvan0ccjfwys26d1vzgq62vp69v6qjwfbgpkz";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ glib zlib pcre mysql80 openssl ];

  # prePatch = ''
  #   echo "DEV: ${getDev mysql80}"
  #   exit 1
  # '';

  # cmakeFlags = [ "-DMYSQL_INCLUDE_DIR=${mysql80}/lib" ];
  cmakeFlags = [ "-DBUILD_DOCS=OFF" "-DWITH_ZSTD=OFF" "-Wno-dev" ];

  meta = with lib; {
    description = "High-perfomance MySQL backup tool";
    homepage = "https://github.com/mydumper/mydumper";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ izorkin ];
  };
}
