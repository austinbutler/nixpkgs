{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, installShellFiles
}:

buildGoModule rec {
  pname = "packer";
  version = "1.7.8";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "packer";
    rev = "1adf1a0fab53a632f1a023f35371eb5a78aad5c1";
    sha256 = "0zvhjc2andxifv7fcf050kj9nbj3sx0zahphqfn0h2f2x9msxwkp";
  };

  vendorSha256 = "1jxgb846pnrjg6zf176mrmp75nxpvkj7s6r0fn6vmm3775413axh";

  subPackages = [ "." ];

  ldflags = [ "-s" "-w" ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --zsh contrib/zsh-completion/_packer
  '';

  meta = with lib; {
    description = "A tool for creating identical machine images for multiple platforms from a single source configuration";
    homepage    = "https://www.packer.io";
    license     = licenses.mpl20;
    maintainers = with maintainers; [ cstrahan zimbatm ma27 ];
    changelog   = "https://github.com/hashicorp/packer/blob/v${version}/CHANGELOG.md";
    platforms   = platforms.unix;
  };
}
