-- MuteClock v2 - Cooldown Tracker for TurtleWoW / Vanilla 1.12

-- -------------------------------------------------------
-- Defaults
-- -------------------------------------------------------
DEF_SH_ALL_CHARACTERS  = 1;
DEF_DO_NOTIFY          = 1;
DEF_POSITION_X         = nil;
DEF_POSITION_Y         = nil;
DEF_DOT_SIZE           = 16;
DEF_DOT_HIDDEN         = 0;
DEF_DISPLAY_MODE       = 0;   -- 0=dot, 1=bar, 2=mini-panel
DEF_ICON_MODE          = 1;   -- 0=dot only, 1=smart, 2=arcanite, 3=mooncloth, 4=cure rugged hide
DEF_GROUP_BY_CRAFT     = 0;
DEF_SHOW_READY_TIME    = 0;
DEF_SHOW_OVERDUE       = 1;
DEF_SHOW_LAST_CRAFTED  = 0;
DEF_SHOW_BADGE         = 0;
DEF_TOOLTIP_MODE       = 0;   -- 0=My Cooldowns, 1=Crafters
DEF_OVERDUE_REMIND     = 0;   -- hours between overdue reminders (0=off)

-- -------------------------------------------------------
-- Runtime globals
-- -------------------------------------------------------
CURRENT_PLAYER_NAME   = "";
SH_ALL_CHARACTERS     = DEF_SH_ALL_CHARACTERS;
DO_NOTIFY             = DEF_DO_NOTIFY;
POSITION_X            = DEF_POSITION_X;
POSITION_Y            = DEF_POSITION_Y;
DOT_SIZE              = DEF_DOT_SIZE;
DOT_HIDDEN            = DEF_DOT_HIDDEN;
DISPLAY_MODE          = DEF_DISPLAY_MODE;
ICON_MODE             = DEF_ICON_MODE;
GROUP_BY_CRAFT        = DEF_GROUP_BY_CRAFT;
SHOW_READY_TIME       = DEF_SHOW_READY_TIME;
SHOW_OVERDUE          = DEF_SHOW_OVERDUE;
SHOW_LAST_CRAFTED     = DEF_SHOW_LAST_CRAFTED;
SHOW_BADGE            = DEF_SHOW_BADGE;
TOOLTIP_MODE          = DEF_TOOLTIP_MODE;
OVERDUE_REMIND        = DEF_OVERDUE_REMIND;

IS_VARIABLES_LOADED   = 0;
CraftingItemName      = nil;
isCraftSuccess        = 0;
MC_SESSION_NOTIFIED   = {};   -- { "charName:craftKey" = true } reset each session

HISTORY_MAX  = 20;
MC_PEERS     = {};
MC_FRIENDS   = {};
MC_NEARBY    = {};

-- -------------------------------------------------------
-- Tracked crafts
-- -------------------------------------------------------
TRACKED_CRAFTS = {
	{ key = "Transmute: Arcanite", label = "Arcanite",   short = "Arc", icon = "Interface\\Icons\\INV_Misc_Stonetablet_05"   },
	{ key = "Mooncloth",           label = "Mooncloth",  short = "Moo", icon = "Interface\\Icons\\INV_Fabric_Moonrag_01"    },
	{ key = "Cure Rugged Hide",    label = "Rugged Hide",short = "Cur", icon = "Interface\\Icons\\INV_Misc_LeatherScrap_02" },
};

ICON_MODE_OPTIONS = {
	{ value = 0, text = "Dot only"         },
	{ value = 1, text = "Smart (auto)"     },
	{ value = 2, text = "Arcanite bar"     },
	{ value = 3, text = "Mooncloth"        },
	{ value = 4, text = "Cure Rugged Hide" },
};

DISPLAY_MODE_OPTIONS = {
	{ value = 0, text = "Dot"        },
	{ value = 1, text = "Bar"        },
	{ value = 2, text = "Mini-panel" },
};

OVERDUE_REMIND_OPTIONS = {
	{ value = 0,  text = "Off"        },
	{ value = 2,  text = "Every 2h"   },
	{ value = 4,  text = "Every 4h"   },
	{ value = 8,  text = "Every 8h"   },
	{ value = 24, text = "Once a day" },
};

MC_CTRL = "MuteClockConfigFramePanelSettings";

-- -------------------------------------------------------
-- getCraftEntry
-- -------------------------------------------------------
function getCraftEntry(craftKey)
	for _, entry in ipairs(TRACKED_CRAFTS) do
		if (craftKey == entry.key) then return entry; end
	end
	return nil;
end

-- -------------------------------------------------------
-- SavedVariable helper
-- -------------------------------------------------------
function mcLoad(key, default)
	local v = MuteClock[CURRENT_PLAYER_NAME][key];
	if (v == nil) then
		MuteClock[CURRENT_PLAYER_NAME][key] = default;
		return default;
	end
	return v;
end

-- -------------------------------------------------------
-- VARIABLES_LOADED
-- -------------------------------------------------------
function onVariablesLoaded()
	if (not MuteClock) then MuteClock = {}; end

	-- First-ever load detection (before creating player key)
	local isFirstLoad = (MuteClock[CURRENT_PLAYER_NAME] == nil);

	if (not MuteClock[CURRENT_PLAYER_NAME]) then
		MuteClock[CURRENT_PLAYER_NAME] = {};
	end

	SH_ALL_CHARACTERS = mcLoad("sh_all_characters", DEF_SH_ALL_CHARACTERS);
	DO_NOTIFY         = mcLoad("do_notify",         DEF_DO_NOTIFY);
	POSITION_X        = mcLoad("position_x",        DEF_POSITION_X);
	POSITION_Y        = mcLoad("position_y",        DEF_POSITION_Y);
	DOT_SIZE          = mcLoad("dot_size",           DEF_DOT_SIZE);
	DOT_HIDDEN        = mcLoad("dot_hidden",         DEF_DOT_HIDDEN);
	DISPLAY_MODE      = mcLoad("display_mode",       DEF_DISPLAY_MODE);
	GROUP_BY_CRAFT    = mcLoad("group_by_craft",     DEF_GROUP_BY_CRAFT);
	SHOW_READY_TIME   = mcLoad("show_ready_time",    DEF_SHOW_READY_TIME);
	SHOW_OVERDUE      = mcLoad("show_overdue",       DEF_SHOW_OVERDUE);
	SHOW_LAST_CRAFTED = mcLoad("show_last_crafted",  DEF_SHOW_LAST_CRAFTED);
	SHOW_BADGE        = mcLoad("show_badge",         DEF_SHOW_BADGE);
	TOOLTIP_MODE      = mcLoad("tooltip_mode",       DEF_TOOLTIP_MODE);
	ICON_MODE         = mcLoad("icon_mode",          DEF_ICON_MODE);
	OVERDUE_REMIND    = mcLoad("overdue_remind",     DEF_OVERDUE_REMIND);

	-- Migrate old SMART_ICON boolean
	local oldSmart = MuteClock[CURRENT_PLAYER_NAME]["smart_icon"];
	if (oldSmart ~= nil and MuteClock[CURRENT_PLAYER_NAME]["icon_mode"] == nil) then
		ICON_MODE = (oldSmart == 1) and 1 or 0;
		MuteClock[CURRENT_PLAYER_NAME]["icon_mode"] = ICON_MODE;
	end

	IS_VARIABLES_LOADED = 1;

	if (MuteClock._peers) then
		MC_PEERS = MuteClock._peers;
	else
		MuteClock._peers = {};
		MC_PEERS = MuteClock._peers;
	end

	if (MuteClock._friends) then
		MC_FRIENDS = MuteClock._friends;
	else
		MuteClock._friends = {};
		MC_FRIENDS = MuteClock._friends;
	end

	if (not MuteClock._manual) then
		MuteClock._manual = {};
	end

	doApplyDisplayMode();
	doPositionFrame();
	doRunNotifications();

	if (isFirstLoad) then
		doShowOnboarding();
	end
end

-- -------------------------------------------------------
-- Persist settings
-- -------------------------------------------------------
function doSaveSettings()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	local p = MuteClock[CURRENT_PLAYER_NAME];
	p.sh_all_characters = SH_ALL_CHARACTERS;
	p.do_notify         = DO_NOTIFY;
	p.position_x        = POSITION_X;
	p.position_y        = POSITION_Y;
	p.dot_size          = DOT_SIZE;
	p.dot_hidden        = DOT_HIDDEN;
	p.display_mode      = DISPLAY_MODE;
	p.icon_mode         = ICON_MODE;
	p.group_by_craft    = GROUP_BY_CRAFT;
	p.show_ready_time   = SHOW_READY_TIME;
	p.show_overdue      = SHOW_OVERDUE;
	p.show_last_crafted = SHOW_LAST_CRAFTED;
	p.show_badge        = SHOW_BADGE;
	p.tooltip_mode      = TOOLTIP_MODE;
	p.overdue_remind    = OVERDUE_REMIND;
end

-- -------------------------------------------------------
-- Onboarding: first-load welcome tooltip
-- -------------------------------------------------------
function doShowOnboarding()
	ClockFrame.OnboardingTimer = 30;
	doUpdateOnboardingTooltip();
end

