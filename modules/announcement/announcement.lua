local _G = _G
local unpack = unpack
local select = select
local wipe = wipe
local format = format
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local IsEveryoneAssistant = IsEveryoneAssistant
local bit_band = bit.band
local GetSpellLink = GetSpellLink
local UnitGUID = UnitGUID
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local IsInInstance = IsInInstance
local GetNumGroupMembers = GetNumGroupMembers
local GetSpellInfo = GetSpellInfo

local F, C, L = unpack(select(2, ...))
local ANNOUNCEMENT = F:RegisterModule('Announcement')

C.AnnounceableSpellsList = {
    -- Paladin
    [1044] = true, -- Blessing of Freedom
    [204018] = true, -- Blessing of Spellwarding
    [6940] = true, -- Blessing of Sacrifice
    [1022] = true, -- Blessing of Protection
    [498] = true, -- Divine Protection
    [31850] = true, -- Ardent Defender
    [86659] = true, -- Guardian of Ancient Kings
    [212641] = true, -- Guardian of Ancient Kings (Glyph)
    [642] = true, -- Divine Shield
    [31884] = true, -- Avenging Wrath
    [633] = true, -- Lay On Hands
    [31821] = true, -- Aura Mastery

    -- Warrior
    [97462] = true, -- Rallying Cry

    -- Demon Hunter
    [196718] = true, -- Darkness

    -- Death Knight
    [51052] = true, -- Anti-Magic Zone
    [15286] = true, -- Vampiric Embrace

    -- Priest
    [246287] = true, -- Evangelism
    [265202] = true, -- Holy Word: Salvation
    [200183] = true, -- Apotheosis
    [62618] = true, -- Power Word: Barrier
    [64843] = true, -- Divine Hymn
    [64901] = true, -- Symbol of Hope
    [47536] = true, -- Rapture
    [109964] = true, -- Spirit Shell
    [33206] = true, -- Pain Suppression
    [47788] = true, -- Guardian Spirit

    -- Shaman
    [207399] = true, -- Ancestral Protection Totem
    [108280] = true, -- Healing Tide Totem
    [98008] = true, -- Spirit Link Totem
    [114052] = true, -- Ascendance
    [16191] = true, -- Mana Tide Totem
    [108281] = true, -- Ancestral Guidance
    [198838] = true, -- Earthen Wall Totem

    -- Druid
    [740] = true, -- Tranquility
    [33891] = true, -- Incarnation: Tree of Life
    [197721] = true, -- Flourish
    [205636] = true, -- Force of Nature

    -- Monk
    [115310] = true, -- Revival
    [325197] = true, -- Invoke Chi-Ji, the Red Crane
    [116849] = true, -- Life Cocoon
    [322118] = true, -- Invoke Yu'lon, the Jade Serpent

    -- Covenants
    [316958] = true, -- Ashen Hallow
}

local function IsInMyGroup(flag)
    local inParty = IsInGroup() and bit_band(flag, _G.COMBATLOG_OBJECT_AFFILIATION_PARTY) ~= 0
    local inRaid = IsInRaid() and bit_band(flag, _G.COMBATLOG_OBJECT_AFFILIATION_RAID) ~= 0

    return inRaid or inParty
end

