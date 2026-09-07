{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dbx-desktop";
  version = "0.6.3";

  src = fetchurl {
    url = "https://github.com/t8y2/dbx/releases/download/v${finalAttrs.version}/DBX_${finalAttrs.version}_arm64.app.tar.gz";
    hash = "sha256-OWKANmW6OoMU5ZaawW0FJdZhjv7C5vmUlytM4NFcFN0=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R DBX.app "$out/Applications/"

    runHook postInstall
  '';

  # Keep the upstream Developer ID signature and notarization ticket intact.
  dontFixup = true;

  meta = {
    description = "Open-source database management tool";
    homepage = "https://github.com/t8y2/dbx";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "dbx";
  };
})
