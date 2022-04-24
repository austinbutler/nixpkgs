{ lib, stdenv, fetchFromGitLab, pkg-config, file, libsigcxx, gettext, glibmm, gst_all_1, gnome, autoconf, automake, autoreconfHook, mm-common, libtool, libxmlxx, intltool}:
stdenv.mkDerivation rec {
  pname = "gstreamermm";
  version = "dfd80ddb4eac02ae6c48a076a9cd9a1dc9e7bed2";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = pname;
    rev = version;
    sha256 = "sha256-4VwVyu0RzvtsTq/UWZ3//KCY0qxfMrdqDCpMnEGe9YA=";
  };
  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ autoconf automake intltool libtool libxmlxx libsigcxx mm-common pkg-config file ];

  propagatedBuildInputs = [ gettext glibmm gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good gst_all_1.gst-plugins-ugly gst_all_1.gst-plugins-bad ];

  enableParallelBuilding = false;
  #preConfigure = "NO_CONFIGURE=1 ./autogen.sh";
  configureFlags = [ "--disable-documentation" ];
  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gst_all_1.gstreamermm";
      packageName = "gstreamermm";
      versionPolicy = "odd-unstable";
    };
  };

  meta = with lib; {
    description = "C++ interface for GStreamer";
    homepage = "https://gstreamer.freedesktop.org/bindings/cplusplus.html";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo ];
  };

}