local function GetChannel(warning)
    if C.DB.Announcement.Channel == 1 then
        if IsInGroup(_G.LE_PARTY_CATEGORY_INSTANCE) then
            return 'INSTANCE_CHAT'
        elseif IsInRaid(_G.LE_PARTY_CATEGORY_HOME) then
            if warning and (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') or IsEveryoneAssistant()) then
                return 'RAID_WARNING'
            else
                return 'RAID'
            end
        elseif IsInGroup(_G.LE_PARTY_CATEGORY_HOME) then
            return 'PARTY'
        end
    elseif C.DB.Announcement.Channel == 2 then
        return 'YELL'
    elseif C.DB.Announcement.Channel == 3 then
        return 'EMOTE'
    elseif C.DB.Announcement.Channel == 4 then
        return 'SAY'
    end
end

ANNOUNCEMENT.AnnounceableSpellsList = {}
function ANNOUNCEMENT:RefreshSpells()
    wipe(ANNOUNCEMENT.AnnounceableSpellsList)

    for spellID in pairs(C.AnnounceableSpellsList) do
        local name = GetSpellInfo(spellID)
        if name then
            local modValue = _G.FREE_ADB['AnnounceableSpellsList'][spellID]
            if modValue == nil then
                ANNOUNCEMENT.AnnounceableSpellsList[spellID] = true
            end
        end
    end

    for spellID, value in pairs(_G.FREE_ADB['AnnounceableSpellsList']) do
        if value then
            ANNOUNCEMENT.AnnounceableSpellsList[spellID] = true
        end
    end
end

function ANNOUNCEMENT:OnEvent()
    if not (IsInInstance() and IsInGroup() and GetNumGroupMembers() > 1) then
        return true
    end

    local _, eventType, _, srcGUID, _, _, _, _, destName, destFlags, _, spellID, _, _, extraSpellID = CombatLogGetCurrentEventInfo()

    if destName then
        destName = destName:gsub('%-[^|]+', '')
    end

    if not (srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet')) then return end

    if eventType == 'SPELL_CAST_SUCCESS' then
        if ANNOUNCEMENT.AnnounceableSpellsList[spellID] and C.DB.Announcement.Spells then
            if destName == nil then
                SendChatMessage(format(L['Used %s'], GetSpellLink(spellID)), GetChannel())
            else
                SendChatMessage(format(L['Used %s -> %s'], GetSpellLink(spellID), destName), GetChannel())
            end
        end
    elseif eventType == 'SPELL_INTERRUPT' and C.DB.Announcement.Interrupt then
        SendChatMessage(format(L['Interrupted %s'], GetSpellLink(extraSpellID)), GetChannel())
    elseif eventType == 'SPELL_DISPEL' and C.DB.Announcement.Dispel then
        SendChatMessage(format(L['Dispelled %s'], GetSpellLink(extraSpellID)), GetChannel())
    elseif eventType == 'SPELL_STOLEN' and C.DB.Announcement.Stolen then
        SendChatMessage(format(L['Stolen %s'], GetSpellLink(extraSpellID)), GetChannel())
    elseif eventType == 'SPELL_MISSED' and C.DB.Announcement.Reflect then
        local spellID, _, _, missType = select(12, CombatLogGetCurrentEventInfo())
        if missType=="REFLECT"then
            SendChatMessage(L['Reflected %s']..GetSpellLink(spellID), GetChannel())
        elseif missType=="ABSORB" and destName == L['Grounding Totem'] and destFlags == 8465 then
            SendChatMessage(L["Absorbed %s"]..GetSpellLink(spellID), GetChannel())
        end
    end
end

function ANNOUNCEMENT:AnnounceSpells()
    F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', ANNOUNCEMENT.OnEvent)
end

function ANNOUNCEMENT:CheckAnnounceableSpells()
    for spellID in pairs(C.AnnounceableSpellsList) do
        local name = GetSpellInfo(spellID)
        if name then
            if _G.FREE_ADB['AnnounceableSpellsList'][spellID] then
                _G.FREE_ADB['AnnounceableSpellsList'][spellID] = nil
            end
        else
            if C.IsDeveloper then
                F:Debug('Invalid Announceable Spells ID: ' .. spellID)
            end
        end
    end

    for spellID, value in pairs(_G.FREE_ADB['AnnounceableSpellsList']) do
        if value == false and C.AnnounceableSpellsList[spellID] == nil then
            _G.FREE_ADB['AnnounceableSpellsList'][spellID] = nil
        end
    end
end

function ANNOUNCEMENT:OnLogin()
    if not C.DB.Announcement.Enable then
        return
    end

    ANNOUNCEMENT:CheckAnnounceableSpells()
    ANNOUNCEMENT:RefreshSpells()

    ANNOUNCEMENT:AnnounceSpells()
    ANNOUNCEMENT:AnnounceReset()
    ANNOUNCEMENT:AnnounceQuest()
end
