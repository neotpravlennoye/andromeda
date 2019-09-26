local F, C, L = unpack(select(2, ...))
local INFOBAR = F:GetModule('Infobar')


local time, date = time, date
local strfind, format, floor = string.find, string.format, math.floor
local mod, tonumber, pairs, ipairs = mod, tonumber, pairs, ipairs
local TIMEMANAGER_TICKER_24HOUR, TIME_TWELVEHOURAM, TIME_TWELVEHOURPM = TIMEMANAGER_TICKER_24HOUR, TIME_TWELVEHOURAM, TIME_TWELVEHOURPM
local invIndex = {}

local FreeUIReportButton = INFOBAR.FreeUIReportButton

local function updateTimerFormat(color, hour, minute)
	if GetCVarBool('timeMgrUseMilitaryTime') then
		return format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = DB.MyColor..(hour < 12 and 'AM' or 'PM')
		if hour > 12 then hour = hour - 12 end
		return format(color..TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

-- Data
local bonus = {
	52834, 52838,	-- Gold
	52835, 52839,	-- Honor
	52837, 52840,	-- Resources
}
local bonusName = GetCurrencyInfo(1580)

local isTimeWalker, walkerTexture
local function checkTimeWalker(event)
	local date = C_Calendar.GetDate()
	C_Calendar.SetAbsMonth(date.month, date.year)
	C_Calendar.OpenCalendar()

	local today = date.monthDay
	local numEvents = C_Calendar.GetNumDayEvents(0, today)
	if numEvents <= 0 then return end

	for i = 1, numEvents do
		local info = C_Calendar.GetDayEvent(0, today, i)
		if info and strfind(info.title, PLAYER_DIFFICULTY_TIMEWALKER) and info.sequenceType ~= 'END' then
			isTimeWalker = true
			walkerTexture = info.iconTexture
			break
		end
	end
	F:UnregisterEvent(event, checkTimeWalker)
end
F:RegisterEvent('PLAYER_ENTERING_WORLD', checkTimeWalker)

local function checkTexture(texture)
	if not walkerTexture then return end
	if walkerTexture == texture or walkerTexture == texture - 1 then
		return true
	end
end

local questlist = {
	{name = L['INFOBAR_BLINGTRON'], id = 34774},
	{name = L['INFOBAR_MEAN_ONE'], id = 6983},
	{name = L['INFOBAR_TIMEWARPED'], id = 40168, texture = 1129674},	-- TBC
	{name = L['INFOBAR_TIMEWARPED'], id = 40173, texture = 1129686},	-- WotLK
	{name = L['INFOBAR_TIMEWARPED'], id = 40786, texture = 1304688},	-- Cata
	{name = L['INFOBAR_TIMEWARPED'], id = 45799, texture = 1530590},	-- MoP
}

local region = GetCVar('portal')
local legionZoneTime = {
	['EU'] = 1565168400, -- CN - 16
	['US'] = 1565197200, -- CN - 8
	['CN'] = 1565226000, -- CN time 8/8/2019 09:00 [1]
}
local bfaZoneTime = {
	['CN'] = 1546743600, -- CN time 1/6/2019 11:00 [1]
	['EU'] = 1546768800, -- CN + 7
	['US'] = 1546769340, -- CN + 16
}

local invIndex = {
	[1] = {title = L['INFOBAR_INVASION_LEG'], duration = 66600, maps = {630, 641, 650, 634}, timeTable = {}, baseTime = legionZoneTime[region] or legionZoneTime['CN']}, -- need reviewed
	[2] = {title = L['INFOBAR_INVASION_BFA'], duration = 68400, maps = {862, 863, 864, 896, 942, 895}, timeTable = {4, 1, 6, 2, 5, 3}, baseTime = bfaZoneTime[region] or bfaZoneTime['CN']},
}

local mapAreaPoiIDs = {
	[630] = 5175,
	[641] = 5210,
	[650] = 5177,
	[634] = 5178,

	[862] = 5973,	-- Zuldazar
	[863] = 5969,	-- Nazmir
	[864] = 5970,	-- Vol'dun
	[896] = 5964,	-- Drustvar
	[942] = 5966,	-- Stormsong Valley
	[895] = 5896,	-- Tiragarde Sound
}

local function GetInvasionInfo(mapID)
	local areaPoiID = mapAreaPoiIDs[mapID]
	local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
	local mapInfo = C_Map.GetMapInfo(mapID)
	return seconds, mapInfo.name
end

local function CheckInvasion(index)
	for _, mapID in pairs(invIndex[index].maps) do
		local timeLeft, name = GetInvasionInfo(mapID)
		if timeLeft and timeLeft > 0 then
			return timeLeft, name
		end
	end
end

local function GetNextTime(baseTime, index)
	local currentTime = time()
	local duration = invIndex[index].duration
	local elapsed = mod(currentTime - baseTime, duration)
	return duration - elapsed + currentTime
end

local function GetNextLocation(nextTime, index)
	local inv = invIndex[index]
	local count = #inv.timeTable
	if count == 0 then return QUEUE_TIME_UNAVAILABLE end

	local elapsed = nextTime - inv.baseTime
	local round = mod(floor(elapsed / inv.duration) + 1, count)
	if round == 0 then round = count end
	return C_Map.GetMapInfo(inv.maps[inv.timeTable[round]]).name
end

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(text, .6,.8,1)
		title = true
	end
end


function INFOBAR:Report()
	if not C.infobar.enable then return end
	if not C.infobar.report then return end

	FreeUIReportButton = INFOBAR:addButton('Report', INFOBAR.POSITION_RIGHT, 120, function(self, button)
		if InCombatLockdown() then UIErrorsFrame:AddMessage(C.InfoColor..ERR_NOT_IN_COMBAT) return end
		
		if button == 'LeftButton' then
			HideUIPanel(GarrisonLandingPage)
			ShowGarrisonLandingPage(LE_GARRISON_TYPE_8_0)
		elseif button == 'RightButton' then
			HideUIPanel(GarrisonLandingPage)
			ShowGarrisonLandingPage(LE_GARRISON_TYPE_7_0)
		elseif button == 'MiddleButton' then
			HideUIPanel(GarrisonLandingPage)
			ShowGarrisonLandingPage(LE_GARRISON_TYPE_6_0)
		end
	end)

	FreeUIReportButton:HookScript('OnEnter', function(self)
		RequestRaidInfo()

		local r, g, b
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -15)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(C.InfoColor..L['INFOBAR_DAILY_WEEKLY_INFO'])

		-- World bosses
		title = false
		for i = 1, GetNumSavedWorldBosses() do
			local name, id, reset = GetSavedWorldBossInfo(i)
			if not (id == 11 or id == 12 or id == 13) then
				addTitle(RAID_INFO_WORLD_BOSS)
				GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 1, 1, 1)
			end
		end

		-- Mythic Dungeons
		title = false
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, diff, locked, extended = GetSavedInstanceInfo(i)
			if diff == 23 and (locked or extended) then
				addTitle(DUNGEON_DIFFICULTY3..DUNGEONS)
				if extended then r, g, b = .3, 1, .3 else r, g, b = 1, 1, 1 end
				GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
			end
		end

		-- Raids
		title = false
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, _, locked, extended, _, isRaid, _, diffName = GetSavedInstanceInfo(i)
			if isRaid and (locked or extended) then
				addTitle(RAID_INFO)
				if extended then r, g, b = .3, 1, .3 else r, g, b = 1, 1, 1 end
				GameTooltip:AddDoubleLine(name..' - '..diffName, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
			end
		end

		-- Quests
		title = false
		local count, maxCoins = 0, 2
		for _, id in pairs(bonus) do
			if IsQuestFlaggedCompleted(id) then
				count = count + 1
			end
		end
		if count > 0 then
			addTitle(QUESTS_LABEL)
			if count == maxCoins then r, g, b = 1, 0, 0 else r, g, b = 0, 1, 0 end
			GameTooltip:AddDoubleLine(bonusName, count..'/'..maxCoins, 1, 1, 1, r, g, b)
		end

		for _, v in pairs(questlist) do
			if v.name and IsQuestFlaggedCompleted(v.id) then
				if v.name == L['INFOBAR_TIMEWARPED'] and isTimeWalker and checkTexture(v.texture) or v.name ~= L['INFOBAR_TIMEWARPED'] then
					GameTooltip:AddLine(' ')
					addTitle(QUESTS_LABEL)
					GameTooltip:AddDoubleLine(v.name, QUEST_COMPLETE, 1, 1, 1, 0, 1, 0)
				end
			end
		end

		-- Invasions
		for index, value in ipairs(invIndex) do
			title = false
			addTitle(value.title)
			local timeLeft, zoneName = CheckInvasion(index)
			local nextTime = GetNextTime(value.baseTime, index)
			if timeLeft then
				timeLeft = timeLeft/60
				if timeLeft < 60 then r, g, b = 1, 0, 0 else r, g, b = 0, 1, 0 end
				GameTooltip:AddDoubleLine(L['INFOBAR_INVASION_CURRENT']..zoneName, format('%.2d:%.2d', timeLeft/60, timeLeft%60), 1, 1, 1, r, g, b)
			end
			local nextLocation = GetNextLocation(nextTime, index)
			GameTooltip:AddDoubleLine(L['INFOBAR_INVASION_NEXT']..nextLocation, date('%m/%d %H:%M', nextTime), 1,1,1, 1,1,1)
		end

		local iwqID = C_IslandsQueue.GetIslandsWeeklyQuestID()
		if iwqID and UnitLevel('player') == 120 then
			title = false
			addTitle(ISLANDS_HEADER)

			if IsQuestFlaggedCompleted(iwqID) then
				GameTooltip:AddDoubleLine(L['INFOBAR_ISLAND'], QUEST_COMPLETE, 1, 1, 1, 0, 1, 0)
			else
				local cur, max = select(4, GetQuestObjectiveInfo(iwqID, 1, false))
				local stautsText = cur..'/'..max
				if not cur or not max then stautsText = LFG_LIST_LOADING end
				GameTooltip:AddDoubleLine(L['INFOBAR_ISLAND'], stautsText, 1, 1, 1, 1, 0, 0)
			end
		end

		if UnitLevel('player') == 120 then
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(' ', C.LineString)
			GameTooltip:AddDoubleLine(' ', C.LeftButton..L['INFOBAR_OPEN_GARRION_REPORT'], 1, 1, 1, .9, .8, .6)
		end
		
		GameTooltip:Show()
	end)

	FreeUIReportButton:HookScript('OnLeave', function(self)
		GameTooltip:Hide()
	end)

	GarrisonLandingPageMinimapButton:SetSize(1, 1)
	GarrisonLandingPageMinimapButton:SetAlpha(0)
	GarrisonLandingPageMinimapButton:EnableMouse(false)
end

