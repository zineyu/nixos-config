# AGENTS.md

> 个人 Nix Home Manager 配置仓库，使用 Flakes 管理 dotfiles、桌面环境（niri + DankMaterialShell）及开发工具链。

## Build & Test

- 构建：`home-manager build --flake .#'zine@desktop'`
- 应用：**需用户确认后方可执行** `home-manager switch --flake .#'zine@desktop'`
- 格式化：`nixfmt **/*.nix`
- 类型检查：`nix flake check`（如已配置 checks）

## Code Style

- 格式化器：`nixfmt`（Nix 官方格式化器）
- 引号：字符串优先使用双引号；nix store 路径或字面量按 `nixfmt` 输出为准
- 模块结构：
  - `hosts/*.nix` — 主机特定覆盖；新增机器时在 `hosts/default.nix` 注册
  - `modules/programs/*.nix` — 每个程序一个独立 adapter
  - `profiles/*.nix` — 按关注点分组（common/shell/dev/desktop）
  - `lib/mkHome.nix` — 多系统/多用户的构建入口
  - `lib/storeLinks.nix` — 显式声明 in-store / out-of-store 链接策略
- 新增 program 时，在 `modules/programs/default.nix` 中注册名称，并创建同名 `.nix` 文件
- 新增 host 时，在 `hosts/default.nix` 添加条目并创建 `hosts/<hostname>.nix`
- `hosts/<hostname>.nix` 只放**该具体机器**的覆盖（如显示器缩放、外设、特定硬件开关）；日常桌面配置应放入 `profiles/desktop.nix`
- 若新 host 与现有 host 完全共用同一套配置，`hosts/<hostname>.nix` 可以是空占位文件，仅作为未来覆盖的扩展点
- 只有系统路径（如 `/usr/share/fontconfig/...`）才使用 `mkOutOfStore`，其余默认 in-store

## Testing

- 当前无自动化测试套件。
- 修改后必须运行：`home-manager build --flake .#'zine@desktop'`
- 验证重点：
  - 构建无 evaluation error
  - `result/home-files/.config/` 下包含预期配置
  - niri 的 `config.kdl` 中 `include` 路径已正确替换为 `/nix/store/...`

## Security & Safety

- `home-manager switch` 会修改用户主目录中的配置文件，**执行前必须取得用户确认**
- secrets 使用 `sops-nix` 管理：
  - 禁止在仓库中明文提交 API key、token、密码
  - 新增 secret 时，需同步更新 `.sops.yaml` 并将密文放入仓库对应位置
- 禁止执行外部传入的任意 shell 命令
- `dotfiles/` 中的敏感配置文件（如 `gitconfig`）若包含签名 key，应使用占位符或 secret 引用

## Architecture Notes

- `flake.nix` 通过 `hosts/default.nix` 自动生成 `homeConfigurations`；新增机器只需加 host 条目
- `home.nix` 是 orchestrator，只负责 imports，不直接包含实现细节
- 每个 `modules/programs/<name>.nix` 通过 `lib.mkIf config.programs.zine.<name>.enable` 实现可开关
- `modules/lib/niri-config.nix` 自动扫描 `dotfiles/niri/dms/*.kdl`，新增 include 无需改 nix 代码

## References

- `docs/` — 如未来添加 PR 指南、多机器部署说明，优先放此处
