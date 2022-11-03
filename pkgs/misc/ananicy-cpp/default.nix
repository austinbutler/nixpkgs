{ lib
, gcc12Stdenv
, fetchFromGitLab
, makeWrapper
, cmake
, spdlog
, nlohmann_json
, systemd
, clang
}:

gcc12Stdenv.mkDerivation rec {
  pname = "ananicy-cpp";
  version = "unstable-2022-10-18";

  src = fetchFromGitLab {
    owner = "ananicy-cpp";
    repo = "ananicy-cpp";
    rev = "a5223907458b94f7240ade581cd62c9ca5a1892a";
    sha256 = "sha256-2MzRdPpsgnGVF7YCLSjcG8bVQUEB1gSgEUWW5Y0zZSY=";
    fetchSubmodules = true;
  };
  
  NIX_CLAGS_COMPILE = "-Wno-error";

  nativeBuildInputs = [
    makeWrapper
    clang
    cmake
  ];

  buildInputs = [
    spdlog
    nlohmann_json
    systemd
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DCMAKE_C_FLAGS=-Wno-error"
    "-DUSE_EXTERNAL_JSON=yON"
    "-DUSE_EXTERNAL_SPDLOG=ON"
    "-DUSE_EXTERNAL_FMTLIB=ON"
  ];

  meta = with lib; {
    homepage = "https://gitlab.com/ananicy-cpp/ananicy-cpp";
    description = "Rewrite of ananicy in c++ for lower cpu and memory usage";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ artturin ];
  };
}
