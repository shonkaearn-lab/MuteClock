-- MuteClock - Cooldown Tracker
-- Based on RamzClock by ramzes

-- -------------------------------------------------------
-- Defaults
-- -------------------------------------------------------
DEF_SH_ALL_CHARACTERS = 1;
DEF_DO_NOTIFY         = 1;
DEF_POSITION_X        = 0;
DEF_POSITION_Y        = 0;
DEF_TOOLTIP_X         = 0;
DEF_TOOLTIP_Y         = -32;
DEF_DOT_SIZE          = 16;
DEF_DOT_HIDDEN        = 0;
DEF_SMART_ICON        = 0;
DEF_GROUP_BY_CRAFT    = 0;
DEF_SHOW_READY_TIME   = 0;

-- -------------------------------------------------------
-- Globals
-- -------------------------------------------------------
CURRENT_PLAYER_NAME  = "";
SH_ALL_CHARACTERS    = DEF_SH_ALL_CHARACTERS;
DO_NOTIFY            = DEF_DO_NOTIFY;
POSITION_X           = DEF_POSITION_X;
POSITION_Y           = DEF_POSITION_Y;
TOOLTIP_X            = DEF_TOOLTIP_X;
TOOLTIP_Y            = DEF_TOOLTIP_Y;
DOT_SIZE             = DEF_DOT_SIZE;
DOT_HIDDEN           = DEF_DOT_HIDDEN;
SMART_ICON           = DEF_SMART_ICON;
GROUP_BY_CRAFT       = DEF_GROUP_BY_CRAFT;
SHOW_READY_TIME      = DEF_SHOW_READY_TIME;
IS_VARIABLES_LOADED  = 0;
CooldownUpdateTimer  = 0;

-- -------------------------------------------------------
-- Tracked crafts registry
-- Priority order matters: first = highest SmartIcon priority
-- -------------------------------------------------------
TRACKED_CRAFTS = {
	{ key = "Arcanite",    label = "Transmute: Arcanite", icon = "Interface\\Icons\\INV_Ingot_07"             },
	{ key = "Mooncloth",   label = "Mooncloth",            icon = "Interface\\Icons\\INV_Fabric_Moonrag_01"   },
	{ key = "Rugged Hide", label = "Cure Rugged Hide",     icon = "Interface\\Icons\\INV_Misc_LeatherScrap_02"},
};

-- -------------------------------------------------------
-- Helper: load a saved variable, initialising with default if absent
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
-- Helper: return the TRACKED_CRAFTS entry matching a stored craft name
-- -------------------------------------------------------
function getCraftEntry(craftName)
	for _, entry in ipairs(TRACKED_CRAFTS) do
		if (string.find(craftName, entry.key)) then
			return entry;
		end
	end
	return nil;
end

-- -------------------------------------------------------
-- Init
-- -------------------------------------------------------
function onVariablesLoaded()
	if (not MuteClock) then MuteClock = {}; end
	if (not MuteClock[CURRENT_PLAYER_NAME]) then MuteClock[CURRENT_PLAYER_NAME] = {}; end

	SH_ALL_CHARACTERS = mcLoad("sh_all_characters", DEF_SH_ALL_CHARACTERS);
	DO_NOTIFY         = mcLoad("do_notify",         DEF_DO_NOTIFY);
	POSITION_X        = mcLoad("position_x",        DEF_POSITION_X);
	POSITION_Y        = mcLoad("position_y",        DEF_POSITION_Y);
	TOOLTIP_X         = mcLoad("tooltip_x",         DEF_TOOLTIP_X);
	TOOLTIP_Y         = mcLoad("tooltip_y",         DEF_TOOLTIP_Y);
	DOT_SIZE          = mcLoad("dot_size",           DEF_DOT_SIZE);
	DOT_HIDDEN        = mcLoad("dot_hidden",         DEF_DOT_HIDDEN);
	SMART_ICON        = mcLoad("smart_icon",         DEF_SMART_ICON);
	GROUP_BY_CRAFT    = mcLoad("group_by_craft",     DEF_GROUP_BY_CRAFT);
	SHOW_READY_TIME   = mcLoad("show_ready_time",    DEF_SHOW_READY_TIME);

	IS_VARIABLES_LOADED = 1;
	doApplyDotAppearance();
	doPositionFrame();
