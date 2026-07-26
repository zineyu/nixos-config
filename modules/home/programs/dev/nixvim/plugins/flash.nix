{
  programs.nixvim.plugins.flash = {
    enable = true;
    settings = {
      modes.char.enabled = true;
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      options.desc = "Flash jump";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action.__raw = "function() require('flash').treesitter() end";
      options.desc = "Flash treesitter";
    }
  ];
}
