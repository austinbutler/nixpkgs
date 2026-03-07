{
  fetchzip,
  revision,
  browserVersion,
  suffix,
  system,
  throwSystem,
  stdenv,
  autoPatchelfHook,
  patchelfUnstable,

  alsa-lib,
  at-spi2-atk,
  expat,
  glib,
  libxcomposite,
  libxdamage,
  libxfixes,
  libxrandr,
  libgbm,
  libgcc,
  libxkbcommon,
  nspr,
  nss,
  ...
}:
let
  cftBase = "https://cdn.playwright.dev/chrome-for-testing-public/${browserVersion}";
  cdnBase = "https://cdn.playwright.dev/dbazure/download/playwright/builds/chromium/${revision}";

  linux = stdenv.mkDerivation {
    name = "playwright-chromium-headless-shell";
    src = fetchzip {
      url =
        if system == "aarch64-linux"
        then "${cdnBase}/chromium-headless-shell-linux-arm64.zip"
        else "${cftBase}/linux64/chrome-headless-shell-linux64.zip";
      stripRoot = false;
      hash =
        {
          x86_64-linux = "";
          aarch64-linux = "";
        }
        .${system} or throwSystem;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      patchelfUnstable
    ];

    buildInputs = [
      alsa-lib
      at-spi2-atk
      expat
      glib
      libxcomposite
      libxdamage
      libxfixes
      libxrandr
      libgbm
      libgcc.lib
      libxkbcommon
      nspr
      nss
    ];

    buildPhase = ''
      cp -R . $out
    '';
  };

  darwin = fetchzip {
    url =
      if system == "aarch64-darwin"
      then "${cftBase}/mac-arm64/chrome-headless-shell-mac-arm64.zip"
      else "${cftBase}/mac-x64/chrome-headless-shell-mac-x64.zip";
    stripRoot = false;
    hash =
      {
        x86_64-darwin = "";
        aarch64-darwin = "";
      }
      .${system} or throwSystem;
  };
in
{
  x86_64-linux = linux;
  aarch64-linux = linux;
  x86_64-darwin = darwin;
  aarch64-darwin = darwin;
}
.${system} or throwSystem
