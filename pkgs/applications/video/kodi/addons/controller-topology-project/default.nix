{
  lib,
  stdenv,
  fetchFromGitHub,
  toKodiAddon,
  addonDir,
}:
let
  drv = stdenv.mkDerivation rec {
    pname = "controller-topology-project";
    version = "1.0.4";

    src = fetchFromGitHub {
      owner = "kodi-game";
      repo = "controller-topology-project";
      rev = "v${version}";
      sha256 = "sha256-0h2Qbnym8XxUVao7aEN25uIKSIreutH272OiqtG4Obc=";
    };

    postPatch = ''
      # remove addons already included in the base kodi package
      rm -r addons/game.controller.default
      rm -r addons/game.controller.keyboard
      rm -r addons/game.controller.mouse
      rm -r addons/game.controller.snes
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out${addonDir}
      cp -r addons/* $out${addonDir}
      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/kodi-game/controller-topology-project";
      description = "Models how controllers connect to and map to each other for all gaming history";
      license = with licenses; [ odbl ];
      teams = [ teams.kodi ];
    };
  };
in
toKodiAddon drv
