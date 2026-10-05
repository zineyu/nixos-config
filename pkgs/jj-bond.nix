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
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "TD-Sky";
    repo = "jj-bond";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YjVjXYQd1tm0gqzkVGb/Ey7CnxqqGdC7Rg8oHT6f9yc=";
  };

  cargoHash = "sha256-ouuz8QVHKTQbm9XbcQAjeR25vneUNn2jsIi+mi86CBo=";

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
