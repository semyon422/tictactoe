local game = {}

game.levels = {3, 4, 5}
game.modes = {
	{"pvc", "Player vs Computer"},
	{"pvp", "Player vs Player"},
	{"cvc", "Computer vs Computer"},
}

game.level = game.levels[1]
game.mode = game.modes[1]
game.isComputerTurnFirst = false
game.isTipsEnabled = false
game.turningPlayer = 1
game.waitingPlayer = 2

function game:load()
	local field = {}
	local possibleWinners = {}
	for i = 1, self.level do
		field[i] = {}
		possibleWinners[i] = {}
	end
	self.field = field
	self.possibleWinners = possibleWinners
	self.bestTurn = {}

	self.winner = nil
	self.turningPlayer = 1
	self.waitingPlayer = 2

	if self.isComputerTurnFirst or self.mode[1] == "cvc" then
		self:switchPlayer()
		self:turnByComputer(true)
	end
end

function game:switchPlayer()
	self.turningPlayer, self.waitingPlayer = self.waitingPlayer, self.turningPlayer
end

function game:compute()
	local possibleWinners = self.possibleWinners
	local field = self.field
	local level = self.level
	if level == 3 then
		for i = 1, level do
			for j = 1, level do
				if not field[i][j] then
					possibleWinners[i][j] = game:recursiveGetWinner(i, j)
				else
					possibleWinners[i][j] = nil
				end
			end
		end
	end
	self.bestTurn = {game:getBestTurn()}
end

function game:getWinner()
	local winner
	for player = 1, 2 do
		if self:checkWinner(player) then
			winner = player
		end
	end
	return winner
end

function game:turn(i, j)
	local field = self.field
	if self.winner or field[i][j] then
		return
	end
	field[i][j] = self.turningPlayer
	self:switchPlayer()
	self.winner = self:getWinner()
	game:compute()
	self:turnByComputer()
end

function game:turnByComputer(isRandom)
	local mode = self.mode[1]
	if not (mode == "cvc" or mode == "pvc" and self.turningPlayer == 2) then
		return
	end
	local i, j
	if isRandom then
		local r = love.math.random
		i, j = r(self.level), r(self.level)
	end
	if not i then
		i, j = self:getBestTurn()
	end
	if not i then
		i, j = self:getEmptyTurn()
	end
	if i then
		self:turn(i, j)
	end
end

function game:checkWinner(player)
	local level = self.level
	local field = self.field

	local diag1, diag2 = true, true
	for i = 1, level do
		diag1 = diag1 and player == field[i][i]
		diag2 = diag2 and player == field[i][level - i + 1]
	end
	if diag1 then
		return "diag", 1
	elseif diag2 then
		return "diag", 2
	end

	for i = 1, level do
		local row = true
		local col = true
		for j = 1, level do
			row = row and player == field[i][j]
			col = col and player == field[j][i]
		end
		if row then
			return "row", i
		elseif col then
			return "col", i
		end
	end
end

function game:recursiveGetWinner(i, j)
	local level = self.level
	local field = self.field
	local turningPlayer = self.turningPlayer
	if field[i][j] then
		return
	end
	field[i][j] = turningPlayer
	if self:checkWinner(turningPlayer) then
		field[i][j] = nil
		return turningPlayer
	end
	self:switchPlayer()
	local _i, _j, _winner = self:getBestTurn()
	if not _i then
		for q = 1, level do
			for w = 1, level do
				if not field[q][w] then
					local winner = self:recursiveGetWinner(q, w)
					if winner == self.turningPlayer then
						_i, _j, _winner = q, w, winner
					end
				end
			end
		end
	end
	if not _i then
		for q = 1, level do
			for w = 1, level do
				if not field[q][w] then
					local winner = self:recursiveGetWinner(q, w)
					if not winner then
						self:switchPlayer()
						field[i][j] = nil
						return
					end
				end
			end
		end
	end
	if not _i then
		for q = 1, level do
			for w = 1, level do
				if not field[q][w] then
					_winner = self.waitingPlayer
				end
			end
		end
	end
	local winner = _winner
	if _i and not winner then
		winner = self:recursiveGetWinner(_i, _j)
	end
	self:switchPlayer()
	field[i][j] = nil
	return winner
