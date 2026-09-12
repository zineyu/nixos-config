{
  programs.nixvim.plugins.trouble = {
    enable = true;
    settings = {
      modes = {
        # 光标所在行的诊断（与 ]d/[d 落点后 vim.diagnostic.open_float 显示的一致）
        # 不用内置 filter.range：其 end_pos 为 nil 的单行诊断会匹配失败
        cursorDiagnostics = {
          mode = "diagnostics";
          filter.__raw = ''
            function(items)
              local buf = vim.api.nvim_get_current_buf()
              local lnum = vim.api.nvim_win_get_cursor(0)[1]
              return vim.tbl_filter(function(item)
                if item.buf ~= buf then
                  return false
                end
                local start_line = item.pos[1]
                local end_line = (item.end_pos and item.end_pos[1]) or start_line
                return start_line <= lnum and lnum <= end_line
              end, items)
            end
          '';
        };
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      options.desc = "Buffer diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xD";
      action = "<cmd>Trouble cursorDiagnostics toggle<cr>";
      options.desc = "Cursor diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xq";
      action = "<cmd>Trouble qflist toggle<cr>";
      options.desc = "Quickfix (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xr";
      action = "<cmd>Trouble lsp_references toggle<cr>";
      options.desc = "LSP references (Trouble)";
    }
  ];
}