function doUpdateOnboardingTooltip()
	if (not ClockFrame.OnboardingTimer or ClockFrame.OnboardingTimer <= 0) then return; end
	GameTooltip:SetOwner(ClockFrame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPRIGHT", "ClockFrame", "TOPLEFT", -4, -8);
	GameTooltip:ClearLines();
	GameTooltip:AddLine("|cFF00FF00Welcome to MuteClock!|r");
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("Tracks your crafting cooldowns.", 0.9, 0.9, 0.9);
	GameTooltip:AddLine("Open a trade skill window to start.", 0.9, 0.9, 0.9);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("|cFF444444Right-click for options.|r");
	GameTooltip:Show();
end

-- -------------------------------------------------------
-- Display mode: dot / bar / mini-panel
-- -------------------------------------------------------
function doApplyDisplayMode()
	if (DOT_HIDDEN == 1) then
		ClockFrame:Hide();
		ClockBarFrame:Hide();
		ClockMiniPanel:Hide();
		return;
	end

	if (DISPLAY_MODE == 1) then
		ClockFrame:Hide();
		ClockBarFrame:Show();
		ClockMiniPanel:Hide();
		doUpdateBar();
	elseif (DISPLAY_MODE == 2) then
		ClockFrame:Hide();
		ClockBarFrame:Hide();
		ClockMiniPanel:Show();
		doUpdateMiniPanel();
	else
		-- Dot mode
		ClockFrame:SetWidth(DOT_SIZE);
		ClockFrame:SetHeight(DOT_SIZE);
		ClockFrame:Show();
		ClockBarFrame:Hide();
		ClockMiniPanel:Hide();
		doUpdateDot();
	end
end

-- Legacy alias used in various places
function doApplyDotAppearance()
	doApplyDisplayMode();
end

function doPositionFrame()
	local function pos(f)
		f:ClearAllPoints();
		if (POSITION_X == nil or POSITION_Y == nil) then
			f:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
		else
			f:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", POSITION_X, POSITION_Y);
		end
	end
	pos(ClockFrame);
	pos(ClockBarFrame);
	pos(ClockMiniPanel);
end

-- -------------------------------------------------------
-- Bar mode update
-- Bar: one row per tracked craft that has data.
-- Each row: coloured pip (4x4) + short label + time string
-- Row height 14px, bar width 120px.
-- -------------------------------------------------------
BAR_ROW_H  = 14;
BAR_WIDTH  = 120;

function doUpdateBar()
	if (DISPLAY_MODE ~= 1) then return; end
	local now    = time();
	local rows   = {};

	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						local entry = getCraftEntry(craftKey);
						if (entry) then
							local remaining = (v > 0) and (v - now) or 0;
							-- Deduplicate: keep best (most ready) per craft
							local key = craftKey;
							if (not rows[key] or remaining < rows[key].remaining) then
								rows[key] = { entry = entry, remaining = remaining };
							end
						end
					end
				end
			end
		end
	end

	-- Flatten to ordered list
	local list = {};
	for _, entry in ipairs(TRACKED_CRAFTS) do
		if (rows[entry.key]) then
			table.insert(list, rows[entry.key]);
		end
	end

	local n = table.getn(list);
	if (n == 0) then
		ClockBarFrame:SetHeight(BAR_ROW_H);
		-- Show single grey "No data" row
		local fs = MuteClockBarLine1;
		if (fs) then fs:SetText("|cFF555555No data|r"); fs:Show(); end
		for i = 2, 3 do
			local f2 = getglobal("MuteClockBarLine"..i);
			if (f2) then f2:Hide(); end
			local p2 = getglobal("MuteClockBarPip"..i);
			if (p2) then p2:Hide(); end
		end
		return;
	end

	ClockBarFrame:SetHeight(n * BAR_ROW_H + 2);

	for i, row in ipairs(list) do
		local pip  = getglobal("MuteClockBarPip"..i);
		local line = getglobal("MuteClockBarLine"..i);
		if (pip and line) then
			-- Pip colour mirrors dot status colours
			local r, g, b;
			if     (row.remaining <= 0)     then r,g,b = 0.1,  0.9,  0.1;
			elseif (row.remaining <= 3600)  then r,g,b = 1.0,  0.75, 0.1;
			elseif (row.remaining <= 14400) then r,g,b = 1.0,  0.5,  0.1;
			else                                 r,g,b = 0.55, 0.55, 0.55; end
			pip:SetVertexColor(r, g, b, 1);
			pip:Show();

			local timeStr;
			if (row.remaining <= 0) then
				timeStr = "|cFF33DD33Ready|r";
			else
				timeStr = doFormatCountdown(row.remaining);
			end
			line:SetText("|cFFCCCCCC" .. row.entry.short .. "|r  " .. timeStr);
			line:Show();
		end
	end
	-- Hide unused rows
	for i = n + 1, 3 do
		local pip  = getglobal("MuteClockBarPip"..i);
		local line = getglobal("MuteClockBarLine"..i);
		if (pip)  then pip:Hide();  end
		if (line) then line:Hide(); end
	end
end

-- -------------------------------------------------------
-- Mini-panel mode update
-- A compact 130x68 floating panel showing own cooldowns.
-- -------------------------------------------------------
function doUpdateMiniPanel()
	if (DISPLAY_MODE ~= 2) then return; end
	local now  = time();
	local rows = {};

	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						local entry = getCraftEntry(craftKey);
						if (entry) then
							local remaining = (v > 0) and (v - now) or 0;
							local key = craftKey;
							if (not rows[key] or remaining < rows[key].remaining) then
								rows[key] = { entry = entry, remaining = remaining };
							end
						end
					end
				end
			end
		end
	end

	local list = {};
	for _, entry in ipairs(TRACKED_CRAFTS) do
		if (rows[entry.key]) then table.insert(list, rows[entry.key]); end
	end

	for i = 1, 3 do
		local label = getglobal("MuteClockMiniLabel"..i);
		local val   = getglobal("MuteClockMiniVal"..i);
		local row   = list[i];
		if (label and val) then
			if (row) then
				label:SetText("|cFF888888" .. row.entry.short .. "|r");
				label:Show();
				local r, g, b;
				if     (row.remaining <= 0)     then r,g,b = 0.1, 0.9, 0.1;
				elseif (row.remaining <= 3600)  then r,g,b = 1.0, 0.75,0.1;
				elseif (row.remaining <= 14400) then r,g,b = 1.0, 0.5, 0.1;
				else                                 r,g,b = 0.55,0.55,0.55; end
				if (row.remaining <= 0) then
					val:SetText("|cFF33DD33Ready|r");
				else
					val:SetText(string.format("|cFF%02X%02X%02X%s|r", floor(r*255), floor(g*255), floor(b*255), doFormatCountdown(row.remaining)));
				end
				val:Show();
			else
				label:Hide();
				val:Hide();
			end
		end
	end
end

-- -------------------------------------------------------
-- Right-click context menu on ClockFrame
-- -------------------------------------------------------
function doShowContextMenu()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	UIDropDownMenu_Initialize(MuteClockContextMenu, doContextMenu_Init, "MENU");
	ToggleDropDownMenu(1, nil, MuteClockContextMenu, "cursor", 0, 0);
end

function doContextMenu_Init()
	local info;

	info = {};
	info.text     = "|cFF00FF00MuteClock|r";
	info.isTitle  = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text     = "Open Config";
	info.notCheckable = 1;
	info.func     = function() MuteClockConfigFrame:Show(); end;
	UIDropDownMenu_AddButton(info);

	-- Switch tooltip view
	local viewLabel = (TOOLTIP_MODE == 1) and "View: My Cooldowns" or "View: Crafters";
	info = {};
	info.text     = viewLabel;
	info.notCheckable = 1;
	info.func     = function()
		TOOLTIP_MODE = (TOOLTIP_MODE == 1) and 0 or 1;
		doSaveSettings();
	end;
	UIDropDownMenu_AddButton(info);

	-- Display mode submenu header
	info = {};
	info.text     = "Display Mode";
	info.notCheckable = 1;
	info.hasArrow = 1;
	info.value    = "DISPLAY_MODE_SUBMENU";
	UIDropDownMenu_AddButton(info);

	-- Separator
	info = {};
	info.text     = "";
	info.notClickable = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text     = "Hide";
	info.notCheckable = 1;
	info.func     = function()
		DOT_HIDDEN = 1;
		doSaveSettings();
		doApplyDisplayMode();
	end;
	UIDropDownMenu_AddButton(info);
end

-- Note: In 1.12, hasArrow submenus need UIDropDownMenu_StartCounting etc.
-- For simplicity we handle display mode via the Settings panel dropdown only,
-- and use the context menu arrow item as a label-only hint.

-- -------------------------------------------------------
-- Reset to defaults
-- -------------------------------------------------------
function doSetDefaultSettings()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	SH_ALL_CHARACTERS = DEF_SH_ALL_CHARACTERS;
	DO_NOTIFY         = DEF_DO_NOTIFY;
	POSITION_X        = DEF_POSITION_X;
	POSITION_Y        = DEF_POSITION_Y;
	DOT_SIZE          = DEF_DOT_SIZE;
	DOT_HIDDEN        = DEF_DOT_HIDDEN;
	DISPLAY_MODE      = DEF_DISPLAY_MODE;
	ICON_MODE         = DEF_ICON_MODE;
	GROUP_BY_CRAFT    = DEF_GROUP_BY_CRAFT;
	SHOW_READY_TIME   = DEF_SHOW_READY_TIME;
	SHOW_OVERDUE      = DEF_SHOW_OVERDUE;
	SHOW_LAST_CRAFTED = DEF_SHOW_LAST_CRAFTED;
	SHOW_BADGE        = DEF_SHOW_BADGE;
	TOOLTIP_MODE      = DEF_TOOLTIP_MODE;
	OVERDUE_REMIND    = DEF_OVERDUE_REMIND;
	doSaveSettings();
	doApplyDisplayMode();
	ClockFrame:ClearAllPoints();
	ClockFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
	ClockBarFrame:ClearAllPoints();
	ClockBarFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
	ClockMiniPanel:ClearAllPoints();
	ClockMiniPanel:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
	doInitializeConfig(1);
end

-- -------------------------------------------------------
-- Config: tab switching
-- Default tab is Planner
-- -------------------------------------------------------
function doShowConfigTab(tabName)
	MuteClockConfigFramePanelSettings:Hide();
	MuteClockConfigFramePanelPlanner:Hide();
	MuteClockConfigFramePanelCrafters:Hide();
	if (tabName == "Settings") then
		MuteClockConfigFramePanelSettings:Show();
	elseif (tabName == "Crafters") then
		MuteClockConfigFramePanelCrafters:Show();
		ClockFrame.CraftersRefreshTimer = 0;
		doPopulateCrafters();
	else
		MuteClockConfigFramePanelPlanner:Show();
		doPopulatePlanner();
	end
end

-- -------------------------------------------------------
-- Dropdown helpers
-- -------------------------------------------------------
function doMakeDropDown_Init(options)
	return function()
		for _, opt in ipairs(options) do
			local info = {};
			info.text  = opt.text;
			info.value = opt.value;
			info.func  = opt.func;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function doIconModeDropDown_Init()
	for _, opt in ipairs(ICON_MODE_OPTIONS) do
		local info = {};
		info.text  = opt.text;
		info.value = opt.value;
		info.func  = doIconModeDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function doIconModeDropDown_OnClick()
	ICON_MODE = this.value;
	UIDropDownMenu_SetSelectedValue(MuteClockConfigFramePanelSettingsDropDownIcon, ICON_MODE);
	doSaveSettings();
	doApplyDisplayMode();
end

function doIconModeDropDown_GetText(mode)
	for _, opt in ipairs(ICON_MODE_OPTIONS) do
		if (opt.value == mode) then return opt.text; end
	end
	return "Smart (auto)";
end

function doDisplayModeDropDown_Init()
	for _, opt in ipairs(DISPLAY_MODE_OPTIONS) do
		local info = {};
		info.text  = opt.text;
		info.value = opt.value;
		info.func  = doDisplayModeDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function doDisplayModeDropDown_OnClick()
	DISPLAY_MODE = this.value;
	UIDropDownMenu_SetSelectedValue(MuteClockConfigFramePanelSettingsDropDownDisplay, DISPLAY_MODE);
	doSaveSettings();
	doApplyDisplayMode();
end

function doDisplayModeDropDown_GetText(mode)
	for _, opt in ipairs(DISPLAY_MODE_OPTIONS) do
		if (opt.value == mode) then return opt.text; end
	end
	return "Dot";
end

function doOverdueRemindDropDown_Init()
	for _, opt in ipairs(OVERDUE_REMIND_OPTIONS) do
		local info = {};
		info.text  = opt.text;
		info.value = opt.value;
		info.func  = doOverdueRemindDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function doOverdueRemindDropDown_OnClick()
	OVERDUE_REMIND = this.value;
	UIDropDownMenu_SetSelectedValue(MuteClockConfigFramePanelSettingsDropDownRemind, OVERDUE_REMIND);
	doSaveSettings();
end

function doOverdueRemindDropDown_GetText(v)
	for _, opt in ipairs(OVERDUE_REMIND_OPTIONS) do
		if (opt.value == v) then return opt.text; end
	end
	return "Off";
end

-- -------------------------------------------------------
-- Config: populate controls from globals
-- -------------------------------------------------------
function doInitializeConfig(isDefaults)
	local p = MC_CTRL;
	getglobal(p.."CBAllChars"):SetChecked(SH_ALL_CHARACTERS);
	getglobal(p.."CBNotify"):SetChecked(DO_NOTIFY);
	getglobal(p.."CBGroupByCraft"):SetChecked(GROUP_BY_CRAFT);
	getglobal(p.."CBReadyTime"):SetChecked(SHOW_READY_TIME);
	getglobal(p.."CBOverdue"):SetChecked(SHOW_OVERDUE);
	getglobal(p.."CBLastCrafted"):SetChecked(SHOW_LAST_CRAFTED);
	getglobal(p.."CBBadge"):SetChecked(SHOW_BADGE);
	getglobal(p.."CBHide"):SetChecked(DOT_HIDDEN);
	getglobal(p.."CBTooltipMode"):SetChecked(TOOLTIP_MODE);
	getglobal(p.."SliderSize"):SetValue(DOT_SIZE);
	local dd = getglobal(p.."DropDownIcon");
	UIDropDownMenu_SetSelectedValue(dd, ICON_MODE);
	UIDropDownMenu_SetText(doIconModeDropDown_GetText(ICON_MODE), dd);
	local ddD = getglobal(p.."DropDownDisplay");
	UIDropDownMenu_SetSelectedValue(ddD, DISPLAY_MODE);
	UIDropDownMenu_SetText(doDisplayModeDropDown_GetText(DISPLAY_MODE), ddD);
	local ddR = getglobal(p.."DropDownRemind");
	UIDropDownMenu_SetSelectedValue(ddR, OVERDUE_REMIND);
	UIDropDownMenu_SetText(doOverdueRemindDropDown_GetText(OVERDUE_REMIND), ddR);
end

-- -------------------------------------------------------
-- Config: save a single control's value
-- -------------------------------------------------------
function doConfigSave()
	local n = this:GetName();
	local p = MC_CTRL;

	if     (n == p.."CBAllChars")    then SH_ALL_CHARACTERS = this:GetChecked() or 0;
	elseif (n == p.."CBNotify")      then DO_NOTIFY         = this:GetChecked() or 0;
	elseif (n == p.."CBGroupByCraft")then GROUP_BY_CRAFT    = this:GetChecked() or 0;
	elseif (n == p.."CBReadyTime")   then SHOW_READY_TIME   = this:GetChecked() or 0;
	elseif (n == p.."CBOverdue")     then SHOW_OVERDUE      = this:GetChecked() or 0;
	elseif (n == p.."CBLastCrafted") then SHOW_LAST_CRAFTED = this:GetChecked() or 0;
	elseif (n == p.."CBBadge")       then SHOW_BADGE        = this:GetChecked() or 0;
	elseif (n == p.."CBHide")        then DOT_HIDDEN        = this:GetChecked() or 0;
	elseif (n == p.."CBTooltipMode") then TOOLTIP_MODE      = this:GetChecked() or 0;
	elseif (n == p.."SliderSize")    then
		DOT_SIZE = floor(this:GetValue());
		getglobal(n.."Text"):SetText("Dot Size ("..DOT_SIZE.."px)");
	end

	doSaveSettings();
	doApplyDisplayMode();
end

-- -------------------------------------------------------
-- History: record a craft event
-- -------------------------------------------------------
function doRecordHistory(charName, craftKey)
	if (not MuteClock[charName]) then return; end
	local hKey = craftKey .. "-history";
	if (not MuteClock[charName][hKey]) then
		MuteClock[charName][hKey] = {};
	end
	local hist = MuteClock[charName][hKey];
	table.insert(hist, { t = time() });
	while (table.getn(hist) > HISTORY_MAX) do
		table.remove(hist, 1);
	end
end

-- -------------------------------------------------------
-- Scroll panel helpers
-- -------------------------------------------------------
MC_ROW_H = 19;

function mcClearContent(contentFrame)
	local i = 1;
	while true do
		local fs  = getglobal(contentFrame:GetName() .. "Line" .. i);
		local btn = getglobal(contentFrame:GetName() .. "Btn"  .. i);
		if (not fs and not btn) then break; end
		if (fs)  then fs:Hide();  fs:SetText(""); end
		if (btn) then btn:Hide(); btn:SetScript("OnClick", nil); end
		i = i + 1;
	end
end

function mcAddLine(contentFrame, lineIndex, text, r, g, b)
	local name = contentFrame:GetName() .. "Line" .. lineIndex;
	local fs   = getglobal(name);
	if (not fs) then
		fs = contentFrame:CreateFontString(name, "OVERLAY", "GameFontNormalSmall");
		fs:SetWidth(contentFrame:GetWidth());
		fs:SetJustifyH("LEFT");
	end
	fs:SetText(text);
	if (r) then fs:SetTextColor(r, g, b); else fs:SetTextColor(0.82, 0.82, 0.82); end
	fs:ClearAllPoints();
	fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -((lineIndex - 1) * MC_ROW_H));
	fs:Show();
	return lineIndex + 1;
