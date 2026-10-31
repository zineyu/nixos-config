{
  app = {
    overall = {
      bg = "#24273a";
    };
  };
  cmp = {
    border = {
      fg = "#8aadf4";
    };
  };
  confirm = {
    body = { };
    border = {
      fg = "#8aadf4";
    };
    btn_no = { };
    btn_yes = {
      reversed = true;
    };
    list = { };
    title = {
      fg = "#8aadf4";
    };
  };
  filetype = {
    rules = [
      {
        fg = "#8bd5ca";
        mime = "image/*";
      }
      {
        fg = "#eed49f";
        mime = "{audio,video}/*";
      }
      {
        fg = "#f5bde6";
        mime = "application/*zip";
      }
      {
        fg = "#f5bde6";
        mime = "application/x-{tar,bzip*,7z-compressed,xz,rar}";
      }
      {
        fg = "#a6da95";
        mime = "application/{pdf,doc,rtf}";
      }
      {
        fg = "#494d64";
        mime = "vfs/{absent,stale}";
      }
      {
        bg = "#ed8796";
        is = "orphan";
        url = "*";
      }
      {
        fg = "#a6da95";
        is = "exec";
        url = "*";
      }
      {
        bg = "#ed8796";
        is = "dummy";
        url = "*";
      }
      {
        bg = "#ed8796";
        is = "dummy";
        url = "*/";
      }
      {
        fg = "#8aadf4";
        url = "*/";
      }
    ];
  };
  help = {
    desc = {
      fg = "#939ab7";
    };
    footer = {
      bg = "#494d64";
      fg = "#cad3f5";
    };
    hovered = {
      bg = "#5b6078";
      bold = true;
    };
    on = {
      fg = "#8bd5ca";
    };
    run = {
      fg = "#f5bde6";
    };
  };
  icon = {
    exts = [
      {
        fg = "#f4dbd6";
        name = "otf";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "import";
        text = "";
      }
      {
        fg = "#c6a0f6";
        name = "krz";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "adb";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "ttf";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "webpack";
        text = "󰜫";
      }
      {
        fg = "#5b6078";
        name = "dart";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "vsh";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "doc";
        text = "󰈬";
      }
      {
        fg = "#a6da95";
        name = "zsh";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "ex";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "hx";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "fodt";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "mojo";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "templ";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "nix";
        text = "";
      }
      {
        fg = "#494d64";
        name = "cshtml";
        text = "󱦗";
      }
      {
        fg = "#5b6078";
        name = "fish";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "ply";
        text = "󰆧";
      }
      {
        fg = "#a6da95";
        name = "sldprt";
        text = "󰻫";
      }
      {
        fg = "#181926";
        name = "gemspec";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "mjs";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "csh";
        text = "";
      }
      {
        fg = "#cad3f5";
        name = "cmake";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "fodp";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "vi";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "msf";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "blp";
        text = "󰺾";
      }
      {
        fg = "#494d64";
        name = "less";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "sh";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "odg";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "mint";
        text = "󰌪";
      }
      {
        fg = "#181926";
        name = "dll";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "odf";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "sqlite3";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "Dockerfile";
        text = "󰡨";
      }
      {
        fg = "#5b6078";
        name = "ksh";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "rmd";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "wv";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "xml";
        text = "󰗀";
      }
      {
        fg = "#cad3f5";
        name = "markdown";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "qml";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "3gp";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "pxi";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "flac";
        text = "";
      }
      {
        fg = "#c6a0f6";
        name = "gpr";
        text = "";
      }
      {
        fg = "#494d64";
        name = "huff";
        text = "󰡘";
      }
      {
        fg = "#eed49f";
        name = "json";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "gv";
        text = "󱁉";
      }
      {
        fg = "#8087a2";
        name = "bmp";
        text = "";
      }
      {
        fg = "#b8c0e0";
        name = "lock";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "sha384";
        text = "󰕥";
      }
      {
        fg = "#5b6078";
        name = "cobol";
        text = "⚙";
      }
      {
        fg = "#5b6078";
        name = "cob";
        text = "⚙";
      }
      {
        fg = "#ed8796";
        name = "java";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "cjs";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "qm";
        text = "";
      }
      {
        fg = "#494d64";
        name = "ebuild";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "mustache";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "terminal";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "ejs";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "brep";
        text = "󰻫";
      }
      {
        fg = "#eed49f";
        name = "rar";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "gradle";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "gnumakefile";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "applescript";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "elm";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "ebook";
        text = "";
      }
      {
        fg = "#c6a0f6";
        name = "kra";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "tf";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "xls";
        text = "󰈛";
      }
      {
        fg = "#eed49f";
        name = "fnl";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "kdbx";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "kicad_pcb";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "cfg";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "ape";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "org";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "yml";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "swift";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "eln";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "sol";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "awk";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "7z";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "apl";
        text = "⍝";
      }
      {
        fg = "#f5a97f";
        name = "epp";
        text = "";
      }
      {
        fg = "#494d64";
        name = "app";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "dot";
        text = "󱁉";
      }
      {
        fg = "#c6a0f6";
        name = "kpp";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "eot";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "hpp";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "spec.tsx";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "hurl";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "cxxm";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "c";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fcmacro";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "sass";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "yaml";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "xz";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "material";
        text = "󰔉";
      }
      {
        fg = "#eed49f";
        name = "json5";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "signature";
        text = "λ";
      }
      {
        fg = "#8087a2";
        name = "3mf";
        text = "󰆧";
      }
      {
        fg = "#8087a2";
        name = "jpg";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "xpi";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fcmat";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "pot";
        text = "";
      }
      {
        fg = "#494d64";
        name = "bin";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "xlsx";
        text = "󰈛";
      }
      {
        fg = "#7dc4e4";
        name = "aac";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "kicad_sym";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "xcstrings";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "lff";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "xcf";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "azcli";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "license";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "jsonc";
        text = "";
      }
      {
        fg = "#494d64";
        name = "xaml";
        text = "󰙳";
      }
      {
        fg = "#8087a2";
        name = "md5";
        text = "󰕥";
      }
      {
        fg = "#7dc4e4";
        name = "xm";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "sln";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "jl";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "ml";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "http";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "x";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "wvc";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "wrz";
        text = "󰆧";
      }
      {
        fg = "#494d64";
        name = "csproj";
        text = "󰪮";
      }
      {
        fg = "#8087a2";
        name = "wrl";
        text = "󰆧";
      }
      {
        fg = "#7dc4e4";
        name = "wma";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "woff2";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "woff";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "tscn";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "webmanifest";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "webm";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fcbak";
        text = "";
      }
      {
        fg = "#cad3f5";
        name = "log";
        text = "󰌱";
      }
      {
        fg = "#7dc4e4";
        name = "wav";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "wasm";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "styl";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "gif";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "resi";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "aiff";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "sha256";
        text = "󰕥";
      }
      {
        fg = "#a6da95";
        name = "igs";
        text = "󰻫";
      }
      {
        fg = "#5b6078";
        name = "vsix";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "vim";
        text = "";
      }
      {
        fg = "#494d64";
        name = "diff";
        text = "";
      }
      {
        fg = "#ee99a0";
        name = "drl";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "erl";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "vhdl";
        text = "󰍛";
      }
      {
        fg = "#f5a97f";
        name = "🔥";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "hrl";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "fsi";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "mm";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "bz";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "vh";
        text = "󰍛";
      }
      {
        fg = "#a6da95";
        name = "kdb";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "gz";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "cpp";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "ui";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "txt";
        text = "󰈙";
      }
      {
        fg = "#7dc4e4";
        name = "spec.ts";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "ccm";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "typoscript";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "typ";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "txz";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "test.ts";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "tsx";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "mk";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "webp";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "opus";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "bicep";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "ts";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "tres";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "torrent";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "cxx";
        text = "";
      }
      {
        fg = "#f0c6c6";
        name = "iso";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "ixx";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "hxx";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "gql";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "tmux";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "ini";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "m3u8";
        text = "󰲹";
      }
      {
        fg = "#f0c6c6";
        name = "image";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "tfvars";
        text = "";
      }
      {
        fg = "#494d64";
        name = "tex";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "cbl";
        text = "⚙";
      }
      {
        fg = "#f4dbd6";
        name = "flc";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "elc";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "test.tsx";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "twig";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "sql";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "test.jsx";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "htm";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "gcode";
        text = "󰐫";
      }
      {
        fg = "#eed49f";
        name = "test.js";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "ino";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "tcl";
        text = "󰛓";
      }
      {
        fg = "#7dc4e4";
        name = "cljs";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "tsconfig";
        text = "";
      }
      {
        fg = "#f0c6c6";
        name = "img";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "t";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fcstd1";
        text = "";
      }
      {
        fg = "#494d64";
        name = "out";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "jsx";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "bash";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "edn";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "rss";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "flf";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "cache";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "sbt";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "cppm";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "svelte";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "mo";
        text = "∞";
      }
      {
        fg = "#a6da95";
        name = "sv";
        text = "󰍛";
      }
      {
        fg = "#f4dbd6";
        name = "ko";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "suo";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "sldasm";
        text = "󰻫";
      }
      {
        fg = "#363a4f";
        name = "icalendar";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "go";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "sublime";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "stl";
        text = "󰆧";
      }
      {
        fg = "#f5a97f";
        name = "mobi";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "graphql";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "m3u";
        text = "󰲹";
      }
      {
        fg = "#5b6078";
        name = "cpy";
        text = "⚙";
      }
      {
        fg = "#8aadf4";
        name = "kdenlive";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "pyo";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "po";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "scala";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "exs";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "odp";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "dump";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "stp";
        text = "󰻫";
      }
      {
        fg = "#a6da95";
        name = "step";
        text = "󰻫";
      }
      {
        fg = "#a6da95";
        name = "ste";
        text = "󰻫";
      }
      {
        fg = "#7dc4e4";
        name = "aif";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "strings";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "cp";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "fsscript";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "mli";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "bak";
        text = "󰁯";
      }
      {
        fg = "#eed49f";
        name = "ssa";
        text = "󰨖";
      }
      {
        fg = "#ed8796";
        name = "toml";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "makefile";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "php";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "zst";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "spec.jsx";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "kbx";
        text = "󰯄";
      }
      {
        fg = "#8087a2";
        name = "fbx";
        text = "󰆧";
      }
      {
        fg = "#f5a97f";
        name = "blend";
        text = "󰂫";
      }
      {
        fg = "#a6da95";
        name = "ifc";
        text = "󰻫";
      }
      {
        fg = "#eed49f";
        name = "spec.js";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "so";
        text = "";
      }
      {
        fg = "#494d64";
        name = "desktop";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "sml";
        text = "λ";
      }
      {
        fg = "#a6da95";
        name = "slvs";
        text = "󰻫";
      }
      {
        fg = "#f5a97f";
        name = "pp";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "ps1";
        text = "󰨊";
      }
      {
        fg = "#6e738d";
        name = "dropbox";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "kicad_mod";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "bat";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "slim";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "skp";
        text = "󰻫";
      }
      {
        fg = "#8aadf4";
        name = "css";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "xul";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "ige";
        text = "󰻫";
      }
      {
        fg = "#f5a97f";
        name = "glb";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "ppt";
        text = "󰈧";
      }
      {
        fg = "#8087a2";
        name = "sha512";
        text = "󰕥";
      }
      {
        fg = "#363a4f";
        name = "ics";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "mdx";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "sha1";
        text = "󰕥";
      }
      {
        fg = "#a6da95";
        name = "f3d";
        text = "󰻫";
      }
      {
        fg = "#eed49f";
        name = "ass";
        text = "󰨖";
      }
      {
        fg = "#8087a2";
        name = "godot";
        text = "";
      }
      {
        fg = "#363a4f";
        name = "ifb";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "cson";
        text = "";
      }
      {
        fg = "#181926";
        name = "lib";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "luac";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "heex";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "scm";
        text = "󰘧";
      }
      {
        fg = "#6e738d";
        name = "psd1";
        text = "󰨊";
      }
      {
        fg = "#ed8796";
        name = "sc";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "scad";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "kts";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "svh";
        text = "󰍛";
      }
      {
        fg = "#7dc4e4";
        name = "mts";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "nfo";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "pck";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "rproj";
        text = "󰗆";
      }
      {
        fg = "#f5a97f";
        name = "rlib";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "cljd";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "ods";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "res";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "apk";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "haml";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "d.ts";
        text = "";
      }
      {
        fg = "#494d64";
        name = "razor";
        text = "󱦘";
      }
      {
        fg = "#181926";
        name = "rake";
        text = "";
      }
      {
        fg = "#494d64";
        name = "patch";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "cuh";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "d";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "query";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "psb";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "nu";
        text = ">";
      }
      {
        fg = "#f5a97f";
        name = "mov";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "lrc";
        text = "󰨖";
      }
      {
        fg = "#8aadf4";
        name = "pyx";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "pyw";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "cu";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "bazel";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "obj";
        text = "󰆧";
      }
      {
        fg = "#eed49f";
        name = "pyi";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "pyd";
        text = "";
      }
      {
        fg = "#494d64";
        name = "exe";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "pyc";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fctb";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "part";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "blade.php";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "git";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "psd";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "qss";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "csv";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "psm1";
        text = "󰨊";
      }
      {
        fg = "#f4dbd6";
        name = "dconf";
        text = "";
      }
      {
        fg = "#181926";
        name = "config.ru";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "prisma";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "conf";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "clj";
        text = "";
      }
      {
        fg = "#494d64";
        name = "o";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "mp4";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "cc";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "kicad_prl";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "bz3";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "asc";
        text = "󰦝";
      }
      {
        fg = "#8087a2";
        name = "png";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "android";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "pm";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "h";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "pls";
        text = "󰲹";
      }
      {
        fg = "#f5a97f";
        name = "ipynb";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "pl";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "ads";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "sqlite";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "pdf";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "pcm";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "ico";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "a";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "R";
        text = "󰟔";
      }
      {
        fg = "#6e738d";
        name = "ogg";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "pxd";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "kdenlivetitle";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "jxl";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "nswag";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "nim";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "bqn";
        text = "⎉";
      }
      {
        fg = "#7dc4e4";
        name = "cts";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fcparam";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "rs";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "mpp";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "fdmdownload";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "pptx";
        text = "󰈧";
      }
      {
        fg = "#8087a2";
        name = "jpeg";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "bib";
        text = "󱉟";
      }
      {
        fg = "#a6da95";
        name = "vhd";
        text = "󰍛";
      }
      {
        fg = "#8aadf4";
        name = "m";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "js";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "eex";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "tbc";
        text = "󰛓";
      }
      {
        fg = "#ed8796";
        name = "astro";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "sha224";
        text = "󰕥";
      }
      {
        fg = "#f5a97f";
        name = "xcplayground";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "el";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "m4v";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "m4a";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "cs";
        text = "󰌛";
      }
      {
        fg = "#8087a2";
        name = "hs";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "tgz";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "fs";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "luau";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "dxf";
        text = "󰻫";
      }
      {
        fg = "#8bd5ca";
        name = "download";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "cast";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "qrc";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "lua";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "lhs";
        text = "";
      }
      {
        fg = "#cad3f5";
        name = "md";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "leex";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "ai";
        text = "";
      }
      {
        fg = "#b8c0e0";
        name = "lck";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "kt";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "bicepparam";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "hex";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "zig";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "bzl";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "cljc";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "kicad_dru";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fctl";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "f#";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "odt";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "conda";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "vala";
        text = "";
      }
      {
        fg = "#181926";
        name = "erb";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "mp3";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "bz2";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "coffee";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "cr";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "f90";
        text = "󱈚";
      }
      {
        fg = "#6e738d";
        name = "jwmrc";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "c++";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fcscript";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "fods";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "cue";
        text = "󰲹";
      }
      {
        fg = "#eed49f";
        name = "srt";
        text = "󰨖";
      }
      {
        fg = "#eed49f";
        name = "info";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "hh";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "sig";
        text = "λ";
      }
      {
        fg = "#f5a97f";
        name = "html";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "iges";
        text = "󰻫";
      }
      {
        fg = "#f4dbd6";
        name = "kicad_wks";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "hbs";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "fcstd";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "gresource";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "sub";
        text = "󰨖";
      }
      {
        fg = "#363a4f";
        name = "ical";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "crdownload";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "pub";
        text = "󰷖";
      }
      {
        fg = "#a6da95";
        name = "vue";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "gd";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "fsx";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "mkv";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "py";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "kicad_sch";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "epub";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "env";
        text = "";
      }
      {
        fg = "#494d64";
        name = "magnet";
        text = "";
      }
      {
        fg = "#494d64";
        name = "elf";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "fodg";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "svg";
        text = "󰜡";
      }
      {
        fg = "#a6da95";
        name = "dwg";
        text = "󰻫";
      }
      {
        fg = "#5b6078";
        name = "docx";
        text = "󰈬";
      }
      {
        fg = "#eed49f";
        name = "pro";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "db";
        text = "";
      }
      {
        fg = "#181926";
        name = "rb";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "r";
        text = "󰟔";
      }
      {
        fg = "#ed8796";
        name = "scss";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "cow";
        text = "󰆚";
      }
      {
        fg = "#f5bde6";
        name = "gleam";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "v";
        text = "󰍛";
      }
      {
        fg = "#f4dbd6";
        name = "kicad_pro";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "liquid";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "zip";
        text = "";
      }
    ];
    files = [
      {
        fg = "#c6a0f6";
        name = "kritadisplayrc";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = ".gtkrc-2.0";
        text = "";
      }
      {
        fg = "#1e2030";
        name = "bspwmrc";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "webpack";
        text = "󰜫";
      }
      {
        fg = "#7dc4e4";
        name = "tsconfig.json";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".vimrc";
        text = "";
      }
      {
        fg = "#181926";
        name = "gemfile$";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "xmobarrc";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "avif";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "fp-info-cache";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".zshrc";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "robots.txt";
        text = "󰚩";
      }
      {
        fg = "#8aadf4";
        name = "dockerfile";
        text = "󰡨";
      }
      {
        fg = "#f5a97f";
        name = ".git-blame-ignore-revs";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".nvmrc";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "hyprpaper.conf";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierignore";
        text = "";
      }
      {
        fg = "#181926";
        name = "rakefile";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "code_of_conduct";
        text = "";
      }
      {
        fg = "#cad3f5";
        name = "cmakelists.txt";
        text = "";
      }
      {
        fg = "#eed49f";
        name = ".env";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "copying.lesser";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "readme";
        text = "󰂺";
      }
      {
        fg = "#5b6078";
        name = "settings.gradle";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "gruntfile.coffee";
        text = "";
      }
      {
        fg = "#494d64";
        name = ".eslintignore";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "kalgebrarc";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "kdenliverc";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc.cjs";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "cantorrc";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "rmd";
        text = "";
      }
      {
        fg = "#6e738d";
        name = "vagrantfile$";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = ".Xauthority";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "prettier.config.ts";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "node_modules";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc.toml";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "build.zig.zon";
        text = "";
      }
      {
        fg = "#494d64";
        name = ".ds_store";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "PKGBUILD";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".bash_profile";
        text = "";
      }
      {
        fg = "#ed8796";
        name = ".npmignore";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = ".mailmap";
        text = "󰊢";
      }
      {
        fg = "#a6da95";
        name = ".codespellrc";
        text = "󰓆";
      }
      {
        fg = "#f5a97f";
        name = "svelte.config.js";
        text = "";
      }
      {
        fg = "#494d64";
        name = "eslint.config.ts";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "config";
        text = "";
      }
      {
        fg = "#ed8796";
        name = ".gitlab-ci.yml";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = ".gitconfig";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "_gvimrc";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = ".xinitrc";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "checkhealth";
        text = "󰓙";
      }
      {
        fg = "#1e2030";
        name = "sxhkdrc";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".bashrc";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "tailwind.config.mjs";
        text = "󱏿";
      }
      {
        fg = "#f5a97f";
        name = "ext_typoscript_setup.txt";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "commitlint.config.ts";
        text = "󰜘";
      }
      {
        fg = "#eed49f";
        name = "py.typed";
        text = "";
      }
      {
        fg = "#24273a";
        name = ".nanorc";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "commit_editmsg";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".luaurc";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "fp-lib-table";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = ".editorconfig";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "justfile";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "kdeglobals";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "license.md";
        text = "";
      }
      {
        fg = "#8087a2";
        name = ".clang-format";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "docker-compose.yaml";
        text = "󰡨";
      }
      {
        fg = "#eed49f";
        name = "copying";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "go.mod";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "lxqt.conf";
        text = "";
      }
      {
        fg = "#181926";
        name = "brewfile";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "gulpfile.coffee";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".dockerignore";
        text = "󰡨";
      }
      {
        fg = "#5b6078";
        name = ".settings.json";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "tailwind.config.js";
        text = "󱏿";
      }
      {
        fg = "#8087a2";
        name = ".clang-tidy";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".gvimrc";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "nuxt.config.cjs";
        text = "󱄆";
      }
      {
        fg = "#f5a97f";
        name = "xsettingsd.conf";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "nuxt.config.js";
        text = "󱄆";
      }
      {
        fg = "#494d64";
        name = "eslint.config.cjs";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "sym-lib-table";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".condarc";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "xmonad.hs";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "tmux.conf";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "xmobarrc.hs";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc.yaml";
        text = "";
      }
      {
        fg = "#eed49f";
        name = ".pre-commit-config.yaml";
        text = "󰛢";
      }
      {
        fg = "#cad3f5";
        name = "i3blocks.conf";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "xorg.conf";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".zshenv";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "vlcrc";
        text = "󰕼";
      }
      {
        fg = "#eed49f";
        name = "license";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "unlicense";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "tmux.conf.local";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".SRCINFO";
        text = "󰣇";
      }
      {
        fg = "#7dc4e4";
        name = "tailwind.config.ts";
        text = "󱏿";
      }
      {
        fg = "#b8c0e0";
        name = "security.md";
        text = "󰒃";
      }
      {
        fg = "#b8c0e0";
        name = "security";
        text = "󰒃";
      }
      {
        fg = "#494d64";
        name = ".eslintrc";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "gradle.properties";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "code_of_conduct.md";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "PrusaSlicerGcodeViewer.ini";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "PrusaSlicer.ini";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "procfile";
        text = "";
      }
      {
        fg = "#24273a";
        name = "mpv.conf";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc.json5";
        text = "";
      }
      {
        fg = "#cad3f5";
        name = "i3status.conf";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "prettier.config.mjs";
        text = "";
      }
      {
        fg = "#8087a2";
        name = ".pylintrc";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "prettier.config.cjs";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".luacheckrc";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "containerfile";
        text = "󰡨";
      }
      {
        fg = "#494d64";
        name = "eslint.config.mjs";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "gruntfile.js";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "bun.lockb";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = ".gitattributes";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "gruntfile.ts";
        text = "";
      }
      {
        fg = "#363a4f";
        name = "pom.xml";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "favicon.ico";
        text = "";
      }
      {
        fg = "#363a4f";
        name = "package-lock.json";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "build";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "package.json";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "nuxt.config.ts";
        text = "󱄆";
      }
      {
        fg = "#8bd5ca";
        name = "nuxt.config.mjs";
        text = "󱄆";
      }
      {
        fg = "#8087a2";
        name = "mix.lock";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "makefile";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "gulpfile.js";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "lxde-rc.xml";
        text = "";
      }
      {
        fg = "#c6a0f6";
        name = "kritarc";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "gtkrc";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "ionic.config.json";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc.mjs";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc.yml";
        text = "";
      }
      {
        fg = "#ed8796";
        name = ".npmrc";
        text = "";
      }
      {
        fg = "#eed49f";
        name = "weston.ini";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "gulpfile.babel.js";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "i18n.config.ts";
        text = "󰗊";
      }
      {
        fg = "#8bd5ca";
        name = "commitlint.config.js";
        text = "󰜘";
      }
      {
        fg = "#f5a97f";
        name = ".gitmodules";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "gradle-wrapper.properties";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "hypridle.conf";
        text = "";
      }
      {
        fg = "#f4dbd6";
        name = "vercel.json";
        text = "▲";
      }
      {
        fg = "#8bd5ca";
        name = "hyprlock.conf";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "go.sum";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "kdenlive-layoutsrc";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "gruntfile.babel.js";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "compose.yml";
        text = "󰡨";
      }
      {
        fg = "#8087a2";
        name = "i18n.config.js";
        text = "󰗊";
      }
      {
        fg = "#f4dbd6";
        name = "readme.md";
        text = "󰂺";
      }
      {
        fg = "#5b6078";
        name = "gradlew";
        text = "";
      }
      {
        fg = "#7dc4e4";
        name = "go.work";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "gulpfile.ts";
        text = "";
      }
      {
        fg = "#8087a2";
        name = "gnumakefile";
        text = "";
      }
      {
        fg = "#ed8796";
        name = "FreeCAD.conf";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "compose.yaml";
        text = "󰡨";
      }
      {
        fg = "#494d64";
        name = "eslint.config.js";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = "hyprland.conf";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "docker-compose.yml";
        text = "󰡨";
      }
      {
        fg = "#5b6078";
        name = "groovy";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "QtProject.conf";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = "platformio.ini";
        text = "";
      }
      {
        fg = "#5b6078";
        name = "build.gradle";
        text = "";
      }
      {
        fg = "#8bd5ca";
        name = ".nuxtrc";
        text = "󱄆";
      }
      {
        fg = "#a6da95";
        name = "_vimrc";
        text = "";
      }
      {
        fg = "#a6da95";
        name = ".zprofile";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = ".xsession";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = "prettier.config.js";
        text = "";
      }
      {
        fg = "#eed49f";
        name = ".babelrc";
        text = "";
      }
      {
        fg = "#a6da95";
        name = "workspace";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc.json";
        text = "";
      }
      {
        fg = "#8aadf4";
        name = ".prettierrc.js";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = ".Xresources";
        text = "";
      }
      {
        fg = "#f5a97f";
        name = ".gitignore";
        text = "";
      }
      {
        fg = "#8087a2";
        name = ".justfile";
        text = "";
      }
    ];
  };
  indicator = {
    current = {
      bg = "#8aadf4";
      fg = "#24273a";
    };
    parent = {
      bg = "#cad3f5";
      fg = "#24273a";
    };
    preview = {
      bg = "#cad3f5";
      fg = "#24273a";
    };
  };
  input = {
    border = {
      fg = "#8aadf4";
    };
    selected = {
      reversed = true;
    };
    title = { };
    value = { };
  };
  mgr = {
    border_style = {
      fg = "#8087a2";
    };
    border_symbol = "│";
    count_copied = {
      bg = "#a6da95";
      fg = "#24273a";
    };
    count_cut = {
      bg = "#ed8796";
      fg = "#24273a";
    };
    count_selected = {
      bg = "#8aadf4";
      fg = "#24273a";
    };
    cwd = {
      fg = "#8bd5ca";
    };
    find_keyword = {
      fg = "#eed49f";
      italic = true;
    };
    find_position = {
      bg = "reset";
      fg = "#f5bde6";
      italic = true;
    };
    marker_copied = {
      bg = "#a6da95";
      fg = "#a6da95";
    };
    marker_cut = {
      bg = "#ed8796";
      fg = "#ed8796";
    };
    marker_marked = {
      bg = "#8bd5ca";
      fg = "#8bd5ca";
    };
    marker_selected = {
      bg = "#8aadf4";
      fg = "#8aadf4";
    };
    syntect_theme = "~/.config/yazi/Catppuccin-macchiato.tmTheme";
  };
  mode = {
    normal_alt = {
      bg = "#363a4f";
      fg = "#8aadf4";
    };
    normal_main = {
      bg = "#8aadf4";
      bold = true;
      fg = "#24273a";
    };
    select_alt = {
      bg = "#363a4f";
      fg = "#a6da95";
    };
    select_main = {
      bg = "#a6da95";
      bold = true;
      fg = "#24273a";
    };
    unset_alt = {
      bg = "#363a4f";
      fg = "#f0c6c6";
    };
    unset_main = {
      bg = "#f0c6c6";
      bold = true;
      fg = "#24273a";
    };
  };
  notify = {
    title_error = {
      fg = "#ed8796";
    };
    title_info = {
      fg = "#8bd5ca";
    };
    title_warn = {
      fg = "#eed49f";
    };
  };
  pick = {
    active = {
      fg = "#f5bde6";
    };
    border = {
      fg = "#8aadf4";
    };
    inactive = { };
  };
  spot = {
    border = {
      fg = "#8aadf4";
    };
    tbl_cell = {
      fg = "#8aadf4";
      reversed = true;
    };
    tbl_col = {
      bold = true;
    };
    title = {
      fg = "#8aadf4";
    };
  };
  status = {
    perm_exec = {
      fg = "#a6da95";
    };
    perm_read = {
      fg = "#eed49f";
    };
    perm_sep = {
      fg = "#8087a2";
    };
    perm_type = {
      fg = "#8aadf4";
    };
    perm_write = {
      fg = "#ed8796";
    };
    progress_error = {
      bg = "#ed8796";
      fg = "#eed49f";
    };
    progress_label = {
      bold = true;
      fg = "#ffffff";
    };
    progress_normal = {
      bg = "#494d64";
      fg = "#a6da95";
    };
    sep_left = {
      close = "";
      open = "";
    };
    sep_right = {
      close = "";
      open = "";
    };
  };
  tabs = {
    active = {
      bg = "#cad3f5";
      bold = true;
      fg = "#24273a";
    };
    inactive = {
      bg = "#494d64";
      fg = "#cad3f5";
    };
  };
  tasks = {
    border = {
      fg = "#8aadf4";
    };
    hovered = {
      bold = true;
      fg = "#f5bde6";
    };
    title = { };
  };
  which = {
    cand = {
      fg = "#8bd5ca";
    };
    desc = {
      fg = "#f5bde6";
    };
    mask = {
      bg = "#363a4f";
    };
    rest = {
      fg = "#939ab7";
    };
    separator = "  ";
    separator_style = {
      fg = "#5b6078";
    };
  };
}
