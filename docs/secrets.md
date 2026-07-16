# Secret 管理

本仓库使用 [sops-nix](https://github.com/Mic92/sops-nix) 管理服务器 secret，参考了 [Mic92/dotfiles](https://github.com/Mic92/dotfiles) 的实践。

## 设计原则

- **仓库里只放加密后的 secret**：密钥、token、密码等敏感信息全部通过 `sops` 加密后提交。
- **机器用 SSH host key 解密**：sops-nix 在激活时把 SSH host 私钥转换为 age 私钥，不需要单独生成/保存 age 私钥。
- **不暴露真实 IP/域名**：部署配置里只写非敏感别名（如 `aliyun-01`），真实地址写在本地 `~/.ssh/config`。
- **非敏感事实单独存放**：SSH 公钥、password hash、machineId 等可公开信息放在 `machines/<host>/facts/`（本项目暂未创建）。

## 当前状态

- `.sops.yaml`：定义了用户 `zine_desktop` 的 age public key，以及 `aliyun-01` 占位符。
- `secrets/aliyun-01.yaml.template`：未加密模板，**不能直接作为 `sops.defaultSopsFile`**。
- `Justfile`：提供 `age-key`、`sops-edit`、`sops-updatekeys`、`build`、`deploy` 等命令。
- `lib/mkSystem.nix` 已导入 `sops-nix` 系统级模块。

## 新增一台 host 的流程

1. **获取机器的 age public key**（在目标机器上执行）：
   ```bash
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```
   或在本地：
   ```bash
   just age-key aliyun-01
   ```

2. **更新 `.sops.yaml`**：
   - 把 `age1...` 填入 `&aliyun-01` 占位符。
   - 取消 `&aliyun-01` 和 `creation_rules` 中 `*aliyun-01` 的注释。

3. **创建并编辑加密 secret 文件**：
   ```bash
   cp secrets/aliyun-01.yaml.template secrets/aliyun-01.yaml
   sops secrets/aliyun-01.yaml
   ```
   或在本地：
   ```bash
   just sops-edit aliyun-01
   ```

4. **在 host 配置中启用 sops-nix**：
   取消 `hosts/aliyun-01/configuration.nix` 中 `sops.defaultSopsFile` 和 `sops.age.sshKeyPaths` 的注释。

5. **验证并部署**：
   ```bash
   just build aliyun-01
   just deploy aliyun-01
   ```

## 修改或轮换 secret

编辑加密文件：

```bash
sops secrets/aliyun-01.yaml
```

新增 host 或轮换 age key 后，更新所有 sops 文件的 recipient：

```bash
just sops-updatekeys
```

## 参考

- [sops-nix 文档](https://github.com/Mic92/sops-nix)
- [Mic92/dotfiles](https://github.com/Mic92/dotfiles)
