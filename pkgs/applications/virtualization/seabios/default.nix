{ lib, stdenv, fetchurl, acpica-tools, python3 }:

stdenv.mkDerivation rec {

  pname = "seabios";
  version = "1.15.0";

  src = fetchurl {
    url = "https://www.seabios.org/downloads/${pname}-${version}.tar.gz";
    sha256 = "sha256-YownF8mUMmtFMlFXPRBZ4qOhEtSqSIds4nyz8d4ZiPg=";
  };

  nativeBuildInputs = [ python3 ];

  buildInputs = [ acpica-tools ];

  strictDeps = true;

  hardeningDisable = [ "pic" "stackprotector" "fortify" ];

  configurePhase = ''
    # build SeaBIOS for CSM
    cat > .config << EOF
    CONFIG_CSM=y
    CONFIG_QEMU_HARDWARE=y
    CONFIG_PERMIT_UNALIGNED_PCIROM=y
    EOF

    make olddefconfig
  '';

  installPhase = ''
    mkdir $out
    cp out/Csm16.bin $out/Csm16.bin
  '';

  meta = with lib; {
    description = "Open source implementation of a 16bit X86 BIOS";
    longDescription = ''
      SeaBIOS is an open source implementation of a 16bit X86 BIOS.
      It can run in an emulator or it can run natively on X86 hardware with the use of coreboot.
      SeaBIOS is the default BIOS for QEMU and KVM.
    '';
    homepage = "http://www.seabios.org";
    license = licenses.lgpl3;
    maintainers = [ maintainers.tstrobel ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
