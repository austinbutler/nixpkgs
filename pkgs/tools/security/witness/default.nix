{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "witness";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "testifysec";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/35hIA6Wm/F5hwyLZbt4JXpwWISWbzVAWrX29r6pejY=";
  };

  vendorSha256 = "sha256-vXDsHHJknw9hsHx1mJA2c0CWwFbRXjCjitNWPh6V4yw=";

  nativeBuildInputs = [ installShellFiles ];

  # We only want the witness binary, not the helper utilities for generating docs.
  subPackages = [ "cmd/witness" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/testifysec/witness/cmd/witness/cmd.Version=v${version}"
  ];

  # Feed in all tests for testing
  # This is because subPackages above limits what is built to just what we
  # want but also limits the tests
  preCheck = ''
    unset subPackages
  '';

  postInstall = ''
    installShellCompletion --cmd witness \
      --bash <($out/bin/witness completion bash) \
      --fish <($out/bin/witness completion fish) \
      --zsh <($out/bin/witness completion zsh)
  '';

  meta = with lib; {
    description = "A pluggable framework for software supply chain security. Witness prevents tampering of build materials and verifies the integrity of the build process from source to target";
    longDescription = ''
      Witness prevents tampering of build materials and verifies the integrity
      of the build process from source to target. It works by wrapping commands
      executed in a continuous integration process. Its attestation system is
      pluggable and offers support out of the box for most major CI and
      infrastructure providers. Verification of Witness metadata and a secure
      PKI distribution system will mitigate against many software supply chain
      attack vectors and can be used as a framework for automated governance.
    '';
    homepage = "https://github.com/testifysec/witness";
    changelog = "https://github.com/testifysec/witness/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ fkautz jk ];
  };
}
