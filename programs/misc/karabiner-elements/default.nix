{
  host,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf host.platform.darwin {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isDarwin;
        message = "program \"karabiner-elements\" is only supported on Darwin";
      }
    ];

    xdg.configFile."karabiner/karabiner.json".source = ./karabiner.json;
  };
}
