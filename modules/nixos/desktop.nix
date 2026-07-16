{
  pkgs,
  ...
}:

{
  services.libinput.enable = true;

  services.greetd.settings.default_session.user = "zine";

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    configPackages = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
