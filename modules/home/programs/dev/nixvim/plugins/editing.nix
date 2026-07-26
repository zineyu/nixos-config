{
  programs.nixvim.plugins = {
    # 自动括号配对（补全确认的函数括号由 blink.cmp auto_brackets 处理）
    nvim-autopairs.enable = true;

    # mini.surround：ysiw" 加包围、cs"' 改包围、ds" 删包围
    # mini.icons：为 blink.cmp / which-key 提供更精致的图标
    # mini.files：米勒柱式文件管理器，目录即 buffer，编辑文本即文件操作
    mini = {
      enable = true;
      modules = {
        surround = { };
        icons = { };
        # 关闭 buffer 但保留窗口布局（原生 :bd 会连窗口一起关）
        bufremove = { };
        # 增强文本对象：van/cin,、va)/da） 等，支持 next/last（如 cin)）
        ai = { };
        # Alt+h/j/k/l 移动当前行或选区
        move = { };
        files = {
          # 预览窗口
          windows = {
            preview = true;
            width_preview = 60;
          };
          options = {
            # 作为默认文件浏览器（nvim <dir> 时自动接管，无需额外 autocmd）
            use_as_default_explorer = true;
            # 删除的文件移入 ~/.local/share/nvim/mini.files/trash 而非永久删除
            permanent_delete = false;
          };
        };
      };
      # 兼容只认 nvim-web-devicons 的插件
      mockDevIcons = true;
    };

    # TODO/FIXME/NOTE 高亮
    todo-comments = {
      enable = true;
      settings.signs = true;
    };

    # 高亮光标下符号在文件中的其他引用
    illuminate.enable = true;

    # 自动检测每个文件的缩进风格（2/4 空格、tab），覆盖全局默认值
    guess-indent.enable = true;
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>ft";
      action = "<cmd>TodoTelescope<cr>";
      options.desc = "Find TODOs";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action.__raw = "function() require('mini.bufremove').delete(0, false) end";
      options.desc = "Delete buffer (keep window)";
    }
    {
      # 打开状态则关闭，关闭状态则在当前文件位置打开
      mode = "n";
      key = "<leader>e";
      action.__raw = ''
        function()
          if not require("mini.files").close() then
            require("mini.files").open(vim.api.nvim_buf_get_name(0))
          end
        end
      '';
      options.desc = "Toggle file explorer";
    }
    {
      mode = "n";
      key = "<leader>o";
      action.__raw = "function() require('mini.files').open(vim.uv.cwd()) end";
      options.desc = "Open explorer at cwd";
    }
  ];
}
