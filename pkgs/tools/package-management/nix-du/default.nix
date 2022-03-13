{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, nix
, nlohmann_json
, boost
, graphviz
, Security
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "nix-du";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "symphorien";
    repo = "nix-du";
    rev = "d334e5a559c7aacdd82787753a79d9d5eb149b5e";
    sha256 = "sha256-wwrXOh7I+x1X1LiIzTicSTtxTJaqGYY7aXxmgHYQpzM=";
  };

  cargoSha256 = "sha256-bE6IVSDDCe5XLF5kNrl22055wK2RIZf9uh2gXyX066w=";

  doCheck = true;
  checkInputs = [ nix graphviz ];

  buildInputs = [
    boost
    nix
    nlohmann_json
  ] ++ lib.optionals stdenv.isDarwin [ Security ];

  nativeBuildInputs = [ pkg-config rustPlatform.bindgenHook ];

  meta = with lib; {
    description = "A tool to determine which gc-roots take space in your nix store";
    homepage = "https://github.com/symphorien/nix-du";
    license = licenses.lgpl3Only;
    maintainers = [ maintainers.symphorien ];
    platforms = platforms.unix;
  };
}
