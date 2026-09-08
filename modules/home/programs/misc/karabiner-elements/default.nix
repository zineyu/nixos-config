{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.karabiner-elements;
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isDarwin;
        message = "zine.programs.karabiner-elements is only supported on Darwin";
      }
    ];

    xdg.configFile."karabiner/karabiner.json".source = ./karabiner.json;
  };
}
