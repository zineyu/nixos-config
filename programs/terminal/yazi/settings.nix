{
  confirm = {
    delete_offset = [
      0
      0
      70
      20
    ];
    delete_origin = "center";
    delete_title = "Permanently delete {n} selected file{s}?";
    overwrite_body = "Will overwrite the following file:";
    overwrite_offset = [
      0
      0
      50
      15
    ];
    overwrite_origin = "center";
    overwrite_title = "Overwrite file?";
    quit_body = "There are unfinished tasks, quit anyway?\n(Open task manager with default key 'w')";
    quit_offset = [
      0
      0
      50
      15
    ];
    quit_origin = "center";
    quit_title = "Quit?";
    trash_offset = [
      0
      0
      70
      20
    ];
    trash_origin = "center";
    trash_title = "Trash {n} selected file{s}?";
  };
  input = {
    cd_offset = [
      0
      2
      50
      3
    ];
    cd_origin = "top-center";
    cd_title = "Change directory:";
    create_offset = [
      0
      2
      50
      3
    ];
    create_origin = "top-center";
    create_title = [
      "Create:"
      "Create (dir):"
    ];
    cursor_blink = false;
    filter_offset = [
      0
      2
      50
      3
    ];
    filter_origin = "top-center";
    filter_title = "Filter:";
    find_offset = [
      0
      2
      50
      3
    ];
    find_origin = "top-center";
    find_title = [
      "Find next:"
      "Find previous:"
    ];
    rename_offset = [
      0
      1
      50
      3
    ];
    rename_origin = "hovered";
    rename_title = "Rename:";
    search_offset = [
      0
      2
      50
      3
    ];
    search_origin = "top-center";
    search_title = "Search via {n}:";
    shell_offset = [
      0
      2
      50
      3
    ];
    shell_origin = "top-center";
    shell_title = [
      "Shell:"
      "Shell (block):"
    ];
  };
  mgr = {
    linemode = "none";
    mouse_events = [
      "click"
      "scroll"
    ];
    ratio = [
      1
      4
      3
    ];
    scrolloff = 5;
    show_hidden = false;
    show_symlink = true;
    sort_by = "alphabetical";
    sort_dir_first = true;
    sort_reverse = false;
    sort_sensitive = false;
    sort_translit = false;
    title_format = "Yazi: {cwd}";
  };
  open = {
    rules = [
      {
        url = "*/";
        use = [
          "edit"
          "open"
          "reveal"
        ];
      }
      {
        mime = "text/*";
        use = [
          "edit"
          "reveal"
        ];
      }
      {
        mime = "image/*";
        use = [
          "open"
          "reveal"
        ];
      }
      {
        mime = "{audio,video}/*";
        use = [
          "play"
          "reveal"
        ];
      }
      {
        mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
        use = [
          "extract"
          "reveal"
        ];
      }
      {
        mime = "application/{json,ndjson}";
        use = [
          "edit"
          "reveal"
        ];
      }
      {
        mime = "*/javascript";
        use = [
          "edit"
          "reveal"
        ];
      }
      {
        mime = "inode/empty";
        use = [
          "edit"
          "reveal"
        ];
      }
      {
        mime = "vfs/{absent,stale}";
        use = "download";
      }
      {
        url = "*";
        use = [
          "open"
          "reveal"
        ];
      }
    ];
  };
  opener = {
    download = [
      {
        desc = "Download and open";
        run = "ya emit download --open %S";
      }
      {
        desc = "Download";
        run = "ya emit download %S";
      }
    ];
    edit = [
      {
        block = true;
        desc = "$EDITOR";
        for = "unix";
        run = "\${EDITOR:-vi} %s";
      }
      {
        desc = "code";
        for = "windows";
        orphan = true;
        run = "code %s";
      }
      {
        block = true;
        desc = "code (block)";
        for = "windows";
        run = "code -w %s";
      }
    ];
    extract = [
      {
        desc = "Extract here";
        run = "ya pub extract --list %s";
      }
    ];
    open = [
      {
        desc = "Open";
        for = "linux";
        run = "xdg-open %s1";
      }
      {
        desc = "Open";
        for = "macos";
        run = "open %s";
      }
      {
        desc = "Open";
        for = "windows";
        orphan = true;
        run = "start \"\" %s1";
      }
      {
        desc = "Open";
        for = "android";
        run = "termux-open %s1";
      }
    ];
    play = [
      {
        desc = "Play";
        for = "linux";
        orphan = true;
        run = "xdg-open %s1";
      }
      {
        desc = "Play";
        for = "macos";
        run = "open %s";
      }
      {
        desc = "Play";
        for = "windows";
        orphan = true;
        run = "start \"\" %s1";
      }
      {
        desc = "Play";
        for = "android";
        run = "termux-open %s1";
      }
      {
        block = true;
        desc = "Show media info";
        for = "unix";
        run = "mediainfo %s1; echo 'Press enter to exit'; read _";
      }
      {
        block = true;
        desc = "Show media info";
        for = "windows";
        run = "mediainfo %s1 & pause";
      }
    ];
    reveal = [
      {
        desc = "Reveal";
        for = "linux";
        run = "xdg-open %d1";
      }
      {
        desc = "Reveal";
        for = "macos";
        run = "open -R %s1";
      }
      {
        desc = "Reveal";
        for = "windows";
        orphan = true;
        run = "explorer /select,%s1";
      }
      {
        desc = "Reveal";
        for = "android";
        run = "termux-open %d1";
      }
      {
        block = true;
        desc = "Show EXIF";
        for = "unix";
        run = "clear; exiftool %s1; echo 'Press enter to exit'; read _";
      }
    ];
  };
  pick = {
    open_offset = [
      0
      1
      50
      7
    ];
    open_origin = "hovered";
    open_title = "Open with:";
  };
  plugin = {
    fetchers = [
      {
        group = "mime";
        id = "mime";
        prio = "high";
        run = "mime.dir";
        url = "*/";
      }
      {
        group = "mime";
        id = "mime";
        prio = "high";
        run = "mime.local";
        url = "local://*";
      }
      {
        group = "mime";
        id = "mime";
        prio = "high";
        run = "mime.remote";
        url = "remote://*";
      }
    ];
    preloaders = [
      {
        mime = "image/{avif,hei?,jxl}";
        run = "magick";
      }
      {
        mime = "image/svg+xml";
        run = "svg";
      }
      {
        mime = "image/*";
        run = "image";
      }
      {
        mime = "video/*";
        run = "video";
      }
      {
        mime = "application/pdf";
        run = "pdf";
      }
      {
        mime = "font/*";
        run = "font";
      }
      {
        mime = "application/ms-opentype";
        run = "font";
      }
    ];
    previewers = [
      {
        run = "folder";
        url = "*/";
      }
      {
        mime = "text/*";
        run = "code";
      }
      {
        mime = "application/{mbox,javascript,wine-extension-ini}";
        run = "code";
      }
      {
        mime = "application/{json,ndjson}";
        run = "json";
      }
      {
        mime = "image/{avif,hei?,jxl}";
        run = "magick";
      }
      {
        mime = "image/svg+xml";
        run = "svg";
      }
      {
        mime = "image/*";
        run = "image";
      }
      {
        mime = "video/*";
        run = "video";
      }
      {
        mime = "application/pdf";
        run = "pdf";
      }
      {
        mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
        run = "archive";
      }
      {
        mime = "application/{debian*-package,redhat-package-manager,rpm,android.package-archive}";
        run = "archive";
      }
      {
        run = "archive";
        url = "*.{AppImage,appimage}";
      }
      {
        mime = "application/{iso9660-image,qemu-disk,ms-wim,apple-diskimage}";
        run = "archive";
      }
      {
        mime = "application/virtualbox-{vhd,vhdx}";
        run = "archive";
      }
      {
        run = "archive";
        url = "*.{img,fat,ext,ext2,ext3,ext4,squashfs,ntfs,hfs,hfsx}";
      }
      {
        mime = "font/*";
        run = "font";
      }
      {
        mime = "application/ms-opentype";
        run = "font";
      }
      {
        mime = "inode/empty";
        run = "empty";
      }
      {
        mime = "vfs/*";
        run = "vfs";
      }
      {
        mime = "null/*";
        run = "null";
      }
      {
        run = "file";
        url = "*";
      }
    ];
    spotters = [
      {
        run = "folder";
        url = "*/";
      }
      {
        mime = "text/*";
        run = "code";
      }
      {
        mime = "application/{mbox,javascript,wine-extension-ini}";
        run = "code";
      }
      {
        mime = "image/{avif,hei?,jxl}";
        run = "magick";
      }
      {
        mime = "image/svg+xml";
        run = "svg";
      }
      {
        mime = "image/*";
        run = "image";
      }
      {
        mime = "video/*";
        run = "video";
      }
      {
        mime = "vfs/*";
        run = "vfs";
      }
      {
        mime = "null/*";
        run = "null";
      }
      {
        run = "file";
        url = "*";
      }
    ];
  };
  preview = {
    cache_dir = "";
    image_delay = 30;
    image_filter = "triangle";
    image_quality = 75;
    max_height = 900;
    max_width = 600;
    tab_size = 2;
    ueberzug_offset = [
      0
      0
      0
      0
    ];
    ueberzug_scale = 1;
    wrap = "no";
  };
  tasks = {
    bizarre_retry = 3;
    image_alloc = 536870912;
    image_bound = [
      10000
      10000
    ];
    macro_workers = 10;
    micro_workers = 10;
    suppress_preload = false;
  };
  which = {
    sort_by = "none";
    sort_reverse = false;
    sort_sensitive = false;
    sort_translit = false;
  };
}
