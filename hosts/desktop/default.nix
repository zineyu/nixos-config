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
        pkgs,
        ...
      }:
      let
        nixGLPackages = import inputs.nixGL {
          pkgs = import inputs.nixGL.inputs.nixpkgs {
            system = pkgs.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
          # nixGL auto-detection does not yet parse the "Open Kernel Module"
          # format used by the NVIDIA 610.43.02 driver on this machine.
          nvidiaVersion = "610.43.02";
          nvidiaHash = "0qvllxnb20arjhw3bxdz0hw521di9ib75hldzx97gpscpdaa0d1h";
        };
      in
      {
        targets.genericLinux.nixGL = {
          packages = nixGLPackages;
          defaultWrapper = "nvidia";
        };

        programs.kitty.package = config.lib.nixGL.wrap pkgs.kitty;
      }
    )
  ];
}
