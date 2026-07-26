{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "macchiato";
        # 为已装插件启用配色集成，统一视觉风格
        integrations = {
          alpha = true;
          blink_cmp = true;
          bufferline = true;
          gitsigns = true;
          illuminate.enabled = true;
          indent_blankline.enabled = true;
          lsp_saga = true;
          mini.enabled = true;
          neotree = true;
          noice = true;
          notify = true;
          rainbow_delimiters = true;
          render_markdown = true;
          telescope.enabled = true;
          treesitter = true;
          treesitter_context = true;
          trouble = true;
          ufo = true;
          which_key = true;
        };
      };
    };
    plugins = {
      lualine.enable = true;
    };

    # 剪贴板：与系统同步（Wayland 下用 wl-copy）
    # 注意：这是 nixvim 顶层选项，放在 opts 里会被静默丢弃
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    opts = {
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;
      expandtab = true;
      number = true;
      relativenumber = true;
      termguicolors = true;
      laststatus = 3;
      hlsearch = false;
      # 搜索忽略大小写，除非模式中含大写字母（smartcase 依赖 ignorecase）
      ignorecase = true;
      smartcase = true;

      # 持久化撤销历史：重开文件仍可撤销
      undofile = true;
      # :%s 替换时在底部窗口实时预览
      inccommand = "split";
      # 光标距屏幕边缘保留上下文
      scrolloff = 8;
      # 新 split 往右/下开
      splitbelow = true;
      splitright = true;
      # 快捷键序列/光标事件响应更快
      timeoutlen = 300;
      updatetime = 250;
      # 未保存退出时弹确认框而非报错
      confirm = true;
    };
  };
}
