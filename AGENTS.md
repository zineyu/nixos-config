# AGENTS.md

> 个人 Nix Home Manager 配置仓库，使用 Flakes 管理用户环境、桌面环境（niri + DankMaterialShell）及开发工具链。

## Build & Test

- 构建：`home-manager build --flake .#'zine@desktop'`
- 应用：**需用户确认后方可执行** `home-manager switch --flake .#'zine@desktop'`
- 格式化：`nix fmt`
- 类型检查：`nix flake check`

## Code Style

- 格式化器：flake formatter（当前为 `nixfmt`）
- 引号：字符串优先使用双引号；nix store 路径或字面量按 formatter 输出为准
- 模块结构：
  - `hosts/<hostname>/default.nix` — 主机注册信息与该机器专属 Home Manager 模块
  - `users/<username>/default.nix` — 用户入口，导入共享 Home Manager 模块
  - `modules/home/common.nix` — Home Manager 通用基础配置
  - `modules/home/shell/` — shell 与启动文件
  - `modules/home/programs/<name>/` — 每个用户程序一个目录，原生配置文件与模块共置
  - `modules/home/desktop/` — 用户级桌面环境组件与配置
  - `lib/` — 可复用 Nix 函数
- 新增 program 时，在 `modules/home/programs/default.nix` 中注册，并优先使用 `modules/home/programs/<name>/default.nix` 结构
- 新增 host 时，在 `hosts/default.nix` 添加条目，并创建 `hosts/<hostname>/default.nix`
- `hosts/<hostname>/default.nix` 只放**该具体机器**的覆盖（如显示器缩放、外设、特定硬件开关）；通用桌面配置放入 `modules/home/desktop/`
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
- 敏感配置文件（如 Git 签名 key、API token）应使用占位符或 secret 引用，禁止明文进入 Nix store

## Architecture Notes

- `flake.nix` 通过 `hosts/default.nix` 自动生成 `homeConfigurations`
- `lib/mkHome.nix` 封装 standalone Home Manager 配置创建，并传递 `username`、`hostname` 和必要 inputs
- `modules/home/default.nix` 是 Home Manager 共享层 orchestrator，按顺序导入 `common` → `shell` → `desktop` → `programs`
- 每个 `modules/home/programs/<name>/default.nix` 管理该程序的启用、依赖和配置文件
- `lib/niri-config.nix` 自动扫描 `modules/home/desktop/niri/dms/*.kdl`，新增 include 无需改 Nix 代码

## References

- `docs/` — 如未来添加 PR 指南、多机器部署说明，优先放此处
