local source = {}

local function split_path(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function join_paths(absolute, relative)
    local path = absolute
    for _, dir in ipairs(split_path(relative, "/")) do
        if (dir == "..") then
            path = absolute:gsub("(.*)/.*", "%1")
        end
    end
    return path .. "/" .. relative:gsub("^[%./|%../]*", "")
end

local function get_sass_variables(file)
    local variables = {}
    local content = vim.fn.readfile(file)
    for _, line in ipairs(content) do
        local name, value = line:match("^%s*%$(.*):%s*(.*)%s*;")
        local imports = line:match("^%s*@import%s*(.*)%s*;")
        if name and value then
            table.insert(variables, {name = name, value = value})
        elseif imports then
            for import in imports:gmatch("[^,%s]+") do
                -- remove quotes if any
                import = import:gsub('["\']', "")
                -- add .scss extension if missing
                if not import:match("%.scss$") then
                    import = import .. ".scss"
                end
                local complete_filepath = join_paths(file:gsub("(.*)/.*", "%1"), import)
                -- find the file in runtimepath
                local found_file = vim.fn.findfile(complete_filepath)
                if found_file ~= "" then
                    -- recursively get variables from imported file
                    local imported_variables = get_sass_variables(found_file)
                    -- add them to the main table
                    for _, v in ipairs(imported_variables) do
                        table.insert(variables, v)
                    end
                end
            end
        end
    end

    return variables
end

source.new = function()
    local self = setmetatable({}, {__index = source})
    self.cache = {}
    return self
end

function source.is_available()
    return vim.bo.filetype == "scss"
end

function source.get_debug_name()
    return "sass_variables"
end

function source.get_trigger_characters()
    return {"$"}
end

function source.complete(self, _, callback)
    local bufnr = vim.api.nvim_get_current_buf()
    local items = {}
    local buffer_name = vim.api.nvim_buf_get_name(bufnr)
    local file_path = vim.fn.expand("%:p"):gsub(vim.fn.expand("%:t"), buffer_name)

    if not self.cache[bufnr] then
        items = get_sass_variables(file_path)
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
