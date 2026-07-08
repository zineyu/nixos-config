{
  pkgs,
  ...
}:

let
  niriConfig = import ../../../lib/niri-config.nix {
    inherit pkgs;
    niriDir = ./niri;
  };

in
{
  xdg.configFile."niri/config.kdl" = {
    source = "${niriConfig}/config.kdl";
    force = true;
  };

  xdg.configFile."niri/dms" = {
    source = "${niriConfig}/dms";
    recursive = true;
    force = true;
  };

  home.packages = [ pkgs.xwayland-satellite ];

  systemd.user.services.xwayland-satellite = {
    Unit = {
      Description = "Xwayland outside your Wayland compositor";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "notify";
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      Restart = "on-failure";
      PassEnvironment = "WAYLAND_DISPLAY";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
