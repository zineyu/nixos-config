# EasyCLIProxyAPI — CLIProxyAPI 的桌面管理 GUI（官方 Linux portable tarball 打包）。
# 上游：https://github.com/router-for-me/EasyCLIProxyAPI
#
# 打包说明：
# - 该 Tauri 应用在 Linux 下把 CPA 内核安装到“可执行文件所在目录”的 cpa-core/
#   （见上游 src-tauri/src/core_runtime.rs::core_base_dir），且支持应用内自更新
#   （portable-app.json autoUpdate: true），因此要求可执行目录可写。Nix store 只读，
#   故启动脚本在首次运行（或 store 路径变化）时把应用同步到
#   ~/.local/share/easycliproxyapi 并从该处启动。
# - 同步采用覆盖式拷贝，保留用户已有的 cpa-core 解压产物与配置；
#   应用内自更新的结果会在下次 nix 配置更新后被重置为商店版本。
# - 内置 CPA 内核是动态链接的预编译二进制，启动脚本在同步时预解压并用 patchelf
#   将其解释器修正为 store 中的 glibc（同时兜底应用自更新下载的新内核）。
# 更新方式：上游发布新版后，更新 version 并重新计算 src.hash / icon.hash
#   （将 hash 置为 lib.fakeHash 后构建，取报错中的 "got: sha256-..." 值）。
{ pkgs, lib }:

let
  pname = "easycliproxyapi";
  version = "0.2.25";

  src = pkgs.fetchurl {
    url = "https://github.com/router-for-me/EasyCLIProxyAPI/releases/download/v${version}/EasyCLIProxyAPI-v${version}-Linux-amd64.tar.gz";
    hash = "sha256-2aGVwFP0tGIBSRBpQVVJfN5aVPt4de3v563L1DQSZQA=";
  };

  icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/router-for-me/EasyCLIProxyAPI/v${version}/src-tauri/icons/icon.png";
    hash = "sha256-k++FGcabudip3asHFWqDKhH+/YloDMXbY4zTStzkTJ0=";
  };
in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  sourceRoot = "EasyCLIProxyAPI-v${version}-Linux-amd64";

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
  ];

  # Tauri (webkit2gtk 4.1) 运行时库
  buildInputs = with pkgs; [
    cairo
    dbus
    gdk-pixbuf
    glib
    gtk3
    libsoup_3
    stdenv.cc.cc.lib
    webkitgtk_4_1
  ];

  installPhase =
    let
      # 启动脚本：把商店中的应用同步到可写的用户目录后再启动
      launcher = pkgs.writeShellScript "easycliproxyapi-launcher" ''
        store_app="@out@/lib/easycliproxyapi"
        app_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/easycliproxyapi"
        marker="$app_dir/.nix-store-path"
        core_dir="$app_dir/cpa-core"
        core_bin="$core_dir/cli-proxy-api"

        if [ ! -x "$app_dir/EasyCLIProxyAPI" ] || [ "$(cat "$marker" 2>/dev/null || true)" != "$store_app" ]; then
          mkdir -p "$app_dir"
          # 覆盖式同步：保留用户已有的 cpa-core 解压产物与配置，仅更新商店提供的文件
          cp -rT "$store_app" "$app_dir"
          # 商店文件为只读，放开写权限以支持内核安装/升级与应用自更新
          chmod -R u+rwX "$app_dir"
          # 预解压内置 CPA 内核，避免应用首次启动时解压出未修正解释器的二进制
          tarball=$(ls "$core_dir"/CLIProxyAPI_*_linux_amd64.tar.gz 2>/dev/null | head -n 1)
          if [ -n "$tarball" ]; then
            tar xzf "$tarball" -C "$core_dir"
            chmod -R u+rwX "$core_dir"
          fi
          echo "$store_app" > "$marker"
        fi

        # CPA 内核为官方预编译动态链接二进制，解释器指向 /lib64/ld-linux-x86-64.so.2，
        # 在 NixOS 上需修正为 store 中的 glibc 解释器（同时兜底应用自更新的新内核）
        if [ -f "$core_bin" ] && [ "$(patchelf --print-interpreter "$core_bin" 2>/dev/null || true)" = "/lib64/ld-linux-x86-64.so.2" ]; then
          patchelf --set-interpreter "${pkgs.glibc}/lib/ld-linux-x86-64.so.2" "$core_bin" || true
        fi

        exec "$app_dir/EasyCLIProxyAPI" "$@"
      '';
    in
    ''
      runHook preInstall

      mkdir -p $out/lib/easycliproxyapi $out/libexec $out/bin $out/share/applications $out/share/pixmaps
      cp -r . $out/lib/easycliproxyapi/
      rm -f $out/lib/easycliproxyapi/.nix-store-path

      # launcher 需与最终 wrapper 路径分离，避免 wrapper 原地覆盖后自我 exec 死循环
      substitute ${launcher} $out/libexec/easycliproxyapi --replace-fail "@out@" "$out"
      chmod +x $out/libexec/easycliproxyapi

      makeWrapper $out/libexec/easycliproxyapi $out/bin/easycliproxyapi \
        --prefix PATH : ${
          lib.makeBinPath (
            with pkgs;
            [
              gnutar
              gzip
              patchelf
              xdg-utils
            ]
          )
        } \
        --prefix GIO_EXTRA_MODULES : ${pkgs.glib-networking}/lib/gio/modules \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${
          lib.makeSearchPath "lib/gstreamer-1.0" (
            with pkgs.gst_all_1;
            [
              gst-plugins-base
              gst-plugins-good
              gst-plugins-bad
            ]
          )
        } \
        --prefix XDG_DATA_DIRS : "${
          lib.concatStringsSep ":" (
            map (p: lib.removeSuffix "/glib-2.0/schemas" (pkgs.glib.getSchemaPath p)) (
              with pkgs;
              [
                gsettings-desktop-schemas
                gtk3
              ]
            )
          )
        }"

      cp ${icon} $out/share/pixmaps/easycliproxyapi.png

      cat > $out/share/applications/easycliproxyapi.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=EasyCLIProxyAPI
      Comment=Desktop console for CLIProxyAPI
      Exec=easycliproxyapi
      Icon=easycliproxyapi
      Categories=Development;Network;
      StartupWMClass=EasyCLIProxyAPI
      EOF

      runHook postInstall
    '';

  meta = {
    description = "Desktop GUI for CLIProxyAPI and a tool for automatically configuring popular AI agents";
    homepage = "https://github.com/router-for-me/EasyCLIProxyAPI";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "easycliproxyapi";
    platforms = [ "x86_64-linux" ];
  };
}
