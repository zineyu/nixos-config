{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  cpio,
  gzip,
  writeShellApplication,
  nix-update,
  git,
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

    # The signature shipped in the 1.1.2 pkg is invalid after extraction, so
    # macOS refuses to register Squirrel as an input source. Re-sign the whole
    # bundle locally and fail the build if the resulting bundle is not valid.
    /usr/bin/codesign \
      --force \
      --deep \
      --sign - \
      "$out/Library/Input Methods/Squirrel.app"
    /usr/bin/codesign \
      --verify \
      --deep \
      --strict \
      "$out/Library/Input Methods/Squirrel.app"

    runHook postInstall
  '';

  # Preserve the valid ad-hoc signature produced above.
  dontFixup = true;

  passthru.updateScript = writeShellApplication {
    name = "update-squirrel";
    runtimeInputs = [
      nix-update
      git
    ];
    text = ''exec nix-update --flake squirrel "$@"'';
  };

  meta = {
    description = "Rime input method for macOS";
    homepage = "https://github.com/rime/squirrel";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    # 不声明 platforms：installPhase 依赖 /usr/bin/codesign，实际只能 darwin 构建；
    # 但需保证 Linux 上可求值，nix-update（CI runner 为 ubuntu）才能更新 src hash
  };
})
