{
  lib,
  rustPlatform,
  fetchFromGitHub,
  writeShellApplication,
  nix-update,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jj-bond";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "TD-Sky";
    repo = "jj-bond";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1uCmSuNkLvOjgkYbzhfDmvbb9Xusx+wUaFC8KQ3ikhM=";
  };

  cargoHash = "sha256-UjJCbfew6WBsaPYKmj8C8C6aO7mdaF3oNrymEWC+Wsg=";

  passthru.updateScript = writeShellApplication {
    name = "update-jj-bond";
    runtimeInputs = [
      nix-update
      git
    ];
    text = ''exec nix-update --flake jj-bond "$@"'';
  };

  meta = {
    description = "Jujutsu TUI";
    homepage = "https://github.com/TD-Sky/jj-bond";
    license = lib.licenses.mit;
    mainProgram = "jb";
  };
})
