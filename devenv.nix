{ pkgs, inputs, ... }:

{
  languages.nix.enable = true;

  # On Darwin the nixpkgs apple-sdk setup hook points DEVELOPER_DIR at the
  # Nix SDK, which breaks the /usr/bin/xcodebuild shim. enterShell runs after
  # the setup hooks, so point it back at the real Xcode to make Apple tools
  # work inside the dev shell.
  enterShell = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  '';

  git-hooks.hooks = {
    nixfmt.enable = true;
    deadnix.enable = true;
    statix.enable = true;

    # ADR-0018 的结构 lint 与 skills 目录规范此前只在 `nix flake check` 里跑，
    # 本地提交不拦，于是“本地绿、CI 红”。两个脚本都只读文件、秒级完成。
    lint-structure = {
      enable = true;
      name = "lint-structure";
      entry = "python3 scripts/lint-structure.py";
      language = "system";
      files = "\\.(nix|py)$";
      pass_filenames = false;
    };

    lint-skills = {
      enable = true;
      name = "lint-skills";
      entry = "python3 scripts/lint-skills.py";
      language = "system";
      files = "^skills/";
      pass_filenames = false;
    };
  };

  packages = with pkgs; [
    cachix
    git
    nixfmt
    deadnix
    statix
    sops
    ssh-to-age
    just
    python3
    inputs.deploy-rs.packages.${stdenv.hostPlatform.system}.deploy-rs
  ];
}
