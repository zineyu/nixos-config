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
  pnpm_10,
  mold,
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
    version = "0.6.65-beta.20261103.1";
    # 上游 release tag 与资产名中的版本可能不同（tag v0.6.65 对应资产
    # DBX_0.6.65-beta.20261103.1_arm64.app.tar.gz），故单独声明 tag。
    releaseTag = "0.6.65";

    src = fetchurl {
      url = "https://github.com/t8y2/dbx/releases/download/v${finalAttrs.releaseTag}/DBX_${finalAttrs.version}_arm64.app.tar.gz";
      hash = "sha256-ELzKyBkMOC+v2rJiwzaCrigQYtoHb0JJxMydHuHqb3s=";
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
    version = "0.6.65-beta.20261103.1";

    # 上游 release tag 对应的 commit；version/rev/hash 由本目录 update.sh 自动更新
    src = fetchFromGitHub {
      owner = "t8y2";
      repo = "dbx";
      rev = "8e080e9717c08c7e6a3c08ae1fbf34f1847ff034";
      hash = "sha256-e8o79zQhM+Fyb1cfauYb9BMaJeaNu+IEJIwhLkrjm/M=";
    };

    # 上游 packageManager 为 pnpm@10.34.x，其 package.json 里的 pnpm.overrides
    # 与 pnpm-lock.yaml 的 overrides 段匹配；pnpm 11+ 只读 pnpm-workspace.yaml
    # 的 overrides，会报 ERR_PNPM_LOCKFILE_CONFIG_MISMATCH，故显式钉 pnpm_10。
    # fetcherVersion = 4 的 FOD 产物随 pnpm 大版本变化；本 hash 基于 pnpm_10 计算，
    # 换 pnpm 大版本或 nixpkgs 升级 sqlite 时需重新生成
    # （本目录 update.sh 会在版本未变但构建失败时自动重建）：
    #   nix build .#dbx-desktop.pnpmDeps 2>&1 | grep 'got:'
    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 4;
      hash = "sha256-lBkJNxk39G07brqQs2+W+jnoKd7Gi511VpxBq0A95kE=";
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
      pnpm_10
      pnpmConfigHook # 从 pnpmDeps 离线安装 node_modules
      cargo-tauri # tauri build 负责嵌入前端资源
      jq # preConfigure 删除 packageManager 字段
      perl
      pkg-config
      mold # 比默认 bfd 快数倍的链接器（见下方 RUSTFLAGS）
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

      # 上游 release profile 是 `lto = true` + `codegen-units = 1`（全程序 fat LTO），
      # 实测编译/链接阶段只吃满一个核，是构建时长的绝对大头。这里用 cargo 的
      # 环境变量覆盖而不是改 Cargo.toml（源码不可变）：thin LTO 可并行，运行性能
      # 与 fat LTO 差异在个位数百分比，对 DB 客户端无感。
      # 想完全对齐上游产物（体积最小）时删掉这两行即可。
      CARGO_PROFILE_RELEASE_LTO = "thin";
      CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "16";
    };

    # mold 经 gcc 包装器以 -fuse-ld=mold 使用；rustPlatform 支持列表形式 RUSTFLAGS。
    RUSTFLAGS = [
      "-C"
      "link-arg=-fuse-ld=mold"
    ];

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
      text = builtins.readFile ./update.sh;
    };

    meta = {
      description = "Open-source database management tool (Tauri 2)";
      homepage = "https://github.com/t8y2/dbx";
      license = lib.licenses.asl20;
      platforms = lib.platforms.linux;
      mainProgram = "dbx";
    };
  })