end

-- -------------------------------------------------------
-- Save all settings to SavedVariables
-- -------------------------------------------------------
function doSaveSettings()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	local p = MuteClock[CURRENT_PLAYER_NAME];
	p.sh_all_characters = SH_ALL_CHARACTERS;
	p.do_notify         = DO_NOTIFY;
	p.position_x        = POSITION_X;
	p.position_y        = POSITION_Y;
	p.tooltip_x         = TOOLTIP_X;
	p.tooltip_y         = TOOLTIP_Y;
	p.dot_size          = DOT_SIZE;
	p.dot_hidden        = DOT_HIDDEN;
	p.smart_icon        = SMART_ICON;
	p.group_by_craft    = GROUP_BY_CRAFT;
	p.show_ready_time   = SHOW_READY_TIME;
end

-- -------------------------------------------------------
-- Apply dot appearance (size, visibility, then refresh status)
-- -------------------------------------------------------
function doApplyDotAppearance()
	ClockFrame:SetWidth(DOT_SIZE);
	ClockFrame:SetHeight(DOT_SIZE);
	if (DOT_HIDDEN == 1) then
		ClockFrame:Hide();
	else
		ClockFrame:Show();
		doUpdateDot();
	end
end

-- -------------------------------------------------------
-- Position the frame on screen
-- -------------------------------------------------------
function doPositionFrame()
	ClockFrame:ClearAllPoints();
	if ((POSITION_X == 0) and (POSITION_Y == 0)) then
		ClockFrame:SetPoint("TOP", "UIParent", "TOP", 0, 0);
	else
		ClockFrame:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", POSITION_X, POSITION_Y);
	end
end

-- -------------------------------------------------------
-- Reset to defaults (preserves cooldown data)
-- -------------------------------------------------------
function doSetDefaultSettings()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	SH_ALL_CHARACTERS = DEF_SH_ALL_CHARACTERS;
	DO_NOTIFY         = DEF_DO_NOTIFY;
	POSITION_X        = DEF_POSITION_X;
	POSITION_Y        = DEF_POSITION_Y;
	TOOLTIP_X         = DEF_TOOLTIP_X;
	TOOLTIP_Y         = DEF_TOOLTIP_Y;
	DOT_SIZE          = DEF_DOT_SIZE;
	DOT_HIDDEN        = DEF_DOT_HIDDEN;
	SMART_ICON        = DEF_SMART_ICON;
	GROUP_BY_CRAFT    = DEF_GROUP_BY_CRAFT;
	SHOW_READY_TIME   = DEF_SHOW_READY_TIME;
	doSaveSettings();
	doApplyDotAppearance();
	doPositionFrame();
	doInitializeConfig(1);
end

-- -------------------------------------------------------
-- Config window: populate controls from current globals
-- isDefaults=1 uses direct frame references (called from Lua)
-- isDefaults=0 uses this (called from XML OnShow)
-- -------------------------------------------------------
function doInitializeConfig(isDefaults)
	local fn;
	if (isDefaults == 1) then
		fn = "MuteClockConfigFrame";
	else
		fn = this:GetName();
	end
	getglobal(fn.."CheckButtonShowAllCharacters"):SetChecked(SH_ALL_CHARACTERS);
	getglobal(fn.."CheckButtonDoNotify"):SetChecked(DO_NOTIFY);
	getglobal(fn.."SliderTooltipX"):SetValue(TOOLTIP_X);
	getglobal(fn.."SliderTooltipY"):SetValue(TOOLTIP_Y);
	getglobal(fn.."SliderSize"):SetValue(DOT_SIZE);
	getglobal(fn.."CheckButtonHideDot"):SetChecked(DOT_HIDDEN);
	getglobal(fn.."CheckButtonSmartIcon"):SetChecked(SMART_ICON);
	getglobal(fn.."CheckButtonGroupByCraft"):SetChecked(GROUP_BY_CRAFT);
	getglobal(fn.."CheckButtonShowReadyTime"):SetChecked(SHOW_READY_TIME);
end

