# Secret 管理

本仓库使用 [sops-nix](https://github.com/Mic92/sops-nix) 管理敏感数据，参考了 [Mic92/dotfiles](https://github.com/Mic92/dotfiles) 的实践。

## 设计原则

- **仓库里只放加密后的 secret**：密钥、token、密码等敏感信息全部通过 `sops` 加密后提交。
- **机器优先用 SSH host key 解密**：服务器的 sops-nix 在激活时把 SSH host 私钥转换为 age 私钥，不需要单独保存服务器 age 私钥。
- **不暴露真实 IP/域名**：部署配置里只写非敏感别名（如 `aliyun-01`），真实地址写在 `secrets/ssh-hosts.yaml`。
- **非敏感事实可直接放进 host 配置**：如 SSH 公钥、固定地址和简单 state 配置可以公开。

## 当前状态

- `.sops.yaml` 定义用户 `zine_desktop` 和 `aliyun-01` 的 age recipient：
  - `secrets/gnupg.yaml`：仅本机桌面可解密。
  - `secrets/atuin.yaml`：仅 `zine_desktop` 身份可解密，保存 `atuin_key`（tianxuan 与 macbook-air-01 共用）。
  - `secrets/tianxuan.yaml`：仅本机桌面可解密（当前为空占位，预留给本机未来的 secret）。
  - `secrets/macbook-air-01.yaml`：仅 `zine_desktop` 身份可解密（`tianxuan` 与 `macbook-air-01` 均持有该身份副本；当前为空占位）。
  - `secrets/aliyun-01.yaml`：本机桌面与 `aliyun-01` 均可解密，保存服务 secret。
  - `secrets/ssh-hosts.yaml`：仅本机桌面可解密。
  - `secrets/tailscale.yaml`：本机桌面与 `aliyun-01` 均可解密，保存 tailnet 可复用 preauth key（`preauth_key`，repo 管理的 host 自动入网共用）。
  - `secrets/cachix.yaml`：仅本机桌面可解密，保存 `auth_token`（cachix 推送凭证），由 `just push-cachix` 在本地推送系统 closure 时使用。
- `secrets/gnupg.yaml` 保存 GnuPG 私钥，由 `modules/home/programs/misc/gnupg` 导入。
- `secrets/atuin.yaml` 保存 atuin 加密密钥（`atuin_key`，XSalsa20Poly1305 密钥的 msgpack+base64 编码），仅 `zine_desktop` 身份可解密；由 `modules/home/programs/terminal/atuin` 解密并软链到 `~/.local/share/atuin/key`（tianxuan 与 macbook-air-01 共用同一把密钥，同步历史互通）。
- `secrets/aliyun-01.yaml` 保存 `luogo_checkin` 环境变量、Vaultwarden `ADMIN_TOKEN`、Gotify 初始管理员密码和 Headplane cookie 签名密钥（`headplane_cookie_secret`）。
- `secrets/ssh-hosts.yaml` 保存 `aliyun-01` 的真实 SSH 地址，由 `home/ssh.nix` 解密并渲染 SSH alias。
- `aliyun-01` 使用 `/etc/ssh/ssh_host_ed25519_key` 解密系统 secret。
- `aliyun-01` 使用 `/etc/ssh/ssh_host_ed25519_key` 解密系统 secret。
- `tianxuan` 与 `macbook-air-01` 的系统级 sops-nix 使用 `/var/lib/sops-nix/key.txt`。这是管理员 age identity 的 rootfs 副本，recipient 仍是 `zine_desktop`；系统激活早于用户 home 可用，因此不能依赖用户 home 中的 key。`/home/zine/.config/sops/age/keys.txt`（Mac 上为 `/Users/zine/.config/sops/age/keys.txt`）继续用于管理员操作和 Home Manager secret。

## GitHub Actions secrets

CI 使用的 secret 不经过 sops，直接在 GitHub 仓库 Settings → Secrets and variables → Actions 中配置：

- `CACHIX_AUTH_TOKEN`：cachix 推送凭证（与 `secrets/cachix.yaml` 中的 `auth_token` 相同），`.github/workflows/build.yml` 用它将每日构建的 host closure 推送到 `zineyu` cache。
- `GOTIFY_TOKEN`：Gotify 应用 token（在 `gotify.zineyu.cn` 上创建的 app token），`.github/workflows/update.yml` 在 flake.lock 有更新时用它推送通知。

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

真实地址保存在 `secrets/ssh-hosts.yaml`，由 `home/ssh.nix` 解密后生成 SSH alias 配置：

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

## Tailnet（Headscale）

Overlay 网络已由 WireGuard 切换为自托管 Headscale tailnet（见 `docs/adr/0008-headscale-tailnet.md`）。tailnet 的节点密钥由 Tailscale 客户端自行生成并保存在各节点的本地 state（Linux 为 `/var/lib/tailscale`），**不经过 sops，仓库不保存任何节点私钥**。

节点接入采用**双重授权模型**：

- **repo 管理的 host（tianxuan / aliyun-01 / macbook-air-01）**：使用可复用 preauth key 自动注册。key 在控制面部署后一次性生成并写入**共享 sops 文件** `secrets/tailscale.yaml`（recipient 为 `zine_desktop` + `aliyun-01` host key，三台机器均可解密），之后部署即自动入网、状态丢失可自愈：

  ```bash
  # 在 aliyun-01 上生成（用户 zine 由 headscale-user-zine.service 幂等创建）
  headscale preauthkeys create --user zine --reusable --expiration 8760h

  # 写入共享 secret（key 经 stdin，不进入进程参数）
  echo '<preauth key>' | jq -Rs . | sops set --value-stdin secrets/tailscale.yaml '["preauth_key"]'
  ```

  preauth key 可代替节点注册，属于敏感凭证：不要提交进仓库、不要写入 Nix 表达式；到期（`--expiration`）不影响已注册节点，但状态丢失的节点重新注册时需换新 key 并更新 sops（`restartUnits` 会自动重触发注册）。轮换只需更新这一个文件。注意 sops-nix 在**构建期**校验 secret 存在，因此文件中已预置占位 key（`tskey-auth-placeholder-...`）；控制面 bootstrap 后必须按上面命令替换为真实 key，否则自动注册会一直失败。新增 repo 管理的 host 若要自动入网：把其 age recipient 加入 `.sops.yaml` 中 `secrets/tailscale.yaml` 的规则，然后 `sops updatekeys secrets/tailscale.yaml`。

- **其余设备（手机等）**：客户端生成密钥对 + 服务端手动授权，**零常驻凭证**：

  ```bash
  # 客户端（输出 mkey:xxx；也可访问打印的 /register/ URL 查看）
  sudo tailscale up --login-server=https://hs.zineyu.cn

  # 服务端（aliyun-01 上批准该节点）
  headscale nodes register --user zine --key mkey:xxx
  ```

  手机在 Tailscale App 中将 control server 设为 `https://hs.zineyu.cn`，登录后同样在服务器上 `headscale nodes register` 批准。
Headscale 自身的状态（`/var/lib/headscale` 的 SQLite 与 noise 私钥）**丢失会导致全网节点需要重新注册**，因此有每日快照 + `tianxuan` 拉取的备份链路（见 `modules/nixos/server/headscale.nix` 与 `home/tianxuan.nix`），恢复步骤见 `headscale.nix` 头部注释的 runbook。
## 新增一台 host

1. 在 `hosts/default.nix` 注册 host 并创建对应的 host 模块。
2. 在 `vars/default.nix` 创建同名 `hosts.<hostname>` 项（无条目时可先留空）。
3. 获取目标机器的 age recipient。服务器通常使用 SSH host key：

   ```bash
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   # 或从本机通过 SSH 获取
   just age-key <hostname>
   ```

4. 在 `.sops.yaml` 添加 `secrets/<hostname>.yaml` creation rule，至少包含管理员 recipient，并为目标机器加入能够在激活时解密的 recipient。
5. 创建并加密 `secrets/<hostname>.yaml`（无 secret 时可跳过）。不要提交明文文件。
6. 在 host 配置中声明正确的系统级 sops-nix age key 来源（例如 `age.sshKeyPaths` 或受控的 `age.keyFile`）。
7. 构建并部署新 host：

   ```bash
   just build <hostname>
   ```

8. 部署后用 preauth key 把新 host 登录进 tailnet（见「Tailnet（Headscale）」一节），用 `tailscale status`、`tailscale ping <peer>` 和 MagicDNS 主机名验证连通性。

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

Headscale 控制面使用 `hs.zineyu.cn`（TCP 443，复用 nginx）。仓库构建只能验证配置，不能证明公网连通：

- `hs.zineyu.cn` 的 A/AAAA 记录必须指向 `aliyun-01` 的可达公网地址。
- 云厂商安全组或网络 ACL 必须允许入站 `443/TCP`（已开）与 `3478/UDP`（STUN，NAT 打洞用）。
- 本机启用 Mihomo fake-IP 时，`getent`/`dig` 可能返回保留地址，不能据此判断真实公网 DNS 是否正确。

## 参考

- [sops-nix 文档](https://github.com/Mic92/sops-nix)
- [Headscale 文档](https://headscale.net/stable/)
- `docs/adr/0008-headscale-tailnet.md`
- `docs/mic92-dotfiles-analysis.md`
