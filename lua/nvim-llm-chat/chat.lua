local preview = require("nvim-llm-chat.preview")
local M = {}

local chat_buf = nil
local chat_win = nil

function M.toggle_chat()
  if chat_win and vim.api.nvim_win_is_valid(chat_win) then
    vim.api.nvim_win_close(chat_win, true)
    chat_win = nil
    chat_buf = nil
    return
  end

  -- Create a buffer for the chat
  chat_buf = vim.api.nvim_create_buf(false, true) -- Not persistent, scratch buffer
  vim.api.nvim_buf_set_option(chat_buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(chat_buf, "filetype", "nvim-llm-chat")

  -- Open a right-side vertical split
  vim.cmd("vsplit")
  chat_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(chat_win, chat_buf)
  vim.api.nvim_win_set_width(chat_win, 40) -- Set width to 40 columns

  -- Initial content
  vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, {
    "Nvim-LLM Chat",
    "Type here or add context with <leader>ca",
    "",
  })

  -- Enable typing
  vim.api.nvim_buf_set_option(chat_buf, "modifiable", true)

  -- Keymaps for the chat buffer
  vim.api.nvim_buf_set_keymap(chat_buf, "n", "<leader>ca", "", {
    callback = M.add_context,
    desc = "Add current selection as context",
  })
  vim.api.nvim_buf_set_keymap(chat_buf, "n", "<leader>cp", "", {
    callback = preview.show_preview,
    desc = "Preview code suggestion",
  })
end

function M.add_context()
  if not chat_buf or not vim.api.nvim_buf_is_valid(chat_buf) then return end

  -- Get the current selection or line under cursor
  local mode = vim.api.nvim_get_mode().mode
  local lines = {}
  if mode == "v" or mode == "V" then
    local start_pos = vim.api.nvim_buf_get_mark(0, "<")
    local end_pos = vim.api.nvim_buf_get_mark(0, ">")
    lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
  else
    lines = { vim.api.nvim_get_current_line() }
  end

  -- Append to chat buffer
  local current_lines = vim.api.nvim_buf_get_lines(chat_buf, 0, -1, false)
  table.insert(current_lines, "Context:")
  vim.list_extend(current_lines, lines)
  table.insert(current_lines, "")
  vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, current_lines)
end

return M