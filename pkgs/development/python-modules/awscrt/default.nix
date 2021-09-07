{ lib, buildPythonPackage, fetchPypi, cmake, perl, stdenv, gcc10, darwin, nix-gitignore }:

buildPythonPackage rec {
  pname = "awscrt";
  version = "0.11.24";

  buildInputs = lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation Security ]);

  # Required to suppress -Werror
  # https://github.com/NixOS/nixpkgs/issues/39687
  hardeningDisable = lib.optional stdenv.cc.isClang "strictoverflow";

  nativeBuildInputs = [ cmake ] ++
    # gcc <10 is not supported, LLVM on darwin is just fine
    lib.optionals (!stdenv.isDarwin && stdenv.isAarch64) [ gcc10 perl ];

  dontUseCmakeConfigure = true;

  # Unable to import test module
  # https://github.com/awslabs/aws-crt-python/issues/281
  doCheck = false;

  #src = nix-gitignore.gitignoreSource [".venv"] /Users/abutler/Documents/aws-crt-python;
  src = fetchPypi {
    inherit pname version;
    sha256 = "b8aa68bca404bf0085be0570eff5b542d01f7e8e3c0f9b0859abfe5e070162ff";
  };

  postPatch = ''
    cat /Users/abutler/Documents/aws-crt-python/awscrt/io.py > awscrt/io.py
    #substituteInPlace awscrt/io.py \
    #  --replace "self.shutdown_event = shutdown_event" "self.shutdown_event = shutdown_event\nprint('CREATING BINDING')"
  '';

  meta = with lib; {
    homepage = "https://github.com/awslabs/aws-crt-python";
    description = "Python bindings for the AWS Common Runtime";
    license = licenses.asl20;
    maintainers = with maintainers; [ davegallant ];
  };
}
