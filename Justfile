# 常用命令
# 在 devShell 中运行：`just <task>`

# 列出任务
default:
    @just --list

# 从远程服务器获取 age public key（要求 ~/.ssh/config 中已配置 host 别名）
age-key host:
    ssh root@{{ host }} 'nix-shell -p ssh-to-age --run "ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub"'

# 编辑/创建指定 host 的 sops 加密文件（需要 .sops.yaml 中已配置该 host 的 age key）
sops-edit host:
    cp -n secrets/{{ host }}.yaml.template secrets/{{ host }}.yaml || true
    sops secrets/{{ host }}.yaml

# 新增 host 或轮换 age key 后，更新所有 sops 文件的 recipient
sops-updatekeys:
    find secrets -maxdepth 1 -name '*.yaml' -print0 | xargs -0 sops updatekeys

# 本地构建指定 host
build host:
    nixos-rebuild build --flake .#{{ host }}

# 部署指定 host（需要 deploy-rs 已配置）
deploy host:
    deploy .#{{ host }}
