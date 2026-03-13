-- MuteClock - Cooldown Tracker for TurtleWoW / Vanilla 1.12

-- -------------------------------------------------------
-- Defaults
-- -------------------------------------------------------
DEF_SH_ALL_CHARACTERS = 1;
DEF_DO_NOTIFY         = 1;
DEF_POSITION_X        = 0;
DEF_POSITION_Y        = 0;
DEF_DOT_SIZE          = 16;
DEF_DOT_HIDDEN        = 0;
DEF_SMART_ICON        = 0;
DEF_GROUP_BY_CRAFT    = 0;
DEF_SHOW_READY_TIME   = 0;
DEF_SHOW_OVERDUE      = 1;
DEF_SHOW_LAST_CRAFTED = 0;
DEF_SHOW_BADGE        = 0;
DEF_USE_MINIMAP       = 0;
DEF_MINIMAP_ANGLE     = 210;

-- -------------------------------------------------------
-- Runtime globals
-- -------------------------------------------------------
CURRENT_PLAYER_NAME  = "";
SH_ALL_CHARACTERS    = DEF_SH_ALL_CHARACTERS;
DO_NOTIFY            = DEF_DO_NOTIFY;
POSITION_X           = DEF_POSITION_X;
POSITION_Y           = DEF_POSITION_Y;
DOT_SIZE             = DEF_DOT_SIZE;
DOT_HIDDEN           = DEF_DOT_HIDDEN;
SMART_ICON           = DEF_SMART_ICON;
GROUP_BY_CRAFT       = DEF_GROUP_BY_CRAFT;
SHOW_READY_TIME      = DEF_SHOW_READY_TIME;
SHOW_OVERDUE         = DEF_SHOW_OVERDUE;
SHOW_LAST_CRAFTED    = DEF_SHOW_LAST_CRAFTED;
SHOW_BADGE           = DEF_SHOW_BADGE;
USE_MINIMAP          = DEF_USE_MINIMAP;
MINIMAP_ANGLE        = DEF_MINIMAP_ANGLE;

IS_VARIABLES_LOADED  = 0;
CooldownUpdateTimer  = 0;
MINIMAP_DRAGGING     = false;
CraftingItemName     = nil;
isCraftSuccess       = 0;

HISTORY_MAX = 20;

-- -------------------------------------------------------
-- Tracked crafts
-- 'key' must exactly match the string returned by
-- GetTradeSkillInfo() for that recipe in enUS client.
-- -------------------------------------------------------
TRACKED_CRAFTS = {
	{ key = "Transmute: Arcanite", label = "Transmute: Arcanite", icon = "Interface\\Icons\\INV_Ingot_07"              },
	{ key = "Mooncloth",           label = "Mooncloth",            icon = "Interface\\Icons\\INV_Fabric_Moonrag_01"    },
	{ key = "Cure Rugged Hide",    label = "Cure Rugged Hide",     icon = "Interface\\Icons\\INV_Misc_LeatherScrap_02" },
};

-- XML frame name prefix for config controls (PanelSettings children)
-- All controls inside $parentPanelSettings resolve to this prefix.
MC_CTRL = "MuteClockConfigFramePanelSettings";

