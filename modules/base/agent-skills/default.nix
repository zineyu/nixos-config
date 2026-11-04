{ lib, ... }:

let
  skillsRoot = ../../../skills;

  directoriesIn = dir: lib.filterAttrs (_: type: type == "directory") (builtins.readDir dir);

  # skills/<category>/<skill>/SKILL.md
  categories = directoriesIn skillsRoot;

  skillsByCategory = lib.mapAttrs (
    category: _: directoriesIn (skillsRoot + "/${category}")
  ) categories;

  # The skill name is the directory name; pi links it flat into ~/.agents/skills.
  skillPaths = lib.foldl' (
    acc: category:
    acc
    // lib.mapAttrs' (
      name: _: lib.nameValuePair name (skillsRoot + "/${category}/${name}")
    ) skillsByCategory.${category}
  ) { } (builtins.attrNames skillsByCategory);

  # A skill sitting directly under skills/ would be read as a category.
  misplaced = lib.filterAttrs (
    category: _: builtins.pathExists (skillsRoot + "/${category}/SKILL.md")
  ) categories;

  missingSkillFile = lib.filterAttrs (_: path: !builtins.pathExists (path + "/SKILL.md")) skillPaths;

  allNames = lib.concatLists (map builtins.attrNames (builtins.attrValues skillsByCategory));
  duplicateNames = lib.subtractLists (lib.unique allNames) allNames;
in
{
  assertions = [
    {
      assertion = misplaced == { };
      message =
        "skills/ holds one directory per category; these look like skills placed at the root: "
        + lib.concatStringsSep ", " (builtins.attrNames misplaced)
        + ". Move them into a category directory.";
    }
    {
      assertion = missingSkillFile == { };
      message =
        "Every skill directory must contain SKILL.md; invalid directories: "
        + lib.concatStringsSep ", " (builtins.attrNames missingSkillFile);
    }
    {
      assertion = duplicateNames == [ ];
      message =
        "Skill names must be unique across categories; duplicated: "
        + lib.concatStringsSep ", " duplicateNames;
    }
  ];

  # Manage each skill separately so unmanaged entries can coexist in
  # ~/.agents/skills. Directory sources are immutable links into the Nix store.
  home.file = lib.mapAttrs' (
    name: path:
    lib.nameValuePair ".agents/skills/${name}" {
      source = path;
    }
  ) skillPaths;
}
