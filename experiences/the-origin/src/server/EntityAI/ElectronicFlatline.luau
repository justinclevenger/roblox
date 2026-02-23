--!strict

--[[
    Electronic Flatline

    The Patient's unique mechanic. When within 20 studs:
    - Player flashlights flicker and dim
    - CCTV monitors show static
    - Radios buzz

    This serves as an early warning system that players learn to read.
]]

local Players = game:GetService("Players")

local ElectronicFlatline = {}

local FLATLINE_RANGE = 20
local _FLATLINE_INTERVAL = 2 -- check every 2 seconds

function ElectronicFlatline.check(entityPosition: Vector3)
	local Remotes = require(script.Parent.Parent.Remotes)

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if not character then
			continue
		end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end

		local distance = (hrp.Position - entityPosition).Magnitude
		if distance <= FLATLINE_RANGE then
			-- Player is within flatline range — flicker their electronics
			if Remotes.FlashlightFlicker then
				Remotes.FlashlightFlicker:FireClient(player)
			end
		end
	end
end

return ElectronicFlatline
