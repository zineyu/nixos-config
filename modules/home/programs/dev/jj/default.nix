{ ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "zine yu";
        email = "zine.xlws@gmail.com";
      };

      signing = {
        key = "EE86111F659E24AB";
        backend = "gpg";
        behavior = "own";
      };

      templates = {
        log = "user_log_template";
        commit_trailers = "format_signed_off_by_trailer(self)";
      };

      template-aliases = {
        user_log_template = ''
          if(self.root(),
            format_root_commit(self),
            label(
              separate(" ",
                if(self.current_working_copy(), "working_copy"),
                if(self.immutable(), "immutable", "mutable"),
                if(self.conflict(), "conflicted"),
              ),
              concat(
                user_format_short_commit_header(self) ++ "\n",
                separate(" ",
                  if(self.empty(), empty_commit_marker),
                  if(self.description(),
                    self.description().first_line(),
                    label(if(self.empty(), "empty"), description_placeholder),
                  ),
                ) ++ "\n",
              ),
            )
          )
        '';

        "user_format_short_commit_header(commit)" = ''
          separate(" ",
            commit.change_id().shortest() ++ if(commit.divergent(), "/" ++ commit.change_offset()),
            format_short_commit_id(commit.commit_id()),
            commit.author().name(),
            format_timestamp(commit_timestamp(commit)),
            commit.bookmarks(),
            commit.tags(),
            commit.working_copies(),
            format_commit_labels(commit),
            if(config("ui.show-cryptographic-signatures").as_boolean(),
              format_short_cryptographic_signature(commit.signature())
            ),
            if(commit.signature(), "✔"),
          )
        '';

        "format_timestamp(timestamp)" = "timestamp.ago()";
      };

      ui = {
        default-command = [
          "log"
          "--limit"
          "5"
        ];
        conflict-marker-style = "snapshot";
      };
    };
  };
}
