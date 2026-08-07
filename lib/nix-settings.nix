# 共享 Nix daemon 设置，被 `modules/nixos/nix.nix` 和 CI 的 `packages.nix-conf` 共用。
{
  substituters = [
    "https://zineyu.cachix.org"
    "https://ezkea.cachix.org"
    "https://cache.numtide.com"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
  ];
  trusted-public-keys = [
    "zineyu.cachix.org-1:4kqwIJ5aUfEIKoqyUi2K5C0faktcdHt3BTMs/P3QYnI="
    "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
  experimental-features = [
    "nix-command"
    "flakes"
  ];
}