end

function mcAddHeader(contentFrame, lineIndex, text)
	local name = contentFrame:GetName() .. "Line" .. lineIndex;
	local fs   = getglobal(name);
	if (not fs) then
		fs = contentFrame:CreateFontString(name, "OVERLAY", "GameFontNormal");
		fs:SetWidth(contentFrame:GetWidth());
		fs:SetJustifyH("LEFT");
	end
	fs:SetText("|cFF5AC8FA" .. text .. "|r");
	fs:SetTextColor(1, 1, 1);
	fs:ClearAllPoints();
	fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -((lineIndex - 1) * MC_ROW_H));
	fs:Show();
	return lineIndex + 1;
end

function mcAddSpacer(contentFrame, lineIndex)
	local name = contentFrame:GetName() .. "Line" .. lineIndex;
	local fs   = getglobal(name);
	if (not fs) then
		fs = contentFrame:CreateFontString(name, "OVERLAY", "GameFontNormalSmall");
		fs:SetWidth(1);
	end
	fs:SetText(" ");
	fs:ClearAllPoints();
	fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -((lineIndex - 1) * MC_ROW_H));
	fs:Show();
	return lineIndex + 1;
end

function mcAddSmallSpacer(contentFrame, lineIndex)
	local name = contentFrame:GetName() .. "Line" .. lineIndex;
	local fs   = getglobal(name);
	if (not fs) then
		fs = contentFrame:CreateFontString(name, "OVERLAY", "GameFontNormalSmall");
		fs:SetWidth(1);
		fs:SetHeight(8);
	end
	fs:SetText("");
	fs:ClearAllPoints();
	fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -((lineIndex - 1) * MC_ROW_H));
	fs:Show();
	return lineIndex + 1;
end

