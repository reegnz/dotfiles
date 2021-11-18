# allow `hs` cli
require("hs.ipc")
hs.ipc.cliInstall()

hs.loadSpoon("SpoonInstall")
Install = spoon.SpoonInstall

Install:andUse("ReloadConfiguration", {
  start = true,
})

Safari = "com.apple.Safari"
Chrome = 'com.google.Chrome'
Firefox = 'org.mozilla.firefox'
Zoom = 'us.zoom.xos'
DefaultBrowser = Chrome

Install:andUse("URLDispatcher", {
  config = {
    url_patterns = {
	    { "https?://.*%.zoom%.us", Zoom },
	    { "https?://.*github.com", Firefox },
    },
    default_handler = DefaultBrowser,
  },
  start = true,
})
