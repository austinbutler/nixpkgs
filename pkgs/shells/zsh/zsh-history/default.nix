{ lib, fetchFromGitHub, buildGoModule, installShellFiles, nixosTests }:

buildGoModule rec {
  pname = "zsh-history";
  version = "2019-12-10";

  src = fetchFromGitHub {
    owner = "b4b4r07";
    repo = "history";
    rev = "8da016bd91b0c2eb53c9980f00eee6abdbb097e2";
    sha256 = "13n643ik1zjvpk8h9458yd9ffahhbdnigmbrbmpn7b7g23wqqsi3";
  };

  nativeBuildInputs = [ installShellFiles ];

  vendorSha256 = "1863ad97y82fx0an1ysalkxnqjz3zfz228wag9a92wdssl1vwzws";

  doCheck = false;

  postInstall = ''
    install -d $out/share
    cp -r "$NIX_BUILD_TOP/source/misc/"* "$out/share"
    installShellCompletion --zsh --name _history $out/share/zsh/completions/_history
  '';

  meta = with lib; {
    description = "A CLI to provide enhanced history for your ZSH shell";
    license = licenses.mit;
    homepage = "https://github.com/b4b4r07/history";
    platforms = platforms.unix;
    maintainers = with maintainers; [ ];
  };

  passthru.tests = {
    zsh-history-shell-integration = nixosTests.zsh-history;
  };
}
