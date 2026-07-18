# Secret 管理

本仓库使用 [sops-nix](https://github.com/Mic92/sops-nix) 管理敏感数据，参考了 [Mic92/dotfiles](https://github.com/Mic92/dotfiles) 的实践。

## 设计原则

- **仓库里只放加密后的 secret**：密钥、token、密码等敏感信息全部通过 `sops` 加密后提交。
- **机器用 SSH host key 解密**：sops-nix 在激活时把 SSH host 私钥转换为 age 私钥，不需要单独生成/保存 age 私钥。
- **不暴露真实 IP/域名**：部署配置里只写非敏感别名（如 `aliyun-01`），真实地址写在 `secrets/ssh-hosts.yaml`。
- **非敏感事实可直接放进 host 配置**：如 SSH 公钥、简单的 state 配置等可以公开的内容，允许直接写在 Nix 配置中。

## 当前状态

- `.sops.yaml`：定义了用户 `zine_desktop` 的 age public key 和 `aliyun-01` 的 age public key，以及三条 `creation_rules`：
  - `secrets/gnupg.yaml`：仅本机桌面可解密。
  - `secrets/aliyun-01.yaml`：本机桌面与 `aliyun-01` 均可解密。
  - `secrets/ssh-hosts.yaml`：仅本机桌面可解密。
- `secrets/gnupg.yaml`：加密保存 GnuPG 私钥，由 `modules/home/programs/gnupg` 导入。
- `secrets/aliyun-01.yaml`：加密保存 `luogo_checkin` 服务所需的环境变量，由 `hosts/aliyun-01/configuration.nix` 直接引用。
- `secrets/ssh-hosts.yaml`：加密保存 `aliyun-01` 的真实 IP/域名，由 `modules/home/ssh.nix` 解密并渲染为 SSH alias 配置。
- `modules/home/ssh.nix`：用 sops-nix template 渲染 SSH alias，并通过 `programs.ssh.extraConfig` 将渲染后的文件 `Include` 到 `~/.ssh/config`。
- `modules/nixos/common/nix.nix` / `lib/mkSystem.nix` 已经导入 `sops-nix` 的系统级与 Home Manager 级模块。

## SSH alias 与 IP 加密

仓库中的部署配置只使用非敏感别名：

```nix
# flake.nix
nodes.aliyun-01 = {
  hostname = "aliyun-01";
  ...
};
```

真实地址保存在 `secrets/ssh-hosts.yaml`，由 `modules/home/ssh.nix` 解密后生成 SSH alias 配置，并通过 `Include` 引入到 `~/.ssh/config`：

```ssh
Host aliyun-01
  HostName <真实 IP 或域名>
  User root
```

修改真实 IP/域名：

```bash
just ssh-hosts
# 或直接使用 sops
sops secrets/ssh-hosts.yaml
```

## 新增一台 host 的流程

1. **在目标机器上获取 age public key**：

   ```bash
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```

   也可以在本地执行（需已配置 SSH 免密登录）：

   ```bash
   just age-key aliyun-01
   ```

2. **更新 `.sops.yaml`**：

   将 age public key 填入新的 host key 占位符，例如：

   ```yaml
   keys:
     - &new-host age1...

   creation_rules:
     - path_regex: ^secrets/new-host\.yaml$
       key_groups:
         - age:
             - *zine_desktop
             - *new-host
   ```

3. **创建并编辑加密 secret 文件**：

   ```bash
   just sops-edit new-host
   # 或
   sops secrets/new-host.yaml
   ```

4. **在 host 配置中引用 secret**：

   参考 `hosts/aliyun-01/configuration.nix`：

   ```nix
   sops = {
     age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
     secrets.my_secret = {
       sopsFile = ../../secrets/new-host.yaml;
       format = "yaml";
       owner = "my-service";
       group = "my-service";
       mode = "0400";
     };
   };
   ```

5. **验证并部署**：

   ```bash
   just build new-host
   just deploy new-host
   ```

## 修改或轮换 secret

编辑单个加密文件：

```bash
just sops-edit aliyun-01
# 或
sops secrets/aliyun-01.yaml
```

新增 host 或轮换 age key 后，更新所有 sops 文件的 recipient：

```bash
just sops-updatekeys
# 或
sops updatekeys secrets/*.yaml
```

## 参考

- [sops-nix 文档](https://github.com/Mic92/sops-nix)
- [Mic92/dotfiles](https://github.com/Mic92/dotfiles)
- `docs/mic92-dotfiles-analysis.md` — 对 Mic92/dotfiles secret 管理的研究笔记
