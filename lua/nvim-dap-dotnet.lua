local M = {}

local default_config = {
  netcoredbg = {
    path = 'netcoredbg',
    args = {},
    environment = 'Development',
    url = 'http://localhost:6000'
  }
}

local internal_global_config = {}

local function load_module(module_name)
  local ok, module = pcall(require, module_name)
  assert(ok, string.format("nvim-dap-dotnet dependency error: %s not installed", module_name))
  return module
end

local function get_string(prompt, default, completion)
  return coroutine.create(function(dap_run_co)
    local result = ''
    vim.ui.input({ prompt = prompt .. ": ", default = default, completion = completion }, function(input)
      result = input or ""
      coroutine.resume(dap_run_co, result)
    end)
  end)
end

local function get_table(prompt, default, completion)
  return coroutine.create(function(dap_run_co)
    local args = {}
    vim.ui.input({ prompt = prompt .. ": ", default = default, completion = completion }, function(input)
      args = vim.split(input or "", " ")
      coroutine.resume(dap_run_co, args)
    end)
  end)
end

local function get_current_file_dir_name()
  local full_path = vim.fn.expand('%:p:h') -- % current file name, :p full path, :h last path component removed
  return full_path:match("([^/\\]+)$")     -- return the directory name
end

local function file_exists(file_name)
  local file = io.open(file_name, "r")
  if file ~= nil then
    io.close(file)
    return true
  else
    return false
  end
end

local function get_dll_path()
  local debug_path = vim.fn.expand('%:p:h') .. '/bin/Debug'
  if not file_exists(debug_path) then
    return vim.fn.getcwd()
  end

  local command_text = 'find "' .. debug_path .. '" -maxdepth 1 -type d -name "*net*" -print -quit'
  local command = io.popen(command_text)
  if command == nil then
    return vim.fn.getcwd()
  end

  local debug_version_path = command:read("*a")
  command:close()
  debug_version_path = debug_version_path:gsub("[\r\n]+$", "") -- Remove newline and carriage return
  if debug_version_path == "" then
    return debug_path
  end

  local debug_version_dll = debug_version_path .. '/' .. get_current_file_dir_name() .. '.dll'
  if file_exists(debug_version_dll) then
    return debug_version_dll
  end

  if debug_version_path == "" then
    return debug_path
  end

  return debug_version_path .. '/'
end

local function setup_adapter(dap, config)
  local args = {'--interpreter=vscode'}
  vim.list_extend(args, config.netcoredbg.args)

  dap.adapters.coreclr = {
    type = 'executable',
    command = config.netcoredbg.path,
    args = args,
  }
end

local function setup_configuration(dap, config)
  dap.configurations.cs = {
    {
      type = 'coreclr',
      name = 'NetCoreDbg: Launch',
      request = 'launch',
      cwd = '${fileDirname}',
      program = get_string('Path to dll', get_dll_path(), 'file'),
      args = get_table('Args'),
      env = {
        ASPNETCORE_ENVIRONMENT = get_string('Environment', config.netcoredbg.environment),
        ASPNETCORE_URL = get_string('Url', config.netcoredbg.url),
      }
    },
  }
end

function M.setup(opts)
  internal_global_config = vim.tbl_deep_extend("force", default_config, opts or {})

  local dap = load_module("dap")
  setup_adapter(dap, internal_global_config)
  setup_configuration(dap, internal_global_config)
end

return M
