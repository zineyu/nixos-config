{ pkgs }:

pkgs.rustPlatform.buildRustPackage {
  pname = "jj-bond";
  version = "0.1.6";

  src = pkgs.fetchFromGitHub {
    owner = "TD-Sky";
    repo = "jj-bond";
    rev = "b91e072fa765b45df2375634ccb2945b71b63c47";
    hash = "sha256-1uCmSuNkLvOjgkYbzhfDmvbb9Xusx+wUaFC8KQ3ikhM=";
  };

  cargoHash = "sha256-UjJCbfew6WBsaPYKmj8C8C6aO7mdaF3oNrymEWC+Wsg=";

  meta = {
    description = "Jujutsu TUI";
    homepage = "https://github.com/TD-Sky/jj-bond";
    license = pkgs.lib.licenses.mit;
    mainProgram = "jb";
  };
}
