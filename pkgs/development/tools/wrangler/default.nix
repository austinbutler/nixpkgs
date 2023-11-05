{ lib, buildNpmPackage, fetchFromGitHub, chromium, makeWrapper }:

buildNpmPackage rec {
  pname = "wrangler3";
  version = "3.14.0";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "workers-sdk";
    rev = "wrangler@${version}";
    hash = "sha256-T8PMu8UY0VFahodSGp+skjWtfdEPB0bhfCiRFdjy+B8=";
  };

  npmDepsHash = "sha256-/dpxmclN7ZoPNEe9SplMUnhHer/A49p+aoEtsaSA9zM=";

  # dontNpmBuild = true;

  # npmInstallFlags = [ "--omit=dev" ];

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    cd packages/wrangler
    # use generated package-lock.json as upstream does not provide one
    cp ${./package-lock.json} ./package-lock.json
  '';

  # env = {
  #   PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
  # };

  # postPatch = ''
  #   substituteInPlace package.json --replace "git config core.hooksPath .git-hooks" ""
  # '';

  # postInstall = ''
  #   wrapProgram $out/bin/percollate \
  #     --set PUPPETEER_EXECUTABLE_PATH ${chromium}/bin/chromium
  # '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Cloudflare Developer Platform command-line interface";
    homepage = "https://github.com/cloudflare/workers-sdk";
    license = licenses.mit;
    maintainers = [ maintainers.austinbutler ];
    mainProgram = "wrangler";
  };
}
