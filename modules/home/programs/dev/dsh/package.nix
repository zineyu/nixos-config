{
  lib,
  pkgs,
}:

let
  version = "0.1.0-rc.6";

  tarball = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${version}.tgz";
    hash = "sha256-G4qaCtPH/q7OR5JuC9N8oVHHzPqZeVOvpf0BJheE6tw=";
  };

  # 发布到 npm 的 tarball 只有 package.json/lib/config，没有 lockfile。
  # 这里把本地生成的 package-lock.json 注入进去，供 buildNpmPackage 依赖缓存使用。
  src = pkgs.runCommand "dsh-src" { nativeBuildInputs = [ pkgs.gnutar ]; } ''
    mkdir -p "$out"
    tar -xzf ${tarball} -C "$out" --strip-components=1
    cp ${./package-lock.json} "$out/package-lock.json"
  '';
in
pkgs.buildNpmPackage {
  pname = "dsh";
  inherit version src;

  npmDepsHash = "sha256-9Cx3OhIK3xuyd6o+HZhAs+2eGsIrys8fNdtRePd4GnQ=";
  # 包体已打包（bundled），无 build 脚本；`npm run build` 不存在。
  dontNpmBuild = true;
  # `npm rebuild` 会触发 node-pty 等原生依赖的 node-gyp 构建。
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.python3
    pkgs.gnumake
    pkgs.gcc
    pkgs.pkg-config
  ];

  # cordis-plugin-hmr 要求 node 以 --expose-internals 启动
  # （cordis-plugin-loader 检查 process.execArgv，NODE_OPTIONS 不生效），
  # 因此用 makeWrapper 包装 node 并前置该 flag。
  postFixup = ''
    rm $out/bin/dsh
    makeWrapper ${lib.getExe pkgs.nodejs} $out/bin/dsh \
      --add-flags "--expose-internals $out/lib/node_modules/@deepseek-ai/dsh/lib/bin.js"
  '';

  meta = {
    description = "DeepSeek Harness agent harness CLI (dsh)";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    mainProgram = "dsh";
  };
}
