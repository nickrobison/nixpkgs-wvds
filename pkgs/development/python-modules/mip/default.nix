{ lib
, buildPythonPackage
, cffi
, dos2unix
, fetchPypi
, matplotlib
, networkx
, numpy
, pytestCheckHook
, pythonOlder
, gurobi
, gurobipy
# Enable support for the commercial Gurobi solver (requires a license)
, gurobiSupport ? false
# If Gurobi has already been installed outside of the Nix store, specify its
# installation directory here
, gurobiHome ? null
}:

buildPythonPackage rec {
  pname = "mip";
  version = "1.14.2";

  disabled = pythonOlder "3.7";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-wr4gXSh456heG5nsaEi2yo7LMre2Nd6QbTm0dcDCX1k=";
  };

  nativeCheckInputs = [ matplotlib networkx numpy pytestCheckHook ];
  nativeBuildInputs = [ dos2unix ];
  propagatedBuildInputs = [
    cffi
  ] ++ lib.optionals gurobiSupport ([
    gurobipy
  ] ++ lib.optional (builtins.isNull gurobiHome) gurobi);

  # Source files have CRLF terminators, which make patch error out when supplied
  # with diffs made on *nix machines
  prePatch = ''
    find . -type f -exec ${dos2unix}/bin/dos2unix {} \;
  '';

  patches = [
    # Some tests try to be smart and dynamically construct a path to their test
    # inputs. Unfortunately, since the test phase is run after installation,
    # those paths point to the Nix store, which no longer contains the test
    # data. This patch hardcodes the data path to point to the source directory.
    ./test-data-path.patch
  ];

  postPatch = ''
    # Allow cffi versions with a different patch level to be used
    substituteInPlace pyproject.toml --replace "cffi==1.15.0" "cffi==1.15.*"
  '';

  # Make MIP use the Gurobi solver, if configured to do so
  makeWrapperArgs = lib.optional gurobiSupport
    "--set GUROBI_HOME ${if builtins.isNull gurobiHome then gurobi.outPath else gurobiHome}";

  # Tests that rely on Gurobi are activated only when Gurobi support is enabled
  disabledTests = lib.optional (!gurobiSupport) "gurobi";

  passthru.optional-dependencies = {
    inherit gurobipy numpy;
  };

  meta = with lib; {
    homepage = "http://python-mip.com/";
    description = "A collection of Python tools for the modeling and solution of Mixed-Integer Linear programs (MIPs)";
    downloadPage = "https://github.com/coin-or/python-mip/releases";
    changelog = "https://github.com/coin-or/python-mip/releases/tag/${version}";
    license = licenses.epl20;
    maintainers = with maintainers; [ nessdoor ];
  };
}