function mcAddRowWithButton(contentFrame, lineIndex, labelText, btnSymbol, symR, symG, symB, btnCallback)
	local yOff = -((lineIndex - 1) * MC_ROW_H);
	local btnW = 16;
	local gap  = 5;

	local btnName = contentFrame:GetName() .. "Btn" .. lineIndex;
	local btn = getglobal(btnName);
	if (not btn) then
		btn = CreateFrame("Button", btnName, contentFrame);
		btn:SetWidth(btnW);
		btn:SetHeight(btnW);
		local bg = btn:CreateTexture(nil, "BACKGROUND");
		bg:SetTexture("Interface\\Buttons\\WHITE8X8");
		bg:SetVertexColor(0.08, 0.08, 0.10, 0.75);
		bg:SetAllPoints();
		local hl = btn:CreateTexture(nil, "HIGHLIGHT");
		hl:SetTexture("Interface\\Buttons\\WHITE8X8");
		hl:SetVertexColor(1, 1, 1, 0.12);
		hl:SetAllPoints();
		local sym = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		sym:SetAllPoints();
		sym:SetJustifyH("CENTER");
		sym:SetJustifyV("MIDDLE");
		btn._sym = sym;
	end
	btn._sym:SetText(btnSymbol);
	btn._sym:SetTextColor(symR, symG, symB, 1);
	btn:SetScript("OnClick", btnCallback);
	btn:ClearAllPoints();
	btn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOff - 1);
	btn:Show();

	local fsName = contentFrame:GetName() .. "Line" .. lineIndex;
	local fs = getglobal(fsName);
	if (not fs) then
		fs = contentFrame:CreateFontString(fsName, "OVERLAY", "GameFontNormalSmall");
		fs:SetJustifyH("LEFT");
	end
	fs:SetWidth(contentFrame:GetWidth() - btnW - gap);
	fs:SetText(labelText);
	fs:SetTextColor(0.82, 0.82, 0.82);
	fs:ClearAllPoints();
	fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", btnW + gap, yOff);
	fs:Show();
	return lineIndex + 1;
end

function mcFinaliseScroll(scrollFrame, scrollBar, contentFrame, lineCount)
	local totalH = math.max(lineCount * MC_ROW_H, 1);
	contentFrame:SetHeight(totalH);
	local viewH     = scrollFrame:GetHeight();
	local maxScroll = math.max(totalH - viewH, 0);
	scrollBar:SetMinMaxValues(0, maxScroll);
	scrollBar:SetValue(0);
	scrollFrame:SetVerticalScroll(0);
end

-- -------------------------------------------------------
-- Planner panel  (replaces History)
-- Shows ALL cooldowns — own alts + saved crafters —
-- sorted by remaining time, soonest first.
-- Columns: Name | Craft | Status
-- -------------------------------------------------------
function doPopulatePlanner()
	local scrollFrame  = MuteClockConfigFramePanelPlannerScrollFrame;
	local scrollBar    = MuteClockConfigFramePanelPlannerScrollBar;
	local contentFrame = MuteClockConfigFramePanelPlannerScrollFrameContent;
	mcClearContent(contentFrame);
	local li  = 1;
	local now = time();

	-- Collect own-character rows
	local rows = {};
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						local entry = getCraftEntry(craftKey);
						if (entry) then
							local remaining = (v > 0) and (v - now) or 0;
							table.insert(rows, {
								source    = "own",
								name      = charName,
								entry     = entry,
								remaining = remaining,
							});
						end
					end
				end
			end
		end
	end

	-- Collect saved-crafter rows
	for name in pairs(MC_FRIENDS) do
		local data    = MC_PEERS[name] or {};
		local updated = data._updated;
		local stale   = updated and ((now - updated) > 172800); -- >48h
		for _, entry in ipairs(TRACKED_CRAFTS) do
			local ts = data[entry.key];
			if (ts ~= nil) then
				local remaining = (ts > 0) and (ts - now) or 0;
				table.insert(rows, {
					source    = "crafter",
					name      = name,
					entry     = entry,
					remaining = remaining,
					stale     = stale,
				});
			end
		end
	end

	-- Sort: ready first, then by remaining ascending
	table.sort(rows, function(a, b)
		if ((a.remaining <= 0) ~= (b.remaining <= 0)) then return a.remaining <= 0; end
		if (a.remaining ~= b.remaining) then return a.remaining < b.remaining; end
		return a.name < b.name;
	end);

	if (table.getn(rows) == 0) then
		li = mcAddLine(contentFrame, li, "No cooldown data yet.", 0.5, 0.5, 0.5);
		li = mcAddLine(contentFrame, li, "Open trade skill windows on your characters.", 0.38, 0.38, 0.38);
		li = mcAddLine(contentFrame, li, "Add crafters in the Crafters tab.", 0.38, 0.38, 0.38);
		mcFinaliseScroll(scrollFrame, scrollBar, contentFrame, li - 1);
		return;
	end

	-- Column header
	local cw = contentFrame:GetWidth();
	li = mcAddLine(contentFrame, li,
		"|cFF5AC8FACHARACTER|r                  |cFF5AC8FACRAFT|r                          |cFF5AC8FASTATUS|r");

	local lastReady = nil;
	for _, row in ipairs(rows) do
		-- Section divider between ready and waiting
		if (lastReady ~= nil and (row.remaining > 0) ~= lastReady) then
			li = mcAddSpacer(contentFrame, li);
		end
		lastReady = (row.remaining <= 0);

		local nameCol = (row.source == "own")
			and ((row.name == CURRENT_PLAYER_NAME) and "|cFFFFD100" or "|cFFAAAAAA")
			or  "|cFF00CCFF";
		local staleTag = (row.stale) and " |cFFFF6600⚠|r" or "";
		local nameStr = nameCol .. row.name .. "|r" .. staleTag;

		local craftStr = "|cFF888888" .. row.entry.label .. "|r";

		local statusStr;
		if (row.remaining <= 0) then
			local od = "";
			if (SHOW_OVERDUE == 1) then
				local s = doFormatOverdue(row.remaining);
				if (s) then od = "  |cFFFF6600" .. s .. "|r"; end
			end
			statusStr = "|cFF33DD33Ready|r" .. od;
		else
			local r2, g2, b2;
			if     (row.remaining <= 3600)  then r2,g2,b2 = 1.0, 0.75, 0.1;
			elseif (row.remaining <= 14400) then r2,g2,b2 = 1.0, 0.50, 0.1;
			else                                 r2,g2,b2 = 0.55,0.55, 0.55; end
			local ts = string.format("|cFF%02X%02X%02X%s|r",
				floor(r2*255), floor(g2*255), floor(b2*255), doFormatCountdown(row.remaining));
			if (SHOW_READY_TIME == 1) then
				local rt = doFormatReadyTime(row.remaining);
				if (rt) then ts = ts .. "  |cFF555555" .. rt .. "|r"; end
			end
			statusStr = ts;
		end

		-- Pad name and craft to fixed widths using spaces
		-- (GameFontNormalSmall is proportional so this is approximate)
		li = mcAddLine(contentFrame, li, nameStr .. "   " .. craftStr .. "   " .. statusStr);
	end

	mcFinaliseScroll(scrollFrame, scrollBar, contentFrame, li - 1);
end

-- -------------------------------------------------------
-- Frame OnLoad handlers
-- -------------------------------------------------------
function Clock_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("SPELLCAST_START");
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("TRADE_SKILL_CLOSE");
	this:RegisterEvent("SPELLCAST_INTERRUPTED");
	this:RegisterEvent("SPELLCAST_FAILED");
	this:RegisterEvent("ITEM_PUSH");
	this:RegisterEvent("CHAT_MSG_ADDON");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("RAID_ROSTER_UPDATE");

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock v2|r loaded.");
	end
	SLASH_MUTECLOCK1 = "/muteclock";
	SlashCmdList["MUTECLOCK"] = SlashCommandHandler;
	ClockFrame.TimeSinceLastUpdate = 0;
	ClockFrame:Hide();
	ClockFrame:RegisterForDrag("LeftButton");
	doBadgeInit();
end

function MuteClockConfig_OnLoad()
	this:SetBackdropColor(0.06, 0.06, 0.08, 0.97);
	this:SetBackdropBorderColor(0.20, 0.20, 0.26, 1);
	MuteClockConfigFrameTopBar:SetVertexColor(0.07, 0.10, 0.16, 1);
	MuteClockConfigFrameTitle:SetTextColor(0.85, 0.88, 1, 1);
	MuteClockDivTracking:SetVertexColor(0.25, 0.55, 0.75, 0.4);
	MuteClockDivDisplay:SetVertexColor(0.25, 0.55, 0.75, 0.4);
	MuteClockDivNotify:SetVertexColor(0.25, 0.55, 0.75, 0.4);
	MuteClockDivDot:SetVertexColor(0.25, 0.55, 0.75, 0.4);
	MuteClockCraftersDivider:SetVertexColor(0.25, 0.55, 0.75, 0.35);
	this:RegisterForDrag("LeftButton");
	MuteClockConfigFramePanelPlanner:Hide();
	MuteClockConfigFramePanelSettings:Hide();
	MuteClockConfigFramePanelCrafters:Show();
	UIDropDownMenu_Initialize(MuteClockConfigFramePanelSettingsDropDownIcon, doIconModeDropDown_Init);
	UIDropDownMenu_SetWidth(120, MuteClockConfigFramePanelSettingsDropDownIcon);
	UIDropDownMenu_Initialize(MuteClockConfigFramePanelSettingsDropDownDisplay, doDisplayModeDropDown_Init);
	UIDropDownMenu_SetWidth(100, MuteClockConfigFramePanelSettingsDropDownDisplay);
	UIDropDownMenu_Initialize(MuteClockConfigFramePanelSettingsDropDownRemind, doOverdueRemindDropDown_Init);
	UIDropDownMenu_SetWidth(100, MuteClockConfigFramePanelSettingsDropDownRemind);
end

function MuteClockConfig_OnShow()
	doInitializeConfig(0);
	doShowConfigTab("Planner");
end

function MuteClockBar_OnLoad()
	this:RegisterForDrag("LeftButton");
	this:Hide();
	-- Style the bar background
	MuteClockBarBg:SetVertexColor(0.05, 0.05, 0.08, 0.88);
end

function MuteClockMiniPanel_OnLoad()
	this:RegisterForDrag("LeftButton");
	this:Hide();
	MuteClockMiniPanelBg:SetVertexColor(0.05, 0.05, 0.08, 0.88);
	MuteClockMiniPanelBorder:SetVertexColor(0.20, 0.45, 0.65, 0.7);
end

function doBadgeInit()
	MuteClockBadge:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
	MuteClockBadge:SetTextColor(1, 0.9, 0, 1);
end

-- -------------------------------------------------------
-- Config tooltip
-- -------------------------------------------------------
function ConfigTooltip_Show(...)
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	for i = 1, arg.n do
		GameTooltip:AddLine(arg[i], 0.9, 0.9, 0.9, 1);
	end
	GameTooltip:Show();
