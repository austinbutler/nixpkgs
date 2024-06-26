{ lib
, buildPythonPackage
, fetchFromGitLab
, future
, ifaddr
, pytestCheckHook
, pythonOlder
}:

buildPythonPackage rec {
  pname = "yeelight";
  version = "0.7.9";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitLab {
    owner = "stavros";
    repo = "python-yeelight";
    rev = "v${version}";
    sha256 = "sha256-8N+HOhUX3BXecS/kaAfLoge+NYzKLKPyoTthu+useJA=";
  };

  propagatedBuildInputs = [
    future
    ifaddr
  ];

  checkInputs = [
    pytestCheckHook
  ];

  pytestFlagsArray = [
    "yeelight/tests.py"
  ];

  pythonImportsCheck = [
    "yeelight"
  ];

  meta = with lib; {
    description = "Python library for controlling YeeLight RGB bulbs";
    homepage = "https://gitlab.com/stavros/python-yeelight/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ nyanloutre ];
  };
}