-- -------------------------------------------------------
-- Config window: handle a control changing value
-- -------------------------------------------------------
function doConfigSave()
	local n  = this:GetName();
	local pn = this:GetParent():GetName();
	if (n == pn.."CheckButtonShowAllCharacters") then
		SH_ALL_CHARACTERS = this:GetChecked();
		if (SH_ALL_CHARACTERS == nil) then SH_ALL_CHARACTERS = 0; end
	elseif (n == pn.."CheckButtonDoNotify") then
		DO_NOTIFY = this:GetChecked();
		if (DO_NOTIFY == nil) then DO_NOTIFY = 0; end
	elseif (n == pn.."SliderTooltipX") then
		TOOLTIP_X = this:GetValue();
		getglobal(n.."Text"):SetText("Tooltip X ("..floor(TOOLTIP_X)..")");
	elseif (n == pn.."SliderTooltipY") then
		TOOLTIP_Y = this:GetValue();
		getglobal(n.."Text"):SetText("Tooltip Y ("..floor(TOOLTIP_Y)..")");
	elseif (n == pn.."SliderSize") then
		DOT_SIZE = floor(this:GetValue());
		getglobal(n.."Text"):SetText("Dot Size ("..DOT_SIZE.."px)");
	elseif (n == pn.."CheckButtonHideDot") then
		DOT_HIDDEN = this:GetChecked();
		if (DOT_HIDDEN == nil) then DOT_HIDDEN = 0; end
	elseif (n == pn.."CheckButtonSmartIcon") then
		SMART_ICON = this:GetChecked();
		if (SMART_ICON == nil) then SMART_ICON = 0; end
	elseif (n == pn.."CheckButtonGroupByCraft") then
		GROUP_BY_CRAFT = this:GetChecked();
		if (GROUP_BY_CRAFT == nil) then GROUP_BY_CRAFT = 0; end
	elseif (n == pn.."CheckButtonShowReadyTime") then
		SHOW_READY_TIME = this:GetChecked();
		if (SHOW_READY_TIME == nil) then SHOW_READY_TIME = 0; end
	end
	doSaveSettings();
	doApplyDotAppearance();
end

-- -------------------------------------------------------
-- Frame load
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
end

