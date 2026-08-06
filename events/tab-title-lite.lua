local wezterm = require('wezterm')

local nf = wezterm.nerdfonts

local M = {}

local EDGE_BACKGROUND = 'rgba(0, 0, 0, 0.4)'
local ICON_SCIRCLE_LEFT = nf.ple_left_half_circle_thick
local ICON_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick

local PREFIX_ICON = {
   admin = nf.md_shield_half_full,
   wsl = nf.cod_terminal_linux,
   debug = nf.fa_bug,
   select = nf.md_selection_search,
   launcher = nf.oct_rocket,
   edit = nf.fa_edit,
}

-- Keep the original tab colors while avoiding the original mutable Cells graph.
local STYLE = {
   default = { bg = '#45475A', fg = '#1C1B19' },
   hover = { bg = '#7188b0', fg = '#1C1B19' },
   active = { bg = '#89b4fa', fg = '#11111B' },
}

local function starts_with(value, prefix)
   return value:sub(1, #prefix) == prefix
end

local function ends_with(value, suffix)
   return suffix == '' or value:sub(-#suffix) == suffix
end

local function clean_process_name(process_name)
   process_name = process_name or ''
   local name = process_name:gsub('.*[/\\](.*)', '%1')
   return name:gsub('%.exe$', '')
end

local function clean_title(title)
   title = (title or 'Terminal'):gsub('%c', ' '):match('^%s*(.-)%s*$')
   return title ~= '' and title or 'Terminal'
end

---Preserve the original lightweight prefix icons without scanning other panes.
local function create_base_title(pane_title, process_name)
   local icon
   local title = clean_title(pane_title)

   if title == 'Debug' then
      icon = PREFIX_ICON.debug
      title = title:upper()
   elseif title == 'Launcher' then
      icon = PREFIX_ICON.launcher
      title = title:upper()
   elseif starts_with(title, 'Administrator:') or ends_with(title, '(Admin)') then
      icon = PREFIX_ICON.admin
      title = title:gsub('Administrator: ', ''):gsub('%s*%(Admin%)$', '')
   elseif starts_with(process_name, 'wsl') then
      icon = PREFIX_ICON.wsl
   elseif starts_with(title, 'InputSelector:') then
      icon = PREFIX_ICON.select
      title = title:gsub('^InputSelector:%s*', '')
   elseif starts_with(title, 'InputLine:') then
      icon = PREFIX_ICON.edit
      title = title:gsub('^InputLine:%s*', '')
   end

   return title, icon
end


local function fit_title(process_name, base_title, max_width, has_icon)
   local title = process_name ~= '' and process_name .. ' ~ ' .. base_title or base_title
   local inset = has_icon and 6 or 4
   local available = math.max(1, (max_width or 23) - inset)
   local width = wezterm.column_width(title)

   if width > available then
      return wezterm.truncate_right(title, available)
   end

   return title .. string.rep(' ', available - width)
end

---Format tabs with the original pill appearance but without progress, unseen-output,
---pane scans, retained tab state, or the shared mutable Cells renderer.
function M.setup()
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
      local pane = tab.active_pane or {}
      local process_name = clean_process_name(pane.foreground_process_name)
      local base_title, prefix_icon = create_base_title(pane.title, process_name)
      local title = fit_title(process_name, base_title, max_width, prefix_icon ~= nil)

      local state = 'default'
      if tab.is_active then
         state = 'active'
      elseif hover then
         state = 'hover'
      end
      local style = STYLE[state]

      -- Direct, bounded FormatItem list: same colors and glyphs as the original style.
      local items = {
         { Background = { Color = EDGE_BACKGROUND } },
         { Foreground = { Color = style.bg } },
         { Text = ICON_SCIRCLE_LEFT },
         { Background = { Color = style.bg } },
         { Foreground = { Color = style.fg } },
         { Text = ' ' },
      }

      if prefix_icon then
         items[#items + 1] = { Text = prefix_icon }
         items[#items + 1] = { Text = ' ' }
      end

      items[#items + 1] = { Attribute = { Intensity = 'Bold' } }
      items[#items + 1] = { Text = title }
      items[#items + 1] = { Attribute = { Intensity = 'Normal' } }
      items[#items + 1] = { Text = ' ' }
      items[#items + 1] = { Background = { Color = EDGE_BACKGROUND } }
      items[#items + 1] = { Foreground = { Color = style.bg } }
      items[#items + 1] = { Text = ICON_SCIRCLE_RIGHT }
      items[#items + 1] = 'ResetAttributes'

      return items
   end)
end

return M