end

function ConfigTooltip_Hide()
	GameTooltip:Hide();
end

-- -------------------------------------------------------
-- Event handler
-- -------------------------------------------------------
function Clock_OnEvent()
	if (event == "VARIABLES_LOADED") then
		CURRENT_PLAYER_NAME = UnitName("player");
		onVariablesLoaded();

	elseif (event == "PLAYER_ENTERING_WORLD") then
		if (IS_VARIABLES_LOADED == 1) then
			doNetSendAll("HELLO");
			doNetBroadcastAll();
		end

	elseif (event == "SPELLCAST_START") then
		local idx = GetTradeSkillSelectionIndex();
		if (idx and idx > 0) then
			local name = GetTradeSkillInfo(idx);
			if (getCraftEntry(name)) then
				CraftingItemName = name;
				isCraftSuccess   = 1;
			else
				CraftingItemName = nil;
				isCraftSuccess   = 0;
			end
		end

	elseif (event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED") then
		CraftingItemName = nil;
		isCraftSuccess   = 0;

	elseif (event == "ITEM_PUSH") then
		if (isCraftSuccess == 1 and CraftingItemName ~= nil) then
			local idx = GetTradeSkillSelectionIndex();
			if (idx and idx > 0) then
				local cd = GetTradeSkillCooldown(idx);
				if (cd and cd > 0) then
					local key   = CraftingItemName;
					local avail = time() + floor(cd);
					MuteClock[CURRENT_PLAYER_NAME][key .. "-available"] = avail;
					MuteClock[CURRENT_PLAYER_NAME][key .. "-notified"]  = nil;
					MuteClock[CURRENT_PLAYER_NAME][key .. "-crafted"]   = time();
					-- Clear session reminder so it fires again next window open
					MC_SESSION_NOTIFIED[CURRENT_PLAYER_NAME .. ":" .. key] = nil;
					doRecordHistory(CURRENT_PLAYER_NAME, key);
					doNetSendCraft(key, avail);
				end
			end
			CraftingItemName = nil;
			isCraftSuccess   = 0;
		end

	elseif (event == "CHAT_MSG_ADDON") then
		if (arg1 == "MUTECLOCK" and arg4 ~= CURRENT_PLAYER_NAME) then
			doNetOnMessage(arg4, arg2);
		end

	elseif (event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE") then
		local newNearby = {};
		for name in pairs(MC_NEARBY) do
			if (doIsInGroup(name)) then
				newNearby[name] = true;
			end
		end
		MC_NEARBY = newNearby;
		doNetSend("HELLO");
		doNetBroadcastAll();

	elseif (event == "TRADE_SKILL_SHOW") then
		local knownCrafts = {};
		local n = GetNumTradeSkills();
		for i = 1, n do
			local name, kind = GetTradeSkillInfo(i);
			if (kind ~= "header" and getCraftEntry(name)) then
				knownCrafts[name] = true;
				local cd = GetTradeSkillCooldown(i);
				if (cd and cd > 0) then
					MuteClock[CURRENT_PLAYER_NAME][name .. "-available"] = time() + floor(cd);
					MuteClock[CURRENT_PLAYER_NAME][name .. "-notified"]  = nil;
				else
					local existing = MuteClock[CURRENT_PLAYER_NAME][name .. "-available"];
					if (existing == nil or existing <= time()) then
						MuteClock[CURRENT_PLAYER_NAME][name .. "-available"] = 0;
					end
				end
			end
		end

		-- Session re-arm reminder: if a craft is ready and we haven't
		-- reminded this session, fire one notification.
		if (DO_NOTIFY == 1) then
			local charData = MuteClock[CURRENT_PLAYER_NAME];
			for craftName in pairs(knownCrafts) do
				local entry = getCraftEntry(craftName);
				if (entry) then
					local v = charData[craftName .. "-available"];
					if (v ~= nil) then
						local remaining = (v > 0) and (v - time()) or 0;
						local sessionKey = CURRENT_PLAYER_NAME .. ":" .. craftName;
						if (remaining <= 0 and not MC_SESSION_NOTIFIED[sessionKey]) then
							MC_SESSION_NOTIFIED[sessionKey] = true;
							doSendNotify(CURRENT_PLAYER_NAME, entry, remaining);
						end
					end
				end
			end
		end

		-- Do NOT clean up other-profession data. See earlier fix.
		doNetBroadcastAll();

	elseif (event == "TRADE_SKILL_CLOSE") then
		doNetBroadcastAll();
	end
end

-- -------------------------------------------------------
-- Per-frame update (5s tick)
-- -------------------------------------------------------
function Clock_OnUpdate(arg1)
	ClockFrame.TimeSinceLastUpdate = (ClockFrame.TimeSinceLastUpdate or 0) + arg1;
	if (ClockFrame.TimeSinceLastUpdate >= 5.0) then
		ClockFrame.TimeSinceLastUpdate = 0;
		if (IS_VARIABLES_LOADED ~= 1) then return; end
		doRunNotifications();
		if     (DISPLAY_MODE == 0) then doUpdateDot();
		elseif (DISPLAY_MODE == 1) then doUpdateBar();
		elseif (DISPLAY_MODE == 2) then doUpdateMiniPanel();
		end
		-- Dismiss onboarding tooltip after 30s
		if (ClockFrame.OnboardingTimer and ClockFrame.OnboardingTimer > 0) then
			ClockFrame.OnboardingTimer = ClockFrame.OnboardingTimer - 5;
			if (ClockFrame.OnboardingTimer <= 0) then
				ClockFrame.OnboardingTimer = 0;
				if (GameTooltip:GetOwner() == ClockFrame) then
					GameTooltip:Hide();
				end
			end
		end
	end

	ClockFrame.CraftersRefreshTimer = (ClockFrame.CraftersRefreshTimer or 0) + arg1;
	if (ClockFrame.CraftersRefreshTimer >= 5.0) then
		ClockFrame.CraftersRefreshTimer = 0;
		if (IS_VARIABLES_LOADED == 1) then
			if (MuteClockConfigFramePanelCrafters:IsVisible()) then doPopulateCrafters(); end
			if (MuteClockConfigFramePanelPlanner:IsVisible())  then doPopulatePlanner();  end
		end
	end
end

-- -------------------------------------------------------
-- Drag handlers (shared logic for all movable frames)
-- -------------------------------------------------------
function ClockFrame_OnDragStart()
	ClockFrame:ClearAllPoints();
	ClockFrame:StartMoving();
end

function ClockFrame_OnDragStop()
	ClockFrame:StopMovingOrSizing();
	POSITION_X, POSITION_Y = ClockFrame:GetCenter();
	doSaveSettings();
end

function ClockBarFrame_OnDragStop()
	ClockBarFrame:StopMovingOrSizing();
	POSITION_X, POSITION_Y = ClockBarFrame:GetCenter();
	doSaveSettings();
end

function ClockMiniPanel_OnDragStop()
	ClockMiniPanel:StopMovingOrSizing();
	POSITION_X, POSITION_Y = ClockMiniPanel:GetCenter();
	doSaveSettings();
end

-- -------------------------------------------------------
-- Click handling (left + right)
-- -------------------------------------------------------
function ClickHandler(btn, updown)
	if (updown ~= "UP") then return; end
	-- Dismiss onboarding on any click
	if (ClockFrame.OnboardingTimer and ClockFrame.OnboardingTimer > 0) then
		ClockFrame.OnboardingTimer = 0;
		if (GameTooltip:GetOwner() == ClockFrame) then GameTooltip:Hide(); end
	end
	if (btn == "RightButton") then
		doShowContextMenu();
	elseif (btn == "LeftButton") then
		if (IsControlKeyDown()) then
			MuteClockConfigFrame:Show();
		elseif (IsShiftKeyDown()) then
			TOOLTIP_MODE = (TOOLTIP_MODE == 1) and 0 or 1;
			doSaveSettings();
			if (GameTooltip:IsVisible() and GameTooltip:GetOwner() == ClockFrame) then
				GameTooltip:ClearLines();
				doFillTooltip();
				GameTooltip:Show();
			end
		end
	end
end

-- Shared click handler for bar and mini-panel
function AltFrame_ClickHandler(btn, updown)
	ClickHandler(btn, updown);
end

-- -------------------------------------------------------
-- Slash commands
-- -------------------------------------------------------
function SlashCommandHandler(msg)
	local cmd = string.gsub(msg, "^%s*(.-)%s*$", "%1");
	if (cmd == "") then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r commands:");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock config|r   open settings");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock reset|r    restore defaults");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock show|r     unhide the indicator");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock status|r   print cooldown summary to chat");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock debug|r    print network state");
	elseif (cmd == "config") then
		MuteClockConfigFrame:Show();
	elseif (cmd == "reset") then
		doSetDefaultSettings();
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r settings reset to defaults.");
	elseif (cmd == "show") then
		DOT_HIDDEN = 0;
		doSaveSettings();
		doApplyDisplayMode();
	elseif (cmd == "status") then
		doSlashStatus();
	elseif (cmd == "debug") then
		local ch = doNetGetChannel();
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r debug:");
		DEFAULT_CHAT_FRAME:AddMessage("  Party: " .. (ch or "|cFFFF4444none|r"));
		DEFAULT_CHAT_FRAME:AddMessage("  Guild: " .. (doNetGetGuildChannel() or "|cFFFF4444none|r"));
		DEFAULT_CHAT_FRAME:AddMessage("  Party members: " .. GetNumPartyMembers());
		DEFAULT_CHAT_FRAME:AddMessage("  Raid members: "  .. GetNumRaidMembers());
		local pay = doNetBuildPayload();
		DEFAULT_CHAT_FRAME:AddMessage("  Payload: |cFFAAAAAA" .. (pay ~= "" and pay or "(empty)") .. "|r");
		local pc = 0;
		for name, data in pairs(MC_PEERS) do
			pc = pc + 1;
			local cc = 0;
			for _ in pairs(data) do cc = cc + 1; end
			DEFAULT_CHAT_FRAME:AddMessage("  Peer: |cFFFFD100" .. name .. "|r (" .. cc .. " crafts)");
		end
		if (pc == 0) then
			DEFAULT_CHAT_FRAME:AddMessage("  |cFFAAAAAAPeers: none seen yet|r");
		end
		doNetSendAll("HELLO");
	end
