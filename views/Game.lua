local screens = {
	MainMenu = require("views.MainMenu"),
	Gameplay = require("views.Gameplay"),
}

local screen = "MainMenu"
return function()
	local _screen = screens[screen]()
	if _screen then
		screen = _screen
	end
end
