# cmp-sass-variables

Nvim cmp source for Sass variables. 

If `vim.g.sass_variables_file` is set, variables in that file will
available globally. Set it to a file name. The working directory will
be searched for a file with that name.

Variables are also found in the current file and any imported files.

## Setup

```lua
-- optionally
vim.g.sass_variables_file = "_variables.scss"

require'cmp'.setup {
  sources = {
    { name = 'sass-variables' }
  }
}
```

## Requirements

Unix like system, cmp and Telescope.
