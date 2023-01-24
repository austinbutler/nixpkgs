{ lib
, stdenv
, fetchFromGitLab
, fetchpatch
, appstream-glib
, clang
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustPlatform
, wrapGAppsHook4
, gdk-pixbuf
, glib
, gst_all_1
, gtk4
, libadwaita
, libclang
, openssl
, pipewire
, sqlite
, wayland
, zbar
}:

stdenv.mkDerivation rec {
  pname = "authenticator";
  version = "4.1.6";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Authenticator";
    rev = version;
    hash = "sha256-fv7Np3haRCJABlJocKuu+1jevHYrdo+VyiQBpRmHs2g=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-8GddlDM1lU365GXdrKNhO331/y1p3Om5uZfVLy8TBGI=";
  };

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ] ++ (with rustPlatform; [
    cargoSetupHook
    rust.cargo
    rust.rustc
    bindgenHook
  ]);

  buildInputs = [
    gdk-pixbuf
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-bad.override { enableZbar = true; })
    gtk4
    libadwaita
    openssl
    pipewire
    sqlite
    wayland
    zbar
  ];

  # https://gitlab.gnome.org/World/Authenticator/-/issues/362
  preBuild = ''
    export BINDGEN_EXTRA_CLANG_ARGS="$BINDGEN_EXTRA_CLANG_ARGS -DPW_ENABLE_DEPRECATED"
  '';

  patches = [
    # https://gitlab.gnome.org/World/Authenticator/-/issues/339
    (fetchpatch {
      name = "token-check.patch";
      url = "https://gitlab.gnome.org/World/Authenticator/-/commit/192d296f3b800832cdc84934e5395052f6080db5.patch";
      sha256 = "sha256-bTzrl36/71EpmXp4XlOMRNH8vISZMS6/PbKx4fYiQ4s=";
    })
  ];

  meta = {
    description = "Two-factor authentication code generator for GNOME";
    homepage = "https://gitlab.gnome.org/World/Authenticator";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ austinbutler ];
    platforms = lib.platforms.linux;
  };
}
