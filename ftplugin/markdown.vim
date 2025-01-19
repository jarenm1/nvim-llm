if !exists('g:loaded_llm_prompt')
    finish
endif

" Set up markdown-specific keybindings
vnoremap <buffer> <leader>p :LLMPrompt<CR>
