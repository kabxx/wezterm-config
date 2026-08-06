local Config = require('config')
local wezterm = require('wezterm')

require('utils.backdrops')
   -- :set_images_dir(require('wezterm').home_dir .. '/Pictures/Wallpapers/')
   :scan_images_dir()
   :random()

require('events.left-status').setup()
require('events.right-status').setup({ date_format = '%a %H:%M:%S' })
require('events.auto-backdrop').setup({ interval_minutes = 60 })
require('events.tab-title-lite').setup()
require('events.new-tab-button').setup()
require('events.gui-startup').setup()

-- Keep tab-bar toggling independent from the disabled heavyweight title formatter.
wezterm.on('tabs.toggle-tab-bar', function(window, _pane)
   local effective_config = window:effective_config()
   window:set_config_overrides({
      enable_tab_bar = not effective_config.enable_tab_bar,
      background = effective_config.background,
   })
end)

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
