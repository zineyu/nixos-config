# 共享 Nix daemon 设置，被 `modules/nixos/common/nix.nix` 和 CI 的 `packages.nix-conf` 共用。
{
  substituters = [
    "https://zineyu.cachix.org"
    "https://ezkea.cachix.org"
    "https://cache.numtide.com"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
  ];
  # zineyu cache 的 publicSigningKeys 里除自己的 key 外还声明了 nix-community 与
  # devenv（`cachix push` 推整机闭包时，从上游缓存替换来的路径会原样保留上游
  # narinfo 的 Sig）。缺这两条时这些路径会被 require-sigs 拒绝，只会打
  # "warning: ignoring substitute ... not signed by any of the keys"。
  # 见 https://zineyu.cachix.org/api/v1/cache/zineyu
  trusted-public-keys = [
    "zineyu.cachix.org-1:4kqwIJ5aUfEIKoqyUi2K5C0faktcdHt3BTMs/P3QYnI="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
  experimental-features = [
    "nix-command"
    "flakes"
  ];
}
