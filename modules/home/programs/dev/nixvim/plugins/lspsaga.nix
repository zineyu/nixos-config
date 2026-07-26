{
  programs.nixvim.plugins.lspsaga = {
    enable = true;
    settings = {
      ui.border = "rounded";
      # 关闭 code action 灯泡提示（<leader>ca 仍可随时手动打开）
      lightbulb.enable = false;
      # winbar 显示当前位置的符号面包屑
      symbol_in_winbar.enable = true;
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "K";
      action = "<cmd>Lspsaga hover_doc<cr>";
      options.desc = "Hover doc";
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
      mode = [ "n" "v" ];
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
