{ pkgs, lib, fetchurl, buildPythonPackage,
  gtk3, pygobject3, gst-python, gsettings-desktop-schemas, python3Packages }:

buildPythonPackage rec {
  pname = "soundconverter";
  version = "4.0.3";

  src = fetchurl {
    url = "https://launchpad.net/${pname}/trunk/${version}/+download/${pname}-${version}.tar.gz";
    sha256 = "17di1jb8dsvq0w5a4a7ds8bp115szdvbvn5kg8wvvpy3hbzhccl7";
  };

  doCheck = false;
  # FIXME: Tests still fail with:
  # 'Settings schema 'org.soundconverter' is not installed'
  #preCheck = let
  #  gsds = gsettings-desktop-schemas;
  #in ''
  #  export XDG_DATA_DIRS=${gsds}/share/gsettings-schemas/${gsds.name}:./:$XDG_DATA_DIRS
  #  pwd
  #  ls -l
  #'';

  buildInputs = with pkgs; [
    python3Packages.distutils_extra
    gtk3
  ];

  nativeBuildInputs = with pkgs; [
    intltool
  ];
  propagatedBuildInputs = with pkgs; [
    pygobject3
    # FIXME: Still fails with:
    # 'soundconverter needs GTK >= 3.0 (Error: "Namespace GstPbutils not available")'
    gst-python
    gst_all_1.gst-devtools
    gst_all_1.gst-libav
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  meta = with lib; {
    homepage = "https://soundconverter.org/";
    description = "Leading audio file converter for the GNOME Desktop";
    longDescription = ''
      SoundConverter reads anything the GStreamer library can read, and writes
      WAV, FLAC, MP3, AAC and Ogg Vorbis files.  Uses Python and GTK+ GUI
      toolkit,and runs on X Window System.
    '';
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jakubgs ];
  };
}
