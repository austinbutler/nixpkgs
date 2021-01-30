{ stdenv, lib, fetchurl, writeScript, cdrtools, dvdauthor, ffmpeg_3, imagemagick
, lame, mjpegtools, sox, transcode, vorbis-tools, runtimeShell }:

stdenv.mkDerivation rec {
  pname = "4kslideshowmaker";
  versionMajor = "1";
  versionMinor = "8";
  versionPatch = "2";
  version = "${versionMajor}.${versionMinor}.${versionPatch}.1041";

  src = fetchurl {
    url = "https://dl.4kdownload.com/app/${pname}_${versionMajor}.${versionMinor}.${versionPatch}_amd64.tar.bz2";
    sha256 = "2c87658444df5451f04ca8d4daaa534c93e4684689721389ae8382065e40d361";
  };

  #patchPhase = ''
  #  # fix upstream typos
  #  substituteInPlace dvd-slideshow \
  #    --replace "version='0.8.4-1'" "version='0.8.4-2'" \
  #    --replace "mymyecho" "myecho"
  #'';

  installPhase = ''
    mkdir -p "$out/bin"
    cp dvd-slideshow         "$out/bin/dvd-slideshow.real"
    cp dvd-menu              "$out/bin/dvd-menu.real"
    cp dir2slideshow         "$out/bin/dir2slideshow.real"
    cp gallery1-to-slideshow "$out/bin/gallery1-to-slideshow.real"
    cp jigl2slideshow        "$out/bin/jigl2slideshow.real"

    cp ${wrapper} "$out/bin/dvd-slideshow.sh"
    ln -s dvd-slideshow.sh "$out/bin/dvd-slideshow"
    ln -s dvd-slideshow.sh "$out/bin/dvd-slideshow.ffmpeg"
    ln -s dvd-slideshow.sh "$out/bin/dvd-menu"
    ln -s dvd-slideshow.sh "$out/bin/dir2slideshow"
    ln -s dvd-slideshow.sh "$out/bin/gallery1-to-slideshow"
    ln -s dvd-slideshow.sh "$out/bin/jigl2slideshow"

    cp -a man "$out/"
  '';

  meta = {
    description =
      "Create slideshows with music, different effects, and presets";
    homepage = "https://www.4kdownload.com/products/product-slideshowmaker";
    license = {
      fullName = "4K Download Terms of Use";
      url = "https://www.4kdownload.com/agreement/terms-of-use";
      free = false;
    };
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.austinbutler ];
  };
}
