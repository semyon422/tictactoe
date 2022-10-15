local just = require("just")
local Button = require("views.Button")
local Cell = require("views.Cell")
local game = require("game")

local function drawTip(i, j, size)
	local bi, bj = unpack(game.bestTurn)
	if game.isTipsEnabled and not game.winner then
		local possibleWinner = game.possibleWinners[i][j]
		if possibleWinner == game.turningPlayer then
			love.graphics.setColor(0.1, 1, 0.8, 0.4)
			love.graphics.rectangle("fill", 0, 0, size, size)
		elseif possibleWinner == game.waitingPlayer then
			love.graphics.setColor(1, 0.1, 0.1, 0.4)
			love.graphics.rectangle("fill", 0, 0, size, size)
		elseif i == bi and j == bj then
			love.graphics.setColor(1, 1, 0.1, 0.4)
			love.graphics.rectangle("fill", 0, 0, size, size)
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
end

local _size = 0
local function _x(i)
	return (i - 0.5) * _size
end

local function drawWinnerLine(size)
	_size = size
	local level = game.level
	local line, num = game:checkWinner(game.winner)

	love.graphics.setLineWidth(16)
	love.graphics.setColor(0.2, 1, 0.7, 1)

	local a, b = _x(1), _x(level)
	if line == "diag" then
		love.graphics.line(a, _x(1 + (level - 1) * (num - 1)), b, _x(1 + (level - 1) * (num % 2)))
	elseif line == "row" then
		love.graphics.line(a, _x(num), b, _x(num))
	elseif line == "col" then
		love.graphics.line(_x(num), a, _x(num), b)
	end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1, 1)
end

return function()
	local width, height = love.graphics.getDimensions()

	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)

	local level = game.level
	just.text("FPS: " .. love.timer.getFPS())
	just.text("Level: " .. ("%dx%d"):format(level, level))
	just.text("Mode: " .. game.mode[2])
	just.text("Turning player: " .. game.turningPlayer)
	if game.winner then
		just.text("Winner: " .. game.winner)
	end

	local size = 100

	love.graphics.origin()
	love.graphics.translate((width - size * level) / 2, (height - size * level) / 2)

	for i = 1, level do
		just.row(true)
		for j = 1, level do
			drawTip(i, j, size)
			if Cell(i, j, game.field[i][j], size) then
				game:turn(i, j)
			end
		end
		just.row(false)
	end

	love.graphics.origin()
	love.graphics.translate((width - size * level) / 2, (height - size * level) / 2)
	if game.winner then
		drawWinnerLine(size)
	end

	love.graphics.origin()
	love.graphics.translate(100, height / 2)
	if Button("restart", 200, 200 / 3) then
		game:load()
	end
	if Button("back", 200, 200 / 3) then
		return "MainMenu"
	end
end