end

-- /muteclock status — shareable summary line
function doSlashStatus()
	local now   = time();
	local parts = {};

	-- Own alts
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						local entry = getCraftEntry(craftKey);
						if (entry) then
							local remaining = (v > 0) and (v - now) or 0;
							local s;
							if (remaining <= 0) then
								local od = doFormatOverdue(remaining);
								s = "|cFF33DD33ready|r" .. (od and (" |cFFFF6600" .. od .. "|r") or "");
							else
								s = doFormatCountdown(remaining);
							end
							table.insert(parts, "|cFFFFD100" .. charName .. "|r " .. entry.label .. " " .. s);
						end
					end
				end
			end
		end
	end

	-- Crafters
	for name in pairs(MC_FRIENDS) do
		local data = MC_PEERS[name] or {};
		for _, entry in ipairs(TRACKED_CRAFTS) do
			local ts = data[entry.key];
			if (ts ~= nil) then
				local remaining = (ts > 0) and (ts - now) or 0;
				local s;
				if (remaining <= 0) then
					s = "|cFF33DD33ready|r";
				else
					s = doFormatCountdown(remaining);
				end
				table.insert(parts, "|cFF00CCFF" .. name .. "|r " .. entry.label .. " " .. s);
			end
		end
	end

	local frame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME;
	if (table.getn(parts) == 0) then
		frame:AddMessage("|cFF00FF00MuteClock|r  No data yet.");
	else
		frame:AddMessage("|cFF00FF00MuteClock:|r  " .. table.concat(parts, "  |cFF333333·|r  "));
	end
end

-- -------------------------------------------------------
-- Time formatting
-- -------------------------------------------------------
function doFormatCountdown(remaining)
	if (remaining <= 0) then return "Ready"; end
	local d = floor(remaining / 86400);
	local r = remaining - (d * 86400);
	local h = floor(r / 3600);
	r = r - (h * 3600);
	local m = floor(r / 60);
	local ds = (d > 0) and (d .. "d ") or "";
	local hs = (h > 0) and (h .. "h ") or "";
	local ms = (m > 0) and (m .. "m")  or "";
	if (ds == "" and hs == "" and ms == "") then return "< 1m"; end
	return ds .. hs .. ms;
end

function doFormatOverdue(remaining)
	local e = -remaining;
	if (e < 60) then return nil; end
	local d = floor(e / 86400);
	local r = e - (d * 86400);
	local h = floor(r / 3600);
	r = r - (h * 3600);
	local m = floor(r / 60);
	local ds = (d > 0) and (d .. "d ") or "";
	local hs = (h > 0) and (h .. "h ") or "";
	local ms = (m > 0) and (m .. "m")  or "";
	if (ds == "" and hs == "" and ms == "") then return nil; end
	return "+" .. ds .. hs .. ms;
end

function doFormatReadyTime(remaining)
	if (remaining < 3600) then return nil; end
	local at = time() + remaining;
	if (remaining > 518400) then return date("%d %b %H:%M", at); end
	return date("%a %H:%M", at);
end

function doFormatTimestamp(t)
	if (not t or t == 0) then return nil; end
	if ((time() - t) < 86400) then return date("%H:%M", t); end
	return date("%a %H:%M", t);
end

-- -------------------------------------------------------
-- Collect cooldown rows (own characters)
-- -------------------------------------------------------
function doCollectCooldownData()
	local results = {};
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						local entry = getCraftEntry(craftKey);
						if (entry) then
							local remaining = (v > 0) and (v - time()) or 0;
							table.insert(results, {
								craftKey    = craftKey,
								label       = entry.label,
								charName    = charName,
								remaining   = remaining,
								lastCrafted = charData[craftKey .. "-crafted"],
							});
						end
					end
				end
			end
		end
	end
	return results;
end

-- -------------------------------------------------------
-- Dot status (0=no data, 1=ready, 2=<4h, 3=long)
-- -------------------------------------------------------
function doGetDotStatus()
	if (not MuteClock) then return 0, 0; end
	local hasData  = false;
	local hasReady = false;
	local hasSoon  = false;
	local readyN   = 0;
	local crafterReadyN = 0;

	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						if (getCraftEntry(craftKey)) then
							hasData = true;
							local remaining = (v > 0) and (v - time()) or 0;
							if (remaining <= 0) then
								hasReady = true;
								readyN   = readyN + 1;
							elseif (remaining <= 14400) then
								hasSoon = true;
							end
						end
					end
				end
			end
		end
	end

	-- Count crafter readies for badge
	local now = time();
	for name in pairs(MC_FRIENDS) do
		local data = MC_PEERS[name] or {};
		for _, entry in ipairs(TRACKED_CRAFTS) do
			local ts = data[entry.key];
			if (ts ~= nil) then
				local rem = (ts > 0) and (ts - now) or 0;
				if (rem <= 0) then crafterReadyN = crafterReadyN + 1; end
			end
		end
	end

	if (not hasData) then return 0, 0, 0; end
	if (hasReady)    then return 1, readyN, crafterReadyN; end
	if (hasSoon)     then return 2, 0, crafterReadyN; end
	return 3, 0, crafterReadyN;
end

-- -------------------------------------------------------
-- SmartIcon: best ready craft entry (ICON_MODE=1)
-- -------------------------------------------------------
function doGetSmartIcon()
	local best = {};
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						local entry = getCraftEntry(craftKey);
						if (entry) then
							local remaining = (v > 0) and (v - time()) or 0;
							if (remaining <= 0) then
								local tier = (charName == CURRENT_PLAYER_NAME) and 1 or 2;
								if (not best[entry.key] or tier < best[entry.key]) then
									best[entry.key] = tier;
								end
							end
						end
					end
				end
			end
		end
	end
	local bestEntry, bestTier = nil, 99;
	for _, entry in ipairs(TRACKED_CRAFTS) do
		local t = best[entry.key];
		if (t and t < bestTier) then
			bestEntry = entry;
			bestTier  = t;
		end
	end
	return bestEntry;
end

-- -------------------------------------------------------
-- Networking
-- -------------------------------------------------------
function doNetGetChannel()
	if (GetNumRaidMembers() > 0)  then return "RAID";  end
	if (GetNumPartyMembers() > 0) then return "PARTY"; end
	return nil;
end

function doNetGetGuildChannel()
	if (IsInGuild and IsInGuild()) then return "GUILD"; end
	return nil;
end

function doNetSend(msg)
	local ch = doNetGetChannel();
	if (not ch) then return; end
	SendAddonMessage("MUTECLOCK", msg, ch);
end

function doNetSendGuild(msg)
	local ch = doNetGetGuildChannel();
	if (not ch) then return; end
	SendAddonMessage("MUTECLOCK", msg, ch);
end

function doNetSendAll(msg)
	doNetSend(msg);
	doNetSendGuild(msg);
end

function doNetBuildPayload()
	local parts = {};
	local charData = MuteClock[CURRENT_PLAYER_NAME];
	if (not charData) then return ""; end
	for k, v in pairs(charData) do
		if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
			local craftKey = string.sub(k, 1, string.len(k) - 10);
			if (getCraftEntry(craftKey)) then
				table.insert(parts, craftKey .. "~" .. tostring(v));
			end
		end
	end
	return table.concat(parts, ";");
end

function doNetBroadcastAll()
	local payload = doNetBuildPayload();
	if (payload ~= "") then
		doNetSendAll("REPLY:" .. payload);
	end
end

function doNetSendCraft(craftKey, avail)
	doNetSendAll("CD:" .. craftKey .. "~" .. tostring(avail));
end

function doNetParseRecord(record)
	local sep = string.find(record, "~");
	if (not sep) then return nil, nil; end
	local craftKey = string.sub(record, 1, sep - 1);
	local ts       = tonumber(string.sub(record, sep + 1));
	return craftKey, ts;
end

function doNetOnMessage(sender, msg)
	if (msg == "HELLO") then
		if (not MC_PEERS[sender]) then MC_PEERS[sender] = {}; end
		if (not MC_FRIENDS[sender]) then MC_NEARBY[sender] = true; end
		doNetBroadcastAll();

	elseif (string.sub(msg, 1, 6) == "REPLY:") then
		if (not MC_PEERS[sender]) then MC_PEERS[sender] = {}; end
		if (not MC_FRIENDS[sender]) then MC_NEARBY[sender] = true; end
		local data = MC_PEERS[sender];
		for k in pairs(data) do
			if (k ~= "_updated") then data[k] = nil; end
		end
		for record in string.gfind(string.sub(msg, 7), "[^;]+") do
			local craftKey, ts = doNetParseRecord(record);
			if (craftKey and ts and getCraftEntry(craftKey)) then
				data[craftKey] = ts;
			end
		end
		data._updated = time();
		MuteClock._peers = MC_PEERS;

	elseif (string.sub(msg, 1, 3) == "CD:") then
		local craftKey, ts = doNetParseRecord(string.sub(msg, 4));
		if (craftKey and ts and getCraftEntry(craftKey)) then
			if (not MC_PEERS[sender]) then MC_PEERS[sender] = {}; end
			if (not MC_FRIENDS[sender]) then MC_NEARBY[sender] = true; end
			MC_PEERS[sender][craftKey]  = ts;
			MC_PEERS[sender]._updated   = time();
			MuteClock._peers = MC_PEERS;
		end
	end

	if (MuteClockConfigFramePanelCrafters:IsVisible()) then doPopulateCrafters(); end
	if (MuteClockConfigFramePanelPlanner:IsVisible())  then doPopulatePlanner();  end
end

-- -------------------------------------------------------
-- Group membership
-- -------------------------------------------------------
function doIsInGroup(name)
	local i;
	for i = 1, GetNumRaidMembers() do
		local n = GetRaidRosterInfo(i);
		if (n == name) then return true; end
	end
	for i = 1, GetNumPartyMembers() do
		if (UnitName("party"..i) == name) then return true; end
	end
	return false;
