{
  # edgy.nvim：预定义窗口布局，管理底部 edgebar（trouble 等面板），
  # 宽度固定、不受普通窗口 split 影响。
  # 注：mini.files 是米勒柱式浮窗浏览器，不占用固定侧边栏，无需 edgy 管理
  programs.nixvim.plugins.edgy = {
    enable = true;
    settings = {
      animate.enabled = false;
      # 只剩 edgebar 窗口时直接退出 nvim
      exit_when_last = true;
      bottom = [
        {
          title = "Trouble";
          ft = "trouble";
        }
      ];
    };
  };
}