-- -------------------------------------------------------
-- getCraftEntry: exact key match only
-- -------------------------------------------------------
function getCraftEntry(craftKey)
	for _, entry in ipairs(TRACKED_CRAFTS) do
		if (craftKey == entry.key) then
			return entry;
		end
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
-- VARIABLES_LOADED: read saved vars, apply state
-- -------------------------------------------------------
function onVariablesLoaded()
	if (not MuteClock) then MuteClock = {}; end
	if (not MuteClock[CURRENT_PLAYER_NAME]) then
		MuteClock[CURRENT_PLAYER_NAME] = {};
	end

	SH_ALL_CHARACTERS = mcLoad("sh_all_characters", DEF_SH_ALL_CHARACTERS);
	DO_NOTIFY         = mcLoad("do_notify",         DEF_DO_NOTIFY);
	POSITION_X        = mcLoad("position_x",        DEF_POSITION_X);
	POSITION_Y        = mcLoad("position_y",        DEF_POSITION_Y);
	DOT_SIZE          = mcLoad("dot_size",           DEF_DOT_SIZE);
	DOT_HIDDEN        = mcLoad("dot_hidden",         DEF_DOT_HIDDEN);
	SMART_ICON        = mcLoad("smart_icon",         DEF_SMART_ICON);
	GROUP_BY_CRAFT    = mcLoad("group_by_craft",     DEF_GROUP_BY_CRAFT);
	SHOW_READY_TIME   = mcLoad("show_ready_time",    DEF_SHOW_READY_TIME);
	SHOW_OVERDUE      = mcLoad("show_overdue",       DEF_SHOW_OVERDUE);
	SHOW_LAST_CRAFTED = mcLoad("show_last_crafted",  DEF_SHOW_LAST_CRAFTED);
	SHOW_BADGE        = mcLoad("show_badge",         DEF_SHOW_BADGE);
	USE_MINIMAP       = mcLoad("use_minimap",        DEF_USE_MINIMAP);
	MINIMAP_ANGLE     = mcLoad("minimap_angle",      DEF_MINIMAP_ANGLE);

	IS_VARIABLES_LOADED = 1;
	doApplyDotAppearance();
	doPositionFrame();
	doUpdateMinimapButton();
	doRunNotifications();
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
	p.smart_icon        = SMART_ICON;
	p.group_by_craft    = GROUP_BY_CRAFT;
	p.show_ready_time   = SHOW_READY_TIME;
	p.show_overdue      = SHOW_OVERDUE;
	p.show_last_crafted = SHOW_LAST_CRAFTED;
	p.show_badge        = SHOW_BADGE;
	p.use_minimap       = USE_MINIMAP;
	p.minimap_angle     = MINIMAP_ANGLE;
end

-- -------------------------------------------------------
-- Dot appearance
-- -------------------------------------------------------
function doApplyDotAppearance()
	ClockFrame:SetWidth(DOT_SIZE);
	ClockFrame:SetHeight(DOT_SIZE);
	if (DOT_HIDDEN == 1 or USE_MINIMAP == 1) then
		ClockFrame:Hide();
	else
		ClockFrame:Show();
		doUpdateDot();
	end
end

function doPositionFrame()
	ClockFrame:ClearAllPoints();
	if (POSITION_X == 0 and POSITION_Y == 0) then
		ClockFrame:SetPoint("TOP", "UIParent", "TOP", 0, 0);
	else
		ClockFrame:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", POSITION_X, POSITION_Y);
	end
end

-- -------------------------------------------------------
-- Minimap button
-- -------------------------------------------------------
function doUpdateMinimapButton()
	if (USE_MINIMAP == 1) then
		ClockFrame:Hide();
		MuteClockMinimapButton:Show();
		doPositionMinimapButton();
		doUpdateMinimapDot();
	else
		MuteClockMinimapButton:Hide();
		if (DOT_HIDDEN ~= 1) then
			ClockFrame:Show();
			doUpdateDot();
		end
	end
end

function doPositionMinimapButton()
	local angle = MINIMAP_ANGLE * (math.pi / 180);
	local r     = 80;
	MuteClockMinimapButton:ClearAllPoints();
	MuteClockMinimapButton:SetPoint("CENTER", "Minimap", "CENTER",
		math.cos(angle) * r, math.sin(angle) * r);
end

function MinimapButton_OnDragStart()
	MINIMAP_DRAGGING = true;
end

function MinimapButton_OnDragStop()
	MINIMAP_DRAGGING = false;
	doSaveSettings();
end

function MinimapButton_OnUpdate()
	if (not MINIMAP_DRAGGING) then return; end
	local cx, cy = Minimap:GetCenter();
	local mx, my = GetCursorPosition();
	local s = UIParent:GetEffectiveScale();
	MINIMAP_ANGLE = math.atan2((my / s) - cy, (mx / s) - cx) * (180 / math.pi);
	doPositionMinimapButton();
end

function MinimapButton_OnClick(btn, updown)
	if (btn == "LeftButton" and updown == "UP" and not MINIMAP_DRAGGING) then
		if (IsControlKeyDown()) then
			MuteClockConfigFrame:Show();
		end
	end
end

