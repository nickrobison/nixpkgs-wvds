{ lib, pkgs, fetchFromGitHub, python3Packages, qt5, ... }:

python3Packages.buildPythonPackage rec {
  pname = "vitables";
  version = "3.0.2";

  src = fetchFromGitHub {
      inherit version;
      owner = "uvemas";
      repo = "ViTables";
      rev = "08709d4dcf9266c8ed6d8669a27a18637c27d35e";
      sha256 = "sha256-oxMlFP8NHM4TGlLtpRxX9joPeW3VNv3CKzKBTdw2e7U=";
  };

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  propagatedBuildInputs = [
    qt5.qtbase
  ] ++ (with python3Packages; [
    numexpr
    numpy
    pyqt5
    qtpy
    setuptools # To load plugins at runtime
    tables
  ]);

  checkInputs = with python3Packages; [
    pytestCheckHook
    sip
  ];

  disabledTestPaths = [
    # Requires GUI
    "tests/test_filenode.py"
    "tests/test_logger.py"
    "tests/test_utils.py"
    "tests/test_vtconfig.py"
    "tests/test_vtgui.py"
    "tests/test_samples.py"
  ];

  preFixup = ''
    wrapQtApp "$out/bin/vitables"
  '';

  meta = {
    description = ''
      A graphical tool for browsing and editing files in both PyTables and HDF5
      format
    '';
    homepage = "https://vitables.org";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ williamvds ];
  };
}
