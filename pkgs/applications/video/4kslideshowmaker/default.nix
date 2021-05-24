{ stdenv, lib, fetchurl, writeScript, cdrtools, dvdauthor, ffmpeg_3, imagemagick
, lame, mjpegtools, sox, transcode, vorbis-tools, runtimeShell, makeWrapper }:

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

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin" "$out/lib"
    cp 4kslideshowmaker-bin "$out/bin/4kslideshowmaker"
    cp -r . "$out/lib"
    rm $out/lib/{4kslideshowmaker-bin,4kslideshowmaker.sh}
    wrapProgram "$out/bin/${pname}" --set LD_LIBRARY_PATH $out/lib
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
