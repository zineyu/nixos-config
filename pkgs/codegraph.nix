{
  lib,
  pkgs,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "1.6.0";

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
    darwin-arm64 = "sha256-HHMDNRLVX2e+BHF+gVMui+r3vm+4Ux9RoXn6IwZK1IA=";
    darwin-x64 = "sha256-y4aiti7mdrYqVr+EI2AOfYZ+dS5X8yPNyYwPYjbv2Qg=";
    linux-arm64 = "sha256-bck1p7jxph5oileLmOo0aA6y4217kdsHnWT0AR8aZo8=";
    linux-x64 = "sha256-3jOR957UJiLZN+bNW3ZCp+qLt9FHNgfoC4ebpz7yFrA=";
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
    pkgs.gccForLibs.libgcc
  ];

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
