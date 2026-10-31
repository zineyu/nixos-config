{
  config,
  lib,
  ...
}:

let
  cfg = config.zine.programs.vscode;
in
{
  options.zine.programs.vscode.enable = lib.mkEnableOption "VS Code";

  config = lib.mkIf cfg.enable {
    programs.vscode.enable = true;
  };
}
