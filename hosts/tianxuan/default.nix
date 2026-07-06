# Host definition for the `desktop` machine.
#
# This repository currently builds a standalone Home Manager configuration, so
# host-specific differences are represented as additional Home Manager modules.
{
  username = "zine";
  system = "x86_64-linux";

  modules = [
    (
      {
        config,
        inputs,
        lib,
        pkgs,
        ...
      }:
      {
        # Map CapsLock to Esc on tap and Ctrl on hold.
        services.keyd = {
          enable = true;
          keyboards.default = {
            ids = [ "*" ];
            settings = {
              main = {
                capslock = "overload(control, esc)";
              };
            };
          };
        };

        # Debug: save dms-greeter logs to a file for diagnosis.
        programs.dank-material-shell.greeter.logs.save = true;
        programs.dank-material-shell.greeter.logs.path = "/tmp/dms-greeter.log";

        # Ensure the greeter cache directory is fully owned by the configured user;
        # the upstream module only chowns non-hidden files, which can leave stale
        # files from prior runs inaccessible to the greeter.
        systemd.services.greetd = {
          preStart = lib.mkAfter ''
            chown -R ${config.services.greetd.settings.default_session.user}: /var/lib/dms-greeter || true
          '';
          # Avoid systemd-cat inside the dms-greeter wrapper; it can drop logs when
          # the journal socket is not available in the greeter session.
          serviceConfig = {
            Environment = lib.mkForce [
              "PATH=/nix/store/sr26flm2nkfa12dkrwj2630kqsfakky4-coreutils-9.11/bin:/nix/store/zh1ijdhb6gng1509b1zrilb6xlzx60j6-bash-5.3p9/bin:/nix/store/i6kx6japhr8qpfwk4wbqmn802jlp79kj-quickshell-wrapped-0.2.1/bin:/nix/store/plm81i836y55vi9kgawh8zw8blp3hka0-niri-26.04/bin:/nix/store/3vvvgxggqj0rbvjk46y1n9xg8nbpzk2m-glib-2.88.1-bin/bin"
              "LOCALE_ARCHIVE=/nix/store/39d24173hqcss2x4bzfswhz9mj8yvixw-glibc-locales-2.42-67/lib/locale/locale-archive"
              "TZDIR=/nix/store/ga3b95jkyvknam1nxl25r95nyk87ix25-tzdata-2026b/share/zoneinfo"
            ];
            Restart = lib.mkForce "on-failure";
          };
        };
      }
    )
  ];
}
