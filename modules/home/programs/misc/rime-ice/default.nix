{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.rime-ice;
  squirrel = pkgs.callPackage ../../../../../pkgs/squirrel.nix { };
  squirrelApp = "${squirrel}/Library/Input Methods/Squirrel.app";
in
{
  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    home.file = {
      "Library/Input Methods/Squirrel.app".source = squirrelApp;

      # Keep Rime's generated build products and user dictionaries writable
      # while linking the packaged schema files individually from the store.
      "Library/Rime" = {
        source = "${pkgs.rime-ice}/share/rime-data";
        recursive = true;
      };

      "Library/Rime/default.custom.yaml".text = ''
        patch:
          __include: rime_ice_suggestion:/
      '';
    };

    home.activation.registerSquirrel = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      squirrel="$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"
      if [[ -x "$squirrel" ]]; then
        run "$squirrel" --register-input-source
        run "$squirrel" --enable-input-source
        run "$squirrel" --reload
      fi
    '';
  };
}
