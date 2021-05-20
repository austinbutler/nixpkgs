{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, glib, zlib, pcre, libmysqlclient, libressl }:

let inherit (lib) getDev; in

stdenv.mkDerivation rec {
  version = "0.10.5";
  pname = "mydumper";

  src = fetchFromGitHub {
    owner  = "maxbube";
    repo   = "mydumper";
    rev    = "v${version}";
    sha256 = "1rik7v8hcd9nkbfzaqi275bhmzicnxckafxx0kfyr5mjvql729ca";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ glib zlib pcre libmysqlclient libressl ];

  cmakeFlags = [
    "-DMYSQL_INCLUDE_DIR=${libmysqlclient.dev}/include"
    "-DWITH_SSL=OFF"
  #  "-DGLIB2_LIBRARIES=${glib.dev}/include/glib-2.0/glib.h"
  #  "-DZLIB_LIBRARY=${zlib.dev}/include/zlib.h"
  #  "-DPCRE_PCRE_LIBRARY=${pcre.dev}/include/pcre.h"
  #  "-DPCRE_PCREPOSIX_LIBRARY=${pcre.dev}/include/pcreposix.h"
  ];

  preConfigure = ''
    echo "pcre"
    ls -lah ${pcre.dev}/include
    echo "glib"
    ls -lah ${glib.dev}/include/glib-2.0
    echo "zlib"
    ls -lah ${zlib.dev}/include
    echo "mysql-client"
    ls -lah ${mysql}
  '';

  meta = with lib; {
    description = "High-perfomance MySQL backup tool";
    homepage = "https://github.com/maxbube/mydumper";
    license = licenses.gpl3;
    maintainers = with maintainers; [ izorkin ];
  };
}
