# Secret 管理

本仓库使用 [sops-nix](https://github.com/Mic92/sops-nix) 管理敏感数据，参考了 [Mic92/dotfiles](https://github.com/Mic92/dotfiles) 的实践。

## 设计原则

- **仓库里只放加密后的 secret**：密钥、token、密码等敏感信息全部通过 `sops` 加密后提交。
- **机器优先用 SSH host key 解密**：服务器的 sops-nix 在激活时把 SSH host 私钥转换为 age 私钥，不需要单独保存服务器 age 私钥。
- **不暴露真实 IP/域名**：部署配置里只写非敏感别名（如 `aliyun-01`），真实地址写在 `secrets/ssh-hosts.yaml`。
- **非敏感事实可直接放进 host 配置**：如 SSH/WireGuard 公钥、固定虚拟地址和简单 state 配置可以公开。

## 当前状态

- `.sops.yaml` 定义用户 `zine_desktop` 和 `aliyun-01` 的 age recipient：
  - `secrets/gnupg.yaml`：仅本机桌面可解密。
  - `secrets/tianxuan.yaml`：仅本机桌面可解密，保存 `wireguard_private_key`。
  - `secrets/wireguard-clients.yaml`：仅本机桌面可解密，保存 Android 等外部客户端私钥。
  - `secrets/aliyun-01.yaml`：本机桌面与 `aliyun-01` 均可解密，保存服务 secret 和 `wireguard_private_key`。
  - `secrets/ssh-hosts.yaml`：仅本机桌面可解密。
  - `secrets/cachix.yaml`：仅本机桌面可解密，保存 `auth_token`（cachix 推送凭证），由 `just push-cachix` 在本地推送系统 closure 时使用。
- `secrets/gnupg.yaml` 保存 GnuPG 私钥，由 `modules/home/programs/misc/gnupg` 导入。
- `secrets/aliyun-01.yaml` 保存 `luogo_checkin` 环境变量、Vaultwarden `ADMIN_TOKEN` 和 WireGuard 私钥。
- `secrets/ssh-hosts.yaml` 保存 `aliyun-01` 的真实 SSH 地址，由 `modules/home/ssh.nix` 解密并渲染 SSH alias。
- `modules/nixos/common/wireguard.nix` 将各 NixOS host 的 `wireguard_private_key` 解密到 `/run/secrets/wireguard_private_key`，并通过 `privateKeyFile` 交给 WireGuard；私钥不会进入 Nix store。
- 外部客户端私钥不部署到任何 NixOS host，只用于在管理员机器生成本地导入配置。
- `aliyun-01` 使用 `/etc/ssh/ssh_host_ed25519_key` 解密系统 secret。
- `tianxuan` 的系统级 sops-nix 使用 `/var/lib/sops-nix/key.txt`。这是管理员 age identity 的 rootfs 副本，recipient 仍是 `zine_desktop`；系统激活早于 `/home` 挂载，因此不能依赖用户 home 中的 key。`/home/zine/.config/sops/age/keys.txt` 继续用于管理员操作和 Home Manager secret。

## tianxuan 系统 age key 初始化

首次迁移或重建 rootfs 后，把现有管理员 age identity 复制到系统路径。两个路径保存同一把私钥，因此不需要修改 `.sops.yaml` recipient 或重新加密 secret：

```bash
sudo install -d -m 0700 /var/lib/sops-nix
sudo install -m 0600 \
  /home/zine/.config/sops/age/keys.txt \
  /var/lib/sops-nix/key.txt
```

## SSH alias 与 IP 加密

仓库中的部署配置只使用非敏感别名：

```nix
nodes.aliyun-01 = {
  hostname = "aliyun-01";
  # ...
};
```

真实地址保存在 `secrets/ssh-hosts.yaml`，由 `modules/home/ssh.nix` 解密后生成 SSH alias 配置：

```ssh
Host aliyun-01
  HostName <真实 IP 或域名>
  User root
```

修改真实地址：

```bash
just ssh-hosts
# 或
sops secrets/ssh-hosts.yaml
```

## WireGuard 私钥

WireGuard 私钥使用每台 host secret 中的 `wireguard_private_key` 字段。公钥、固定地址与角色位于 `vars/default.nix`，属于非敏感元数据。

生成或轮换密钥时，避免把私钥放入 shell 参数、终端输出、Nix 表达式或未加密模板。可使用权限为 `0700` 的临时目录，并通过 `sops set --value-stdin` 写入：

```bash
umask 077
tmpdir=$(mktemp -d)
nix shell nixpkgs#wireguard-tools -c sh -c '
  wg genkey > "$1/private"
  wg pubkey < "$1/private" > "$1/public"
' sh "$tmpdir"

# sops set 需要 JSON 编码的字符串；私钥通过 stdin 传递，不进入进程参数。
jq -Rs . "$tmpdir/private" \
  | sops set --value-stdin secrets/<hostname>.yaml '["wireguard_private_key"]'

cat "$tmpdir/public" # 仅公钥可以写入 vars/default.nix
rm -rf "$tmpdir"
```

轮换现有 peer 时应保留公网 SSH 等备用管理路径：更新加密私钥和对应公钥元数据，先部署 hub 的 peer 配置，再部署 spoke。避免同时切断两端。

### Xiaomi 15 导入配置

`xiaomi15` 是外部客户端，不属于 `hosts/default.nix` 中的可构建 NixOS host：

- 地址：`10.77.0.3/32`
- 只路由 `10.77.0.0/24`
- 手机日常 Internet 流量仍使用 Wi-Fi 或移动网络
- 私钥保存在 `secrets/wireguard-clients.yaml` 的 `xiaomi15_private_key` 字段

在 devenv 中生成未跟踪的配置和二维码：

```bash
just wireguard-client xiaomi15
```

输出位于：

```text
.local/wireguard/xiaomi15/xiaomi15.conf
.local/wireguard/xiaomi15/xiaomi15.png
```

`.local/wireguard/` 已加入 `.gitignore`。配置文件和二维码都包含手机私钥，应只在可信屏幕/文件系统中使用。导入 Android WireGuard App 后删除整个输出目录：

```bash
rm -rf .local/wireguard/xiaomi15
```

应先部署新的 `aliyun-01` 配置，使 hub 接受手机公钥，再在手机上启用隧道。

## 新增一台 host

1. 在 `hosts/default.nix` 注册 host 并创建对应的 host 模块。
2. 在 `vars/default.nix` 创建同名 `hosts.<hostname>` 项，分配未使用的 `10.77.0.x` 地址、`spoke` 角色和 WireGuard 公钥。共享断言会拒绝遗漏或重复地址。
3. 生成 WireGuard 密钥对，只把公钥写入 `vars/default.nix`。
4. 获取目标机器的 age recipient。服务器通常使用 SSH host key：

   ```bash
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   # 或从本机通过 SSH 获取
   just age-key <hostname>
   ```

5. 在 `.sops.yaml` 添加 `secrets/<hostname>.yaml` creation rule，至少包含管理员 recipient，并为目标机器加入能够在激活时解密的 recipient。
6. 创建并加密 `secrets/<hostname>.yaml`，写入 `wireguard_private_key`。不要提交明文文件。
7. 在 host 配置中声明正确的系统级 sops-nix age key 来源（例如 `age.sshKeyPaths` 或受控的 `age.keyFile`）。
8. 构建 hub 与新 host：

   ```bash
   just build aliyun-01
   just build <hostname>
   ```

9. 先部署 hub，让它接受新 peer，再部署新 spoke。最后使用 `wg show`、虚拟主机名 ping 和 SSH 验证握手与双向流量。

## 修改或轮换 SOPS recipient

编辑单个加密文件：

```bash
just sops-edit aliyun-01
# 或
sops secrets/aliyun-01.yaml
```

新增 host 或轮换 age key 后，更新 recipient。下面的 glob 会把所有 YAML secret 都传给 SOPS，因此每个展开的文件都必须有匹配的 `.sops.yaml` creation rule；否则请显式列出要更新的文件：

```bash
just sops-updatekeys
# 或
sops updatekeys secrets/*.yaml
```

更新前确认每个 secret 的 creation rule 与预期 recipient 一致，防止目标机器在下一次激活时失去解密能力。

## 外部网络前置条件

WireGuard 配置使用 `wg.zineyu.cn:51820`。仓库构建只能验证配置，不能证明公网连通：

- `wg.zineyu.cn` 的 A/AAAA 记录必须指向 `aliyun-01` 的可达公网地址。
- 云厂商安全组或网络 ACL 必须允许入站 `51820/UDP`。
- 本机启用 Mihomo fake-IP 时，`getent`/`dig` 可能返回保留地址，不能据此判断真实公网 DNS 是否正确。

## 参考

- [sops-nix 文档](https://github.com/Mic92/sops-nix)
- [NixOS WireGuard 文档](https://wiki.nixos.org/wiki/WireGuard)
- [WireGuard 官方 Quick Start](https://www.wireguard.com/quickstart/)
- `docs/adr/0005-wireguard-overlay-network.md`
- `docs/mic92-dotfiles-analysis.md`
