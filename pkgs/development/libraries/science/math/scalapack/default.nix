{ lib, stdenv, fetchFromGitHub, cmake, openssh
, mpi, blas, lapack
} :

assert blas.isILP64 == lapack.isILP64;

stdenv.mkDerivation rec {
  pname = "scalapack";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "Reference-ScaLAPACK";
    repo = pname;
    rev = "v${version}";
    sha256 = "0hiap5i9ik6xpvl721n2slanlqygagc1pg2bcjb27ans6balhsfh";
  };

  passthru = { inherit (blas) isILP64; };

  # Required to activate ILP64.
  # See https://github.com/Reference-ScaLAPACK/scalapack/pull/19
  postPatch = lib.optionalString passthru.isILP64 ''
    sed -i 's/INTSZ = 4/INTSZ = 8/g'   TESTING/EIG/* TESTING/LIN/*
    sed -i 's/INTGSZ = 4/INTGSZ = 8/g' TESTING/EIG/* TESTING/LIN/*

    # These tests are not adapted to ILP64
    sed -i '/xssep/d;/xsgsep/d;/xssyevr/d' TESTING/CMakeLists.txt
  '';

  nativeBuildInputs = [ cmake ];
  checkInputs = [ openssh ];
  buildInputs = [ blas lapack ];
  propagatedBuildInputs = [ mpi ];

  doCheck = true;

  preConfigure = ''
    cmakeFlagsArray+=(
      -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF
      -DLAPACK_LIBRARIES="-llapack"
      -DBLAS_LIBRARIES="-lblas"
      -DCMAKE_Fortran_COMPILER=${mpi}/bin/mpif90
      ${lib.optionalString passthru.isILP64 ''
        -DCMAKE_Fortran_FLAGS="-fdefault-integer-8"
        -DCMAKE_C_FLAGS="-DInt=long"
      ''}
      )
  '';

  # Increase individual test timeout from 1500s to 10000s because hydra's builds
  # sometimes fail due to this
  checkFlagsArray = [ "ARGS=--timeout 10000" ];

  preCheck = ''
    # make sure the test starts even if we have less than 4 cores
    export OMPI_MCA_rmaps_base_oversubscribe=1

    # Fix to make mpich run in a sandbox
    export HYDRA_IFACE=lo

    # Run single threaded
    export OMP_NUM_THREADS=1

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}`pwd`/lib
  '';

  meta = with lib; {
    homepage = "http://www.netlib.org/scalapack/";
    description = "Library of high-performance linear algebra routines for parallel distributed memory machines";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ costrouc markuskowa ];
  };
}
