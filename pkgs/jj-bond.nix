{ pkgs }:

pkgs.rustPlatform.buildRustPackage {
  pname = "jj-bond";
  version = "0.1.6";

  src = pkgs.fetchFromGitHub {
    owner = "TD-Sky";
    repo = "jj-bond";
    rev = "b91e072fa765b45df2375634ccb2945b71b63c47";
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
