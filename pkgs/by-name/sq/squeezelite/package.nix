{
  lib,
  stdenv,
  fetchFromGitHub,
  flac,
  libgpiod,
  libmad,
  libpulseaudio,
  libvorbis,
  mpg123,
  audioBackend ? if stdenv.hostPlatform.isLinux then "alsa" else "portaudio",
  alsaSupport ? stdenv.hostPlatform.isLinux,
  alsa-lib,
  dsdSupport ? true,
  faad2Support ? true,
  faad2,
  ffmpegSupport ? true,
  ffmpeg,
  opusSupport ? true,
  opusfile,
  resampleSupport ? true,
  soxr,
  sslSupport ? true,
  openssl,
  portaudioSupport ? stdenv.hostPlatform.isDarwin,
  portaudio,
  slimserver,
}:

let
  inherit (lib) optional optionals optionalString;

  pulseSupport = audioBackend == "pulse";

  binName = "squeezelite${optionalString pulseSupport "-pulse"}";
in
stdenv.mkDerivation {
  # the nixos module uses the pname as the binary name
  pname = binName;
  # versions are specified in `squeezelite.h`
  # see https://github.com/ralph-irving/squeezelite/issues/29
  version = "2.0.0.1541";

  src = fetchFromGitHub {
    owner = "ralph-irving";
    repo = "squeezelite";
    rev = "72e1fd8abfa9b2f8e9636f033247526920878718";
    hash = "sha256-1uzkf7vkzfHdsWvWcXnUv279kgtzrHLU0hAPaTKRWI8=";
  };

  buildInputs = [
    flac
    libmad
    libvorbis
    mpg123
  ]
  ++ optional pulseSupport libpulseaudio
  ++ optional alsaSupport alsa-lib
  ++ optional portaudioSupport portaudio

  ++ optional faad2Support faad2
  ++ optional ffmpegSupport ffmpeg
  ++ optional opusSupport opusfile
  ++ optional resampleSupport soxr
  ++ optional sslSupport openssl
  ++ optional (stdenv.hostPlatform.isAarch32 or stdenv.hostPlatform.isAarch64) libgpiod;

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace opus.c \
      --replace "<opusfile.h>" "<opus/opusfile.h>"
  '';

  EXECUTABLE = binName;

  OPTS = [
    "-DLINKALL"
    "-DGPIO"
  ]
  ++ optional dsdSupport "-DDSD"
  ++ optional (!faad2Support) "-DNO_FAAD"
  ++ optional ffmpegSupport "-DFFMPEG"
  ++ optional opusSupport "-DOPUS"
  ++ optional portaudioSupport "-DPORTAUDIO"
  ++ optional pulseSupport "-DPULSEAUDIO"
  ++ optional resampleSupport "-DRESAMPLE"
  ++ optional sslSupport "-DUSE_SSL"
  ++ optional (stdenv.hostPlatform.isAarch32 or stdenv.hostPlatform.isAarch64) "-DRPI";

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin { LDADD = "-lportaudio -lpthread"; };

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin                   ${binName}
    install -Dm444 -t $out/share/man/man1 doc/squeezelite.1

    runHook postInstall
  '';

  passthru = {
    inherit (slimserver) tests;
    updateScript = ./update.sh;
  };

  meta = with lib; {
    description = "Lightweight headless squeezebox client emulator";
    homepage = "https://github.com/ralph-irving/squeezelite";
    license = with licenses; [ gpl3Plus ] ++ optional dsdSupport bsd2;
    mainProgram = binName;
    maintainers = with maintainers; [ adamcstephens ];
    platforms =
      if (audioBackend == "pulse") then platforms.linux else platforms.linux ++ platforms.darwin;
  };
}
