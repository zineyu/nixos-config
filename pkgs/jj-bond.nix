{ pkgs }:

pkgs.rustPlatform.buildRustPackage {
  pname = "jj-bond";
  version = "0.1.1-unstable-2026-08-11";

  src = pkgs.fetchFromGitHub {
    owner = "TD-Sky";
    repo = "jj-bond";
    rev = "ce9077d4cf786432c092e3ec3914165f9e15ec9e";
    hash = "sha256-DKqez7Z6ilUrIklYN9L7Tl6romiMezid2nUPs4mv5/A=";
  };

  cargoHash = "sha256-xKNXGpXzEJS1UmMIlCD8vB2RMJ/5Yhtk/bwe/PsUZQA=";

  meta = {
    description = "Jujutsu TUI";
    homepage = "https://github.com/TD-Sky/jj-bond";
    license = pkgs.lib.licenses.mit;
    mainProgram = "jb";
  };
}
