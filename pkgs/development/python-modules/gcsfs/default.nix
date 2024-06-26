{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, pythonOlder
, google-auth
, google-auth-oauthlib
, google-cloud-storage
, requests
, decorator
, fsspec
, ujson
, aiohttp
, crcmod
, pytest-vcr
, vcrpy
}:

buildPythonPackage rec {
  pname = "gcsfs";
  version = "2022.01.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "fsspec";
    repo = pname;
    rev = version;
    hash = "sha256-wNeK1GdjK9GKaaECcFeBLjFf/h3MbLI5e4MX0UNoTqE=";
  };

  propagatedBuildInputs = [
    aiohttp
    crcmod
    decorator
    fsspec
    google-auth
    google-auth-oauthlib
    google-cloud-storage
    requests
    ujson
  ];

  checkInputs = [
    pytest-vcr
    pytestCheckHook
    vcrpy
  ];

  disabledTestPaths = [
    # Tests require a running Docker instance
    "gcsfs/tests/test_core.py"
    "gcsfs/tests/test_mapping.py"
    "gcsfs/tests/test_retry.py"
  ];

  pytestFlagsArray = [ "-x" ];

  pythonImportsCheck = [
    "gcsfs"
  ];

  meta = with lib; {
    description = "Convenient Filesystem interface over GCS";
    homepage = "https://github.com/fsspec/gcsfs";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nbren12 ];
  };
}
