# 共享 Nix daemon 设置，被 `modules/nixos/nix.nix` 和 CI 的 `packages.nix-conf` 共用。
{
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
}
