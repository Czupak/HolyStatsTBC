local isSpellsFrameConfig = false
local isSpellsFrameConfigInit = false

function toggleSpellsFrameConfig()
    if not isSpellsFrameConfigInit
    then
        SpellsFrameConfig_Fill(SpellsFrameConfig)
    end
	if isSpellsFrameConfig
	then 
		SpellsFrameConfig:Hide()
		isSpellsFrameConfig = false
	else
		SpellsFrameConfig:Show()
		isSpellsFrameConfig = true
	end
end

function SpellsFrameConfig_OnLoad(self)
	self:SetMinResize(20,20)
	self:SetClampedToScreen(true)

	local btn_close = CreateFrame("Button", nil, SpellsFrameConfig, "UIPanelButtonTemplate")
	btn_close:SetPoint("TOPLEFT", 0, 1)
	btn_close:SetScript("OnClick", function()
		toggleSpellsFrameConfig()
	end)
	btn_close:SetText('x')
	btn_close:SetWidth(20)

	if myIgnoredSpells == nil
	then
		myIgnoredSpells = {}
	end
end

function SpellsFrameConfig_OnMouseDown(self, button)
	if (button == "LeftButton") then
		self:StartMoving()
		return
	elseif button == "RightButton" then
		self:StartSizing()
		return
	elseif button == "MiddleButton" then
		toggleSpellsFrameConfig()
	end
end

function SpellsFrameConfig_OnMouseUp(self, button)
	self:StopMovingOrSizing()
end

function isSpellIgnored(spell, rank)
	if myIgnoredSpells[spell] == nil
	then
		myIgnoredSpells[spell] = {}
	end

	if myIgnoredSpells[spell][rank] == nil
	then
		return false 
	else 
		return myIgnoredSpells[spell][rank]
	end
	
end

function toggleSpellIgnore(spell, rank)
	if myIgnoredSpells[spell] == nil
	then
		myIgnoredSpells[spell] = {}
	end
	if isSpellIgnored(spell, rank)
	then
		myIgnoredSpells[spell][rank] = false
	else
		myIgnoredSpells[spell][rank] = true
	end
end

local offsetY = 0
local frameLoaded = false
function SpellsFrameConfig_Fill(self)
	local spells = getHealingSpells()
	local wSpellName = 110
	local height = 20
	local offsetX = wSpellName
	local numRanks = 12
	self:SetWidth( numRanks * 50 + wSpellName)
	SpellsFrameConfigBG:SetVertexColor(0.1, 0.3, 0.3)
	if not frameLoaded
	then
		for i=1, numRanks
		do
			local label = self:CreateFontString(tostring(i) .. '1', 'OVERLAY' ,"GameFontNormal")
			label:SetPoint("TOPLEFT", offsetX, offsetY)
			label:SetWidth(50)
			label:SetHeight(20)
			label:SetVertexColor(0.9, 0.9, 0.9)
			label:SetText('Rank ' .. tostring(i))
			offsetX = offsetX + label:GetWidth()
		end
		offsetX = 0
		offsetY = offsetY - height
	
		for _,spell in pairs(sortKeys(spells))
		do
			local label = self:CreateFontString(tostring(i) .. '1', 'OVERLAY' ,"GameFontNormal")
			label:SetPoint("TOPLEFT", offsetX, offsetY)
			label:SetWidth(wSpellName)
			label:SetHeight(20)
			label:SetText(spell)
			offsetX = offsetX + label:GetWidth()

			local ranks = {}
			for i=1, numRanks
			do
				table.insert(ranks, 'Rank ' ..  tostring(i))
			end

			for _,rank in pairs(ranks)
			do
				if spells[spell][rank] ~= nil
				then
					local btn_check = CreateFrame("CheckButton", spell .. rank, self ,"UICheckButtonTemplate")
					btn_check:SetPoint("TOPLEFT", offsetX + 15, offsetY)
					btn_check:SetScript("OnClick", function(self)
						local lSpell = spell
						local lRank = rank
						toggleSpellIgnore(spell, rank)
					end)
					btn_check:SetChecked(not isSpellIgnored(spell, rank))
					btn_check:SetWidth(20)
					btn_check:SetHeight(20)
				end
				offsetX = offsetX + 50
			end
			offsetX = 0
			offsetY = offsetY - height
		end
    end
    self:SetHeight( offsetY * -1 + 5)
	frameLoaded = true
end
