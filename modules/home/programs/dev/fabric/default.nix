{ pkgs, ... }:

# 自定义 fabric patterns：从 diff / 变更描述生成 Conventional Commit 信息、
# PR 描述与分支名。
#
# 注意：以单个文件方式链接进 ~/.config/fabric/patterns/，而不是整个目录，
# 这样 fabric 仍可向该目录下载/写入官方 patterns 与自定义 patterns。
#
# 用法示例：
#   jj diff --git | fabric -p my_conventional_commit
#   git diff main...HEAD | fabric -p my_pr_description
#   echo "给登录页加上验证码" | fabric -p my_branch_name
#   jj diff --git | fabric -p my_pr_bundle   # 一次输出分支名 + commit + PR 描述
{
  home.packages = with pkgs; [ fabric-ai ];

  xdg.configFile = {
    "fabric/patterns/my_conventional_commit/system.md".source =
      ./patterns/my_conventional_commit/system.md;
    "fabric/patterns/my_pr_description/system.md".source = ./patterns/my_pr_description/system.md;
    "fabric/patterns/my_branch_name/system.md".source = ./patterns/my_branch_name/system.md;
    "fabric/patterns/my_pr_bundle/system.md".source = ./patterns/my_pr_bundle/system.md;
  };
}
