{
  lib,
  stdenv,
  file,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  bash,
  gawk,
  coreutils,
  xorg,
  gnugrep,
  gnused,
  uni2ascii,
  dbus,
  libkrb5,
  linux-pam,
  nx-libs,
  libGL,
  perl,
  jsoncpp,
  pulseaudio,
  libpulseaudio,
}: let
  versionMajor = "7.8";
  versionMinor = "2";
  versionBuild_x86_64 = "1";
  versionBuild_i686 = "1";
in
  stdenv.mkDerivation rec {
    pname = "nomachine";
    version = "${versionMajor}.${versionMinor}";

    src =
      if stdenv.hostPlatform.system == "x86_64-linux"
      then
        fetchurl {
          url = "https://download.nomachine.com/download/${versionMajor}/Linux/nomachine_${version}_${versionBuild_x86_64}_x86_64.tar.gz";
          sha256 = "sha256-DZtEt3zBhkvANlCvDwhFY3X+46zzhmKrm6zKPA99w7o=";
        }
      else if stdenv.hostPlatform.system == "i686-linux"
      then
        fetchurl {
          url = "https://download.nomachine.com/download/${versionMajor}/Linux/nomachine_${version}_${versionBuild_i686}_i686.tar.gz";
          sha256 = "sha256-T38lOp4R1CoU6TZYeYcZkeZUi9l613LxLUZaEScOcHg=";
        }
      else throw "NoMachine client is not supported on ${stdenv.hostPlatform.system}";

    # nxusb-legacy is only needed for kernel versions < 3
    postUnpack = ''
      mv $(find . -type f -name nxserver.tar.gz) .
      mv $(find . -type f -name nxnode.tar.gz) .
      mv $(find . -type f -name nxclient.tar.gz) .
      mv $(find . -type f -name nxplayer.tar.gz) .
      rm -r NX/
      tar xf nxserver.tar.gz
      tar xf nxnode.tar.gz
      tar xf nxclient.tar.gz
      tar xf nxplayer.tar.gz
      rm $(find . -maxdepth 1 -type f)
      rm -r NX/share/src/nxusb-legacy
      rm NX/bin/nxusbd-legacy NX/lib/libnxusb-legacy.so
    '';

    nativeBuildInputs = [uni2ascii coreutils file makeWrapper autoPatchelfHook];
    buildInputs = [libGL dbus libkrb5 linux-pam perl nx-libs jsoncpp libpulseaudio];

    installPhase = ''
      rm bin/nxserver bin/nxclient bin/nxplayer

      mkdir -p $out/NX
      cp -r etc scripts bin lib share $out/NX/

      ln -s $out/NX/bin $out/bin

      ### NXSERVER SETUP BEGIN
      ln -s $out/bin/nxserver $out/NX/etc/
      mkdir -p $out/NX/scripts/etc/server/localhost
      ln -s /etc/NX/server/localhost/server.cfg $out/NX/scripts/etc/server/localhost/server.cfg
      ln -s /etc/NX/server/localhost/node.cfg $out/NX/scripts/etc/server/localhost/node.cfg

      mv $out/NX/etc/usb.db.sample            $out/NX/etc/usb.db

      # make sure we can symlink a writable etc to /var
      mv $out/NX/etc $out/NX/etc.static

      # nxserver depends on the systemd service to create these paths
      mkdir $out/NX/var
      ln -s /run/nxserver/run           $out/NX/var/run
      ln -s /run/nxserver/tmp           $out/NX/var/tmp
      ln -s /var/lib/nxserver/db        $out/NX/var/db
      ln -s /var/log/nxserver           $out/NX/var/log
      ln -s /etc/NX                     $out/NX/etc

      # Everything is hardcoded
      for i in $out/NX/scripts/restricted/*.sh; do
        substituteInPlace "$i" --replace /bin/echo ${coreutils}/bin/echo
        substituteInPlace "$i" --replace /bin/ls ${coreutils}/bin/ls
        substituteInPlace "$i" --replace /bin/cat ${coreutils}/bin/cat
        substituteInPlace "$i" --replace /bin/kill ${coreutils}/bin/kill
        substituteInPlace "$i" --replace /bin/cut ${coreutils}/bin/cut
        substituteInPlace "$i" --replace /bin/mkdir ${coreutils}/bin/mkdir
        substituteInPlace "$i" --replace /bin/rm ${coreutils}/bin/rm
        substituteInPlace "$i" --replace /bin/cp ${coreutils}/bin/cp
        substituteInPlace "$i" --replace /bin/mv ${coreutils}/bin/mv
        substituteInPlace "$i" --replace /bin/chmod ${coreutils}/bin/chmod
        substituteInPlace "$i" --replace /bin/chown ${coreutils}/bin/chown
        substituteInPlace "$i" --replace /bin/id ${coreutils}/bin/id
        substituteInPlace "$i" --replace /bin/pwd ${coreutils}/bin/pwd
        substituteInPlace "$i" --replace /bin/sleep ${coreutils}/bin/sleep
        substituteInPlace "$i" --replace /usr/bin/whoami ${coreutils}/bin/whoami
        substituteInPlace "$i" --replace /usr/bin/expr ${coreutils}/bin/expr
        substituteInPlace "$i" --replace /bin/awk ${gawk}/bin/awk
        substituteInPlace "$i" --replace /bin/grep ${gnugrep}/bin/grep
        substituteInPlace "$i" --replace /bin/sed ${gnused}/bin/sed
        substituteInPlace "$i" --replace /bin/su /run/wrappers/bin/su
        substituteInPlace "$i" --replace /bin/bash ${bash}/bin/bash
      done

      # Because a lot of scripts in scripts/00restricted need to have u+s set
      # the complete scripts folder will live in /var/lib/nxserver
      # symlinking scripts/restricted will cause nxexec to fail as a symlink
      # is "not a folder" (security checks)
      mv $out/NX/scripts $out/NX/scripts.static
      ln -s /run/nxserver/scripts $out/NX/scripts

      # we need u+s which can only be done through wrappers
      mv $out/NX/bin/nxexec $out/NX/bin/nxexec.orig
      ln -s /run/wrappers/bin/nxexec $out/NX/bin/nxexec

      ### NXCLIENT SETUP BEGIN
      for i in share/icons/*; do
        if [[ -d "$i" ]]; then
          mkdir -p "$out/share/icons/hicolor/$(basename $i)/apps"
          cp "$i"/* "$out/share/icons/hicolor/$(basename $i)/apps/"
        fi
      done

      mkdir $out/share/applications
      cp share/applnk/player/xdg/*.desktop $out/share/applications/
      cp share/applnk/client/xdg-mime/*.desktop $out/share/applications/

      mkdir -p $out/share/mime/packages
      cp share/applnk/client/xdg-mime/*.xml $out/share/mime/packages/

      for i in $out/share/applications/*.desktop; do
        substituteInPlace "$i" --replace /usr/NX/bin $out/bin
      done
    '';

    postFixup = ''
      # NXSERVER BEGIN
      makeWrapper $out/NX/scripts.static/etc/nxserver $out/bin/nxserver \
        --prefix PATH : ${lib.makeBinPath [coreutils gawk]}
      makeWrapper $out/NX/scripts.static/etc/nxnode $out/bin/nxnode \
        --prefix PATH : ${lib.makeBinPath [coreutils gawk]}

      for i in nxserver nxnode; do
        sed 's|-e "/bin/id"|1|g' -i "$out/NX/scripts.static/etc/$i"
        sed 's|_ID="/bin/id"|_ID="id"|g' -i "$out/NX/scripts.static/etc/$i"
      done

      # helper function to create an escaped hex string (\\xfe)
      function tohexstr() {
        uni2ascii -Bspqa 7 <<< "$1" | tr '[:upper:]' '[:lower:]'
      }

      # Using the helper function defined above, replace
      # "/usr/bin/" with "/run/current-system/sw/bin/" in obfuscated
      # perl files.
      for i in nxnode/Common/NXShellCommands.pm \
               nxserver/Common/NXShellCommands.pm \
               nxnode/NXCommands.pm \
               nxserver/NXTools.pm; do
        substituteInPlace "$out/NX/lib/perl/$i" \
                          --replace "$(tohexstr '/usr/bin/')" \
                                    "$(tohexstr '/run/current-system/sw/bin/')"
      done

      patchelf --add-needed libpam.so.0 --add-needed libkrb5.so.3 $out/NX/bin/nxexec.orig
      patchelf --add-needed libdbus-1.so.3 $out/NX/bin/nxserver.bin

      # NXCLIENT BEGIN
      makeWrapper $out/bin/nxplayer.bin $out/bin/nxplayer --set NX_SYSTEM $out/NX
      makeWrapper $out/bin/nxclient.bin $out/bin/nxclient --set NX_SYSTEM $out/NX

      # libnxcau.so needs libpulse.so.0 for audio to work, but doesn't
      # have a DT_NEEDED entry for it.
      patchelf --add-needed libpulse.so.0 $out/NX/lib/libnxcau.so
    '';

    dontBuild = true;
    dontStrip = true;

    meta = with lib; {
      description = "NoMachine remote desktop";
      homepage = "https://www.nomachine.com/";
      license = {
        fullName = "NoMachine 7 End-User License Agreement";
        url = "https://www.nomachine.com/licensing-7";
        free = false;
      };
      maintainers = with maintainers; [talyz rytec-nl];
      platforms = ["x86_64-linux" "i686-linux"];
    };
  }
