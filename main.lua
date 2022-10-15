local just = require("just")
local Game = require("views.Game")

function love.mousemoved(x, y)
	if just.callbacks.mousemoved(x, y) then return end
end

function love.mousepressed(x, y, button)
	if just.callbacks.mousepressed(x, y, button) then return end
end

function love.mousereleased(x, y, button)
	if just.callbacks.mousereleased(x, y, button) then return end
end

function love.wheelmoved(x, y)
	if just.callbacks.wheelmoved(x, y) then return end
end

function love.keypressed(_, key)
	if just.callbacks.keypressed(_, key) then return end
	if key == "f11" then
		return love.window.setFullscreen(not love.window.getFullscreen())
	end
end

function love.draw()
	Game()
	just._end()
end
