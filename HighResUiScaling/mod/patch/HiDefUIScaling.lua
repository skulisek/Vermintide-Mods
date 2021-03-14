--[[
	Credit: Aussiemon
	https://github.com/Aussiemon/Vermintide-JHF-Mods/tree/master/hi_def_ui_scaling

	Provides better UI scaling for higher-resolution displays.
--]]

local HiDefUIScalingMod, mod_name, oi = Mods.new_mod("HiDefUIScaling")

local scale = 4

HiDefUIScalingMod.SETTINGS = {
	ENABLED = {
		["save"] = "cb_res_scaling",
		["widget_type"] = "stepper",
		["text"] = "Resolution Scaling Enabled",
		["tooltip"] = "Enables UI Scaling for high resolutions",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	}
}

Mods.hook.set(mod_name, "UIResolutionScale", function (func, ...)

	if not Application.user_setting((HiDefUIScalingMod.SETTINGS.ENABLED).save) then
		return func(...)
	end

	local width, height = UIResolution()

	if width > UIResolutionWidthFragments() and height > UIResolutionHeightFragments() then

		local width_scale_c = width / UIResolutionWidthFragments()
		local height_scale_c = height / UIResolutionHeightFragments()

		local width_scale = math.min(width_scale_c, scale)
		local height_scale = math.min(height_scale_c, scale)
		local ret = math.min(width_scale, height_scale)

		return ret
	else
		return func(...)
	end
end)

local function create_options()
	Mods.option_menu:add_group("hidef_scaling_group", "High Definition UI Scaling")
	Mods.option_menu:add_item("hidef_scaling_group", HiDefUIScalingMod.SETTINGS.ENABLED, true)
end

safe_pcall(create_options)
UPDATE_RESOLUTION_LOOKUP(true)