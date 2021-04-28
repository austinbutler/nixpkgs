{ lib, stdenv, fetchCrate, rustPlatform, sqlcipher }:

rustPlatform.buildRustPackage rec {
  pname = "seshat";
  version = "2.2.4";

  src = fetchCrate {
    inherit pname version;
    sha256 = "0lihc6bb4xyd3rbfxcij3k2i8s6vxy4l41jchn1bz6vvdfbsjhls";
  };

  buildInputs = [ sqlcipher ];
  preCheck = ''
    echo "TMP $TMP"
    ls -lah "$TMP"
  '';

  cargoPatches = [ ./add-Cargo.lock.patch ];

  cargoSha256 = "1hchaj0pc6chnn7m6xp8kqnqq13wyk2ia2w1bc128ds22hgbnpnm";
}
