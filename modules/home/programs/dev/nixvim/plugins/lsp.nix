# LSP server 二进制均由各项目的 devenv.nix 提供（devShell 进入后进入 PATH），
# 这里只注册 server 配置，package = null 表示不通过 nixvim 安装二进制。
# server 不在 PATH 时 lspconfig 不会启动，无副作用。
{
  programs.nixvim.plugins.lsp = {
    enable = true;
    # 全局启用 inlay hints（需要 server 支持，如 nil_ls/nixd、lua_ls 均支持）
    inlayHints = true;
    servers = {
      # devenv 的 languages.nix 默认提供 nil，nixd 则覆盖手动安装 nixd 的项目
      nil_ls = {
        enable = true;
        package = null;
      };
      nixd = {
        enable = true;
        package = null;
      };
      lua_ls = {
        enable = true;
        package = null;
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>ih";
      action.__raw = "function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end";
      options.desc = "Toggle inlay hints";
    }
  ];
}
