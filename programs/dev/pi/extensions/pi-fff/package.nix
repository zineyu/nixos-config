# pi-fff 有 npm 运行时依赖（@ff-labs/fff-node + 预编译的 ffi-rs / libfff_c），
# 源码目录不能直接链接进 ~/.pi/agent/extensions，只能构建出带 node_modules 的产物。
{
  lib,
  stdenv,
  buildNpmPackage,
  nodejs_22,
  autoPatchelfHook,
}:

buildNpmPackage {
  pname = "pi-fff";
  version = "0.9.0";

  src = ./.;

  # nix run nixpkgs#prefetch-npm-deps -- ./package-lock.json
  npmDepsHash = "sha256-ZVlnvtD+JlhMu0xZodwWNGwBhjUaA9lamxxQayhSlf0=";

  # peer 依赖由 pi 自己以虚拟模块提供；装上副本会让扩展解析到另一份 pi，丢掉键位配置。
  npmInstallFlags = [
    "--omit=dev"
    "--omit=peer"
  ];

  # 没有构建步骤：扩展是 jiti 直接加载的 TypeScript。
  dontNpmBuild = true;

  nodejs = nodejs_22;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  # 扩展目录本身：package.json 的 pi.extensions 指向 ./extensions/index.ts，
  # node_modules 与它同级，扩展内的 import 按目录向上解析得到。
  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R extensions node_modules package.json README.md CHANGELOG.md NOTICE.md "$out/"

    # --omit=peer 仍会留下空的 scope 目录（@earendil-works 等由 pi 自己提供）
    rmdir "$out"/node_modules/{@earendil-works,@esbuild,@isaacs,@pkgjs,@types} 2>/dev/null || true

    runHook postInstall
  '';

  meta = {
    description = "FFF-powered fuzzy file and content search extension for pi";
    homepage = "https://github.com/bacnh85/pi-extensions/tree/main/pi-fff";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
