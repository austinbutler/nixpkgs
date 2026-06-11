{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  makeWrapper,
  git,
  uv,
  python312,
  versionCheckHook,
  nix-update-script,
  callPackage,
  prek,
  withPythonSupport ? false,
}:

let
  pythonRuntimeDeps = [
    python312
    uv
  ];

  runtimeDeps = [
    git
  ] ++ lib.optionals withPythonSupport pythonRuntimeDeps;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "prek";
  version = "0.3.11";

  src = fetchFromGitHub {
    owner = "j178";
    repo = "prek";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Vd4XmO+Z0Zs5kE/PMesnr6q+JUz+DGXWKVoHsPZPKwM=";
  };

  cargoHash = "sha256-AggCANaSMeKftOlan8TpgLgpYgaLCpYBBbBOeLKCCVo=";

  patches = [ ./hardcode-hook-path.patch ];

  postPatch = ''
    substituteInPlace crates/prek/src/cli/install.rs \
      --subst-var-by out "$out"
  '';

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  nativeCheckInputs = [
    git
    python312
    uv
  ];

  # many tests just do not work, as they require network access
  # best to disable all, as the upstream already tests everything
  doCheck = false;

  postInstall = ''
    wrapProgram "$out/bin/prek" \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}
  '' + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd prek \
      --bash <(COMPLETE=bash $out/bin/prek) \
      --fish <(COMPLETE=fish $out/bin/prek) \
      --zsh <(COMPLETE=zsh $out/bin/prek)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
    tests = callPackage ./tests.nix { inherit prek; };
  };

  meta = {
    homepage = "https://github.com/j178/prek";
    description = "Better `pre-commit`, re-engineered in Rust ";
    mainProgram = "prek";
    changelog = "https://github.com/j178/prek/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.knl ];
  };
})
