{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, sqlite
}:

rustPlatform.buildRustPackage rec {
  pname = "shellcaster";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "jeff-hughes";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Fzoo6HkIQRtecpitW36IgsHKwCE9Sqh4KofJNp9qMSY=";
  };

  cargoHash = "sha256-jlToF7GO+DHoqqgcBNC+QBLbxTc9lGkzzDpn8NEO8Xw=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl sqlite ];

  meta = with lib; {
    description = "Terminal-based podcast manager built in Rust ";
    homepage = "https://github.com/jeff-hughes/shellcaster";
    changelog = "https://github.com/jeff-hughes/shellcaster/blob/v${version}/CHANGELOG.md";
    license = licenses.gpl3;
    maintainers = with maintainers; [ austinbutler ];
  };
}
