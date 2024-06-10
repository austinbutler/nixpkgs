{ lib, stdenv, fetchFromGitHub, nodejs, pnpm_9 }:

stdenv.mkDerivation (finalAttrs: {
  pname = "vtsls";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "yioneko";
    repo = "vtsls";
    rev = "server-v${finalAttrs.version}";
    hash = "sha256-bc8KDsvAxvHdUhO2wn1KBc4jB/LKz+fozfrPGmD15wQ=";
  };

  # npmDepsHash = "sha256-T0WfJaSVzwbN0TL1AiuzMUW/3MKMOZo14v4Ut9Iqxas=";
  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-PpGsJM3wVTqDu4ITXCalqI5XohUb2WOs/yd2BxJ60OE=";
  };

  nativeBuildInputs = [ nodejs pnpm_9.configHook ];

    postBuild = ''
      pnpm build
    '';

    postInstall = ''
      cp -r dist $out
    '';

  # passthru.tests = {
  #   version = testers.testVersion {
  #     package = vtsls;
  #   };
  # };

  meta = with lib; {
    description = "LSP wrapper for typescript extension of vscode ";
    homepage = "https://github.com/yioneko/vtsls";
    changelog = "https://github.com/yioneko/vtsls/releases/tag/service-v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ maintainers.austinbutler ];
    mainProgram = "tsserver";
  };
})
