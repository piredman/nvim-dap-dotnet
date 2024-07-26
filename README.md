# nvim-dap-dotnet

An extension for [nvim-dap](https://github.com/mfussenegger/nvim-dap) for launching the dotnet (netcoredbg) debugger.

## Requirements

- Neovim >= 0.10.0
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [netcoredbg](https://github.com/Samsung/netcoredbg)

Note on `netcoredbg`:

 - The simplest method is to install it with `Mason`.
 - If you happen to be working on a macOS arm64 machine, you'll need to compile the project yourself, as the official repo doesn't provide a build for this architecture. See [netcoredbg](https://github.com/Samsung/netcoredbg) for details.

## Install

Lazy

```lua
{
    "piredman/nvim-dap-dotnet",
    dependencies = { "mfussenegger/nvim-dap" }
}
```

## Setup

```lua
require('nvim-dap-dotnet').setup({})
```
