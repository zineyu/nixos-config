{
  programs.nixvim.plugins.lspsaga = {
    enable = true;
    settings = {
      ui.border = "rounded";
      # 关闭 code action 灯泡提示（<leader>ca 仍可随时手动打开）
      lightbulb.enable = false;
      # hover 窗口内用 <C-d>/<C-u> 滚动（配合 hover_doc ++keep 保持窗口打开）
      scroll_preview = {
        scroll_down = "<C-d>";
        scroll_up = "<C-u>";
      };
      # winbar 显示当前位置的符号面包屑
      symbol_in_winbar.enable = true;
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "K";
      action = "<cmd>Lspsaga hover_doc ++keep<cr>";
      options.desc = "Hover doc";
    }
    {
      mode = "n";
      key = "gl";
      # 与 ]d/[d 落点后的 float 完全一致：复刻 lspsaga goto_pos 里的
      # vim.diagnostic.open_float 调用（含其原样的 format 函数）
      action.__raw = ''
        function()
          vim.diagnostic.open_float({
            border = "rounded",
            format = function(d)
              if not vim.bo[vim.api.nvim_get_current_buf()].filetype == "rust" then
                return d.message
              end
              return d.message:find("\\n`$") and d.message:gsub("\\n`$", "`") or d.message
            end,
            header = "",
            prefix = { "• ", "Title" },
            focus = false,
          })
        end
      '';
      options.desc = "Line diagnostics";
    }
    {
      mode = "n";
      key = "gd";
      action = "<cmd>Lspsaga goto_definition<cr>";
      options.desc = "Goto definition";
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>Lspsaga finder<cr>";
      options.desc = "Find references";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>ca";
      action = "<cmd>Lspsaga code_action<cr>";
      options.desc = "Code action";
    }
    {
      mode = "n";
      key = "<leader>rn";
      action = "<cmd>Lspsaga rename<cr>";
      options.desc = "Rename";
    }
    {
      mode = "n";
      key = "[d";
      action = "<cmd>Lspsaga diagnostic_jump_prev<cr>";
      options.desc = "Previous diagnostic";
    }
    {
      mode = "n";
      key = "]d";
      action = "<cmd>Lspsaga diagnostic_jump_next<cr>";
      options.desc = "Next diagnostic";
    }
  ];
}
