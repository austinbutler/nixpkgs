{ lib, stdenv, fetchurl, pkg-config, pure, freeglut, libGLU, libGL, xlibsWrapper }:

stdenv.mkDerivation rec {
  pname = "pure-gl";
  version = "0.9";

  src = fetchurl {
    url = "https://bitbucket.org/purelang/pure-lang/downloads/pure-gl-${version}.tar.gz";
    sha256 = "edd594222f89ae372067eda6679a37488986b9739b5b79b4a25ac48255d31bba";
  };

  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ pure freeglut libGLU libGL xlibsWrapper ];
  makeFlags = [
    "libdir=${placeholder "out"}/lib"
    "prefix=${placeholder "out"}/"
  ];
  setupHook = ../generic-setup-hook.sh;

  meta = {
    description = "Fairly complete Pure bindings for the OpenGL graphics library, which allow you to do 2D and 3D graphics programming with Pure";
    homepage = "http://puredocs.bitbucket.org/pure-gl.html";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ asppsa ];
  };
}