-- -------------------------------------------------------
-- Frame events
-- -------------------------------------------------------
function Clock_OnEvent()
	if (event == "VARIABLES_LOADED") then
		CURRENT_PLAYER_NAME = UnitName("player");
		onVariablesLoaded();

	elseif (event == "SPELLCAST_START") then
		local idx = GetTradeSkillSelectionIndex();
		if (idx and idx > 0) then
			CraftingItemName, _, _, _ = GetTradeSkillInfo(idx);
			isCraftSuccess = 1;
		end

	elseif ((event == "SPELLCAST_FAILED") or (event == "SPELLCAST_INTERRUPTED")) then
		CraftingItemName = nil;
		isCraftSuccess   = 0;

	elseif (event == "ITEM_PUSH") then
		if (isCraftSuccess == 1) then
			local idx = GetTradeSkillSelectionIndex();
			if (idx and idx > 0) then
				CraftingItemName, _, _, _ = GetTradeSkillInfo(idx);
				local cd = GetTradeSkillCooldown(idx);
				if (cd ~= nil) then
					MuteClock[CURRENT_PLAYER_NAME][CraftingItemName.."-available"] = time() + floor(cd);
					MuteClock[CURRENT_PLAYER_NAME][CraftingItemName.."-notified"]  = nil;
				end
			end
			isCraftSuccess = 0;
		end

	elseif ((event == "TRADE_SKILL_SHOW") or (event == "TRADE_SKILL_CLOSE")) then
		for i = 1, GetNumTradeSkills() do
			local name, kind, _, _ = GetTradeSkillInfo(i);
			if (kind ~= "header") then
				if (getCraftEntry(name)) then
					local cd = GetTradeSkillCooldown(i);
					if (cd and cd > 0) then
						-- On cooldown: store the future ready-time, clear notified
						MuteClock[CURRENT_PLAYER_NAME][name.."-available"] = time() + floor(cd);
						MuteClock[CURRENT_PLAYER_NAME][name.."-notified"]  = nil;
					else
						-- Available right now: only write 0 if not currently tracking
						-- an unexpired cooldown (don't clobber a valid future timestamp)
						local existing = MuteClock[CURRENT_PLAYER_NAME][name.."-available"];
						if (existing == nil or existing <= time()) then
							MuteClock[CURRENT_PLAYER_NAME][name.."-available"] = 0;
						end
					end
				end
			end
		end
	end
end

-- -------------------------------------------------------
-- Per-frame update
-- -------------------------------------------------------
function Clock_OnUpdate(arg1)
	ClockFrame.TimeSinceLastUpdate = ClockFrame.TimeSinceLastUpdate + arg1;
	if (ClockFrame.TimeSinceLastUpdate > 0.1) then
		if ((IS_VARIABLES_LOADED == 1) and (CooldownUpdateTimer >= 1.0)) then
			doRunNotifications();
			doUpdateDot();
			CooldownUpdateTimer = 0;
		end
		CooldownUpdateTimer = CooldownUpdateTimer + ClockFrame.TimeSinceLastUpdate;
		ClockFrame.TimeSinceLastUpdate = 0;
	end
end

-- -------------------------------------------------------
-- Click / drag
-- -------------------------------------------------------
function ClickHandler(btn, updown)
	if (btn == "LeftButton") then
		if (ClockFrame.moving) then
			if (updown == "UP") then
				ClockFrame.moving = nil;
				ClockFrame:StopMovingOrSizing();
				POSITION_X, POSITION_Y = ClockFrame:GetCenter();
				ClockFrame:SetMovable(0);
				doSaveSettings();
			end
		elseif (IsShiftKeyDown() and updown == "DOWN") then
			ClockFrame.moving = true;
			ClockFrame:SetMovable(1);
			ClockFrame:StartMoving();
		end
	elseif (btn == "RightButton") then
		if (IsControlKeyDown() and updown == "UP") then
			MuteClockConfigFrame:Show();
		end
	end
end

-- -------------------------------------------------------
-- Slash commands
-- -------------------------------------------------------
function SlashCommandHandler(cmd)
	cmd = string.gsub(cmd, " ", "");
	if (cmd == "") then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r commands:");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock config|r  open config window");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock reset|r   restore defaults");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock show|r    unhide the dot");
	elseif (cmd == "config") then
		MuteClockConfigFrame:Show();
	elseif (cmd == "reset") then
		doSetDefaultSettings();
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r defaults restored.");
	elseif (cmd == "show") then
		DOT_HIDDEN = 0;
		doSaveSettings();
		doApplyDotAppearance();
	end
end

-- -------------------------------------------------------
-- Cooldown time formatting
-- Base format (always): Xd Xh Xm countdown  (original style)
-- With SHOW_READY_TIME: appends local ready-time "Fri 14:30"
--   Uses client local time via date() - not server time.
--   For cooldowns over 6 days, shows "14 Apr 14:30" instead.
--   Ready-time suffix is omitted when under 1h (not useful).
-- -------------------------------------------------------
function doFormatCountdown(remaining)
	if (remaining <= 0) then return nil; end
	local days    = floor(remaining / 86400);
	local r       = remaining - days * 86400;
	local hours   = floor(r / 3600);
	r             = r - hours * 3600;
	local minutes = floor(r / 60);
	local d = (days    > 0) and (days.."d ")  or "";
	local h = (hours   > 0) and (hours.."h ") or "";
	local m = (minutes > 0) and (minutes.."m") or "";
	if (d == "" and h == "" and m == "") then return "< 1m"; end
	return d..h..m;
end

function doFormatReadyTime(remaining)
	-- Returns the local clock time when this cooldown expires, or nil if < 1h
	if (remaining < 3600) then return nil; end
	local readyAt = time() + remaining;
	if (remaining > 518400) then
		return date("%d %b %H:%M", readyAt); -- "14 Apr 14:30"
	end
	return date("%a %H:%M", readyAt); -- "Fri 14:30"
end

