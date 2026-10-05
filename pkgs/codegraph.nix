{
  lib,
  pkgs,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  writeShellApplication,
  curl,
  jq,
  git,
  nix,
}:

let
  version = "1.6.2";

  # Upstream publishes self-contained per-platform bundles (bundled Node.js
  # runtime + JS lib + native Rust kernel addon).
  platform =
    {
      aarch64-darwin = "darwin-arm64";
      x86_64-darwin = "darwin-x64";
      aarch64-linux = "linux-arm64";
      x86_64-linux = "linux-x64";
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "codegraph: unsupported system ${stdenvNoCC.hostPlatform.system}");

  hashes = {
    darwin-arm64 = "sha256-100b+0Bg22PsPCtyxOF/dsMZeK87rWrOQ3DRUBrAZi4=";
    darwin-x64 = "sha256-U9Gk0amvMdbOwRs0bfKueSCHCB4T9iP1g+J3g8Hn+bw=";
    linux-arm64 = "sha256-yMa+KSviHQDeomutiyjUNHMc9hL7jMR13BD1swOLW2Q=";
    linux-x64 = "sha256-7wr0FgkhKPsczHI3hgALft9KaXH+YErNCL+Wbk83uCg=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "codegraph";
  inherit version;

  src = fetchurl {
    url = "https://github.com/colbymchenry/codegraph/releases/download/v${finalAttrs.version}/codegraph-${platform}.tar.gz";
    hash = hashes.${platform};
  };

  # The bundled Node.js binary and kernel addon are prebuilt ELF on Linux.
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [
    pkgs.stdenv.cc.cc.lib
  ]
  ++ lib.optional pkgs.stdenv.isLinux pkgs.gccForLibs.libgcc;

  # Stripping would invalidate the code signature of the bundled runtime.
  dontStrip = true;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec" "$out/bin"
    cp -R "codegraph-${platform}" "$out/libexec/codegraph"
    ln -s "$out/libexec/codegraph/bin/codegraph" "$out/bin/codegraph"

    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-codegraph";
    runtimeInputs = [
      curl
      jq
      git
      nix
    ];
    # 多平台 hash 表无法由 nix-update 处理，脚本与包定义共置于 pkgs/
    text = builtins.readFile ./update-codegraph.sh;
  };

  meta = {
    description = "Pre-indexed code knowledge graph with surgical context for coding agents, 100% local";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "codegraph";
  };
})
