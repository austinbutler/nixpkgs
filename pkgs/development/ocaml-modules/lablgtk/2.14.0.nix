{ stdenv, lib, fetchurl, ocaml, findlib, pkg-config, gtk2, libgnomecanvas, gtksourceview, camlp4 }:

if lib.versionAtLeast ocaml.version "4.04"
then throw "lablgtk-2.14 is not available for OCaml ${ocaml.version}" else

let
  pname = "lablgtk";
in

stdenv.mkDerivation (rec {
  name = "${pname}-${version}";
  version = "2.14.0";

  src = fetchurl {
    url = "https://forge.ocamlcore.org/frs/download.php/561/${name}.tar.gz";
    sha256 = "1fnh0amm7lwgyjdhmlqgsp62gwlar1140425yc1j6inwmgnsp0a9";
  };

  nativeBuildInputs = [ pkg-config ocaml findlib camlp4 ];
  buildInputs = [ gtk2 libgnomecanvas gtksourceview ];

  configureFlags = [ "--with-libdir=$(out)/lib/ocaml/${ocaml.version}/site-lib" ];
  buildFlags = [ "world" ];

  preInstall = ''
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib
    export OCAMLPATH=$out/lib/ocaml/${ocaml.version}/site-lib/:$OCAMLPATH
  '';

  meta = {
    branch = "2.14";
    platforms = ocaml.meta.platforms or [];
    maintainers = [
      lib.maintainers.maggesi
      lib.maintainers.roconnor
    ];
    homepage = "http://wwwfun.kurims.kyoto-u.ac.jp/soft/lsl/lablgtk.html";
    description = "LablGTK is is an Objective Caml interface to GTK";
    license = lib.licenses.lgpl21Plus;
  };
})