-- -------------------------------------------------------
-- Collect all cooldown rows into a flat table for display/logic
-- -------------------------------------------------------
function doCollectCooldownData(isAllCharacters, playerName)
	local results = {};
	for charName, value in pairs(MuteClock) do
		if (type(value) == "table") then
			if ((isAllCharacters == 0 and charName == playerName) or isAllCharacters == 1) then
				for idx, val in pairs(MuteClock[charName]) do
					if (string.find(idx, "-available")) then
						local craftName = string.gsub(idx, "-available", "", 1);
						if (getCraftEntry(craftName)) then
							local remaining = val and (val - time()) or 0;
							table.insert(results, {
								craftName = craftName,
								charName  = charName,
								remaining = remaining,
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
-- SmartIcon: find the highest-priority available craft icon
-- Tier 1 = current character can craft it
-- Tier 2 = another character has it available
-- Within each tier, follows TRACKED_CRAFTS priority order
-- -------------------------------------------------------
function doGetSmartIcon()
	local best = {};  -- best[key] = tier (1 or 2)

	for charName, value in pairs(MuteClock) do
		if (type(value) == "table") then
			local inScope = (SH_ALL_CHARACTERS == 1) or (charName == CURRENT_PLAYER_NAME);
			if (inScope) then
				for idx, val in pairs(MuteClock[charName]) do
					if (string.find(idx, "-available")) then
						local craftName = string.gsub(idx, "-available", "", 1);
						local entry = getCraftEntry(craftName);
						if (entry) then
							local remaining = val and (val - time()) or 0;
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

	-- Walk TRACKED_CRAFTS in defined priority order
	local bestEntry, bestTier = nil, 99;
	for _, entry in ipairs(TRACKED_CRAFTS) do
		local tier = best[entry.key];
		if (tier and tier < bestTier) then
			bestEntry = entry;
			bestTier  = tier;
		end
	end
	return bestEntry;
end

-- -------------------------------------------------------
-- Tooltip rendering
-- -------------------------------------------------------
function doShowTooltip()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	GameTooltip:SetOwner(ClockFrame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOP", "ClockFrame", "TOP", TOOLTIP_X, TOOLTIP_Y);
	GameTooltip:AddLine("|cFFFFD100Craft Cooldowns|r");
	GameTooltip:AddLine(" ");

	local data = doCollectCooldownData(SH_ALL_CHARACTERS, CURRENT_PLAYER_NAME);

	if (table.getn(data) == 0) then
		GameTooltip:AddLine("No data yet.", 0.55, 0.55, 0.55);
		GameTooltip:AddLine("Open a trade skill window.", 0.55, 0.55, 0.55);
	elseif (GROUP_BY_CRAFT == 1) then
		doTooltipByCraft(data);
	else
		doTooltipByChar(data);
	end

	GameTooltip:Show();
end

-- Grouped by character
function doTooltipByChar(data)
	table.sort(data, function(a, b)
		if (a.charName == CURRENT_PLAYER_NAME) then return true; end
		if (b.charName == CURRENT_PLAYER_NAME) then return false; end
		return a.charName < b.charName;
	end);
	local lastChar = "";
	for _, row in ipairs(data) do
		if (row.charName ~= lastChar) then
			if (lastChar ~= "") then GameTooltip:AddLine(" "); end
			local col = (row.charName == CURRENT_PLAYER_NAME) and "|cFFFFD100" or "|cFFAAAAAA";
			GameTooltip:AddLine(col..row.charName.."|r");
			lastChar = row.charName;
		end
		doTooltipCooldownLine(row.craftName, row.remaining);
	end
end

-- Grouped by craft type
function doTooltipByCraft(data)
	local byKey = {};
	for _, row in ipairs(data) do
		local entry = getCraftEntry(row.craftName);
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
			GameTooltip:AddLine("|cFF00CCFF"..entry.label.."|r");
			table.sort(rows, function(a, b)
				if (a.charName == CURRENT_PLAYER_NAME) then return true; end
				if (b.charName == CURRENT_PLAYER_NAME) then return false; end
				if ((a.remaining <= 0) ~= (b.remaining <= 0)) then return a.remaining <= 0; end
				return a.charName < b.charName;
			end);
			for _, row in ipairs(rows) do
				doTooltipCooldownLine(row.charName, row.remaining);
			end
		end
	end
end

-- Single cooldown line, colour-coded by urgency
function doTooltipCooldownLine(label, remaining)
	if (remaining <= 0) then
		GameTooltip:AddDoubleLine("  "..label, "Ready", 0.2, 1, 0.2, 0.2, 1, 0.2);
	else
		local countdown = doFormatCountdown(remaining);
		local timeStr;
		if (SHOW_READY_TIME == 1) then
			local readyTime = doFormatReadyTime(remaining);
			if (readyTime) then
				timeStr = countdown.."  |cFF888888"..readyTime.."|r";
			else
				timeStr = countdown;
			end
		else
			timeStr = countdown;
		end
		local vr, vg, vb;
		if (remaining <= 3600) then
			vr, vg, vb = 1, 0.75, 0.1;     -- amber:  < 1h
		elseif (remaining <= 14400) then
			vr, vg, vb = 1, 0.5,  0.1;     -- orange: < 4h
		else
			vr, vg, vb = 0.55, 0.55, 0.55; -- grey:   long CD
		end
		GameTooltip:AddDoubleLine("  "..label, timeStr, 0.8, 0.8, 0.8, vr, vg, vb);
	end
end

-- -------------------------------------------------------
-- Background notification pass (runs every ~1s via OnUpdate)
-- -------------------------------------------------------
function doRunNotifications()
	for charName, value in pairs(MuteClock) do
		if (type(value) == "table") then
			if ((SH_ALL_CHARACTERS == 0 and charName == CURRENT_PLAYER_NAME) or SH_ALL_CHARACTERS == 1) then
				for idx, val in pairs(MuteClock[charName]) do
					if (string.find(idx, "-available")) then
						local craftName = string.gsub(idx, "-available", "", 1);
						if (getCraftEntry(craftName)) then
							local remaining = val and (val - time()) or 0;
							if (remaining <= 0) then
								local notifiedKey = craftName.."-notified";
								if (not MuteClock[charName][notifiedKey]) then
									if (DO_NOTIFY == 1) then
										doSendNotify(charName, craftName);
									end
									MuteClock[charName][notifiedKey] = 1;
								end
							end
						end
					end
				end
			end
		end
	end
end

function doSendNotify(playerName, craftName)
	local entry = getCraftEntry(craftName);
	local label = entry and entry.label or craftName;
	local who   = (playerName == CURRENT_PLAYER_NAME) and "Your" or (playerName.."'s");
	SELECTED_CHAT_FRAME:AddMessage(
		"|cFF00FF00MuteClock|r  "..who.." |cFFFFD100"..label.."|r is ready!"
	);
	PlaySound("AuctionWindowOpen");
end

-- -------------------------------------------------------
-- Dot status
-- Returns: 0=no data  1=something ready  2=<4h  3=long CD
-- -------------------------------------------------------
function doGetDotStatus()
	if (not MuteClock) then return 0; end
	local hasData = 0;
	local hasReady = 0;
	local hasSoon  = 0;
	for charName, value in pairs(MuteClock) do
		if (type(value) == "table") then
			for idx, val in pairs(MuteClock[charName]) do
				if (string.find(idx, "-available")) then
					local craftName = string.gsub(idx, "-available", "", 1);
					if (getCraftEntry(craftName)) then
						hasData = 1;
						local remaining = val and (val - time()) or 0;
						if (remaining <= 0) then
							hasReady = 1;
						elseif (remaining <= 14400) then
							hasSoon = 1;
						end
					end
				end
			end
		end
	end
	if (hasData  == 0) then return 0; end
	if (hasReady == 1) then return 1; end
	if (hasSoon  == 1) then return 2; end
	return 3;
end

-- -------------------------------------------------------
-- Dot visual update: SmartIcon or status colour square
-- -------------------------------------------------------
function doUpdateDot()
	if (DOT_HIDDEN == 1) then return; end

	local status = doGetDotStatus();

	if (SMART_ICON == 1 and status == 1) then
		local entry = doGetSmartIcon();
		if (entry) then
			ClockDot:SetTexture(entry.icon);
			ClockDot:SetVertexColor(1, 1, 1, 1);
			return;
		end
	end

	-- Fallback: coloured square
	ClockDot:SetTexture("Interface\\Buttons\\WHITE8X8");
	if (status == 0) then
		ClockDot:SetVertexColor(0.3,  0.3,  0.3,  1); -- grey:   no data
	elseif (status == 1) then
		ClockDot:SetVertexColor(0.1,  0.9,  0.1,  1); -- green:  ready
	elseif (status == 2) then
		ClockDot:SetVertexColor(0.95, 0.85, 0.1,  1); -- yellow: < 4h
	else
		ClockDot:SetVertexColor(0.9,  0.15, 0.15, 1); -- red:    long CD
	end
end
