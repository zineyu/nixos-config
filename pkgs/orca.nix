{ pkgs }:

let
  pname = "orca-ide";
  version = "1.4.158";

  src = pkgs.fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha512-uuurGnuXqxX3skapuK25Gi72+B1WIgCAlBm4kvH/YTtbjgUn3m6Io5Fr3sUkh2wjdgvkXaSP/XgHLRFyhJKfEw==";
  };

  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/orca-ide.desktop $out/share/applications/orca-ide.desktop
    substituteInPlace $out/share/applications/orca-ide.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=orca-ide'
    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Next-gen IDE for parallel agentic development";
    homepage = "https://github.com/stablyai/orca";
    license = pkgs.lib.licenses.mit;
    sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "orca-ide";
    platforms = [ "x86_64-linux" ];
  };
}
