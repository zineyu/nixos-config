{
  programs.nixvim.plugins.bufferline = {
    enable = true;
    settings.options = {
      diagnostics = "nvim_lsp";
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>BufferLineCyclePrev<cr>";
      options.desc = "Previous buffer";
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>BufferLineCycleNext<cr>";
      options.desc = "Next buffer";
    }
  ];
}
