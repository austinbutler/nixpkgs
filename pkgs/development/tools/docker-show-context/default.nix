{ lib, buildGoModule, fetchFromGitHub, installShellFiles, runCommand }:

buildGoModule rec {
  pname = "docker-show-context";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "pwaller";
    repo = pname;
    rev = "v${version}";
    sha256 = "0l6h5hb2lggv8jcalcgchs2xiq2sbqw4yb0l8qgsarxa6h59naz6";
  };

  vendorSha256 = "sha256-W7elWOW/tz1ISM/KC1njkZmPi8AEEssZ5QtxK/+1/1I=";

  doCheck = false;

  #nativeBuildInputs = [ installShellFiles ];

  meta = with lib; {
    description = "Show where time is wasted during the context upload of docker build";
    homepage = "https://github.com/pwaller/docker-show-context";
    license = [ licenses.mit ];
    maintainers = [ maintainers.austinbutler ];
  };
}
