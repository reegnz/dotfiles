# allow `hs` cli
require("hs.ipc")
hs.ipc.cliInstall()

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
