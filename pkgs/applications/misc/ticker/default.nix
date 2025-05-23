{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "ticker";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-THVzurv1LB2lxGsCw0ZPUF5QLgtUfN4ZNp8ak05I2Es=";
  };

  vendorSha256 = "sha256-6bosJ2AlbLZ551tCNPmvNyyReFJG+iS3SYUFti2/CAw=";

  ldflags = [
    "-s" "-w" "-X github.com/achannarasappa/ticker/cmd.Version=v${version}"
  ];

  # Tests require internet
  doCheck = false;

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ siraben ];
  };
}
