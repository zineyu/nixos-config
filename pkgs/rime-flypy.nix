{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rime-flypy";
  version = "20251211";

  src = fetchFromGitHub {
    owner = "cubercsl";
    repo = "rime-flypy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Lw54pNXUzsVv9OFp7c5Bf+pCCA0DWTslSTrN/raX9CM=";
  };

  # 不预编译码表，首次部署时由 Rime 在用户目录自动编译（与 rime-ice 一致）
  dontBuild = true;
  installPhase = ''
    runHook preInstall

    install -Dm644 flypy*.yaml -t $out/share/rime-data
    install -Dm644 flypy/*.yaml -t $out/share/rime-data/flypy
    install -Dm644 lua/*.lua -t $out/share/rime-data/lua

    runHook postInstall
  '';

  meta = {
    description = "小鹤音形 Rime 挂接 (flypy schema for Rime)";
    homepage = "https://github.com/cubercsl/rime-flypy";
    platforms = lib.platforms.all;
  };
})
