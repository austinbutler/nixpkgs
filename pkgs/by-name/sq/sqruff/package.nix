{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
  rust-jemalloc-sys,
  nix-update-script,
  versionCheckHook,
  breakpointHook,
  neovim,
}:
rustPlatform.buildRustPackage rec {
  pname = "sqruff";
  version = "0.24.3";

  src = fetchFromGitHub {
    owner = "quarylabs";
    repo = "sqruff";
    tag = "v${version}";
    hash = "sha256-vJlnJAn9e5bjGGorEeWMskBi4X7fpBsRfkE8ujeh+fg=";
  };

  cargoHash = "sha256-0du3ACrrY+uCQazaH9AFOM0zsSZSYwZHXkHcX50IO/I=";

  useNextest = true;

  buildInputs = [
    neovim
    rust-jemalloc-sys
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.apple_sdk.frameworks.CoreServices ];

  nativeBuildInputs = [ breakpointHook ];

  # Patch the tests to find the binary
  postPatch = ''
    substituteInPlace crates/cli/tests/{config_not_found,configure_rule,fix_parse_errors,fix_return_code,ui,ui_github,ui_json}.rs \
      --replace-fail \
      'sqruff_path.push(format!("../../target/{}/sqruff", profile));' \
      'sqruff_path.push(format!("../../target/${stdenv.hostPlatform.rust.cargoShortTarget}/{}/sqruff", profile));'
    substituteInPlace crates/cli/tests/ui_with_python.rs \
      --replace-fail \
      'let sqruff_path = temp_dir.path().join("debug").join("sqruff");' \
      'let sqruff_path = String::from("../../target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/sqruff");'
  '';

  cargoBuildFeatures = [ "python" ];
  cargoCheckFeatures = [ "python" ];

  # checkFlags = [
  #   # reason for disabling test
  #   "--skip=sqruff::ui_with_python"
  # ];

  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = [ "--version" ];
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast SQL formatter/linter";
    homepage = "https://github.com/quarylabs/sqruff";
    changelog = "https://github.com/quarylabs/sqruff/releases/tag/${version}";
    license = lib.licenses.asl20;
    mainProgram = "sqruff";
    maintainers = with lib.maintainers; [ hasnep ];
  };
}
