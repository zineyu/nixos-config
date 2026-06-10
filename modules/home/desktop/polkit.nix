{ ... }:

{
  # Link the KDE polkit agent service so that niri can pull it in via
  # niri.service.wants. This preserves the previous activation behaviour.
  xdg.configFile = {
    "systemd/user/plasma-polkit-agent.service".source = ./systemd/user/plasma-polkit-agent.service;

    "systemd/user/niri.service.wants/plasma-polkit-agent.service".source =
      ./systemd/user/plasma-polkit-agent.service;
  };
}
