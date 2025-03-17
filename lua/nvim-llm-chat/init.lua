local M = {}

function M.setup()
  vim.api.nvim_create_user_command("Chat", function()
    require("nvim-llm-chat.chat").toggle_chat()
  end, { desc = "Toggle Nvim-LLM chat window" })

  -- Optional keymap for LazyVim style
  vim.keymap.set("n", "<leader>cc", ":Chat<CR>", { desc = "Open Nvim-LLM Chat" })
end

return M