-- -------------------------------------------------------
-- Reset to defaults (preserves cooldown/history data)
-- -------------------------------------------------------
function doSetDefaultSettings()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	SH_ALL_CHARACTERS = DEF_SH_ALL_CHARACTERS;
	DO_NOTIFY         = DEF_DO_NOTIFY;
	POSITION_X        = DEF_POSITION_X;
	POSITION_Y        = DEF_POSITION_Y;
	DOT_SIZE          = DEF_DOT_SIZE;
	DOT_HIDDEN        = DEF_DOT_HIDDEN;
	SMART_ICON        = DEF_SMART_ICON;
	GROUP_BY_CRAFT    = DEF_GROUP_BY_CRAFT;
	SHOW_READY_TIME   = DEF_SHOW_READY_TIME;
	SHOW_OVERDUE      = DEF_SHOW_OVERDUE;
	SHOW_LAST_CRAFTED = DEF_SHOW_LAST_CRAFTED;
	SHOW_BADGE        = DEF_SHOW_BADGE;
	USE_MINIMAP       = DEF_USE_MINIMAP;
	MINIMAP_ANGLE     = DEF_MINIMAP_ANGLE;
	doSaveSettings();
	doApplyDotAppearance();
	doPositionFrame();
	doUpdateMinimapButton();
	doInitializeConfig(1);
end

-- -------------------------------------------------------
-- Config: tab switching
-- Panel names resolve from XML:
--   $parentPanelSettings -> MuteClockConfigFramePanelSettings
--   $parentPanelHistory  -> MuteClockConfigFramePanelHistory
-- -------------------------------------------------------
function doShowConfigTab(tabName)
	MuteClockConfigFramePanelSettings:Hide();
	MuteClockConfigFramePanelHistory:Hide();
	if (tabName == "Settings") then
		MuteClockConfigFramePanelSettings:Show();
	else
		MuteClockConfigFramePanelHistory:Show();
		doPopulateHistory();
	end
end

-- -------------------------------------------------------
-- Config: populate controls from current globals
-- Control names inside $parentPanelSettings resolve to:
--   MC_CTRL .. "CBAllChars" etc.
-- isDefaults=1: called from Lua (this is not the frame)
-- isDefaults=0: called from XML OnShow (this = config frame)
-- -------------------------------------------------------
function doInitializeConfig(isDefaults)
	local p = MC_CTRL;
	getglobal(p.."CBAllChars"):SetChecked(SH_ALL_CHARACTERS);
	getglobal(p.."CBNotify"):SetChecked(DO_NOTIFY);
	getglobal(p.."CBGroupByCraft"):SetChecked(GROUP_BY_CRAFT);
	getglobal(p.."CBReadyTime"):SetChecked(SHOW_READY_TIME);
	getglobal(p.."CBOverdue"):SetChecked(SHOW_OVERDUE);
	getglobal(p.."CBLastCrafted"):SetChecked(SHOW_LAST_CRAFTED);
	getglobal(p.."CBSmartIcon"):SetChecked(SMART_ICON);
	getglobal(p.."CBBadge"):SetChecked(SHOW_BADGE);
	getglobal(p.."CBMinimap"):SetChecked(USE_MINIMAP);
	getglobal(p.."CBHide"):SetChecked(DOT_HIDDEN);
	getglobal(p.."SliderSize"):SetValue(DOT_SIZE);
end

-- -------------------------------------------------------
-- Config: save a single control's value to globals
-- Called by OnClick / OnValueChanged; 'this' is the widget
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
	elseif (n == p.."CBSmartIcon")   then SMART_ICON        = this:GetChecked() or 0;
	elseif (n == p.."CBBadge")       then SHOW_BADGE        = this:GetChecked() or 0;
	elseif (n == p.."CBMinimap")     then
		USE_MINIMAP = this:GetChecked() or 0;
		doUpdateMinimapButton();
	elseif (n == p.."CBHide")        then DOT_HIDDEN        = this:GetChecked() or 0;
	elseif (n == p.."SliderSize")    then
		DOT_SIZE = floor(this:GetValue());
		getglobal(n.."Text"):SetText("Dot Size ("..DOT_SIZE.."px)");
	end

	doSaveSettings();
	doApplyDotAppearance();
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
-- History: fill the history panel
-- ScrollingMessageFrame is $parentPanelHistoryMsgFrame
--   -> MuteClockConfigFramePanelHistoryMsgFrame
-- -------------------------------------------------------
function doPopulateHistory()
	local msg = MuteClockConfigFramePanelHistoryMsgFrame;
	msg:Clear();

	local entries = {};
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table") then
			for k, v in pairs(charData) do
				-- match keys ending in "-history"
				if (string.len(k) > 8 and string.sub(k, -8) == "-history") then
					local craftKey = string.sub(k, 1, string.len(k) - 8);
					local entry = getCraftEntry(craftKey);
					if (entry and type(v) == "table") then
						for _, rec in ipairs(v) do
							table.insert(entries, {
								t        = rec.t,
								charName = charName,
								label    = entry.label,
							});
						end
					end
				end
			end
		end
	end

	-- Sort newest first; equal timestamps keep stable order
	table.sort(entries, function(a, b)
		if (a.t ~= b.t) then return a.t > b.t; end
		return false;
	end);

	if (table.getn(entries) == 0) then
		msg:AddMessage("|cFF888888No crafts recorded yet.|r");
		msg:AddMessage("|cFF666666Open a trade skill and craft something.|r");
		return;
	end

	for _, e in ipairs(entries) do
		local when = date("%a %d %b  %H:%M", e.t);
		local col  = (e.charName == CURRENT_PLAYER_NAME) and "|cFFFFD100" or "|cFFAAAAAA";
		msg:AddMessage(col .. e.charName .. "|r  |cFF00CCFF" .. e.label .. "|r  |cFF888888" .. when .. "|r");
	end
