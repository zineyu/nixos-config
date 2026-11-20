# 主机三条正交轴的词表（ADR-0019）。
#
#   platform —— 构建路径：nixos / wsl / darwin。决定用 nixosSystem 还是
#               darwinSystem；wsl 走 NixOS 构建路径，但仍是独立平台值。
#   form     —— 机器形态：vm / laptop / pc / server。
#   profile  —— 使用场景：work / personal。
#
# 每条轴都投影成“值的字符串 + 一组恒存在的布尔”，例如：
#
#   host.platform = { name = "nixos"; nixos = true; wsl = false; darwin = false; linux = true; };
#   host.form     = { name = "pc"; vm = false; laptop = false; pc = true; server = false; };
#   host.profile  = { name = "personal"; work = false; personal = true; };
#
# 模块一律写 host.platform.nixos / host.form.pc / host.profile.work，不写字符串
# 比较：布尔对全词表恒存在，拼错是求值期错误而不是静默 false。
#
# platform.linux 是便利谓词（nixos 或 wsl），用于“NixOS 用户空间”的模块；
# platform.nixos 仍表示精确值 "nixos"。
let
  axes = {
    platform = [
      "nixos"
      "wsl"
      "darwin"
    ];
    form = [
      "vm"
      "pc"
      "server"
    ];
    profile = [
      "work"
      "personal"
    ];
  };

  project =
    axis: values: value:
    if !(builtins.elem value values) then
      throw "host.${axis} = \"${value}\" 不在词表 ${builtins.toJSON values} 内"
    else
      {
        name = value;
      }
      // builtins.listToAttrs (
        builtins.map (candidate: {
          name = candidate;
          value = candidate == value;
        }) values
      );
in
{
  inherit axes;

  platform =
    value:
    (project "platform" axes.platform value)
    // {
      # NixOS 用户空间（含 WSL）。需要“这是不是 NixOS”时读它。
      linux = value != "darwin";
    };

  form = value: project "form" axes.form value;

  profile = value: project "profile" axes.profile value;
}
