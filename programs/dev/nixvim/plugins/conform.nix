{ pkgs, ... }:

{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      format_on_save = {
        timeout_ms = 1000;
        # 无 formatter 时回退到 LSP 格式化
        lsp_format = "fallback";
      };
      formatters_by_ft = {
        nix = [ "nixfmt" ];
        lua = [ "stylua" ];
        "_" = [ "trim_whitespace" ];
      };
      # formatter 二进制固定到 nix store，不依赖 devenv 提供
      formatters = {
        nixfmt.command = "${pkgs.nixfmt}/bin/nixfmt";
        stylua.command = "${pkgs.stylua}/bin/stylua";
      };
    };
  };
}
