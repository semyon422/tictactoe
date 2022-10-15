local just = require("just")
local gfx_util = require("gfx_util")
local fonts = require("fonts")
local Button = require("views.Button")
local game = require("game")

return function()
	local width, height = love.graphics.getDimensions()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(fonts.Font72)
	gfx_util.printFrame("Tic Tac Toe", 0, 40, width, 200, "center", "bottom")

	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.setFont(fonts.Font16)
	love.graphics.translate(width - 200, 50)
	just.text("F11 - fullscreen", 200)

	love.graphics.origin()
	local bw = 150
	local x = 100
	love.graphics.translate(x, height / 2)
	love.graphics.setFont(fonts.Font16)
	love.graphics.setColor(1, 1, 1, 1)
	for _, level in ipairs(game.levels) do
		if Button(("%dx%d"):format(level, level), bw, bw / 3, game.level == level) then
			game.level = level
		end
	end
	if Button("Tips: " .. tostring(game.isTipsEnabled), bw, bw / 3) then
		game.isTipsEnabled = not game.isTipsEnabled
	end

	love.graphics.origin()
	love.graphics.translate(x + bw, height / 2)
	for _, mode in ipairs(game.modes) do
		if Button(mode[2], bw, bw / 3, game.mode == mode) then
			game.mode = mode
		end
	end
	if Button("Player 2 turns first: " .. tostring(game.isComputerTurnFirst), bw, bw / 3) then
		game.isComputerTurnFirst = not game.isComputerTurnFirst
	end

	local buttonWidth = 200
	love.graphics.origin()
	love.graphics.translate(width / 2 - buttonWidth / 2, height / 2)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(fonts.Font24)
	local screen
	if Button("Play", buttonWidth, buttonWidth / 3) then
		screen = "Gameplay"
		game:load()
	end
	if Button("Exit", buttonWidth, buttonWidth / 3) then
		love.event.quit()
	end
	return screen
end
