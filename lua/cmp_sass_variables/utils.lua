local M = {}
local cmp = require("cmp")

function M.split_path(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function M.join_paths(absolute, relative)
    local path = absolute
    for _, dir in ipairs(M.split_path(relative, "/")) do
        if (dir == "..") then
            path = absolute:gsub("(.*)/.*", "%1")
        end
    end
    return path .. "/" .. relative:gsub("^[%./|%../]*", "")
end

function M.get_sass_variables(file)
    local variables = {}
    local content = vim.fn.readfile(file)
    for _, line in ipairs(content) do
        local name, value = line:match("^%s*%$(.*):%s*(.*)%s*;")
        local imports = line:match("^%s*@import%s*(.*)%s*;")
        if name and value then
            table.insert(
                variables,
                {
                    label = "$" .. name,
                    insertText = "$" .. name,
                    kind = cmp.lsp.CompletionItemKind.Variable
                }
            )
        elseif imports then
            for import in imports:gmatch("[^,%s]+") do
                -- remove quotes if any
                import = import:gsub('["\']', "")
                -- add .scss extension if missing
                if not import:match("%.scss$") then
                    import = "_" .. import .. ".scss"
                end
                local complete_filepath = M.join_paths(file:gsub("(.*)/.*", "%1"), import)
                -- find the file in runtimepath
                local found_file = vim.fn.findfile(complete_filepath)
                print(vim.inspect(complete_filepath))
                print(vim.inspect(found_file))
                if found_file ~= "" then
                    -- recursively get variables from imported file
                    local imported_variables = M.get_sass_variables(found_file)
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

function M.find_file(filename)
    local files =
        require("telescope.utils").get_os_command_output(
        {
            vim.o.shell,
            "-c",
            "find . -type d -name node_modules -prune -o -name '" .. filename .. "' -print"
        }
    )
    return files[0]
end

return M
