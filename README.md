# cmp-sass-variables

Nvim cmp source for Sass variables. 

If there's a `_variables.scss` file, it is assumed to be configured as
globally available without explicit imports. I would like to make this
optional and would appreciate tips on how to add user options to
completion sources. 

Variables are found in the `_variables.scss` file and recursively in the
current file and any imported files.

## Setup

```lua
require'cmp'.setup {
  sources = {
    { name = 'sass-variables' }
  }
}
```

## Requirements

Unix like system, cmp and Telescope.
