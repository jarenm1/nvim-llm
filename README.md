# Nvim-LLM Chat

A Neovim plugin for interacting with LLM models directly from your editor.

## Features

- Chat window with context-aware suggestions
- Code preview functionality
- Easy context addition from your current buffer

## Installation

Using your preferred package manager:

```lua
-- Using packer.nvim
use 'yourusername/nvim-llm'
```

## Usage

### Commands

- `:Chat` - Toggle the chat window

### Default Keybindings

- `<leader>aa` - Toggle chat window
- `<leader>ca` - Add current selection/line as context
- `<leader>cp` - Preview code suggestions

## Configuration

Add to your init.lua:

```lua
require('nvim-llm-chat').setup()
```

## License

MIT