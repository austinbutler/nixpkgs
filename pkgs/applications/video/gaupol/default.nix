{ lib, fetchFromGitHub, appstream-glib, desktop-file-utils, gettext, glib
, gobject-introspection, gst_all_1, gtk3, libhandy, librsvg, meson, ninja
, pkg-config, python3Packages, wrapGAppsHook }:

python3Packages.buildPythonApplication rec {
  pname = "gaupol";
  version = "1.9";

  src = fetchFromGitHub {
    owner = "otsaloma";
    repo = "gaupol";
    rev = "${version}";
    sha256 = "1mmjg8nwhif2hmmp8i11643izwzdf839brqdai3ksfg0qkh8rnxk";
  };

  buildInputs = [
    glib
    gobject-introspection
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gtk3
  ];

  nativeBuildInputs =
    [ appstream-glib desktop-file-utils gettext pkg-config wrapGAppsHook ];

  propagatedBuildInputs = with python3Packages;
    [ pygobject3 ] ++ [ gobject-introspection ];
  #checkInputs = with python3Packages;
  #  [ pygobject3 pytestCheckHook ] ++ [ glib gobject-introspection ];
  setupPyGlobalFlags = [ "--without-aeidon" ];

  strictDeps = false;

  buildPhase = ''
    export GST_PLUGIN_SYSTEM_PATH_1_0="$out/lib/gstreamer-1.0/:$GST_PLUGIN_SYSTEM_PATH_1_0"
  '';

  # Fixes https://github.com/NixOS/nixpkgs/issues/31168
  #postPatch = ''
  #  chmod +x build-aux/meson/postinstall.py
  #  patchShebangs build-aux/meson/postinstall.py
  #'';

  meta = with lib; {
    description = "Simple screen recorder";
    homepage = "https://github.com/SeaDve/Kooha";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ austinbutler ];
  };
}
