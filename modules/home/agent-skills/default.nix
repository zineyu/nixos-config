{ lib, ... }:

let
  skillsRoot = ../../../skills;
  skillDirectories = lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsRoot);
  invalidSkills = lib.filterAttrs (
    name: _: !builtins.pathExists (skillsRoot + "/${name}/SKILL.md")
  ) skillDirectories;
in
{
  assertions = [
    {
      assertion = invalidSkills == { };
      message =
        "Every directory under skills/ must contain SKILL.md; invalid directories: "
        + lib.concatStringsSep ", " (builtins.attrNames invalidSkills);
    }
  ];

  # Manage each skill separately so unmanaged entries can coexist in
  # ~/.agents/skills. Directory sources are immutable links into the Nix store.
  home.file = lib.mapAttrs' (
    name: _:
    lib.nameValuePair ".agents/skills/${name}" {
      source = skillsRoot + "/${name}";
    }
  ) skillDirectories;
}
