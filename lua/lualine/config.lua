-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local modules = require('lualine_require').lazy_require {
  utils_notices = 'lualine.utils.notices',
}

local config = {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = vim.go.laststatus == 3,
    refresh = {
      statusline = 1000,
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  extensions = {},
}

--- change separator format 'x' to {left='x', right='x'}
---@param separators string|table
---@return table
local function fix_separators(separators)
  if separators ~= nil then
    if type(separators) == 'string' then
      return { left = separators, right = separators }
    end
  end
  return separators
end

---copy raw disabled_filetypes to inner statusline tables.
---@param disabled_filetypes table
---@return table
local function fix_disabled_filetypes(disabled_filetypes)
  if disabled_filetypes == nil then
    return
  end
  if disabled_filetypes.statusline == nil then
    disabled_filetypes.statusline = {}
  end
  for k, disabled_ft in ipairs(disabled_filetypes) do
    table.insert(disabled_filetypes.statusline, disabled_ft)
    disabled_filetypes[k] = nil
  end
  return disabled_filetypes
end
---extends config based on config_table
---@param config_table table
---@return table copy of config
local function apply_configuration(config_table)
  if not config_table then
    return utils.deepcopy(config)
  end
  local function parse_sections(section_group_name)
    if config_table[section_group_name] == nil then
      return
    end
    if not next(config_table[section_group_name]) then
      config[section_group_name] = {}
      return
    end
    for section_name, section in pairs(config_table[section_group_name]) do
      if section_name == 'refresh' then
        config[section_group_name][section_name] =
          vim.tbl_deep_extend('force', config[section_group_name][section_name], utils.deepcopy(section))
      else
        config[section_group_name][section_name] = utils.deepcopy(section)
      end
    end
  end

  parse_sections('options')
  parse_sections('sections')
  parse_sections('inactive_sections')
  if config_table.extensions then
    config.extensions = utils.deepcopy(config_table.extensions)
  end
  config.options.section_separators = fix_separators(config.options.section_separators)
  config.options.component_separators = fix_separators(config.options.component_separators)
  config.options.disabled_filetypes = fix_disabled_filetypes(config.options.disabled_filetypes)
  return utils.deepcopy(config)
end

--- returns current active config
---@return table a copy of config
local function get_current_config()
  return utils.deepcopy(config)
end

return {
  get_config = get_current_config,
  apply_configuration = apply_configuration,
}
