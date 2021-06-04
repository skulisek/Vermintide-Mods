local mod_name = "IngameTimer"

local user_setting = Application.user_setting

IngameTimer = {}

IngameTimer.session_time = 0
IngameTimer.last_update_time = 0

IngameTimer.widget_settings = {
	ACTIVE = {
		["save"] = "ingame_timer_active",
		["widget_type"] = "stepper",
		["text"] = "In-game Mission Timer",
		["tooltip"] =  "In-game Timer\n" ..
				"Enables an in-game timer showing the time spent in the current map.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Disabled", value = false},
			{text = "Enabled", value = true},
		},
		["default"] = 2, -- Default second option is enabled. In this case On
	},
    ACTIVE_IN_INN = {
        ["save"] = "ingame_timer_active_inn",
        ["widget_type"] = "stepper",
        ["text"] = "Inn Session Timer",
        ["tooltip"] =  "In-game Timer\n" ..
                "Enables an in-game timer showing the time spent in the current session.",
        ["value_type"] = "boolean",
        ["options"] = {
            {text = "Disabled", value = false},
            {text = "Enabled", value = true},
        },
        ["default"] = 2, -- Default second option is enabled. In this case On
    },
}

IngameTimer.create_options = function()
	Mods.option_menu:add_group("HUD", "In-game Timer")

	Mods.option_menu:add_item("HUD", IngameTimer.widget_settings.ACTIVE, true)
    Mods.option_menu:add_item("HUD", IngameTimer.widget_settings.ACTIVE_IN_INN, true)
end

GameTimerUI.update_absolute = function (self, dt)
	local resolution_modified = RESOLUTION_LOOKUP.modified
	local is_dirty = false

	if resolution_modified or self.cleanui_data.is_dirty then
		is_dirty = true
		self.timer_background.element.dirty = true
	end

	local current_network_time = Managers.state.network:network_time()

	if IngameTimer.last_update_time > current_network_time then
		IngameTimer.session_time = IngameTimer.session_time + IngameTimer.last_update_time
	end
	IngameTimer.last_update_time = current_network_time

    local time = current_network_time

    local game_mode_key = Managers.state.game_mode:game_mode_key()
    if game_mode_key == "inn" then
        time = IngameTimer.session_time + current_network_time
    end

	self:set_time(time)
	self:draw(dt)
end

Mods.hook.set(mod_name, "IngameHud.init", function(func, self, ingame_ui_context)
	self.is_in_inn = ingame_ui_context.is_in_inn
	local cutscene_system = Managers.state.entity:system("cutscene_system")
	self.cutscene_system = cutscene_system
	self.gdc_build = Development.parameter("gdc")
	ingame_ui_context.cleanui = UICleanUI.create()
	self.cleanui = ingame_ui_context.cleanui
	self.ui_renderer = ingame_ui_context.ui_renderer
	self.input_manager = ingame_ui_context.input_manager

	self:create_ui_elements()

	self.profile_synchronizer = ingame_ui_context.profile_synchronizer
	self.peer_id = ingame_ui_context.peer_id
	self.player_manager = ingame_ui_context.player_manager
	self.mission_system = Managers.state.entity:system("mission_system")
	self.subtitle_gui = SubtitleGui:new(ingame_ui_context)
	self.damage_indicator_gui = DamageIndicatorGui:new(ingame_ui_context)
	self.interaction_ui = InteractionUI:new(ingame_ui_context)
	self.tutorial_ui = TutorialUI:new(ingame_ui_context)
	self.area_indicator = AreaIndicatorUI:new(ingame_ui_context)
	self.mission_objective = MissionObjectiveUI:new(ingame_ui_context)
	self.crosshair = CrosshairUI:new(ingame_ui_context)
	self.fatigue_ui = FatigueUI:new(ingame_ui_context)
	self.bonus_dice_ui = BonusDiceUI:new(ingame_ui_context)
	self.ingame_player_list_ui = IngamePlayerListUI:new(ingame_ui_context)
	self.wait_for_rescue_ui = WaitForRescueUI:new(ingame_ui_context)
	self.positive_reinforcement_ui = PositiveReinforcementUI:new(ingame_ui_context)
	self.observer_ui = ObserverUI:new(ingame_ui_context)
	self.overcharge_bar_ui = OverchargeBarUI:new(ingame_ui_context)

	if PLATFORM == "win32" then
		self.player_inventory_ui = PlayerInventoryUI:new(ingame_ui_context)
	end

	if not script_data.disable_news_ticker then
		self.ingame_news_ticker_ui = IngameNewsTickerUI:new(ingame_ui_context)
	end

	self.gift_popup_ui = GiftPopupUI:new(ingame_ui_context)
	self.unit_frames_handler = UnitFramesHandler:new(ingame_ui_context)
	local game_mode_key = Managers.state.game_mode:game_mode_key()
	self.boon_ui = BoonUI:new(ingame_ui_context)
	local backend_settings = GameSettingsDevelopment.backend_settings

	if backend_settings.quests_enabled then
		self.contract_log_ui = ContractLogUI:new(ingame_ui_context)
	end

	-- Moved this out of the condition
	self.game_timer_ui = GameTimerUI:new(ingame_ui_context)
	if game_mode_key == "survival" then
		self.difficulty_unlock_ui = DifficultyUnlockUI:new(ingame_ui_context)
		self.difficulty_notification_ui = DifficultyNotificationUI:new(ingame_ui_context)
	end

	if self.gdc_build then
		self.gdc_start_ui = GDCStartUI:new(ingame_ui_context)
	end
end)

Mods.hook.set(mod_name, "IngameHud.update", function(func, self, dt, t, menu_active)
	local game_timer_ui = self.game_timer_ui
	local game_mode_key = Managers.state.game_mode:game_mode_key()

    if game_mode_key == "inn" and game_timer_ui and user_setting(IngameTimer.widget_settings.ACTIVE_IN_INN.save) then
		Profiler.start("updating game timer")
		game_timer_ui:update_absolute(dt)
		Profiler.stop("game timer")
	end

	if game_mode_key == "adventure" and game_timer_ui and user_setting(IngameTimer.widget_settings.ACTIVE.save) then
		Profiler.start("updating game timer")
		game_timer_ui:update_absolute(dt)
		Profiler.stop("game timer")
	end

	return func(self, dt, t, menu_active)
end)

IngameTimer.create_options()
