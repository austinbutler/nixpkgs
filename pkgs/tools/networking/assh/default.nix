{ lib
, buildGoModule
, fetchpatch
, fetchFromGitHub
, openssh
, makeWrapper
}:

buildGoModule rec {
  pname = "assh";
  version = "2.12.0";

  src = fetchFromGitHub {
    repo = "advanced-ssh-config";
    owner = "moul";
    rev = "19cf2fc158ecb532679442558f32c426d92373c5";
    sha256 = "1323ck1wmdhzx9903dw7ignzylb739rxqfcay0cvi9l9cdipchdr";
  };

  vendorSha256 = "0d2202jgaklrwx773cff4lryhm1dbah80lcinxrnf3qd182vbhcp";

  doCheck = false;

  ldflags = [
    "-s" "-w" "-X moul.io/assh/v2/pkg/version.Version=${version}"
  ];

  nativeBuildInputs = [ makeWrapper ];

  #patches = [
  #  # https://github.com/moul/assh/pull/430
  #  (fetchpatch {
  #    name = "gopsutil-update-1";
  #    url = "https://github.com/moul/assh/commit/19cf2fc158ecb532679442558f32c426d92373c5.patch";
  #    sha256 = "0a089ay6sk4ixgx46fdp7pz86fk8nzi4zql20b6c2w3z80hh5c1g";
  #  })
  #];

  postInstall = ''
    wrapProgram "$out/bin/assh" \
      --prefix PATH : ${openssh}/bin
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/assh --help > /dev/null
  '';

  meta = with lib; {
    description = "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts";
    homepage = "https://github.com/moul/assh";
    changelog = "https://github.com/moul/assh/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ zzamboni ];
    platforms = with platforms; linux ++ darwin;
  };
}