end

-- -------------------------------------------------------
-- Frame OnLoad handlers
-- -------------------------------------------------------
function Clock_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("SPELLCAST_START");
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("TRADE_SKILL_CLOSE");
	this:RegisterEvent("SPELLCAST_INTERRUPTED");
	this:RegisterEvent("SPELLCAST_FAILED");
	this:RegisterEvent("ITEM_PUSH");
	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r loaded.");
	end
	SLASH_MUTECLOCK1 = "/muteclock";
	SlashCmdList["MUTECLOCK"] = SlashCommandHandler;
	ClockFrame.TimeSinceLastUpdate = 0;
	ClockFrame:Hide();
	ClockFrame:RegisterForDrag("LeftButton");
	doBadgeInit();
end

function MuteClockConfig_OnLoad()
	this:SetBackdropColor(0.05, 0.05, 0.05, 0.97);
	this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
	MuteClockConfigFrameTopBar:SetVertexColor(0.08, 0.12, 0.18, 1);
	MuteClockConfigFrameTitle:SetTextColor(0.9, 0.9, 1, 1);
	MuteClockDivTracking:SetVertexColor(0.25, 0.55, 0.75, 0.5);
	MuteClockDivDisplay:SetVertexColor(0.25, 0.55, 0.75, 0.5);
	MuteClockDivDot:SetVertexColor(0.25, 0.55, 0.75, 0.5);
	this:RegisterForDrag("LeftButton");
	-- Default to Settings tab
	MuteClockConfigFramePanelHistory:Hide();
	MuteClockConfigFramePanelSettings:Show();
end

-- Badge font/colour setup - called after all XML frames exist
function doBadgeInit()
	MuteClockBadge:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
	MuteClockBadge:SetTextColor(1, 0.9, 0, 1);
	MuteClockMinimapBadge:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
	MuteClockMinimapBadge:SetTextColor(1, 0.9, 0, 1);
end

-- -------------------------------------------------------
-- Config tooltip (Lua 5.0: varargs come via 'arg' table)
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
					local key = CraftingItemName;
					MuteClock[CURRENT_PLAYER_NAME][key .. "-available"] = time() + floor(cd);
					MuteClock[CURRENT_PLAYER_NAME][key .. "-notified"]  = nil;
					MuteClock[CURRENT_PLAYER_NAME][key .. "-crafted"]   = time();
					doRecordHistory(CURRENT_PLAYER_NAME, key);
				end
			end
			CraftingItemName = nil;
			isCraftSuccess   = 0;
		end

	elseif (event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE") then
		local n = GetNumTradeSkills();
		for i = 1, n do
			local name, kind = GetTradeSkillInfo(i);
			if (kind ~= "header" and getCraftEntry(name)) then
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
	end
end

-- -------------------------------------------------------
-- Per-frame update: 1s action interval
-- -------------------------------------------------------
function Clock_OnUpdate(arg1)
	ClockFrame.TimeSinceLastUpdate = ClockFrame.TimeSinceLastUpdate + arg1;
	if (ClockFrame.TimeSinceLastUpdate >= 0.1) then
		ClockFrame.TimeSinceLastUpdate = 0;
		if (IS_VARIABLES_LOADED ~= 1) then return; end
		CooldownUpdateTimer = CooldownUpdateTimer + 0.1;
		if (CooldownUpdateTimer >= 1.0) then
			CooldownUpdateTimer = 0;
			doRunNotifications();
			doUpdateDot();
			doUpdateMinimapDot();
		end
	end
end

-- -------------------------------------------------------
-- Drag and click - main dot
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

function ClickHandler(btn, updown)
	if (btn == "LeftButton" and updown == "UP" and IsControlKeyDown()) then
		MuteClockConfigFrame:Show();
	end
end

-- -------------------------------------------------------
-- Slash commands
-- -------------------------------------------------------
function SlashCommandHandler(msg)
	local cmd = string.gsub(msg, "^%s*(.-)%s*$", "%1");
	if (cmd == "") then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r commands:");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock config|r  open settings");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock reset|r   restore defaults");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock show|r    unhide the dot");
	elseif (cmd == "config") then
		MuteClockConfigFrame:Show();
	elseif (cmd == "reset") then
		doSetDefaultSettings();
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r settings reset to defaults.");
	elseif (cmd == "show") then
		DOT_HIDDEN = 0;
		doSaveSettings();
		doApplyDotAppearance();
	end
