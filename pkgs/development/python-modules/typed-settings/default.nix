{ lib
, buildPythonPackage
, pythonOlder
, fetchPypi
, setuptoolsBuildHook
, attrs
, cattrs
, toml
, pytestCheckHook
, click
, click-option-group
}:

buildPythonPackage rec {
  pname = "typed-settings";
  version = "2.0.0";
  format = "pyproject";
  disabled = pythonOlder "3.7";

  src = fetchPypi {
    pname = "typed_settings";
    inherit version;
    hash = "sha256-o0cPD/7/DS9aUtLDA1YhxKrxUDE7Elv4B7zlKVSsFJQ=";
  };

  nativeBuildInputs = [
    setuptoolsBuildHook
  ];

  propagatedBuildInputs = [
    attrs
    cattrs
    click-option-group
    toml
  ];

  pytestFlagsArray = [
    "tests"
  ];

  nativeCheckInputs = [
    click
    pytestCheckHook
  ];

  pythonImportsCheck = [ "typed_settings" ];

  meta = {
    description = "Typed settings based on attrs classes";
    homepage = "https://gitlab.com/sscherfke/typed-settings";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fridh ];
  };
}
