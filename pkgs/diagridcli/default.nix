{ lib
, stdenv
, fetchurl
}:

let
  version = "0.355.0";

  # Define platform-specific attributes
  platform = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      sha256 = "1wfyxpmhbgmq3ci2671w11pq0wxyilbhadrxkj77jahs453s2yah";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      sha256 = "0hbq19qyshxdambr490bdbn45q4bx865p3q4hx3ydjxx5qbg6mnm";
    };
    x86_64-darwin = {
      os = "darwin";
      arch = "amd64";
      sha256 = "129zh9ymbwh7aa32rkd1nwss91gzjiqb90varvz5wj74iybjrwv4";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      sha256 = "0mxk7p4qmaajkcy05z0pjzm118dbkpi3wawapbpbmhjbz99y0dg5";
    };
  };

  # Select the appropriate platform
  plat = platform.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  # GCP bucket path from the installation script
  gcpBucket = "bkt-p-cli-common-us-central1-95640";
  pathPrefix = "diagrid";

in
stdenv.mkDerivation {
  pname = "diagridcli";
  inherit version;

  src = fetchurl {
    url = "https://storage.googleapis.com/${gcpBucket}/v${version}/${pathPrefix}/diagrid_${plat.os}_${plat.arch}/diagrid_${plat.os}_${plat.arch}.tar.gz";
    sha256 = plat.sha256;
  };

  # No need for build phase, just unpack and install
  dontBuild = true;

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp diagrid $out/bin/
    chmod +x $out/bin/diagrid
  '';

  meta = with lib; {
    description = "Diagrid CLI tool";
    homepage = "https://diagrid.io";
    license = licenses.unfree;
    platforms = attrNames platform;
    maintainers = ["Tiago Scolari"];
  };
}