end

-- -------------------------------------------------------
-- Time formatting helpers
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
	-- remaining <= 0; returns e.g. "+2h 15m" or nil if < 1 min
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
-- Collect cooldown rows (filters by scope setting)
-- -------------------------------------------------------
function doCollectCooldownData()
	local results = {};
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table") then
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
-- Dot status (0=no data, 1=ready, 2=<4h, 3=long CD)
-- -------------------------------------------------------
function doGetDotStatus()
	if (not MuteClock) then return 0, 0; end
	local hasData  = false;
	local hasReady = false;
	local hasSoon  = false;
	local readyN   = 0;
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table") then
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
	if (not hasData) then return 0, 0; end
	if (hasReady)    then return 1, readyN; end
	if (hasSoon)     then return 2, 0; end
	return 3, 0;
end

-- -------------------------------------------------------
-- SmartIcon: highest-priority ready craft
-- -------------------------------------------------------
function doGetSmartIcon()
	local best = {};
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table") then
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
-- Tooltip anchor: always left of the icon, slightly down.
-- -------------------------------------------------------
function doGetTooltipAnchor(frame)
	return "TOPRIGHT", "TOPLEFT", -4, -8;
end

-- -------------------------------------------------------
-- Tooltip: build and show
-- -------------------------------------------------------
function doShowTooltip()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	GameTooltip:SetOwner(ClockFrame, "ANCHOR_NONE");
	local ap, rp, ox, oy = doGetTooltipAnchor(ClockFrame);
	GameTooltip:SetPoint(ap, "ClockFrame", rp, ox, oy);
	doFillTooltip();
	GameTooltip:Show();
end

function doShowMinimapTooltip()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	GameTooltip:SetOwner(MuteClockMinimapButton, "ANCHOR_NONE");
	local ap, rp, ox, oy = doGetTooltipAnchor(MuteClockMinimapButton);
	GameTooltip:SetPoint(ap, "MuteClockMinimapButton", rp, ox, oy);
	doFillTooltip();
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("|cFF666666Ctrl+click to open config|r");
	GameTooltip:Show();
end

function doFillTooltip()
	local data = doCollectCooldownData();
	local readyN = 0;
	local waitN  = 0;
	for _, row in ipairs(data) do
		if (row.remaining <= 0) then readyN = readyN + 1;
		else waitN = waitN + 1; end
	end

	local header = "|cFFFFD100Craft Cooldowns|r";
	if (readyN > 0) then header = header .. "  |cFF22FF22" .. readyN .. " ready|r"; end
	if (waitN  > 0) then header = header .. "  |cFF888888" .. waitN  .. " waiting|r"; end
	GameTooltip:AddLine(header);

	if (table.getn(data) == 0) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine("No data yet. Open a trade skill window.", 0.55, 0.55, 0.55);
		return;
	end

	GameTooltip:AddLine(" ");
	if (GROUP_BY_CRAFT == 1) then
		doTooltipByCraft(data);
	else
		doTooltipByChar(data);
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
		if (ts) then lastStr = "  |cFF666666" .. ts .. "|r"; end
	end

	if (remaining <= 0) then
		local overdueStr = "";
		if (SHOW_OVERDUE == 1) then
			local od = doFormatOverdue(remaining);
			if (od) then overdueStr = "  |cFFFF6600" .. od .. "|r"; end
		end
		GameTooltip:AddDoubleLine(
			"  " .. label,
			"Ready" .. overdueStr .. lastStr,
			0.8, 0.8, 0.8,
			0.2, 1.0, 0.2
		);
	else
		local timeStr = doFormatCountdown(remaining);
		if (SHOW_READY_TIME == 1) then
			local rt = doFormatReadyTime(remaining);
			if (rt) then timeStr = timeStr .. "  |cFF888888" .. rt .. "|r"; end
		end
		timeStr = timeStr .. lastStr;
		local r, g, b;
		if     (remaining <= 3600)  then r, g, b = 1, 0.75, 0.1;
		elseif (remaining <= 14400) then r, g, b = 1, 0.5,  0.1;
		else                             r, g, b = 0.55, 0.55, 0.55;
		end
		GameTooltip:AddDoubleLine("  " .. label, timeStr, 0.8, 0.8, 0.8, r, g, b);
	end
