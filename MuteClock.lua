-- MuteClock - Cooldown Tracker for TurtleWoW / Vanilla 1.12

-- -------------------------------------------------------
-- Defaults
-- -------------------------------------------------------
DEF_SH_ALL_CHARACTERS = 1;
DEF_DO_NOTIFY         = 1;
DEF_POSITION_X        = nil;
DEF_POSITION_Y        = nil;
DEF_DOT_SIZE          = 16;
DEF_DOT_HIDDEN        = 0;
DEF_SMART_ICON        = 1;
DEF_GROUP_BY_CRAFT    = 0;
DEF_SHOW_READY_TIME   = 0;
DEF_SHOW_OVERDUE      = 1;
DEF_SHOW_LAST_CRAFTED = 0;
DEF_SHOW_BADGE        = 0;

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

IS_VARIABLES_LOADED  = 0;
CraftingItemName     = nil;
isCraftSuccess       = 0;

HISTORY_MAX  = 20;
MC_PEERS     = {};
MC_FRIENDS   = {};
MC_NEARBY    = {};

-- -------------------------------------------------------
-- Tracked crafts
-- -------------------------------------------------------
TRACKED_CRAFTS = {
	{ key = "Transmute: Arcanite", label = "Transmute: Arcanite", icon = "Interface\\Icons\\INV_Misc_Stonetablet_05"   },
	{ key = "Mooncloth",           label = "Mooncloth",            icon = "Interface\\Icons\\INV_Fabric_Moonrag_01"    },
	{ key = "Cure Rugged Hide",    label = "Cure Rugged Hide",     icon = "Interface\\Icons\\INV_Misc_LeatherScrap_02" },
};

MC_CTRL = "MuteClockConfigFramePanelSettings";

-- -------------------------------------------------------
-- getCraftEntry
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
-- VARIABLES_LOADED
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

	doApplyDotAppearance();
	doPositionFrame();
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
end

-- -------------------------------------------------------
-- Dot appearance
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

function doPositionFrame()
	ClockFrame:ClearAllPoints();
	if (POSITION_X == nil or POSITION_Y == nil) then
		ClockFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
	else
		ClockFrame:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", POSITION_X, POSITION_Y);
	end
end

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
	SMART_ICON        = DEF_SMART_ICON;
	GROUP_BY_CRAFT    = DEF_GROUP_BY_CRAFT;
	SHOW_READY_TIME   = DEF_SHOW_READY_TIME;
	SHOW_OVERDUE      = DEF_SHOW_OVERDUE;
	SHOW_LAST_CRAFTED = DEF_SHOW_LAST_CRAFTED;
	SHOW_BADGE        = DEF_SHOW_BADGE;
	doSaveSettings();
	doApplyDotAppearance();
	ClockFrame:ClearAllPoints();
	ClockFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
	doInitializeConfig(1);
end

-- -------------------------------------------------------
-- Config: tab switching
-- Reset Defaults lives inside PanelSettings so it hides
-- automatically with the panel on other tabs.
-- -------------------------------------------------------
function doShowConfigTab(tabName)
	MuteClockConfigFramePanelSettings:Hide();
	MuteClockConfigFramePanelHistory:Hide();
	MuteClockConfigFramePanelCrafters:Hide();
	MuteClockConfigFramePanelNearby:Hide();
	if (tabName == "Settings") then
		MuteClockConfigFramePanelSettings:Show();
	elseif (tabName == "History") then
		MuteClockConfigFramePanelHistory:Show();
		doPopulateHistory();
	elseif (tabName == "Crafters") then
		MuteClockConfigFramePanelCrafters:Show();
		ClockFrame.CraftersRefreshTimer = 0;
		doPopulateCrafters();
	else
		MuteClockConfigFramePanelNearby:Show();
		doPopulateNearby();
	end
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
	getglobal(p.."CBSmartIcon"):SetChecked(SMART_ICON);
	getglobal(p.."CBBadge"):SetChecked(SHOW_BADGE);
	getglobal(p.."CBHide"):SetChecked(DOT_HIDDEN);
	getglobal(p.."SliderSize"):SetValue(DOT_SIZE);
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
	elseif (n == p.."CBSmartIcon")   then SMART_ICON        = this:GetChecked() or 0;
	elseif (n == p.."CBBadge")       then SHOW_BADGE        = this:GetChecked() or 0;
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
-- Scroll panel helpers
-- 18px rows: enough for GameFontNormalSmall + button at 16px
-- -------------------------------------------------------
MC_ROW_H = 19;   -- px per row (font ~14px + 5px breathing room)

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

-- Plain text line (no button)
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

-- Section header: slightly brighter blue-tinted label
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

