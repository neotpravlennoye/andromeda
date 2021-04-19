local _G = _G
local unpack = unpack
local select = select
local UnitCanAssist = UnitCanAssist
local UnitAura = UnitAura
local GetSpecialization = GetSpecialization
local DebuffTypeColor = DebuffTypeColor

local F, C = unpack(select(2, ...))
local OUF = F.Libs.oUF

local canDispel = {
    DRUID = {Magic = false, Curse = true, Poison = true},
    MAGE = {Curse = true},
    MONK = {Magic = false, Poison = true, Disease = true},
    PALADIN = {Magic = false, Poison = true, Disease = true},
    PRIEST = {Magic = false, Disease = true},
    SHAMAN = {Magic = false, Curse = true}
}

local dispellist = canDispel[C.MyClass] or {}
local origColors = {}
local origBorderColors = {}

local function GetDebuffType(unit, filter)
    if not UnitCanAssist('player', unit) then
        return nil
    end
    local i = 1
    while true do
        local _, texture, _, debufftype = UnitAura(unit, i, 'HARMFUL')
        if not texture then
            break
        end
        if debufftype and not filter or (filter and dispellist[debufftype]) then
            return debufftype, texture
        end
        i = i + 1
    end
end

local function CheckSpec()
    local spec = GetSpecialization()

    if C.MyClass == 'DRUID' then
        if spec == 4 then
            dispellist.Magic = true
        else
            dispellist.Magic = false
        end
    elseif C.MyClass == 'MONK' then
        if spec == 2 then
            dispellist.Magic = true
        else
            dispellist.Magic = false
        end
    elseif C.MyClass == 'PALADIN' then
        if spec == 1 then
            dispellist.Magic = true
        else
            dispellist.Magic = false
        end
    elseif C.MyClass == 'PRIEST' then
        if spec == 3 then
            dispellist.Magic = false
        else
            dispellist.Magic = true
        end
    elseif C.MyClass == 'SHAMAN' then
        if spec == 3 then
            dispellist.Magic = true
        else
            dispellist.Magic = false
        end
    end
end

local function Update(object, _, unit)
    if object.unit ~= unit then
        return
    end
    local debuffType, texture = GetDebuffType(unit, object.DebuffHighlightFilter)
    if debuffType then
        local color = DebuffTypeColor[debuffType]
        if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
            if object.DebuffHighlightBackdrop then
                object:SetBackdropColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or 1)
            end
            if object.DebuffHighlightBackdropBorder then
                object:SetBackdropBorderColor(color.r, color.g, color.b,
                                              object.DebuffHighlightAlpha or 1)
            end
        elseif object.DebuffHighlightUseTexture then
            object.DebuffHighlight:SetTexture(texture)
        else
            object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b,
                                                  object.DebuffHighlightAlpha or 0.5)
        end
    else
        if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
            local color
            if object.DebuffHighlightBackdrop then
                color = origColors[object]
                object:SetBackdropColor(color.r, color.g, color.b, color.a)
            end
            if object.DebuffHighlightBackdropBorder then
                color = origBorderColors[object]
                object:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
            end
        elseif object.DebuffHighlightUseTexture then
            object.DebuffHighlight:SetTexture(nil)
        else
            local color = origColors[object]
            object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
        end
    end
end

local function Enable(object)
    -- If we're not highlighting this unit return
    if not object.DebuffHighlightBackdrop and not object.DebuffHighlightBackdropBorder and
        not object.DebuffHighlight then
        return
    end
    -- If we're filtering highlights and we're not of the dispelling type, return
    if object.DebuffHighlightFilter and not canDispel[C.MyClass] then
        return
    end

    -- Make sure aura scanning is active for this object
    object:RegisterEvent('UNIT_AURA', Update)
    object:RegisterEvent('PLAYER_TALENT_UPDATE', CheckSpec, true)
    CheckSpec()

    if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
        local r, g, b, a = object:GetBackdropColor()
        origColors[object] = {r = r, g = g, b = b, a = a}
        r, g, b, a = object:GetBackdropBorderColor()
        origBorderColors[object] = {r = r, g = g, b = b, a = a}
    elseif not object.DebuffHighlightUseTexture then
        local r, g, b, a = object.DebuffHighlight:GetVertexColor()
        origColors[object] = {r = r, g = g, b = b, a = a}
    end

    return true
end

local function Disable(object)
    if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder or
        object.DebuffHighlight then
        object:UnregisterEvent('UNIT_AURA', Update)
        object:UnregisterEvent('PLAYER_TALENT_UPDATE', CheckSpec)
    end
end

OUF:AddElement('DebuffHighlight', Update, Enable, Disable)

for _, frame in ipairs(OUF.objects) do
    Enable(frame)
end
