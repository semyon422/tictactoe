local just = require("just")
local gfx_util = require("gfx_util")

local scale = 0.8
return function(text, w, h, outlined)
	local changed, active, hovered = just.button(text, just.is_over(w, h))

	love.graphics.setColor(1, 1, 1, 0.2)
	if hovered then
		local alpha = active and 0.4 or 0.3
		love.graphics.setColor(1, 1, 1, alpha)
	end

	local x = h * (1 - scale) / 2
	love.graphics.rectangle("fill", x, x, w - x * 2, h - x * 2, h / 2 * scale)
	love.graphics.setColor(1, 1, 1, 1)
	if outlined then
		love.graphics.rectangle("line", x, x, w - x * 2, h - x * 2, h / 2 * scale)
	end

	gfx_util.printFrame(text, 0, 0, w, h, "center", "center")

	just.next(w, h)

	return changed
end
