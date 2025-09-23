local logger = hs.logger.new("init", "debug")
hs.ipc.cliInstall()

-- Install SpoonInstall if needed
local spoon_install_path = hs.configdir .. "/Spoons"
if
	pcall(function()
		logger.i("Checking if SpoonInstall is installed...")
		hs.fs.dir(spoon_install_path .. "/SpoonInstall.spoon")
	end)
then
	logger.i("SpoonInstall already installed!")
else
	logger.i("Installing SpoonInstall...")
	local status, body, headers =
		hs.http.get("https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip", nil)
	local zipfile = spoon_install_path .. "/SpoonInstall.spoon.zip"
	hs.fs.mkdir(spoon_install_path)
	io.open(zipfile, "w"):write(body):close()
	hs.execute(string.format("/usr/bin/unzip -d %s %s", spoon_install_path, zipfile))

	hs.execute(string.format("/bin/rm '%s'", zipfile))
	logger.i("Installed SpoonInstall!")
end

hs.loadSpoon("SpoonInstall")
local Install = spoon.SpoonInstall

Install:andUse("ReloadConfiguration", {
	hotkeys = { reloadConfiguration = { { "Ctrl" }, ";" } },
	start = true,
})

Install:andUse("RoundedCorners", {
	config = {
		radius = 10,
	},
	start = true,
})

Safari = "com.apple.Safari"
Chrome = "com.google.Chrome"
Firefox = "org.mozilla.firefox"
Zoom = "us.zoom.xos"
Slack = "com.tinyspeck.slackmacgap"

DefaultBrowser = Firefox
WorkBrowser = Chrome

Install:andUse("URLDispatcher", {
	config = {
		url_patterns = {
			{ "https?://.*%.zoom%.us/saml", WorkBrowser },
			{ "https?://.*%.zoom%.us/j", Zoom },
			{ "https?://app%.slack%.com", WorkBrowser },
			{ "https?://.*%.slack%.com/services", WorkBrowser },
			{ "https?://.*%.slack%.com", Slack },
			{ "https?://drive%.google%.com", WorkBrowser },
			{ "https?://slides%.google%.com", WorkBrowser },
			{ "https?://docs%.google%.com", WorkBrowser },
			{ "https?://calendar%.google%.com", WorkBrowser },
			{ "https?://.*%.google%.com/calendar", WorkBrowser },
			{ "https?://.*%.aws%.amazon%.com", WorkBrowser },
			{ "https?://login%.microsoftonline%.com", WorkBrowser },
			{ "https?://.*%.atlassian%.net", WorkBrowser },
			{ "https?://.*%.atlassian%.com", WorkBrowser },
			{ "https?://.*%.datadoghq%.com", WorkBrowser },
			{ "https?://.*%.pagerduty%.com", WorkBrowser },
			{ "https?://.*%.visualforce%.com", WorkBrowser },
			{ "https?://.*%.visual%.force%.com", WorkBrowser },
			{ "https?://.*%.vf%.force%.com", WorkBrowser },
			{ "https?://.*%.salesforce%.com", WorkBrowser },
			{ "https?://.*%.myworkday%.com", WorkBrowser },
			{ "https?://.*%.documentforce%.com", WorkBrowser },
			{ "https?://miro%.com", WorkBrowser },
			{ "https?://.*%.miro%.com", WorkBrowser },
			{ "https?://.*%.happyfox%.com", WorkBrowser },



		},
		default_handler = DefaultBrowser,
	},
	start = true,
})

Install:andUse("FadeLogo", { start = true })
