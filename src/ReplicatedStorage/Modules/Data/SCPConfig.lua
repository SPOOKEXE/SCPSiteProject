
local Module = {}

Module.SCPs = {
	SCP_079 = {
		MaximumLevel = 5,

		PowerChargeRate = { 1, 2, 3, 4, 5 },

		GetMaxPower = function( Level )
			return 100 + (Level * 25)
		end,

		ExpBonusFromActions = {
			Default = 1,
		},
	},

	SCP_939 = {
		ListenRadius = 60,

	},
}

function Module:GetConfigFromID( SCP_ID )
	return Module.SCPs[ SCP_ID ]
end

return Module
