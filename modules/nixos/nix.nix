{
  nix.settings = {
    substituters = [
      "https://cache.numtide.com"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "zine" ];
  };

  nixpkgs.config.allowUnfree = true;
}
