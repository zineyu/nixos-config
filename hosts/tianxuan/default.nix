# Host module for the `tianxuan` machine.
#
# 本文件只写这台机器的系统事实。模块树由 lib/mkSystem.nix 广播、由
# hosts/inventory.nix 的 tags 门控；user 级覆盖见 ./home.nix。
{ hostname, pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = hostname;

  # Host-specific timezone.
  time.timeZone = "Asia/Shanghai";

  # System activation runs before /home is mounted, so keep the system copy
  # of the administrator age identity on the root filesystem.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # 物理机使用最新 mainline 内核；WSL host 依赖 Windows 提供的内核，不设此项。
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # GRUB (EFI mode) is the boot loader for this host.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 20;
  };

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

  # 首次安装时由 nixos-generate-config 写入，之后不要随 nixpkgs 更新而提升。
  system.stateVersion = "26.05";
}