-- Blank spacer row
function mcAddSpacer(contentFrame, lineIndex)
	-- Just advance the line counter; reuse a hidden Line slot
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

-- Row with a small inline action button on the left.
-- The button is 16x16 with just a coloured symbol and a
-- very faint background — much less heavy than a WoW button template.
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

		-- Faint dark background square
		local bg = btn:CreateTexture(nil, "BACKGROUND");
		bg:SetTexture("Interface\\Buttons\\WHITE8X8");
		bg:SetVertexColor(0.08, 0.08, 0.10, 0.75);
		bg:SetAllPoints();

		-- Highlight on hover
		local hl = btn:CreateTexture(nil, "HIGHLIGHT");
		hl:SetTexture("Interface\\Buttons\\WHITE8X8");
		hl:SetVertexColor(1, 1, 1, 0.12);
		hl:SetAllPoints();

		-- Symbol
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
	-- Centre the button vertically within the row
	btn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOff - 1);
	btn:Show();

	-- Label to the right of the button
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
-- History panel
-- -------------------------------------------------------
function doPopulateHistory()
	local scrollFrame  = MuteClockConfigFramePanelHistoryScrollFrame;
	local scrollBar    = MuteClockConfigFramePanelHistoryScrollBar;
	local contentFrame = MuteClockConfigFramePanelHistoryScrollFrameContent;

	local entries = {};
	for charName, charData in pairs(MuteClock) do
		if (type(charData) == "table" and charName ~= "_peers" and charName ~= "_friends") then
			for k, v in pairs(charData) do
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

	table.sort(entries, function(a, b)
		if (a.t ~= b.t) then return a.t > b.t; end
		return false;
	end);

	mcClearContent(contentFrame);
	local li = 1;

	if (table.getn(entries) == 0) then
		li = mcAddLine(contentFrame, li, "No crafts recorded yet.", 0.5, 0.5, 0.5);
		li = mcAddLine(contentFrame, li, "Open a trade skill and craft something.", 0.38, 0.38, 0.38);
	else
		for _, e in ipairs(entries) do
			local when    = date("%a %d %b  %H:%M", e.t);
			local isMine  = (e.charName == CURRENT_PLAYER_NAME);
			local nameCol = isMine and "|cFFFFD100" or "|cFFAAAAAA";
			li = mcAddLine(contentFrame, li,
				nameCol .. e.charName .. "|r  |cFF00CCFF" .. e.label .. "|r  |cFF505050" .. when .. "|r");
		end
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
	this:SetBackdropColor(0.06, 0.06, 0.08, 0.97);
	this:SetBackdropBorderColor(0.20, 0.20, 0.26, 1);
	MuteClockConfigFrameTopBar:SetVertexColor(0.07, 0.10, 0.16, 1);
	MuteClockConfigFrameTitle:SetTextColor(0.85, 0.88, 1, 1);
	MuteClockDivTracking:SetVertexColor(0.25, 0.55, 0.75, 0.4);
	MuteClockDivDisplay:SetVertexColor(0.25, 0.55, 0.75, 0.4);
	MuteClockDivDot:SetVertexColor(0.25, 0.55, 0.75, 0.4);
	this:RegisterForDrag("LeftButton");
	MuteClockConfigFramePanelHistory:Hide();
	MuteClockConfigFramePanelCrafters:Hide();
	MuteClockConfigFramePanelNearby:Hide();
	MuteClockConfigFramePanelSettings:Show();
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

	elseif (event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE") then
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

		local charData = MuteClock[CURRENT_PLAYER_NAME];
		for k in pairs(charData) do
			if (string.len(k) > 10 and string.sub(k, -10) == "-available") then
				local craftKey = string.sub(k, 1, string.len(k) - 10);
				if (getCraftEntry(craftKey) and not knownCrafts[craftKey]) then
					charData[craftKey .. "-available"] = nil;
					charData[craftKey .. "-notified"]  = nil;
					charData[craftKey .. "-crafted"]   = nil;
				end
			end
		end

		doNetBroadcastAll();
	end
end

-- -------------------------------------------------------
-- Per-frame update (5s tick)
-- -------------------------------------------------------
function Clock_OnUpdate(arg1)
	ClockFrame.TimeSinceLastUpdate = ClockFrame.TimeSinceLastUpdate + arg1;
	if (ClockFrame.TimeSinceLastUpdate >= 5.0) then
		ClockFrame.TimeSinceLastUpdate = 0;
		if (IS_VARIABLES_LOADED ~= 1) then return; end
		doRunNotifications();
		doUpdateDot();
	end

	ClockFrame.CraftersRefreshTimer = (ClockFrame.CraftersRefreshTimer or 0) + arg1;
	if (ClockFrame.CraftersRefreshTimer >= 5.0) then
		ClockFrame.CraftersRefreshTimer = 0;
		if (IS_VARIABLES_LOADED == 1 and MuteClockConfigFramePanelCrafters:IsVisible()) then
			doPopulateCrafters();
		end
	end
end

-- -------------------------------------------------------
-- Drag and click
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
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF33/muteclock debug|r   print network state");
	elseif (cmd == "config") then
		MuteClockConfigFrame:Show();
	elseif (cmd == "reset") then
		doSetDefaultSettings();
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00MuteClock|r settings reset to defaults.");
	elseif (cmd == "show") then
		DOT_HIDDEN = 0;
		doSaveSettings();
		doApplyDotAppearance();
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
-- Collect cooldown rows
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
	if (not hasData) then return 0, 0; end
	if (hasReady)    then return 1, readyN; end
	if (hasSoon)     then return 2, 0; end
	return 3, 0;
end

-- -------------------------------------------------------
-- SmartIcon: best ready craft entry
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
		if (not MC_FRIENDS[sender]) then
			MC_NEARBY[sender] = true;
		end
		doNetBroadcastAll();

	elseif (string.sub(msg, 1, 6) == "REPLY:") then
		if (not MC_PEERS[sender]) then MC_PEERS[sender] = {}; end
		if (not MC_FRIENDS[sender]) then
			MC_NEARBY[sender] = true;
		end
		local data = MC_PEERS[sender];
		for k in pairs(data) do data[k] = nil; end
		for record in string.gfind(string.sub(msg, 7), "[^;]+") do
			local craftKey, ts = doNetParseRecord(record);
			if (craftKey and ts and getCraftEntry(craftKey)) then
				data[craftKey] = ts;
			end
		end
		MuteClock._peers = MC_PEERS;

	elseif (string.sub(msg, 1, 3) == "CD:") then
		local craftKey, ts = doNetParseRecord(string.sub(msg, 4));
		if (craftKey and ts and getCraftEntry(craftKey)) then
			if (not MC_PEERS[sender]) then MC_PEERS[sender] = {}; end
			if (not MC_FRIENDS[sender]) then
				MC_NEARBY[sender] = true;
			end
			MC_PEERS[sender][craftKey] = ts;
			MuteClock._peers = MC_PEERS;
		end
	end

	if (MuteClockConfigFramePanelCrafters:IsVisible()) then
		doPopulateCrafters();
	end
	if (MuteClockConfigFramePanelNearby:IsVisible()) then
		doPopulateNearby();
	end
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
	if (MuteClockConfigFramePanelNearby:IsVisible())   then doPopulateNearby();   end
end

function mcRemoveFriend(name)
	MC_FRIENDS[name]   = nil;
	MuteClock._friends = MC_FRIENDS;
	if (doIsInGroup(name)) then
		MC_NEARBY[name] = true;
	end
	if (MuteClockConfigFramePanelCrafters:IsVisible()) then doPopulateCrafters(); end
	if (MuteClockConfigFramePanelNearby:IsVisible())   then doPopulateNearby();   end
end

-- -------------------------------------------------------
-- Crafters panel
-- Respects GROUP_BY_CRAFT setting.
--
-- By friend (GROUP_BY_CRAFT=0):
--   [−] Friendname
--       Mooncloth   Ready
--       Arcanite    2h 15m
--
-- By craft (GROUP_BY_CRAFT=1):
--   Mooncloth
--   [−] Friendname   Ready
--   [−] OtherFriend  3d 2h
-- -------------------------------------------------------
function doPopulateCrafters()
	local scrollFrame  = MuteClockConfigFramePanelCraftersScrollFrame;
	local scrollBar    = MuteClockConfigFramePanelCraftersScrollBar;
	local contentFrame = MuteClockConfigFramePanelCraftersScrollFrameContent;

	mcClearContent(contentFrame);
	local li = 1;

	local friends = {};
	for name in pairs(MC_FRIENDS) do
		table.insert(friends, name);
	end
	table.sort(friends);

	if (table.getn(friends) == 0) then
		li = mcAddLine(contentFrame, li, "No crafters added yet.", 0.5, 0.5, 0.5);
		li = mcAddLine(contentFrame, li, "Add people from the Nearby tab.", 0.38, 0.38, 0.38);
		mcFinaliseScroll(scrollFrame, scrollBar, contentFrame, li - 1);
		return;
	end

	local now = time();

	if (GROUP_BY_CRAFT == 1) then
		-- ── By craft ────────────────────────────────────────
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
				if (not first) then li = mcAddSpacer(contentFrame, li); end
				first = false;

				table.sort(rows, function(a, b)
					if ((a.remaining <= 0) ~= (b.remaining <= 0)) then return a.remaining <= 0; end
					return a.name < b.name;
				end);

				li = mcAddHeader(contentFrame, li, entry.label);

				for _, row in ipairs(rows) do
					local removeName = row.name;
					local timeStr = doFormatCrafterTime(row.remaining);
					li = mcAddRowWithButton(contentFrame, li,
						"|cFFDDDDDD" .. row.name .. "|r  " .. timeStr,
						"-", 0.85, 0.3, 0.3,
						function() mcRemoveFriend(removeName); end);
				end
			end
		end

	else
		-- ── By friend ───────────────────────────────────────
		local first = true;
		for _, name in ipairs(friends) do
			local data = MC_PEERS[name] or {};

			if (not first) then li = mcAddSpacer(contentFrame, li); end
			first = false;

			local removeName = name;
			li = mcAddRowWithButton(contentFrame, li,
				"|cFFFFD100" .. name .. "|r",
				"-", 0.85, 0.3, 0.3,
				function() mcRemoveFriend(removeName); end);

			local hasCraft = false;
			for _, entry in ipairs(TRACKED_CRAFTS) do
				local ts = data[entry.key];
				if (ts ~= nil) then
					hasCraft = true;
					local remaining = (ts > 0) and (ts - now) or 0;
					local timeStr = doFormatCrafterTime(remaining);
					li = mcAddLine(contentFrame, li,
						"    |cFF888888" .. entry.label .. "|r  " .. timeStr);
				end
			end
			if (not hasCraft) then
				li = mcAddLine(contentFrame, li, "    |cFF3A3A3ANo craft data yet.|r");
			end
		end
	end

	mcFinaliseScroll(scrollFrame, scrollBar, contentFrame, li - 1);
end

-- Shared cooldown time string for the Crafters panel
function doFormatCrafterTime(remaining)
	if (remaining <= 0) then
		return "|cFF33DD33Ready|r";
	end
	local r, g, b;
	if     (remaining <= 3600)  then r, g, b = 1.0, 0.75, 0.1;
	elseif (remaining <= 14400) then r, g, b = 1.0, 0.50, 0.1;
	else                             r, g, b = 0.55, 0.55, 0.55; end
	return string.format("|cFF%02X%02X%02X%s|r",
		floor(r * 255), floor(g * 255), floor(b * 255),
		doFormatCountdown(remaining));
end

-- -------------------------------------------------------
-- Nearby panel
-- -------------------------------------------------------
function doPopulateNearby()
	local scrollFrame  = MuteClockConfigFramePanelNearbyScrollFrame;
	local scrollBar    = MuteClockConfigFramePanelNearbyScrollBar;
	local contentFrame = MuteClockConfigFramePanelNearbyScrollFrameContent;

	mcClearContent(contentFrame);
	local li = 1;

	local nearby = {};
	for name in pairs(MC_NEARBY) do
		if (not MC_FRIENDS[name]) then
			table.insert(nearby, name);
		end
	end
	table.sort(nearby);

	if (table.getn(nearby) == 0) then
		li = mcAddLine(contentFrame, li, "No addon users in your group.", 0.5, 0.5, 0.5);
		li = mcAddLine(contentFrame, li, "Group with MuteClock users to see them here.", 0.38, 0.38, 0.38);
	else
		for _, name in ipairs(nearby) do
			local addName = name;
			li = mcAddRowWithButton(contentFrame, li,
				"|cFFCCCCCC" .. name .. "|r",
				"+", 0.2, 0.85, 0.2,
				function() mcAddFriend(addName); end);
		end
	end

	mcFinaliseScroll(scrollFrame, scrollBar, contentFrame, li - 1);
end

-- -------------------------------------------------------
-- Tooltip
-- -------------------------------------------------------
function doShowTooltip()
	if (IS_VARIABLES_LOADED ~= 1) then return; end
	GameTooltip:SetOwner(ClockFrame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPRIGHT", "ClockFrame", "TOPLEFT", -4, -8);
	doFillTooltip();
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
	if (waitN  > 0) then header = header .. "  |cFF777777" .. waitN  .. " waiting|r"; end
	GameTooltip:AddLine(header);

	if (table.getn(data) == 0) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine("No data yet. Open a trade skill window.", 0.5, 0.5, 0.5);
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
		if (ts) then lastStr = "  |cFF505050" .. ts .. "|r"; end
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
			if (rt) then timeStr = timeStr .. "  |cFF777777" .. rt .. "|r"; end
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
	if (DOT_HIDDEN == 1) then return; end
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
