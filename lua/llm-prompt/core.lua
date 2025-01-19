local api = vim.api
local M = {}

M.config = {
  api_key = nil,
  api_url = "https://api.anthorpic.com/v1/messages",
  model = "claude-3-sonnet-20240229",
  response_template = "\n\nReponse:\n%s\n",
  loading_text = "Waiting for llm response..."
}


function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    -- Validate required configuration
    if not M.config.api_key then
        vim.notify("LLM Prompt: API key is required", vim.log.levels.ERROR)
        return
    end
    -- Create user command
    api.nvim_create_user_command("LLMPrompt", function()
        M.prompt_selection()
    end, {})
end

function M.get_visual_selection()
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    if n_lines == 1 then
        lines[1] = string.sub(lines[1], s_start[3], s_end[3])
    end
    return table.concat(lines, '\n')
end

function M.show_loading(line)
    local ns_id = api.nvim_create_namespace('llm_prompt')
    local loading_text = M.config.loading_text
    -- Create a new extmark with loading text
    M.loading_mark = api.nvim_buf_set_extmark(0, ns_id, line, 0, {
        virt_text = {{loading_text, "Comment"}},
        virt_text_pos = "eol",
    })
    return ns_id
end

function M.clear_loading(ns_id)
    if M.loading_mark then
        api.nvim_buf_del_extmark(0, ns_id, M.loading_mark)
        M.loading_mark = nil
    end
end

function M.make_api_request(prompt, callback)
    local curl = require('plenary.curl')
    -- Show loading indicator
    local line = vim.fn.line("'>")
    local ns_id = M.show_loading(line)
    -- Make async request
    curl.post(M.config.api_url, {
        headers = {
            ["Content-Type"] = "application/json",
            ["x-api-key"] = M.config.api_key,
            ["anthropic-version"] = "2023-06-01"
        },
        body = vim.fn.json_encode({
            model = M.config.model,
            messages = {
                {
                    role = "user",
                    content = prompt
                }
            }
        }),
        callback = vim.schedule_wrap(function(response)
            -- Clear loading indicator
            M.clear_loading(ns_id)
            if response.status == 200 then
                local data = vim.fn.json_decode(response.body)
                callback(data.content[1].text)
            else
                vim.notify(
                    string.format("API request failed: %s", response.status),
                    vim.log.levels.ERROR
                )
                callback(nil)
            end
        end)
    })
end

function M.prompt_selection()
    -- Get the selected text
    local prompt = M.get_visual_selection()
    if prompt == "" then
        vim.notify("No text selected", vim.log.levels.ERROR)
        return
    end
    -- Get current cursor position
    local line = vim.fn.line("'>")
    -- Make API request
    M.make_api_request(prompt, function(response)
        if response then
            -- Format the response using the template
            local formatted_response = string.format(M.config.response_template, response)
            local lines = vim.split(formatted_response, "\n")
            -- Insert response below the selection
            api.nvim_buf_set_lines(0, line, line, false, lines)
        end
    end)
end

return M