end

function game:findTurn(line, num, player)
	local field = self.field
	local found
	for i = 1, self.level do
		if line == "row" then
			found = found or field[num][i] == player
		elseif line == "col" then
			found = found or field[i][num] == player
		elseif line == "diag" then
			if num == 1 then
				found = found or field[i][i] == player
			elseif num == 2 then
				found = found or field[i][self.level - i + 1] == player
			end
		end
	end
	return found
end

local diagPriorities = {
	[4] = {
		[1] = {{2, 2}, {3, 3}, {1, 1}, {4, 4}},
		[2] = {{2, 3}, {3, 2}, {1, 4}, {4, 1}},
	},
	[5] = {
		[1] = {{2, 2}, {4, 4}, {1, 1}, {5, 5}},
		[2] = {{2, 4}, {4, 2}, {1, 5}, {5, 1}},
	},
}

function game:getEmptyTurn()
	local level = self.level
	local field = self.field
	local possibleWinners = self.possibleWinners
	for i = 1, level do
		for j = 1, level do
			if not field[i][j] and possibleWinners[i][j] == self.turningPlayer then
				return i, j
			end
		end
	end
	for i = 1, level do
		for j = 1, level do
			if not field[i][j] and possibleWinners[i][j] ~= self.waitingPlayer then
				return i, j
			end
		end
	end
	for i = 1, level do
		for j = 1, level do
			if not field[i][j] then
				return i, j
			end
		end
	end
end

function game:getBestTurn()
	local level = self.level
	local field = self.field
	local turningPlayer = self.turningPlayer
	local waitingPlayer = self.waitingPlayer

	local turnsCount = 0
	local emptyPair, winPair, preventPair
	for i = 1, level do
		for j = 1, level do
			if not field[i][j] then
				field[i][j] = turningPlayer
				if self:checkWinner(turningPlayer) then
					field[i][j] = nil
					winPair = {i, j, turningPlayer}
				end
				field[i][j] = waitingPlayer
				if self:checkWinner(waitingPlayer) then
					field[i][j] = nil
					preventPair = {i, j}
				end
				field[i][j] = nil
				emptyPair = {i, j}
			else
				turnsCount = turnsCount + 1
			end
		end
	end
	if winPair then
		return unpack(winPair)
	end
	if preventPair then
		return unpack(preventPair)
	end
	if turnsCount == level ^ 2 - 1 then
		return unpack(emptyPair)
	end

	if level == 3 then  -- there are full recursive search for level 3
		return
	end

	-- prevent waiting player from winning
	if level == 5 and not field[3][3] then
		return 3, 3
	end
	for i = 1, level do
		if not game:findTurn("row", i, turningPlayer) then
			for j = 1, level do
				if not field[i][j] and not game:findTurn("col", j, turningPlayer) then
					return i, j
				end
			end
			for j = 1, level do
				if not field[i][j] then
					return i, j
				end
			end
		end
	end
	for diag = 1, 2 do
		if not game:findTurn("diag", diag, turningPlayer) then
			for _, dp in ipairs(diagPriorities[level][diag]) do
				local i, j = unpack(dp)
				if not field[i][j] then
					return i, j
				end
			end
		end
	end

	-- try to win
	for diag = 1, 2 do
		if not game:findTurn("diag", diag, waitingPlayer) then
			for _, dp in ipairs(diagPriorities[level][diag]) do
				local i, j = unpack(dp)
				if not field[i][j] then
					return i, j
				end
			end
		end
	end
	for i = 1, level do
		if not game:findTurn("row", i, waitingPlayer) then
			for j = 1, level do
				if not field[i][j] then
					return i, j
				end
			end
		end
		if not game:findTurn("col", i, waitingPlayer) then
			for j = 1, level do
				if not field[j][i] then
					return j, i
				end
			end
		end
	end
end

return game
