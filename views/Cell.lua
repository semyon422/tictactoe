local just = require("just")

local scale = 0.9
local signScale = 0.6 * scale
return function(i, j, player, size)
	local changed, active, hovered = just.button(i .. "-" .. j, just.is_over(size, size))

	love.graphics.setColor(1, 1, 1, 0.2)
	if hovered then
		local alpha = active and 0.4 or 0.3
		love.graphics.setColor(1, 1, 1, alpha)
	end

	local x = size * (1 - scale) / 2
	love.graphics.rectangle("fill", x, x, size - x * 2, size - x * 2, 24)
	love.graphics.setColor(1, 1, 1, 1)

	x = size * (1 - signScale) / 2
	local w = size - x * 2
	love.graphics.setLineWidth(8)
	if player == 1 then
		love.graphics.line(x, x, x + w, x + w)
		love.graphics.line(x + w, x, x, x + w)
	elseif player == 2 then
		love.graphics.circle("line", size / 2, size / 2, w / 2)
	end
	love.graphics.setLineWidth(1)

	just.next(size, size)

	return changed
end
