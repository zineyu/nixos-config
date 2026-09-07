{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  cpio,
  gzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "squirrel";
  version = "1.1.2";

  src = fetchurl {
    url = "https://github.com/rime/squirrel/releases/download/${finalAttrs.version}/Squirrel-${finalAttrs.version}.pkg";
    hash = "sha256-YUdGATISk3Yj1burmQHpxD0eyTeqMjB9a2CSoF4wgoc=";
  };

  nativeBuildInputs = [
    xar
    cpio
    gzip
  ];

  unpackPhase = ''
    runHook preUnpack

    xar -xf "$src"
    gzip -dc Payload | cpio -idm

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Library/Input Methods"
    cp -R Squirrel.app "$out/Library/Input Methods/"

    runHook postInstall
  '';

  # Modifying the bundle after extraction would invalidate the upstream
  # Developer ID signature.
  dontFixup = true;

  meta = {
    description = "Rime input method for macOS";
    homepage = "https://github.com/rime/squirrel";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.darwin;
  };
})
