{ lib
, buildPythonPackage
, fetchPypi
, numpy
, python
}:

buildPythonPackage rec {
  pname = "scikit-fmm";
  version = "2022.2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-0Pvm6Sn0OWOwEX7E4OhBwo2hxzQmGzV2Yvytkm14+ls=";
  };

  propagatedBuildInputs = [
    numpy
  ];

  checkPhase = ''
    mkdir testdir; cd testdir
    ${python.interpreter} -c "import skfmm, sys; sys.exit(skfmm.test())"
  '';

  meta = with lib; {
    description = "A Python extension module which implements the fast marching method";
    homepage = "https://github.com/scikit-fmm/scikit-fmm";
    license = licenses.bsd3;
    maintainers = with maintainers; [ costrouc ];
  };
}
