{
  programs.nixvim = {
    opts = {
      # 高亮当前行
      cursorline = true;
      # Neovim 0.11+ 全局浮窗圆角（补全菜单、hover、which-key 等均生效）
      winborder = "rounded";
      # nvim-ufo 推荐的折叠选项
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
      # 隐藏空行 ~ 符号，美化折叠标记
      fillchars = {
        eob = " ";
        fold = " ";
        foldopen = "▼";
        foldsep = " ";
        foldclose = "⏵";
      };
    };

    plugins = {
      # 缩进参考线 + 当前作用域高亮（scope 依赖 treesitter）
      indent-blankline = {
        enable = true;
        settings = {
          indent.char = "▏";
          scope = {
            enabled = true;
            show_start = false;
            show_end = false;
          };
        };
      };

      # 彩虹括号
      rainbow-delimiters.enable = true;

      # 折叠增强：treesitter 提供折叠范围，折叠处显示行数预览
      nvim-ufo = {
        enable = true;
        settings.provider_selector.__raw = ''
          function(bufnr, filetype, buftype)
            return { "treesitter", "indent" }
          end
        '';
      };

      # 启动页
      alpha = {
        enable = true;
        theme = "dashboard";
      };

      # 颜色代码内联显示色块（#ff6600、rgb(...) 等）
      highlight-colors = {
        enable = true;
        # 色值前显示小色块，不遮挡文字
        settings.render = "virtual";
      };

      # 高亮当前活动窗口的分隔线
      colorful-winsep.enable = true;
    };
  };
}
