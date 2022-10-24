{ lib, buildGoModule, fetchFromGitHub, stdenv }:

buildGoModule rec {
  pname = "wuzz";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "asciimoo";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-H0soiKOytchfcFx17az0pGoFbA+hhXLxGJVdaARvnDc=";
  };

  # package still builds but the vendor isn't reproducible with go > 1.17: nix-build -A $name.go-modules --check
  # may end up needing to mark the package as broken
  vendorSha256 = "sha256-omeAIq8KBYXRnldiGKDF1g+aOKYc+B4grusmfg5wOuA=";

  meta = with lib; {
    homepage = "https://github.com/asciimoo/wuzz";
    description = "Interactive cli tool for HTTP inspection";
    license = licenses.agpl3;
    maintainers = with maintainers; [ pradeepchhetri ];
    broken = stdenv.isDarwin; # build fails with go > 1.17
  };
}
