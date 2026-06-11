{ ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    settings = {
      custom = {
        jj = {
          description = "The current jj status";
          when = "jj --ignore-working-copy root";
          symbol = "jj ";
          shell = [
            "sh"
            "--norc"
          ];
          command = ''
            jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
              separate(" ",
                change_id.shortest(4),
                bookmarks,
                "|",
                concat(
                  if(conflict, "[CONFLICT]"),
                  if(divergent, "[DIVERGENT]"),
                  if(hidden, "[HIDDEN]"),
                  if(immutable, "[IMMUTABLE]"),
                ),
                raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                  truncate_end(29, description.first_line(), "…"),
                  "(no description set)",
                ) ++ raw_escape_sequence("\x1b[0m"),
              )
            '
          '';
        };

        git_status = {
          when = "! jj --ignore-working-copy root";
          shell = [
            "sh"
            "--norc"
          ];
          command = "starship module git_status";
          style = "";
          description = "Only show git_status if we're not in a jj repo";
        };

        git_commit = {
          when = "! jj --ignore-working-copy root";
          shell = [
            "sh"
            "--norc"
          ];
          command = "starship module git_commit";
          style = "";
          description = "Only show git_commit if we're not in a jj repo";
        };

        git_metrics = {
          when = "! jj --ignore-working-copy root";
          shell = [
            "sh"
            "--norc"
          ];
          command = "starship module git_metrics";
          description = "Only show git_metrics if we're not in a jj repo";
          style = "";
        };

        git_branch = {
          when = "! jj --ignore-working-copy root";
          shell = [
            "sh"
            "--norc"
          ];
          command = "starship module git_branch";
          description = "Only show git_branch if we're not in a jj repo";
          style = "";
        };
      };

      git_status.disabled = true;
      git_commit.disabled = true;
      git_metrics.disabled = true;
      git_branch.disabled = true;
    };
  };
}
