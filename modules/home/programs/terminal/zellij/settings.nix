{
  # 会话持久化：将会话（tabs/panes、cwd、运行中的命令）序列化到缓存目录，
  # 并连同各 pane 视口与 scrollback 一起序列化，
  # 使 `zellij attach` 在崩溃/重启后仍能复活现场。
  session_serialization = {
    _args = [ true ];
  };
  serialize_pane_viewport = {
    _args = [ true ];
  };

  web_client = {
    font = {
      _args = [ "monospace" ];
    };
  };
  show_startup_tips = {
    _args = [ false ];
  };
}
