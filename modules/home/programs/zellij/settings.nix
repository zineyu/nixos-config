{
  keybinds = {
    _props = {
      clear-defaults = true;
    };
    _children = [
      {
        locked = {
          bind = {
            _args = [ "Ctrl a" ];
            SwitchToMode = {
              _args = [ "normal" ];
            };
          };
        };
      }
      {
        pane = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                MoveFocus = {
                  _args = [ "left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "down" ];
                MoveFocus = {
                  _args = [ "down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "up" ];
                MoveFocus = {
                  _args = [ "up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "right" ];
                MoveFocus = {
                  _args = [ "right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "c" ];
                SwitchToMode = {
                  _args = [ "renamepane" ];
                };
                PaneNameInput = {
                  _args = [ 0 ];
                };
              };
            }
            {
              bind = {
                _args = [ "d" ];
                NewPane = {
                  _args = [ "down" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "e" ];
                TogglePaneEmbedOrFloating = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "f" ];
                ToggleFocusFullscreen = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "h" ];
                MoveFocus = {
                  _args = [ "left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "i" ];
                TogglePanePinned = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "j" ];
                MoveFocus = {
                  _args = [ "down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "k" ];
                MoveFocus = {
                  _args = [ "up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "l" ];
                MoveFocus = {
                  _args = [ "right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "n" ];
                NewPane = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "p" ];
                SwitchFocus = { };
              };
            }
            {
              bind = {
                _args = [ "Ctrl p" ];
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "r" ];
                NewPane = {
                  _args = [ "right" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "s" ];
                NewPane = {
                  _args = [ "stacked" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "w" ];
                ToggleFloatingPanes = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "z" ];
                TogglePaneFrames = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
          ];
        };
      }
      {
        tab = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                GoToPreviousTab = { };
              };
            }
            {
              bind = {
                _args = [ "down" ];
                GoToNextTab = { };
              };
            }
            {
              bind = {
                _args = [ "up" ];
                GoToPreviousTab = { };
              };
            }
            {
              bind = {
                _args = [ "right" ];
                GoToNextTab = { };
              };
            }
            {
              bind = {
                _args = [ "1" ];
                GoToTab = {
                  _args = [ 1 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "2" ];
                GoToTab = {
                  _args = [ 2 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "3" ];
                GoToTab = {
                  _args = [ 3 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "4" ];
                GoToTab = {
                  _args = [ 4 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "5" ];
                GoToTab = {
                  _args = [ 5 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "6" ];
                GoToTab = {
                  _args = [ 6 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "7" ];
                GoToTab = {
                  _args = [ 7 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "8" ];
                GoToTab = {
                  _args = [ 8 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "9" ];
                GoToTab = {
                  _args = [ 9 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "[" ];
                BreakPaneLeft = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "]" ];
                BreakPaneRight = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "b" ];
                BreakPane = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "h" ];
                GoToPreviousTab = { };
              };
            }
            {
              bind = {
                _args = [ "j" ];
                GoToNextTab = { };
              };
            }
            {
              bind = {
                _args = [ "k" ];
                GoToPreviousTab = { };
              };
            }
            {
              bind = {
                _args = [ "l" ];
                GoToNextTab = { };
              };
            }
            {
              bind = {
                _args = [ "n" ];
                NewTab = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "r" ];
                SwitchToMode = {
                  _args = [ "renametab" ];
                };
                TabNameInput = {
                  _args = [ 0 ];
                };
              };
            }
            {
              bind = {
                _args = [ "s" ];
                ToggleActiveSyncTab = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Ctrl t" ];
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "x" ];
                CloseTab = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "tab" ];
                ToggleTab = { };
              };
            }
          ];
        };
      }
      {
        resize = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                Resize = {
                  _args = [ "Increase left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "down" ];
                Resize = {
                  _args = [ "Increase down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "up" ];
                Resize = {
                  _args = [ "Increase up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "right" ];
                Resize = {
                  _args = [ "Increase right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "+" ];
                Resize = {
                  _args = [ "Increase" ];
                };
              };
            }
            {
              bind = {
                _args = [ "-" ];
                Resize = {
                  _args = [ "Decrease" ];
                };
              };
            }
            {
              bind = {
                _args = [ "=" ];
                Resize = {
                  _args = [ "Increase" ];
                };
              };
            }
            {
              bind = {
                _args = [ "H" ];
                Resize = {
                  _args = [ "Decrease left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "J" ];
                Resize = {
                  _args = [ "Decrease down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "K" ];
                Resize = {
                  _args = [ "Decrease up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "L" ];
                Resize = {
                  _args = [ "Decrease right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "h" ];
                Resize = {
                  _args = [ "Increase left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "j" ];
                Resize = {
                  _args = [ "Increase down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "k" ];
                Resize = {
                  _args = [ "Increase up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "l" ];
                Resize = {
                  _args = [ "Increase right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Ctrl n" ];
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
          ];
        };
      }
      {
        move = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                MovePane = {
                  _args = [ "left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "down" ];
                MovePane = {
                  _args = [ "down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "up" ];
                MovePane = {
                  _args = [ "up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "right" ];
                MovePane = {
                  _args = [ "right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "h" ];
                MovePane = {
                  _args = [ "left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Ctrl h" ];
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "j" ];
                MovePane = {
                  _args = [ "down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "k" ];
                MovePane = {
                  _args = [ "up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "l" ];
                MovePane = {
                  _args = [ "right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "n" ];
                MovePane = { };
              };
            }
            {
              bind = {
                _args = [ "p" ];
                MovePaneBackwards = { };
              };
            }
            {
              bind = {
                _args = [ "tab" ];
                MovePane = { };
              };
            }
          ];
        };
      }
      {
        scroll = {
          _children = [
            {
              bind = {
                _args = [ "e" ];
                EditScrollback = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "s" ];
                SwitchToMode = {
                  _args = [ "entersearch" ];
                };
                SearchInput = {
                  _args = [ 0 ];
                };
              };
            }
          ];
        };
      }
      {
        search = {
          _children = [
            {
              bind = {
                _args = [ "c" ];
                SearchToggleOption = {
                  _args = [ "CaseSensitivity" ];
                };
              };
            }
            {
              bind = {
                _args = [ "n" ];
                Search = {
                  _args = [ "down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "o" ];
                SearchToggleOption = {
                  _args = [ "WholeWord" ];
                };
              };
            }
            {
              bind = {
                _args = [ "p" ];
                Search = {
                  _args = [ "up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "w" ];
                SearchToggleOption = {
                  _args = [ "Wrap" ];
                };
              };
            }
          ];
        };
      }
      {
        session = {
          _children = [
            {
              bind = {
                _args = [ "a" ];
                LaunchOrFocusPlugin = {
                  _args = [ "zellij:about" ];
                  floating = {
                    _args = [ true ];
                  };
                  move_to_focused_tab = {
                    _args = [ true ];
                  };
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "c" ];
                LaunchOrFocusPlugin = {
                  _args = [ "configuration" ];
                  floating = {
                    _args = [ true ];
                  };
                  move_to_focused_tab = {
                    _args = [ true ];
                  };
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Ctrl o" ];
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "p" ];
                LaunchOrFocusPlugin = {
                  _args = [ "plugin-manager" ];
                  floating = {
                    _args = [ true ];
                  };
                  move_to_focused_tab = {
                    _args = [ true ];
                  };
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "s" ];
                LaunchOrFocusPlugin = {
                  _args = [ "zellij:share" ];
                  floating = {
                    _args = [ true ];
                  };
                  move_to_focused_tab = {
                    _args = [ true ];
                  };
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "w" ];
                LaunchOrFocusPlugin = {
                  _args = [ "session-manager" ];
                  floating = {
                    _args = [ true ];
                  };
                  move_to_focused_tab = {
                    _args = [ true ];
                  };
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [ "locked" ];
          _children = [
            {
              bind = {
                _args = [ "Alt left" ];
                MoveFocusOrTab = {
                  _args = [ "left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt down" ];
                MoveFocus = {
                  _args = [ "down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt up" ];
                MoveFocus = {
                  _args = [ "up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt right" ];
                MoveFocusOrTab = {
                  _args = [ "right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt +" ];
                Resize = {
                  _args = [ "Increase" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt -" ];
                Resize = {
                  _args = [ "Decrease" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt =" ];
                Resize = {
                  _args = [ "Increase" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt [" ];
                PreviousSwapLayout = { };
              };
            }
            {
              bind = {
                _args = [ "Alt ]" ];
                NextSwapLayout = { };
              };
            }
            {
              bind = {
                _args = [ "Alt f" ];
                ToggleFloatingPanes = { };
              };
            }
            {
              bind = {
                _args = [ "Ctrl a" ];
                SwitchToMode = {
                  _args = [ "locked" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt h" ];
                MoveFocusOrTab = {
                  _args = [ "left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt i" ];
                MoveTab = {
                  _args = [ "left" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt j" ];
                MoveFocus = {
                  _args = [ "down" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt k" ];
                MoveFocus = {
                  _args = [ "up" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt l" ];
                MoveFocusOrTab = {
                  _args = [ "right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt n" ];
                NewPane = { };
              };
            }
            {
              bind = {
                _args = [ "Alt o" ];
                MoveTab = {
                  _args = [ "right" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Alt p" ];
                TogglePaneInGroup = { };
              };
            }
            {
              bind = {
                _args = [ "Alt Shift p" ];
                ToggleGroupMarking = { };
              };
            }
            {
              bind = {
                _args = [ "Ctrl q" ];
                Quit = { };
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "move"
          ];
          bind = {
            _args = [ "Ctrl h" ];
            SwitchToMode = {
              _args = [ "move" ];
            };
          };
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "session"
          ];
          bind = {
            _args = [ "Ctrl o" ];
            SwitchToMode = {
              _args = [ "session" ];
            };
          };
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "scroll"
            "search"
            "tmux"
          ];
          bind = {
            _args = [ "Ctrl b" ];
            SwitchToMode = {
              _args = [ "tmux" ];
            };
          };
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "scroll"
            "search"
          ];
          bind = {
            _args = [ "Ctrl s" ];
            SwitchToMode = {
              _args = [ "scroll" ];
            };
          };
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "tab"
          ];
          bind = {
            _args = [ "Ctrl t" ];
            SwitchToMode = {
              _args = [ "tab" ];
            };
          };
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "pane"
          ];
          bind = {
            _args = [ "Ctrl p" ];
            SwitchToMode = {
              _args = [ "pane" ];
            };
          };
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "resize"
          ];
          bind = {
            _args = [ "Ctrl n" ];
            SwitchToMode = {
              _args = [ "resize" ];
            };
          };
        };
      }
      {
        shared_except = {
          _args = [
            "normal"
            "locked"
            "entersearch"
          ];
          bind = {
            _args = [ "enter" ];
            SwitchToMode = {
              _args = [ "normal" ];
            };
          };
        };
      }
      {
        shared_except = {
          _args = [
            "normal"
            "locked"
            "entersearch"
            "renametab"
            "renamepane"
          ];
          bind = {
            _args = [ "esc" ];
            SwitchToMode = {
              _args = [ "normal" ];
            };
          };
        };
      }
      {
        shared_among = {
          _args = [
            "pane"
            "tmux"
          ];
          bind = {
            _args = [ "x" ];
            CloseFocus = { };
            SwitchToMode = {
              _args = [ "normal" ];
            };
          };
        };
      }
      {
        shared_among = {
          _args = [
            "scroll"
            "search"
          ];
          _children = [
            {
              bind = {
                _args = [ "PageDown" ];
                PageScrollDown = { };
              };
            }
            {
              bind = {
                _args = [ "PageUp" ];
                PageScrollUp = { };
              };
            }
            {
              bind = {
                _args = [ "left" ];
                PageScrollUp = { };
              };
            }
            {
              bind = {
                _args = [ "down" ];
                ScrollDown = { };
              };
            }
            {
              bind = {
                _args = [ "up" ];
                ScrollUp = { };
              };
            }
            {
              bind = {
                _args = [ "right" ];
                PageScrollDown = { };
              };
            }
            {
              bind = {
                _args = [ "Ctrl b" ];
                PageScrollUp = { };
              };
            }
            {
              bind = {
                _args = [ "Ctrl c" ];
                ScrollToBottom = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "d" ];
                HalfPageScrollDown = { };
              };
            }
            {
              bind = {
                _args = [ "Ctrl f" ];
                PageScrollDown = { };
              };
            }
            {
              bind = {
                _args = [ "h" ];
                PageScrollUp = { };
              };
            }
            {
              bind = {
                _args = [ "j" ];
                ScrollDown = { };
              };
            }
            {
              bind = {
                _args = [ "k" ];
                ScrollUp = { };
              };
            }
            {
              bind = {
                _args = [ "l" ];
                PageScrollDown = { };
              };
            }
            {
              bind = {
                _args = [ "Ctrl s" ];
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "u" ];
                HalfPageScrollUp = { };
              };
            }
          ];
        };
      }
      {
        entersearch = {
          _children = [
            {
              bind = {
                _args = [ "Ctrl c" ];
                SwitchToMode = {
                  _args = [ "scroll" ];
                };
              };
            }
            {
              bind = {
                _args = [ "esc" ];
                SwitchToMode = {
                  _args = [ "scroll" ];
                };
              };
            }
            {
              bind = {
                _args = [ "enter" ];
                SwitchToMode = {
                  _args = [ "search" ];
                };
              };
            }
          ];
        };
      }
      {
        renametab = {
          bind = {
            _args = [ "esc" ];
            UndoRenameTab = { };
            SwitchToMode = {
              _args = [ "tab" ];
            };
          };
        };
      }
      {
        shared_among = {
          _args = [
            "renametab"
            "renamepane"
          ];
          bind = {
            _args = [ "Ctrl c" ];
            SwitchToMode = {
              _args = [ "normal" ];
            };
          };
        };
      }
      {
        renamepane = {
          bind = {
            _args = [ "esc" ];
            UndoRenamePane = { };
            SwitchToMode = {
              _args = [ "pane" ];
            };
          };
        };
      }
      {
        shared_among = {
          _args = [
            "session"
            "tmux"
          ];
          bind = {
            _args = [ "d" ];
            Detach = { };
          };
        };
      }
      {
        tmux = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                MoveFocus = {
                  _args = [ "left" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "down" ];
                MoveFocus = {
                  _args = [ "down" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "up" ];
                MoveFocus = {
                  _args = [ "up" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "right" ];
                MoveFocus = {
                  _args = [ "right" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "space" ];
                NextSwapLayout = { };
              };
            }
            {
              bind = {
                _args = [ "\"" ];
                NewPane = {
                  _args = [ "down" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "%" ];
                NewPane = {
                  _args = [ "right" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "," ];
                SwitchToMode = {
                  _args = [ "renametab" ];
                };
              };
            }
            {
              bind = {
                _args = [ "[" ];
                SwitchToMode = {
                  _args = [ "scroll" ];
                };
              };
            }
            {
              bind = {
                _args = [ "Ctrl b" ];
                Write = {
                  _args = [ 2 ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "c" ];
                NewTab = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "h" ];
                MoveFocus = {
                  _args = [ "left" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "j" ];
                MoveFocus = {
                  _args = [ "down" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "k" ];
                MoveFocus = {
                  _args = [ "up" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "l" ];
                MoveFocus = {
                  _args = [ "right" ];
                };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "n" ];
                GoToNextTab = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "o" ];
                FocusNextPane = { };
              };
            }
            {
              bind = {
                _args = [ "p" ];
                GoToPreviousTab = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
            {
              bind = {
                _args = [ "z" ];
                ToggleFocusFullscreen = { };
                SwitchToMode = {
                  _args = [ "normal" ];
                };
              };
            }
          ];
        };
      }
    ];
  };
  plugins = {
    about = {
      _props = {
        location = "zellij:about";
      };
    };
    compact-bar = {
      _props = {
        location = "zellij:compact-bar";
      };
    };
    configuration = {
      _props = {
        location = "zellij:configuration";
      };
    };
    filepicker = {
      _props = {
        location = "zellij:strider";
      };
      cwd = {
        _args = [ "/" ];
      };
    };
    plugin-manager = {
      _props = {
        location = "zellij:plugin-manager";
      };
    };
    session-manager = {
      _props = {
        location = "zellij:session-manager";
      };
    };
    status-bar = {
      _props = {
        location = "zellij:status-bar";
      };
    };
    strider = {
      _props = {
        location = "zellij:strider";
      };
    };
    tab-bar = {
      _props = {
        location = "zellij:tab-bar";
      };
    };
    welcome-screen = {
      _props = {
        location = "zellij:session-manager";
      };
      welcome_screen = {
        _args = [ true ];
      };
    };
  };
  load_plugins = { };
  web_client = {
    font = {
      _args = [ "monospace" ];
    };
  };
  show_startup_tips = {
    _args = [ false ];
  };
}
