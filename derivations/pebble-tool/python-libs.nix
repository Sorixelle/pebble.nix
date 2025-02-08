{ stdenv, lib, fetchurl, fetchFromGitHub, makeWrapper, python2Packages, pyv8 }:

with python2Packages; rec {
  backports-ssl-match-hostname = buildPythonPackage rec {
    pname = "backports.ssl_match_hostname";
    version = "3.7.0.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-u4LmD5+/TAgOq9lXw58GQfD8JH2aFuMeJtWU2PQrn9I=";
    };
  };

  colorama = buildPythonPackage rec {
    pname = "colorama";
    version = "0.3.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-6yHyunGPvzV6/f329kGrOTkBx8qNnzft0L7kgG/6Jpw=";
    };
  };

  gevent = buildPythonPackage rec {
    pname = "gevent";
    version = "1.1.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "1smf3kvidpdiyi2c81alal74p2zm0clrm6xbyy6y1k9a3f2vkrbf";
    };

    doCheck = false;

    propagatedBuildInputs = [ greenlet ];
  };

  gevent-websocket = buildPythonPackage rec {
    pname = "gevent-websocket";
    version = "0.9.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "07rqwfpbv13mk6gg8mf0bmvcf6siyffjpgai1xd8ky7r801j4xb4";
    };

    propagatedBuildInputs = [ gevent greenlet ];
  };

  greenlet = buildPythonPackage rec {
    pname = "greenlet";
    version = "0.4.9";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-efm4u7scWZxmrtXmQ+i1O65pfK5G4Kz8TuRh30ipABI=";
    };
  };

  importlib-resources = buildPythonPackage rec {
    pname = "importlib_resources";
    version = "3.3.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-DtJQ29KRlH0aKY6J85r8xHfVpmJHcFAwNLcliGAbzAU=";
    };

    propagatedBuildInputs = [ contextlib2 pathlib2 setuptools_scm singledispatch typing zipp ];
  };

  libpebble2 = buildPythonPackage rec {
    pname = "libpebble2";
    version = "0.0.26";
    src = fetchPypi {
      inherit pname version;
      sha256 = "16n69xxma7k8mhl8birdwa0fsqvf902g08s80mjb477s4dcxrvaz";
    };

    doCheck = false;

    propagatedBuildInputs = [ enum34 pyserial six websocket_client ];
  };

  netaddr = buildPythonPackage rec {
    pname = "netaddr";
    version = "0.7.18";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-ofXJ/PdawlebmZXIQ9reMwCVQ8BPIY/3wAezyBaVvRk=";
    };
  };

  oauth2client = buildPythonPackage rec {
    pname = "oauth2client";
    version = "1.4.12";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-dKpsO+uQpKe5uNC8PNYNs01Fxe5hNhh7ueq+hbSZDl4=";
    };

    propagatedBuildInputs = [ httplib2 pyasn1-modules rsa six ];
  };

  peewee = buildPythonPackage rec {
    pname = "peewee";
    version = "2.4.7";
    src = fetchPypi {
      inherit pname version;
      sha256 = "1ga7xls24aixmciibjkh59pfv5na5dqsz843v9lsjci343xw9lca";
    };

    doCheck = false;
  };

  platformdirs = buildPythonPackage rec {
    pname = "platformdirs";
    version = "2.0.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-OwDQgSJ9kDe7vKUhpXh3lrXvUAD66h5D/Xbx1EsG/Po=";
    };
  };

  progressbar2 = buildPythonPackage rec {
    pname = "progressbar2";
    version = "2.7.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "155pf01ca6jrl9jyjr80fprnzjy33mxrnsdj1pjwiqzbab3zyrl3";
    };
  };

  pyasn1 = buildPythonPackage rec {
    pname = "pyasn1";
    version = "0.1.8";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-XTO+fKDsWZfXbSnqTDO2XADAIxQH//l1GZ1/QFMLg0c=";
    };
  };

  pyasn1-modules = buildPythonPackage rec {
    pname = "pyasn1-modules";
    version = "0.0.6";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-H0HT89pD6adp4jZJckNoqguIr8/R/m6fIQ0x0TMi/BU=";
    };

    propagatedBuildInputs = [ pyasn1 ];
  };

  pygeoip = buildPythonPackage rec {
    pname = "pygeoip";
    version = "0.3.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-8ixOAN3xIT4PrjbcYLRu58JaYzmUHsGpdVOQFMH5qW0=";
    };
  };

  pypkjs = if stdenv.isLinux then (buildPythonPackage rec {
    pname = "pypkjs";
    version = "1.1.1";
    src = fetchFromGitHub {
      owner = "pebble";
      repo = "pypkjs";
      rev = "8d0e53b8dd50dd0c016db8b22ea8b34734c82f1e";
      sha256 = "00xr6bfja34xk15m498jh5scjh0pqlniaqvgghxrmkhy8p02ncic";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ makeWrapper ];

    propagatedBuildInputs = [
      backports-ssl-match-hostname
      gevent
      gevent-websocket
      greenlet
      libpebble2
      netaddr
      peewee
      pygeoip
      pypng
      pyv8
      dateutil
      requests
      sh
      six
      websocket_client
      wsgiref
    ];

    patches = [ ./pypkjs-no-prebuilt-pyv8.patch ];

    prePatch = ''
      substituteInPlace requirements.txt --replace "==" ">="
    '';

    postFixup = ''
      wrapProgram $out/bin/pypkjs \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}
    '';
  }) else null;

  pypng = buildPythonPackage rec {
    pname = "pypng";
    version = "0.0.20";
    src = fetchPypi {
      inherit pname version;
      sha256 = "02qpa22ls41vwsrzw9r9qhj1nhq05p03hb5473pay6y980s86chh";
    };
  };

  requests = buildPythonPackage rec {
    pname = "requests";
    version = "2.7.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-OYo9ttYYmdJf1KBsbKEgUbDOFx1wXezX7VURUXtLuT0=";
    };
  };

  rsa = buildPythonPackage rec {
    pname = "rsa";
    version = "3.1.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-4rCwWTbCdrHt0uFSVVMjO2Zt+eKbXDuiI+7XOCd8gqA=";
    };

    propagatedBuildInputs = [ pyasn1 ];
  };

  sh = buildPythonPackage rec {
    pname = "sh";
    version = "1.09";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-89F04q0lw58ok1uuZyvlGqCDBj0xIkBc7rKj56gjnUU=";
    };
  };

  singledispatch = buildPythonPackage rec {
    pname = "singledispatch";
    version = "3.7.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-waTVwdoxDD/Y/M+41OHLffB2FI/V2FioGeN//+RPMJI=";
    };

    propagatedBuildInputs = [ six ];
  };

  sourcemap = buildPythonPackage rec {
    pname = "sourcemap";
    version = "0.2.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0z3q4y04vr4hkdnq0027xwwc92z3spznhap6pf3np8g7hl0sj05y";
    };
  };

  virtualenv = buildPythonPackage rec {
    pname = "virtualenv";
    version = "20.15.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-KIFxE0ov87+xovVPEZ53zRuBwp/BJlojVvPo0Ux9WMQ=";
    };

    propagatedBuildInputs = [ distlib filelock importlib-metadata importlib-resources platformdirs setuptools_scm ];
  };

  websocket_client = buildPythonPackage rec {
    pname = "websocket_client";
    version = "0.32.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-yzq5VhftIJjSRyPjrQTtBsT95mFAC5baoYWa+WW/4EA=";
    };

    propagatedBuildInputs = [ six ];
  };

  wsgiref = buildPythonPackage rec {
    pname = "wsgiref";
    version = "0.1.2";
    src = fetchPypi {
      inherit pname version;
      extension = "zip";
      sha256 = "0y8fyjmpq7vwwm4x732w97qbkw78rjwal5409k04cw4m03411rn7";
    };
  };
}