end

-- -------------------------------------------------------
-- Notifications
-- -------------------------------------------------------
function doRunNotifications()
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for k, v in pairs(charData) do
					if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
						local craftKey = string.sub(k, 1, string.len(k) - 10);
						local entry = getCraftEntry(craftKey);
						if (entry) then
							local remaining = (v > 0) and (v - time()) or 0;
							if (remaining <= 0) then
								local nKey = craftKey .. "-notified";
								if (not charData[nKey]) then
									charData[nKey] = 1;
									if (DO_NOTIFY == 1) then
										doSendNotify(charName, entry, remaining);
									end
								end
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

-- -------------------------------------------------------
-- Dot update
-- -------------------------------------------------------
function doUpdateDot()
	if (DOT_HIDDEN == 1 or USE_MINIMAP == 1) then return; end
	local status, readyN = doGetDotStatus();

	if (SMART_ICON == 1 and status == 1) then
		local entry = doGetSmartIcon();
		if (entry) then
			ClockDot:SetTexture(entry.icon);
			ClockDot:SetVertexColor(1, 1, 1, 1);
			doUpdateBadge(readyN);
			return;
		end
	end

	ClockDot:SetTexture("Interface\\Buttons\\WHITE8X8");
	if     (status == 0) then ClockDot:SetVertexColor(0.3,  0.3,  0.3,  1);
	elseif (status == 1) then ClockDot:SetVertexColor(0.1,  0.9,  0.1,  1);
	elseif (status == 2) then ClockDot:SetVertexColor(0.95, 0.85, 0.1,  1);
	else                      ClockDot:SetVertexColor(0.9,  0.15, 0.15, 1);
	end
	doUpdateBadge(readyN);
end

function doUpdateBadge(readyN)
	if (SHOW_BADGE == 1 and readyN > 0) then
		MuteClockBadge:SetText(readyN);
		MuteClockBadge:Show();
	else
		MuteClockBadge:Hide();
	end
end

-- -------------------------------------------------------
-- Minimap dot update
-- -------------------------------------------------------
function doUpdateMinimapDot()
	if (USE_MINIMAP ~= 1) then return; end
	local status, readyN = doGetDotStatus();

	if (SMART_ICON == 1 and status == 1) then
		local entry = doGetSmartIcon();
		if (entry) then
			MuteClockMinimapButtonIcon:SetTexture(entry.icon);
			MuteClockMinimapButtonIcon:SetVertexColor(1, 1, 1, 1);
			doUpdateMinimapBadge(readyN);
			return;
		end
	end

	MuteClockMinimapButtonIcon:SetTexture("Interface\\Buttons\\WHITE8X8");
	if     (status == 0) then MuteClockMinimapButtonIcon:SetVertexColor(0.3,  0.3,  0.3,  1);
	elseif (status == 1) then MuteClockMinimapButtonIcon:SetVertexColor(0.1,  0.9,  0.1,  1);
	elseif (status == 2) then MuteClockMinimapButtonIcon:SetVertexColor(0.95, 0.85, 0.1,  1);
	else                      MuteClockMinimapButtonIcon:SetVertexColor(0.9,  0.15, 0.15, 1);
	end
	doUpdateMinimapBadge(readyN);
end

function doUpdateMinimapBadge(readyN)
	if (SHOW_BADGE == 1 and readyN > 0) then
		MuteClockMinimapBadge:SetText(readyN);
		MuteClockMinimapBadge:Show();
	else
		MuteClockMinimapBadge:Hide();
	end
end
