{ lib, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "libraspberrypi";
  version = "unstable-2021-10-25";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "userland";
    rev = "0093675e4aa6e152a3ffc318b51a124e96eb287b";
    sha256 = "qpooQy9k2UZ94KaqlFwurV+tt0GrBSRffGdlvMcn1XU=";
  };

  patches = [
    (fetchpatch {
      # https://github.com/raspberrypi/userland/pull/670
      url = "https://github.com/raspberrypi/userland/commit/37cb44f314ab1209fe2a0a2449ef78893b1e5f62.patch";
      sha256 = "1fbrbkpc4cc010ji8z4ll63g17n6jl67kdy62m74bhlxn72gg9rw";
    })
  ];

  nativeBuildInputs = [ cmake pkg-config ];
  cmakeFlags = [
    (if (stdenv.hostPlatform.isAarch64) then "-DARM64=ON" else "-DARM64=OFF")
    "-DVMCS_INSTALL_PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "Userland tools & libraries for interfacing with Raspberry Pi hardware";
    homepage = "https://github.com/raspberrypi/userland";
    license = licenses.bsd3;
    platforms = [ "armv6l-linux" "armv7l-linux" "aarch64-linux" "x86_64-linux" ];
    maintainers = with maintainers; [ dezgeg tkerber ];
  };
}
