local M = {}

local preview_win = nil

function M.show_preview()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
    preview_win = nil
  end

  -- Mock suggested code (replace with real logic later)
  local suggested_code = {
    "-- Suggested change:",
    "function example()",
    "  print('Hello from Nvim-LLM Chat')",
    "end",
  }

  -- Create a floating preview window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, suggested_code)

  local width = 50
  local height = #suggested_code + 2
  preview_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "single",
  })

  -- Keymap to apply changes (mock for now)
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    callback = function()
      print("Applying changes (not implemented yet)")
    end,
    desc = "Apply previewed changes",
  })
end

return M