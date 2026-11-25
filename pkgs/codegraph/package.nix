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
  version = "1.6.4";

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
    darwin-arm64 = "sha256-2qkUJzLu/tW20YeqgqLKnE8+vOENOU+3nPbEWzZ2GMw=";
    darwin-x64 = "sha256-8WpW5d83WhZS7XF86L0PtGZyXmS1KlPcAHDW6MKBNjw=";
    linux-arm64 = "sha256-6c0r67Kc5qqDtEiXVfdqNvPiJli+rF6+8CO4dL58/OE=";
    linux-x64 = "sha256-hHfzhBy6asjEWEfULrUlTx8tf7wwRbrzM+HL6SJnAi0=";
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
  ++ lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.gccForLibs.libgcc;

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
    # 多平台 hash 表无法由 nix-update 处理，脚本与包定义共置于本目录
    text = builtins.readFile ./update.sh;
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
