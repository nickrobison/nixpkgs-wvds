{ buildPythonPackage
, lib
, isPy27
, six
, fetchPypi
, pyyaml
, mock
, contextlib2
, wrapt
, pytest
, pytest-httpbin
, yarl
, pythonOlder
, pythonAtLeast
}:

buildPythonPackage rec {
  pname = "vcrpy";
  version = "4.2.1";

  disabled = isPy27;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-fNPoGixJLgHCgfGAvMKoa1ILFz0rZWy12J2ZR1Qj4BM=";
  };

  nativeCheckInputs = [
    pytest
    pytest-httpbin
  ];

  propagatedBuildInputs = [
    pyyaml
    wrapt
    six
  ]
  ++ lib.optionals (pythonOlder "3.3") [ contextlib2 mock ]
  ++ lib.optionals (pythonAtLeast "3.4") [ yarl ];

  checkPhase = ''
    py.test --ignore=tests/integration -k "not TestVCRConnection"
  '';

  meta = with lib; {
    description = "Automatically mock your HTTP interactions to simplify and speed up testing";
    homepage = "https://github.com/kevin1024/vcrpy";
    license = licenses.mit;
  };
}

