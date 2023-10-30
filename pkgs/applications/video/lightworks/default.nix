{ lib, stdenv, fetchurl, dpkg, makeWrapper, buildFHSEnv
, gtk3, gdk-pixbuf, cairo, libjpeg_original, glib, pango, libGLU
, libGL, nvidia_cg_toolkit, zlib, openssl, libuuid
, alsa-lib, udev, libjack2, freetype, libva, libvdpau, copyDesktopItems, makeDesktopItem
}:
let
  fullPath = lib.makeLibraryPath [
    stdenv.cc.cc
    gtk3
    gdk-pixbuf
    cairo
    libjpeg_original
    glib
    pango
    libGL
    libGLU
    nvidia_cg_toolkit
    zlib
    openssl
    libuuid
    alsa-lib
    libjack2
    udev
    freetype
    libva
    libvdpau
  ];

  lightworks = stdenv.mkDerivation rec {
    version = "2023.2";
    rev = "142600";
    pname = "lightworks";

    src =
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchurl {
          url = "https://cdn.lwks.com/releases/${version}/lightworks_${version}_r${rev}.deb";
          sha256 = "sha256-YPru6IuJHYcX5Ugi83BBffzAkKKOeaW5GC9qtIl+9bc=";
        }
      else throw "${pname}-${version} is not supported on ${stdenv.hostPlatform.system}";

    nativeBuildInputs = [ copyDesktopItems makeWrapper ];
    buildInputs = [ dpkg ];

    desktopItems = [
   ( makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "Lightworks";
    genericName = "Video Editor";
    categories = [ "AudioVideo" "AudioVideoEditing" ];
    startupWMClass = pname;
  })
];

    unpackPhase = "dpkg-deb -x ${src} ./";

    installPhase = ''
      mkdir -p $out/{bin,share/pixmaps}
      substitute usr/bin/lightworks $out/bin/lightworks \
        --replace "/usr/lib/lightworks" "$out/lib/lightworks"
      chmod +x $out/bin/lightworks

      cp -r usr/lib $out

      # /usr/share/fonts is not normally searched
      # This adds it to lightworks' search path while keeping the default
      # using the FONTCONFIG_FILE env variable
      echo "<?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
      <fontconfig>
          <dir>/usr/share/fonts/truetype</dir>
          <include>/etc/fonts/fonts.conf</include>
      </fontconfig>" > $out/lib/lightworks/fonts.conf

      patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/lib/lightworks/ntcardvt

      wrapProgram $out/lib/lightworks/ntcardvt \
        --prefix LD_LIBRARY_PATH : ${fullPath}:$out/lib/lightworks \
        --set FONTCONFIG_FILE $out/lib/lightworks/fonts.conf

      cp -r usr/share $out/

      rm $out/share/applications/lightworks.desktop

      ln -s $out/share/lightworks/Icons/App.png $out/share/pixmaps/lightworks.png

      runHook postInstall
    '';

    dontPatchELF = true;
  };

# Lightworks expects some files in /usr/share/lightworks
in buildFHSEnv {
  name = lightworks.pname;

  targetPkgs = pkgs: [
      lightworks
  ];

 # TODO: Might still need this
  # link desktop item and icon into FHS user environment
  # extraInstallCommands = ''
  #   mkdir -p "$out/share/{applications,pixmaps}"
  #   ln -s ${lightworks}/share/applications/lightworks.desktop "$out/share/applications/lightworks.desktop"
  #   ln -s ${lightworks}/share/pixmaps/lightworks.png "$out/share/pixmaps/lightworks.png"
  # '';

  runScript = "lightworks";

  meta = {
    description = "Professional Non-Linear Video Editor";
    homepage = "https://www.lwks.com/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ antonxy vojta001 kashw2 ];
    platforms = [ "x86_64-linux" ];
  };
}
