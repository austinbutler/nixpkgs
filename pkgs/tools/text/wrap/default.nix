{ lib, buildGoModule, fetchFromGitHub, fetchpatch, makeWrapper, courier-prime }:

buildGoModule rec {
  pname = "wrap";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Wraparound";
    repo = "wrap";
    rev = "v${version}";
    sha256 = "0scf7v83p40r9k7k5v41rwiy9yyanfv3jm6jxs9bspxpywgjrk77";
  };

  nativeBuildInputs = [ makeWrapper ];

  vendorSha256 = "sha256-vg61Vypd+mSF9FyLFVpnS5UCTJDoobkDE1Cneg8O0RM=";

  patches = [
    (fetchpatch {
      name = "courier-prime-variants.patch";
      url = "https://patch-diff.githubusercontent.com/raw/Wraparound/wrap/pull/56.patch";
      sha256 = "sha256-wQ90B9my5LUgTE0zSzpl8ZP8OZA/QEpj6F9sHbc5N/U=";
    })
    (fetchpatch {
      name = "go-119.patch";
      url = "https://patch-diff.githubusercontent.com/raw/Wraparound/wrap/pull/60.patch";
      sha256 = "sha256-eIKvA91olfbNJhOhIUu3GOL/rbgX3m6unmU8nRdKbtc=";
    })
  ];

  postInstall = ''
    wrapProgram $out/bin/wrap --prefix XDG_DATA_DIRS : ${courier-prime}/share/
  '';

  meta = with lib; {
    description = "A Fountain export tool with some extras";
    homepage = "https://github.com/Wraparound/wrap";
    license = licenses.gpl3Only;
    maintainers = [ maintainers.austinbutler ];
  };
}
