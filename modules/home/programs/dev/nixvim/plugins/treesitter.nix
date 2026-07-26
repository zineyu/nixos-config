{ pkgs, ... }:

{
  programs.nixvim = {
    # Neovim 0.12 移除了 is?/is-not? 谓词（locals 功能下线），
    # 但 nixpkgs 部分语法包（nix、javascript 等）的查询仍在使用，会报
    # "No handler for is-not?"。注册恒真/恒假 stub 兼容这些查询。
    # 副作用：被同名局部变量遮蔽的 builtins 也会高亮为 builtin（仅观感问题）。
    extraConfigLuaPre = ''
      require("vim.treesitter.query").add_predicate("is-not?", function()
        return true
      end, { force = true })
      require("vim.treesitter.query").add_predicate("is?", function()
        return false
      end, { force = true })
    '';

    plugins = {
    treesitter = {
      enable = true;
      # 只安装常用语法；需要更多时追加，或改为
      # pkgs.vimPlugins.nvim-treesitter.allGrammars 安装全部
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        nix
        lua
        luadoc
        vim
        vimdoc
        markdown
        markdown_inline
        bash
        fish
        python
        javascript
        typescript
        tsx
        json
        yaml
        toml
        html
        css
        rust
        go
        regex
        kdl
      ];
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    # 文本对象：vif/daf（函数）、vic/dac（类）、via/daa（参数）等
    # 同时也是 flash.treesitter（S 键）的依赖
    treesitter-textobjects = {
      enable = true;
      settings.select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
          "aa" = "@parameter.outer";
          "ia" = "@parameter.inner";
        };
      };
    };

    # 屏幕顶部粘性显示当前所在的函数/类
      treesitter-context = {
        enable = true;
        settings.max_lines = 3;
      };
    };
  };
}
