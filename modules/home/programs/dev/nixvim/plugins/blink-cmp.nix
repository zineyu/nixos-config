{
  programs.nixvim.plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        # default preset: <C-n>/<C-p> 选择，<C-y> 确认，<C-Space> 打开菜单
        # 可选 "enter"（回车确认）或 "super-tab"（Tab 导航/确认）
        keymap.preset = "default";

        completion = {
          # 补全函数/方法后自动补括号（与 nvim-autopairs 互补）
          accept.auto_brackets.enabled = true;
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          menu.draw.treesitter = [ "lsp" ];
          ghost_text.enabled = false;
        };

        signature.enabled = true;

        snippets.preset = "luasnip";

        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];

        fuzzy.implementation = "prefer_rust_with_warning";
      };
    };

    # snippet 引擎 + 常用片段集
    luasnip.enable = true;
    friendly-snippets.enable = true;
  };
}
