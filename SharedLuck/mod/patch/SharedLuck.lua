--[[
	author: Ithiridiel
	
	Makes the strongest luck trinket apply to the whole team.
--]]
local mod_name = "SharedLuck"
local SharedLuck = {}

SharedLuck.luck_options_menu = {
	FILE_ENABLED = {
		["save"] = "shared_luck_file_enabled",
		["widget_type"] = "stepper",
		["text"] = "Shared luck trinkets",
		["tooltip"] =  "Makes everyone benefit from the strongest luck trinket equipped in the team",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	},
	PRINT_ENABLED = {
		["save"] = "shared_luck_print_enabled",
		["widget_type"] = "stepper",
		["text"] = "Send chat message",
		["tooltip"] =  "If turned on, a chat message will be sent with the loot die spawn chance",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1,
	}
}

SharedLuck.luck_options_menu.create_options = function()
	Mods.option_menu:add_group("chest", "Chest")

	Mods.option_menu:add_item("chest", SharedLuck.luck_options_menu.FILE_ENABLED, true)
	Mods.option_menu:add_item("chest", SharedLuck.luck_options_menu.PRINT_ENABLED, true)
end

local ScriptUnit = ScriptUnit
Mods.hook.set(mod_name, "BuffExtension.apply_buffs_to_value", function (func, self, value, stat_buff)

	if stat_buff == StatBuffIndex.INCREASE_LUCK then

		-- I think that checking if the mod is enabled every time is not very elegant, but I dont know how to make it so
		if not Application.user_setting((SharedLuck.luck_options_menu.FILE_ENABLED).save) then
			return func(self, value, stat_buff)
		end

		local player_and_bot_units = PLAYER_AND_BOT_UNITS
		local num_player_units = #player_and_bot_units

		local highest_chance = value

		for i = 1, num_player_units, 1 do
			local player_unit = player_and_bot_units[i]
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

			local stat_buffs = buff_extension._stat_buffs[stat_buff]
			local final_value = value

			for _, stat_buff_data in pairs(stat_buffs) do
				local bonus = stat_buff_data.bonus
				local multiplier = 1 + stat_buff_data.multiplier
				final_value = (final_value + bonus) * multiplier
			end

			highest_chance = math.max(highest_chance, final_value)
		end

		if Application.user_setting((SharedLuck.luck_options_menu.PRINT_ENABLED).save) then
			EchoConsole("Highest chance was: " .. highest_chance)
		end

		local _, procced, parent_id = func(self, value, stat_buff)
		return highest_chance, procced, parent_id
	end

	return func(self, value, stat_buff)
end)

SharedLuck.luck_options_menu.create_options()