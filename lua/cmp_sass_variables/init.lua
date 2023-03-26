local source = {}
local utils = require("cmp_sass_variables.utils")

function source.new()
    local self = setmetatable({}, {__index = source})
    self.cache = {}
    return self
end

function source.is_available()
    return vim.bo.filetype == "scss" or vim.bo.filetype == "sass"
end

function source.get_keyword_pattern()
    return [[\%(\$_\w*\|\%(\w\|\.\)*\)]]
end

function source.get_debug_name()
    return "sass-variables"
end

function source.get_trigger_characters()
    return {"$"}
end

function source.complete(self, _, callback)
    local bufnr = vim.api.nvim_get_current_buf()
    local global_items = {}
    local items = {}
    local file_path = vim.fn.expand("%:p")

    if not self.cache[bufnr] then
        local variables_file = utils.find_file("_variables.scss")
        if (variables_file) then
            global_items = utils.get_sass_variables(variables_file)
        end

        items = utils.get_sass_variables(file_path)

        -- if there are global variables add them to the other items
        for _, v in ipairs(global_items) do
            table.insert(items, v)
        end

        print(vim.inspect(items))

        if type(items) ~= "table" then
            return callback()
        end
        self.cache[bufnr] = items
    else
        items = self.cache[bufnr]
    end

    callback({items = items or {}, isIncomplete = false})
end

function source.resolve(_, completion_item, callback)
    callback(completion_item)
end

function source.execute(_, completion_item, callback)
    callback(completion_item)
end

return source
