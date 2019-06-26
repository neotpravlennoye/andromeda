local F, C, L = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local UnitBattlePetType, UnitBattlePetSpeciesID = UnitBattlePetType, UnitBattlePetSpeciesID
local PET, ID, UNKNOWN = PET, ID, UNKNOWN

function TOOLTIP:PetInfo_Update(petType)
	if not self.petIcon then
		local f = self:CreateTexture(nil, 'OVERLAY')
		f:SetPoint('TOPRIGHT', -5, -5)
		f:SetSize(35, 35)
		f:SetBlendMode('ADD')
		f:SetTexCoord(.188, .883, 0, .348)
		self.petIcon = f
	end
	self.petIcon:SetTexture('Interface\\PetBattles\\PetIcon-'..PET_TYPE_SUFFIX[petType])
	self.petIcon:SetAlpha(1)
end

function TOOLTIP:PetInfo_Reset()
	if self.petIcon and self.petIcon:GetAlpha() ~= 0 then
		self.petIcon:SetAlpha(0)
	end
end
GameTooltip:HookScript('OnTooltipCleared', TOOLTIP.PetInfo_Reset)

function TOOLTIP:PetInfo_Setup()
	local _, unit = self:GetUnit()
	if not unit then return end
	if not UnitIsBattlePet(unit) then return end

	-- Pet Species icon
	TOOLTIP.PetInfo_Update(self, UnitBattlePetType(unit))

	-- Pet ID
	local speciesID = UnitBattlePetSpeciesID(unit)
	self:AddDoubleLine(PET..ID..':', speciesID and (C.InfoColor..speciesID..'|r') or (C.GreyColor..UNKNOWN..'|r'))
end
GameTooltip:HookScript('OnTooltipSetUnit', TOOLTIP.PetInfo_Setup)