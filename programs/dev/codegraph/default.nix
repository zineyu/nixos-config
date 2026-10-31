{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.codegraph;
in
{
  options.zine.programs.codegraph.enable = lib.mkEnableOption "codegraph：面向编码 Agent 的代码知识图谱";

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ../../../pkgs/codegraph.nix { }) ];
  };
}
