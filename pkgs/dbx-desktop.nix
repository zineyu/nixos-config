# DBX Desktop：按平台分别打包。
# - Darwin：上游 release 的预编译 .app（保留签名与公证）
# - Linux ：从源码构建（Tauri 2 + Vue 3 + Rust），不再依赖上游 flake
{
  lib,
  stdenv,
  # ── 更新脚本依赖（passthru.updateScript）──
  writeShellApplication,
  curl,
  git,
  nix,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
  # ── 以下仅 Linux 源码构建使用（darwin 上不求值）──
  rustPlatform,
  fetchPnpmDeps,
  pnpmConfigHook,
  cargo-tauri,
  nodejs_22,
  pnpm,
  jq,
  perl,
  pkg-config,
  openssl,
  makeDesktopItem,
  copyDesktopItems,
  desktop-file-utils,
  imagemagick,
  wrapGAppsHook3,
  webkitgtk_4_1,
  gtk3,
  libappindicator-gtk3,
  libayatana-appindicator,
  librsvg,
  glib,
  glib-networking,
  dbus,
  at-spi2-atk,
  atkmm,
  cairo,
  gdk-pixbuf,
  harfbuzz,
  pango,
  xdotool,
  libx11,
  libxext,
  libxfixes,
}:

if stdenv.hostPlatform.isDarwin then
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "dbx-desktop";
    version = "0.6.35";

    src = fetchurl {
      url = "https://github.com/t8y2/dbx/releases/download/v${finalAttrs.version}/DBX_${finalAttrs.version}_arm64.app.tar.gz";
      hash = "sha256-2yKsObk+tfk56lvuQLmrIscBDNd+SXZyc/i/KSxR+P0=";
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
else
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "dbx-desktop";
    version = "0.6.35";

    # 上游 release tag 对应的 commit；version/rev/hash 由 pkgs/update-dbx-desktop.sh 自动更新
    src = fetchFromGitHub {
      owner = "t8y2";
      repo = "dbx";
      rev = "b1ee471fb3967d912fb7ab7af98fc140fbafa9ee";
      hash = "sha256-KB66SVaNwVk1jw8pcjD+JEsdpMANQtZwKNXysUTZ0wU=";
    };

    # fetcherVersion = 4 的 FOD 产物随 pnpm 大版本变化；本 hash 基于当前
    # nixpkgs 的 pnpm 12 计算，nixpkgs 升级 pnpm 大版本时需重新生成：
    #   nix build .#<pkg>.pnpmDeps 2>&1 | grep 'got:'
    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-0dtXmYIUjxlkXXpNFICPSxUCB1KXvousPi/adGEhaXM=";
    };

    cargoLock = {
      lockFile = "${finalAttrs.src}/Cargo.lock";
      # Cargo.lock 中的 git 依赖（每个唯一 checkout 只需一条 name-version 键）
      outputHashes = {
        "libsqlite3-hotbundle-1.510300.0" = "sha256-X/DWDF+myQOArYz7131v4y3z6pLO1fuJ202qTGhh78I=";
        "mysql_common-0.38.0" = "sha256-fw1rDLNh0BByLHjS8Cgc7KQxdj3N51HVMHXvRyETsas=";
        "mysql_async-0.37.0" = "sha256-zIMZitF9fU6wkeuGAv4LJv80bCWbvmUkgQ1/G5MjDv8=";
        "tokio-postgres-0.7.18" = "sha256-ybf+2siiLokb2iylFEhmLAFCFmbjSKF+zNdH93LggkM=";
      };
    };

    nativeBuildInputs = [
      nodejs_22
      pnpm
      pnpmConfigHook # 从 pnpmDeps 离线安装 node_modules
      cargo-tauri # tauri build 负责嵌入前端资源
      jq # preConfigure 删除 packageManager 字段
      perl
      pkg-config
      copyDesktopItems
      desktop-file-utils
      imagemagick # 生成各尺寸 hicolor 图标
      wrapGAppsHook3
    ];

    buildInputs = [
      openssl
      webkitgtk_4_1
      gtk3
      libappindicator-gtk3
      libayatana-appindicator # libayatana-appindicator3.so.1（运行时 dlopen）
      librsvg
      glib
      glib-networking
      dbus
      at-spi2-atk
      atkmm
      cairo
      gdk-pixbuf
      harfbuzz
      pango
      xdotool
      libx11
      libxext
      libxfixes
    ];

    env = {
      OPENSSL_DIR = "${openssl.dev}";
      OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
      OPENSSL_INCLUDE_DIR = "${lib.getDev openssl}/include";
      # Tauri 构建期读取，跳过 dev server 检查
      TAURI_SKIP_DEVSERVER_CHECK = "true";
    };

    PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" [
      openssl.dev
      webkitgtk_4_1.dev
      gtk3.dev
      glib.dev
      cairo.dev
      gdk-pixbuf.dev
      harfbuzz.dev
      pango.dev
      at-spi2-atk.dev
    ];

    desktopItem = makeDesktopItem {
      name = "dbx";
      type = "Application";
      exec = "dbx %u";
      icon = "dbx";
      desktopName = "DBX";
      genericName = "Database Management Tool";
      comment = "Open-source database management tool for 100+ databases";
      categories = [
        "Development"
        "Database"
      ];
      keywords = [
        "database"
        "sql"
        "client"
        "mysql"
        "postgresql"
        "mongodb"
        "redis"
      ];
      startupWMClass = "DBX";
      terminal = false;
      mimeTypes = [
        "application/sql"
        "x-scheme-handler/dbx"
      ];
    };

    preConfigure = ''
      export HOME=$TMPDIR
      # package.json 的 "packageManager" 字段会让 pnpm 通过 corepack 联网
      # 校验版本，沙箱内必须移除（用 jq 避免留下尾逗号）。
      if [ -f package.json ]; then
        jq 'del(.packageManager)' package.json > package.json.tmp \
          && mv package.json.tmp package.json
      fi
    '';

    buildPhase = ''
      runHook preBuild

      # 必须用 `tauri build --no-bundle`（内部执行 beforeBuildCommand = pnpm build），
      # 裸 cargo build 不会嵌入前端资源，运行时 WebView 无 UI 可加载。
      cargo tauri build --no-bundle

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp target/release/dbx $out/bin/dbx

      # hicolor 图标：覆盖常用尺寸，保证各桌面环境可用
      if [ -d src-tauri/icons ]; then
        for size in 32 128; do
          if [ -f "src-tauri/icons/''${size}x''${size}.png" ]; then
            mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
            cp "src-tauri/icons/''${size}x''${size}.png" \
              "$out/share/icons/hicolor/''${size}x''${size}/apps/dbx.png"
          fi
        done

        if [ -f "src-tauri/icons/128x128@2x.png" ]; then
          mkdir -p "$out/share/icons/hicolor/256x256/apps"
          cp "src-tauri/icons/128x128@2x.png" \
            "$out/share/icons/hicolor/256x256/apps/dbx.png"
        fi

        for size in 16 48 64; do
          mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
          if [ "$size" -le 32 ] && [ -f "src-tauri/icons/32x32.png" ]; then
            src="src-tauri/icons/32x32.png"
          elif [ -f "src-tauri/icons/128x128.png" ]; then
            src="src-tauri/icons/128x128.png"
          else
            continue
          fi
          magick "$src" -resize "''${size}x''${size}" \
            "$out/share/icons/hicolor/''${size}x''${size}/apps/dbx.png"
        done

        if [ -f "src-tauri/icons/icon.png" ]; then
          mkdir -p "$out/share/icons/hicolor/512x512/apps"
          cp "src-tauri/icons/icon.png" \
            "$out/share/icons/hicolor/512x512/apps/dbx.png"
        fi
      fi

      mkdir -p $out/share/applications
      cp ${finalAttrs.desktopItem}/share/applications/dbx.desktop \
        $out/share/applications/dbx.desktop
      desktop-file-validate $out/share/applications/dbx.desktop

      runHook postInstall
    '';

    # libappindicator-sys 运行时 dlopen 库文件，dlopen 不读 RPATH，
    # 需经 wrapGAppsHook3 的 gappsWrapperArgs 注入 LD_LIBRARY_PATH。
    preFixup = ''
      gappsWrapperArgs+=(
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            libappindicator-gtk3
            libayatana-appindicator
          ]
        }"
      )
    '';

    doCheck = false;

    # 多源 + FOD hash 重建逻辑超出 nix-update 能力，参考上游
    # .github/workflows/update-nix-pnpm-hash.yml 的模式由脚本维护。
    # 运行：nix run .#dbx-desktop.updateScript
    passthru.updateScript = writeShellApplication {
      name = "update-dbx-desktop";
      runtimeInputs = [
        curl
        jq
        git
        nix
      ];
      text = builtins.readFile ./update-dbx-desktop.sh;
    };

    meta = {
      description = "Open-source database management tool (Tauri 2)";
      homepage = "https://github.com/t8y2/dbx";
      license = lib.licenses.asl20;
      platforms = lib.platforms.linux;
      mainProgram = "dbx";
    };
  })
