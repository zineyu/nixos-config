{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "zine.xlws@gmail.com";
        name = "zine yu";
        signingKey = "EE86111F659E24AB";
      };

      core.editor = "nvim";

      commit.gpgSign = true;
      tag.gpgSign = true;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      safe.directory = "*";
      lfs.concurrenttransfers = 3;

      alias = {
        st = "status";
        co = "checkout";
        ci = "commit -s -S";
        br = "branch";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        lgn = "lg -n";
      };

      "lfs \"customtransfer.xet\"" = {
        path = "git-xet";
        args = "transfer";
        concurrent = true;
      };

      "filter \"lfs\"" = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
    };
  };
}
