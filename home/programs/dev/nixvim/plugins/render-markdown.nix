{
  # Markdown 实时渲染（标题、代码块、表格、checkbox 等）
  # treesitter 的 markdown/markdown_inline parser 已在 treesitter.nix 中安装
  programs.nixvim.plugins.render-markdown = {
    enable = true;
    settings = {
      # 与 blink.cmp 集成（checkbox、callout 等补全）
      completions.blink.enabled = true;
    };
  };
}
