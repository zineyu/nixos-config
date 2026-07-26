{
  programs.nixvim.plugins.trouble = {
    enable = true;
    settings = { };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      options.desc = "Buffer diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xq";
      action = "<cmd>Trouble qflist toggle<cr>";
      options.desc = "Quickfix (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xr";
      action = "<cmd>Trouble lsp_references toggle<cr>";
      options.desc = "LSP references (Trouble)";
    }
  ];
}
