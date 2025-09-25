{ lib
, pkgs
, stdenv
, fetchurl
}:

let
    version = "0.4.12.1";
    pname = "helium";
    src = fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
        hash = "sha256-Za1erduSuuWvfrV/oggSz3ttj79SVV5g1CdXtlWfanU=";
    };

    appimageContents = pkgs.appimageTools.extractType1 { inherit pname src version; };

in

pkgs.appimageTools.wrapType1 {
    inherit pname src version;

    extraInstallCommands = ''
        # mv $out/bin/${pname}-${version} $out/bin/${pname}
        install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=${pname}'
        cp -r ${appimageContents}/usr/share/icons $out/share
        '';

    meta = {
        description = "Best privacy and unbiased ad-blocking by default";
        homepage = "https://helium.computer/";
        downloadPage = "https://github.com/imputnet/helium/releases";
        license = lib.licenses.gpl3Only;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        maintainers = with lib.maintainers; [ tscolari ];
        platforms = [ "x86_64-linux" ];
    };
}
