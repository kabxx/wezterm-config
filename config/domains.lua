local wezterm = require('wezterm')
local platform = require('utils.platform')

local function find_ubuntu_distribution()
   local ubuntu_variant

   for _, domain in ipairs(wezterm.default_wsl_domains()) do
      if domain.distribution == 'Ubuntu' then
         return domain.distribution
      end

      if not ubuntu_variant and domain.distribution:match('^Ubuntu%-') then
         ubuntu_variant = domain.distribution
      end
   end

   return ubuntu_variant or 'Ubuntu'
end

---@type Config
local options = {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   ssh_domains = {},

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {},
}

if platform.is_win then
   options.wsl_domains = {
      {
         name = 'wsl:ubuntu',
         distribution = find_ubuntu_distribution(),
         username = 'wxh',
         default_cwd = '/home/wxh',
         default_prog = { 'zsh', '-l' },
      },
   }
end

return options
