logger = hs.logger.new('init', 'debug')
-- allow `hs` cli
require("hs.ipc")
hs.ipc.cliInstall()

-- Install SpoonInstall if needed
local spoon_install_path = hs.spoons.resourcePath("Spoons")
if
  not pcall(function()
    logger.i("Checking if SpoonInstall is installed...")
    hs.fs.dir(spoon_install_path .. "/SpoonInstall.spoon")
  end)
then
  logger.i("Installing SpoonInstall...")
  status, body, headers = hs.http.get("https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip", nil)
  local zipfile = spoon_install_path .. "/SpoonInstall.spoon.zip"
  hs.fs.mkdir(spoon_install_path)
  io.open(zipfile, "w"):write(body):close()
  hs.execute(string.format("/usr/bin/unzip -d %s %s", spoon_install_path, zipfile))

  hs.execute(string.format("/bin/rm '%s'", zipfile))
  logger.i("Installed SpoonInstall!")
else
  logger.i("SpoonInstall already installed!")
end

hs.loadSpoon("SpoonInstall")
Install = spoon.SpoonInstall

Install:andUse("ReloadConfiguration", {
  hotkeys = {
    reloadConfiguration = { {"Ctrl"}, ";"}
  },
  start = true,
})

Install:andUse("FadeLogo", { start = true })

Install:andUse("RoundedCorners", {
  config = {
    radius = 10
  },
  start = true
})

Safari = "com.apple.Safari"
Chrome = 'com.google.Chrome'
Firefox = 'org.mozilla.firefox'
Zoom = 'us.zoom.xos'
Slack = 'com.tinyspeck.slackmacgap'

DefaultBrowser = Firefox
WorkBrowser = Chrome

require("private")

Install:andUse("URLDispatcher", {
  config = {
    url_patterns = {
	    { "https?://.*%.zoom%.us", Zoom },
	    { "https?://.*%.slack%.com", Slack },
    },
    default_handler = DefaultBrowser,
  },
  start = true,
})
