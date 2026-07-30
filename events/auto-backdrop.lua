local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')

local M = {}

---@param opts { interval_minutes: number }
M.setup = function(opts)
   local interval_seconds = opts.interval_minutes * 60
   local next_switch_by_window = {}

   wezterm.on('update-status', function(window, _pane)
      local window_id = window:window_id()
      local now = os.time()

      if next_switch_by_window[window_id] == nil then
         next_switch_by_window[window_id] = now + interval_seconds
         return
      end

      if now >= next_switch_by_window[window_id] then
         next_switch_by_window[window_id] = now + interval_seconds
         if not backdrops.no_img then
            backdrops:random(window)
         end
      end
   end)
end

return M
