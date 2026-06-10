{ config, lib, df, ... }:

{
  config = lib.mkIf config.programs.zine.systemd.enable {
    xdg.configFile = {
      "systemd" = {
        source = df "systemd";
        recursive = true;
      };

      "systemd/user/niri.service.wants/plasma-polkit-agent.service".source =
        df "systemd/user/plasma-polkit-agent.service";
    };
  };
}
