--!strict

local Players = game:GetService("Players")

-- Server entry point
print("[Server] Game server started")

Players.PlayerAdded:Connect(function(player: Player)
	print(`[Server] {player.Name} joined the game`)

	-- Set up leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	player.CharacterAdded:Connect(function(_character: Model)
		print(`[Server] {player.Name} spawned`)
	end)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	print(`[Server] {player.Name} left the game`)
end)
