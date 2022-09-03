{ lib
, stdenv
, fetchFromGitHub
, appstream-glib
, desktop-file-utils
, glib
, gobject-introspection
, gst_all_1
, gtk4
, libadwaita
, libpulseaudio
, librsvg
, meson
, ninja
, pkg-config
, python3
, rustPlatform
, wayland
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "kooha";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "SeaDve";
    repo = "Kooha";
    rev = "v${version}";
    sha256 = "sha256-MkX9NObeqPMvz4qR0f9E4cqpzOaNss02zQr+87lA/iQ";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-UTx0zPspkFBA8PZLi6KDMjhgvWZN1C7uLNSoaRgWvrU=";
  };

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    meson
    ninja
    python3
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    wayland
    wrapGAppsHook
  ];

  buildInputs = [
    glib
    gobject-introspection
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk4
    libadwaita
    libpulseaudio
    librsvg
  ];

  propagatedBuildInputs = [ python3.pkgs.pygobject3 ];

  strictDeps = false;

  # Fixes https://github.com/NixOS/nixpkgs/issues/31168
  postPatch = ''
    patchShebangs build-aux/meson_post_install.py
    substituteInPlace meson.build --replace '>= 1.0.0-alpha.1' '>= 1.0.0'
  '';

  installCheckPhase = ''
    $out/bin/kooha --help
  '';

  meta = with lib; {
    description = "Simple screen recorder";
    homepage = "https://github.com/SeaDve/Kooha";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ austinbutler ];
  };
}
