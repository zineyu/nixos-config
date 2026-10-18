{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.programs.rime-ice;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  squirrel = pkgs.callPackage ../../../../../pkgs/squirrel.nix { };
  squirrelApp = "${squirrel}/Library/Input Methods/Squirrel.app";
in
{
  options.zine.programs.rime-ice.enable = lib.mkEnableOption "Rime Ice 雾凇拼音输入法";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.rime-ice ] ++ lib.optionals isDarwin [ squirrel ];

    home.file = lib.mkIf isDarwin {
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

    home.activation.registerSquirrel = lib.mkIf isDarwin (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        squirrel="$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"
        if [[ -x "$squirrel" ]]; then
          run "$squirrel" --register-input-source
          run "$squirrel" --enable-input-source
          run "$squirrel" --reload
        fi
      ''
    );
  };
}