end

-- -------------------------------------------------------
-- Friend management
-- -------------------------------------------------------
function mcAddFriend(name)
	MC_FRIENDS[name]   = true;
	MC_NEARBY[name]    = nil;
	MuteClock._friends = MC_FRIENDS;
	if (MuteClockConfigFramePanelCrafters:IsVisible()) then doPopulateCrafters(); end
end

function mcRemoveFriend(name)
	MC_FRIENDS[name]   = nil;
	MuteClock._friends = MC_FRIENDS;
	if (doIsInGroup(name)) then MC_NEARBY[name] = true; end
	if (MuteClockConfigFramePanelCrafters:IsVisible()) then doPopulateCrafters(); end
end

-- -------------------------------------------------------
-- Crafters panel
-- -------------------------------------------------------
function doPopulateCrafters()
	local lScrollFrame  = MuteClockConfigFramePanelCraftersLeftScrollFrame;
	local lScrollBar    = MuteClockConfigFramePanelCraftersLeftScrollBar;
	local lContent      = MuteClockConfigFramePanelCraftersLeftScrollFrameContent;
	local rScrollFrame  = MuteClockConfigFramePanelCraftersRightScrollFrame;
	local rScrollBar    = MuteClockConfigFramePanelCraftersRightScrollBar;
	local rContent      = MuteClockConfigFramePanelCraftersRightScrollFrameContent;

	mcClearContent(lContent);
	mcClearContent(rContent);
	local ll  = 1;
	local rl  = 1;
	local now = time();

	local friends = {};
	for name in pairs(MC_FRIENDS) do table.insert(friends, name); end
	table.sort(friends);

	local detected = {};
	for name in pairs(MC_NEARBY) do
		if (not MC_FRIENDS[name]) then table.insert(detected, name); end
	end
	table.sort(detected);

	-- ── LEFT: Saved Crafters ─────────────────────────────
	if (table.getn(friends) == 0) then
		ll = mcAddLine(lContent, ll, "No crafters saved.", 0.5, 0.5, 0.5);
		ll = mcAddSpacer(lContent, ll);
		ll = mcAddLine(lContent, ll, "Use [+] on the right to add", 0.38, 0.38, 0.38);
		ll = mcAddLine(lContent, ll, "someone.", 0.38, 0.38, 0.38);
	elseif (GROUP_BY_CRAFT == 0) then
		local first = true;
		for _, name in ipairs(friends) do
			if (not first) then ll = mcAddSmallSpacer(lContent, ll); end
			first = false;
			local data      = MC_PEERS[name] or {};
			local removeName = name;
			local updated    = data._updated;
			local stale      = updated and ((now - updated) > 172800);
			local staleTag   = stale and " |cFFFF6600⚠|r" or "";

			ll = mcAddRowWithButton(lContent, ll,
				"|cFFFFD100" .. name .. "|r" .. staleTag,
				"-", 0.85, 0.3, 0.3,
				function() mcRemoveFriend(removeName); end);

			local hasCraftData = false;
			for _, entry in ipairs(TRACKED_CRAFTS) do
				local ts = data[entry.key];
				if (ts ~= nil) then
					hasCraftData = true;
					local remaining = (ts > 0) and (ts - now) or 0;
					ll = mcAddLine(lContent, ll,
						"  |cFF888888" .. entry.label .. "|r  " .. doFormatCrafterTime(remaining));
				end
			end
			if (not hasCraftData) then
				ll = mcAddLine(lContent, ll, "  |cFF3A3A3ANo data yet.|r");
			end
		end
	else
		local first = true;
		for _, entry in ipairs(TRACKED_CRAFTS) do
			local rows = {};
			for _, name in ipairs(friends) do
				local ts = (MC_PEERS[name] or {})[entry.key];
				if (ts ~= nil) then
					local remaining = (ts > 0) and (ts - now) or 0;
					table.insert(rows, { name = name, remaining = remaining });
				end
			end
			if (table.getn(rows) > 0) then
				if (not first) then ll = mcAddSmallSpacer(lContent, ll); end
				first = false;
				table.sort(rows, function(a, b)
					if ((a.remaining <= 0) ~= (b.remaining <= 0)) then return a.remaining <= 0; end
					return a.name < b.name;
				end);
				ll = mcAddHeader(lContent, ll, entry.label);
				for _, row in ipairs(rows) do
					local removeName = row.name;
					ll = mcAddRowWithButton(lContent, ll,
						"|cFFDDDDDD" .. row.name .. "|r  " .. doFormatCrafterTime(row.remaining),
						"-", 0.85, 0.3, 0.3,
						function() mcRemoveFriend(removeName); end);
				end
			end
		end
	end

	-- ── RIGHT: Detected Users ────────────────────────────
	if (table.getn(detected) == 0) then
		rl = mcAddLine(rContent, rl, "No addon users detected.", 0.5, 0.5, 0.5);
		rl = mcAddSpacer(rContent, rl);
		rl = mcAddLine(rContent, rl, "MuteClock users in your", 0.38, 0.38, 0.38);
		rl = mcAddLine(rContent, rl, "party, raid, or guild will", 0.38, 0.38, 0.38);
		rl = mcAddLine(rContent, rl, "appear here automatically.", 0.38, 0.38, 0.38);
	else
		local first = true;
		for _, name in ipairs(detected) do
			if (not first) then rl = mcAddSmallSpacer(rContent, rl); end
			first = false;
			local data    = MC_PEERS[name] or {};
			local addName = name;
			rl = mcAddRowWithButton(rContent, rl,
				"|cFFCCCCCC" .. name .. "|r",
				"+", 0.2, 0.85, 0.2,
				function() mcAddFriend(addName); end);
			local hasCraftData = false;
			for _, entry in ipairs(TRACKED_CRAFTS) do
				local ts = data[entry.key];
				if (ts ~= nil) then
					hasCraftData = true;
					local remaining = (ts > 0) and (ts - now) or 0;
					rl = mcAddLine(rContent, rl,
						"  |cFF888888" .. entry.label .. "|r  " .. doFormatCrafterTime(remaining));
				end
			end
			if (not hasCraftData) then
				rl = mcAddLine(rContent, rl, "  |cFF3A3A3ANo data yet.|r");
			end
		end
	end

	mcFinaliseScroll(lScrollFrame, lScrollBar, lContent, ll - 1);
	mcFinaliseScroll(rScrollFrame, rScrollBar, rContent, rl - 1);
end

function doFormatCrafterTime(remaining)
	if (remaining <= 0) then return "|cFF33DD33Ready|r"; end
	local r, g, b;
	if     (remaining <= 3600)  then r, g, b = 1.0, 0.75, 0.1;
	elseif (remaining <= 14400) then r, g, b = 1.0, 0.50, 0.1;
	else                             r, g, b = 0.55, 0.55, 0.55; end
	return string.format("|cFF%02X%02X%02X%s|r",
		floor(r*255), floor(g*255), floor(b*255), doFormatCountdown(remaining));
end

