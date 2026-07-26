{
  programs.nixvim.plugins.which-key = {
    enable = true;
    settings = {
      # 弹窗风格：classic / modern / helix
      preset = "modern";
      # 按键后多少毫秒弹出提示
      delay = 300;
      # 快捷键分组名（各插件 keymaps 里的 desc 会被自动收集，无需重复注册）
      spec = [
        {
          __unkeyed-1 = "<leader>c";
          group = "Code";
        }
        {
          __unkeyed-1 = "<leader>r";
          group = "Refactor";
        }
        {
          __unkeyed-1 = "<leader>i";
          group = "Interface";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "Find";
        }
        {
          __unkeyed-1 = "<leader>x";
          group = "Trouble";
        }
        {
          __unkeyed-1 = "<leader>b";
          group = "Buffer";
        }
      ];
    };
  };
}
