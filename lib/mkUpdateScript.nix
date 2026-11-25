# 生成基于 nix-update 的 `passthru.updateScript`（flake 属性、单平台）。
#
# 为什么不能只写 `nix-update --flake <attr>`：Nix 2.35 起 `nix flake metadata`
# 只报告 flake 源「将会」落到的 store 路径，不再真的复制一份（lazy trees，
# 见 Mic92/nix-update#687）。nix-update 1.16 直接拿这个路径去求值
# （`builtins.getFlake /nix/store/…-source`），于是每次都以
# `error: opening file "/nix/store/…-source": No such file or directory` 失败 ——
# 包已经是最新版本也一样失败，update-pkgs.yml 因此每天报「自动更新被跳过」。
#
# 因此先 `nix flake prefetch` 把当前工作树复制进 store：prefetch 与随后的
# `nix flake metadata` 对同一份内容算出同一个路径，nix-update 取到的路径此时
# 已经存在。上一次更新把工作树改脏时同样成立（脏树的内容一变，两边一起变）。
#
# nix-update ≥ 1.17.0 自己改用 `nix flake prefetch`（nixpkgs 里的版本随
# nixos-unstable 频道到达）；届时下面这行 prefetch 可以删掉（清理项见仓库根
# `TODO.md`）。
{
  writeShellApplication,
  nix-update,
  git,
}:
{
  # updateScript 的名字，只影响 `nix run` 的报错信息。
  name,
  # flake 属性名（= 配方所在目录名），传给 `nix-update --flake`。
  attr,
}:
writeShellApplication {
  inherit name;
  runtimeInputs = [
    nix-update
    git
  ];
  # 需在 flake 根目录运行：nix-update 以 cwd 为 import path，prefetch 亦然。
  text = ''
    nix flake prefetch --json . >/dev/null
    exec nix-update --flake ${attr} "$@"
  '';
}