-- -------------------------------------------------------
-- Tooltip
-- -------------------------------------------------------
function doShowTooltip()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	if (ClockFrame.OnboardingTimer and ClockFrame.OnboardingTimer > 0) then return; end
	GameTooltip:SetOwner(ClockFrame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPRIGHT", "ClockFrame", "TOPLEFT", -4, -8);
	doFillTooltip();
	GameTooltip:Show();
end

function doShowBarTooltip()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	GameTooltip:SetOwner(ClockBarFrame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPRIGHT", "ClockBarFrame", "TOPLEFT", -4, 0);
	doFillTooltip();
	GameTooltip:Show();
end

function doShowMiniTooltip()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	GameTooltip:SetOwner(ClockMiniPanel, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPRIGHT", "ClockMiniPanel", "TOPLEFT", -4, 0);
	doFillTooltip();
	GameTooltip:Show();
end

function doFillTooltip()
	GameTooltip:ClearLines();
	if (TOOLTIP_MODE == 1) then
		doTooltipCrafters();
	else
		doTooltipMyCooldowns();
	end
	GameTooltip:AddLine(" ");
	local modeLabel = (TOOLTIP_MODE == 1)
		and "|cFFAAAAAA[ Crafters view ]|r"
		or  "|cFFAAAAAA[ My Cooldowns view ]|r";
	GameTooltip:AddLine(modeLabel);
	GameTooltip:AddLine("|cFF444444Right-click  menu|r");
	GameTooltip:AddLine("|cFF444444Shift+click  switch view|r");
	GameTooltip:AddLine("|cFF444444Ctrl+click   open config|r");
	GameTooltip:AddLine("|cFF444444Drag         move|r");
end

function doTooltipMyCooldowns()
	local data   = doCollectCooldownData();
	local readyN = 0;
	local waitN  = 0;
	for _, row in ipairs(data) do
		if (row.remaining <= 0) then readyN = readyN + 1;
		else waitN = waitN + 1; end
	end
	local header = "|cFFFFD100My Cooldowns|r";
	if (readyN > 0) then header = header .. "  |cFF22FF22" .. readyN .. " ready|r"; end
	if (waitN  > 0) then header = header .. "  |cFF777777" .. waitN  .. " waiting|r"; end
	GameTooltip:AddLine(header);
	if (table.getn(data) == 0) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine("No data yet. Open a trade skill window.", 0.5, 0.5, 0.5);
		return;
	end
	GameTooltip:AddLine(" ");
	if (GROUP_BY_CRAFT == 1) then doTooltipByCraft(data);
	else doTooltipByChar(data); end
end

function doTooltipCrafters()
	local now        = time();
	local friendList = {};
	for name in pairs(MC_FRIENDS) do table.insert(friendList, name); end
	table.sort(friendList);
	local totalReady = 0;
	for _, name in ipairs(friendList) do
		local data = MC_PEERS[name] or {};
		for _, entry in ipairs(TRACKED_CRAFTS) do
			local ts = data[entry.key];
			if (ts ~= nil) then
				local rem = (ts > 0) and (ts - now) or 0;
				if (rem <= 0) then totalReady = totalReady + 1; end
			end
		end
	end
	local header = "|cFFFFD100Crafters|r";
	if (totalReady > 0) then header = header .. "  |cFF22FF22" .. totalReady .. " ready|r"; end
	GameTooltip:AddLine(header);
	if (table.getn(friendList) == 0) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine("No crafters saved.", 0.5, 0.5, 0.5);
		GameTooltip:AddLine("Right-click > Open Config.", 0.38, 0.38, 0.38);
		return;
	end
	GameTooltip:AddLine(" ");
	for _, name in ipairs(friendList) do
		local data    = MC_PEERS[name] or {};
		local updated = data._updated;
		local stale   = updated and ((now - updated) > 172800);
		local staleStr = stale and " |cFFFF6600⚠ stale|r" or "";
		GameTooltip:AddLine("|cFFFFD100" .. name .. "|r" .. staleStr);
		local hasCraft = false;
		for _, entry in ipairs(TRACKED_CRAFTS) do
			local ts = data[entry.key];
			if (ts ~= nil) then
				hasCraft = true;
				local remaining = (ts > 0) and (ts - now) or 0;
				doTooltipCooldownLine(entry.label, remaining, nil);
			end
		end
		if (not hasCraft) then
			GameTooltip:AddLine("  |cFF505050No craft data yet.|r");
		end
	end
end

function doTooltipByChar(data)
	table.sort(data, function(a, b)
		if (a.charName ~= b.charName) then
			if (a.charName == CURRENT_PLAYER_NAME) then return true; end
			if (b.charName == CURRENT_PLAYER_NAME) then return false; end
			return a.charName < b.charName;
		end
		if ((a.remaining <= 0) ~= (b.remaining <= 0)) then return a.remaining <= 0; end
		return a.label < b.label;
	end);
	local lastChar = nil;
	for _, row in ipairs(data) do
		if (row.charName ~= lastChar) then
			if (lastChar ~= nil) then GameTooltip:AddLine(" "); end
			local col = (row.charName == CURRENT_PLAYER_NAME) and "|cFFFFD100" or "|cFFAAAAAA";
			GameTooltip:AddLine(col .. row.charName .. "|r");
			lastChar = row.charName;
		end
		doTooltipCooldownLine(row.label, row.remaining, row.lastCrafted);
	end
end

function doTooltipByCraft(data)
	local byKey = {};
	for _, row in ipairs(data) do
		local entry = getCraftEntry(row.craftKey);
		if (entry) then
			if (not byKey[entry.key]) then byKey[entry.key] = {}; end
			table.insert(byKey[entry.key], row);
		end
	end
	local first = true;
	for _, entry in ipairs(TRACKED_CRAFTS) do
		local rows = byKey[entry.key];
		if (rows) then
			if (not first) then GameTooltip:AddLine(" "); end
			first = false;
			local craftReady = 0;
			for _, row in ipairs(rows) do
				if (row.remaining <= 0) then craftReady = craftReady + 1; end
			end
			local suffix = (craftReady > 0) and ("  |cFF22FF22" .. craftReady .. " ready|r") or "";
			GameTooltip:AddLine("|cFF00CCFF" .. entry.label .. "|r" .. suffix);
			table.sort(rows, function(a, b)
				if ((a.remaining <= 0) ~= (b.remaining <= 0)) then return a.remaining <= 0; end
				if (a.charName ~= b.charName) then
					if (a.charName == CURRENT_PLAYER_NAME) then return true; end
					if (b.charName == CURRENT_PLAYER_NAME) then return false; end
					return a.charName < b.charName;
				end
				return false;
			end);
			for _, row in ipairs(rows) do
				doTooltipCooldownLine(row.charName, row.remaining, row.lastCrafted);
			end
		end
	end
end

function doTooltipCooldownLine(label, remaining, lastCrafted)
	local lastStr = "";
	if (SHOW_LAST_CRAFTED == 1 and lastCrafted and lastCrafted > 0) then
		local ts = doFormatTimestamp(lastCrafted);
		if (ts) then lastStr = "  |cFF505050" .. ts .. "|r"; end
	end
	if (remaining <= 0) then
		local overdueStr = "";
		if (SHOW_OVERDUE == 1) then
			local od = doFormatOverdue(remaining);
			if (od) then overdueStr = "  |cFFFF6600" .. od .. "|r"; end
		end
		GameTooltip:AddDoubleLine("  " .. label, "Ready" .. overdueStr .. lastStr,
			0.8, 0.8, 0.8, 0.2, 1.0, 0.2);
	else
		local timeStr = doFormatCountdown(remaining);
		if (SHOW_READY_TIME == 1) then
			local rt = doFormatReadyTime(remaining);
			if (rt) then timeStr = timeStr .. "  |cFF777777" .. rt .. "|r"; end
		end
		timeStr = timeStr .. lastStr;
		local r, g, b;
		if     (remaining <= 3600)  then r, g, b = 1, 0.75, 0.1;
		elseif (remaining <= 14400) then r, g, b = 1, 0.5,  0.1;
		else                             r, g, b = 0.55, 0.55, 0.55; end
		GameTooltip:AddDoubleLine("  " .. label, timeStr, 0.8, 0.8, 0.8, r, g, b);
	end
end

-- -------------------------------------------------------
-- Notifications
-- -------------------------------------------------------
function doRunNotifications()
	local now = time();
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						local entry = getCraftEntry(craftKey);
						if (entry) then
							local remaining = (v > 0) and (v - now) or 0;
							if (remaining <= 0) then
								local nKey = craftKey .. "-notified";
								if (not charData[nKey]) then
									charData[nKey] = 1;
									if (DO_NOTIFY == 1) then
										doSendNotify(charName, entry, remaining);
									end
								end
								-- Overdue reminder
								if (DO_NOTIFY == 1 and OVERDUE_REMIND > 0) then
									local remindKey = craftKey .. "-remind";
									local lastRemind = charData[remindKey] or 0;
									local elapsed = now - lastRemind;
									if (elapsed >= OVERDUE_REMIND * 3600 and lastRemind > 0) then
										charData[remindKey] = now;
										doSendOverdueReminder(charName, entry, remaining);
									elseif (lastRemind == 0 and charData[nKey]) then
										-- First reminder fires after the interval
										charData[remindKey] = now;
									end
								end
							else
								-- Reset overdue remind timer if craft is back on cooldown
								charData[craftKey .. "-remind"] = nil;
							end
						end
					end
				end
			end
		end
	end
end

function doSendNotify(playerName, entry, remaining)
	local who    = (playerName == CURRENT_PLAYER_NAME) and "Your" or (playerName .. "'s");
	local suffix = "";
	if (remaining < -300) then
		local od = doFormatOverdue(remaining);
		if (od) then suffix = " |cFFFF6600(" .. od .. ")|r"; end
	end
	local frame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME;
	frame:AddMessage("|cFF00FF00MuteClock|r  " .. who .. " |cFFFFD100" .. entry.label .. "|r is ready!" .. suffix);
	PlaySound("AuctionWindowOpen");
end

function doSendOverdueReminder(playerName, entry, remaining)
	local od = doFormatOverdue(remaining);
	if (not od) then return; end
	local who   = (playerName == CURRENT_PLAYER_NAME) and "Your" or (playerName .. "'s");
	local frame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME;
	frame:AddMessage("|cFF00FF00MuteClock|r  Reminder: " .. who .. " |cFFFFD100" .. entry.label .. "|r has been ready for |cFFFF6600" .. od .. "|r");
end

-- -------------------------------------------------------
-- Dot update
-- -------------------------------------------------------
function doUpdateDot()
	if (DOT_HIDDEN == 1) then return; end
	ClockFrame:SetWidth(DOT_SIZE);
	ClockFrame:SetHeight(DOT_SIZE);
	local status, readyN, crafterReadyN = doGetDotStatus();

	if (ICON_MODE > 0 and status == 1) then
		local iconTex = nil;
		if     (ICON_MODE == 1) then local e = doGetSmartIcon(); if (e) then iconTex = e.icon; end
		elseif (ICON_MODE == 2) then iconTex = TRACKED_CRAFTS[1].icon;
		elseif (ICON_MODE == 3) then iconTex = TRACKED_CRAFTS[2].icon;
		elseif (ICON_MODE == 4) then iconTex = TRACKED_CRAFTS[3].icon; end
		if (iconTex) then
			ClockDot:SetTexture(iconTex);
			ClockDot:SetVertexColor(1, 1, 1, 1);
			doUpdateBadge(readyN, crafterReadyN);
			return;
		end
	end

	ClockDot:SetTexture("Interface\\Buttons\\WHITE8X8");
	if     (status == 0) then ClockDot:SetVertexColor(0.3,  0.3,  0.3,  1);
	elseif (status == 1) then ClockDot:SetVertexColor(0.1,  0.9,  0.1,  1);
	elseif (status == 2) then ClockDot:SetVertexColor(0.95, 0.85, 0.1,  1);
	else                      ClockDot:SetVertexColor(0.9,  0.15, 0.15, 1); end
	doUpdateBadge(readyN, crafterReadyN);
end

function doUpdateBadge(readyN, crafterReadyN)
	if (SHOW_BADGE ~= 1) then
		MuteClockBadge:Hide();
		return;
	end
	local total = (readyN or 0) + (crafterReadyN or 0);
	if (total > 0) then
		-- Gold for own, cyan tint if any crafters ready
		if ((crafterReadyN or 0) > 0 and (readyN or 0) == 0) then
			MuteClockBadge:SetTextColor(0, 0.85, 1, 1);   -- cyan: crafters only
		elseif ((crafterReadyN or 0) > 0) then
			MuteClockBadge:SetTextColor(0.7, 0.95, 0.5, 1); -- mixed
		else
			MuteClockBadge:SetTextColor(1, 0.9, 0, 1);    -- gold: own only
		end
		MuteClockBadge:SetText(total);
		MuteClockBadge:Show();
	else
		MuteClockBadge:Hide();
	end
end
