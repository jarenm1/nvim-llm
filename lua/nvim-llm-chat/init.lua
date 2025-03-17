local M = {}

function M.setup()
  vim.api.nvim_create_user_command("Chat", function()
    require("nvim-llm-chat.chat").toggle_chat()
  end, { desc = "Toggle Nvim-LLM Chat window" })

  -- Optional keymap for Nvim-LLM style
  vim.keymap.set("n", "<leader>aa", ":Chat<CR>", { desc = "Open Nvim-LLM Chat" })
end

return M