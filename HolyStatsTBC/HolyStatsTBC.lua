local prefix = "|cffffa500MP5|cff1784d1Regen|r: "
local regen
local delay
local isSpellsFrame = false
local pauseUpdate = false
local _, class = UnitClass("player");

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
-- frame:RegisterEvent("PLAYER_LOGOUT")

function frame:OnEvent(event, arg1)
	if event == "ADDON_LOADED" -- and arg1 == 'HolyStats'
	then
		if myIgnoredSpells == nil
		then
			myIgnoredSpells = {}
		end
		if config == nil
		then
			config = {}
		end
		if config['sim'] == null
		then
			config['sim'] = {}
		end
		HolyStats_OnLoad(HolyStats)
		SpellsFrameConfig_OnLoad(SpellsFrameConfig)
	end
end
frame:SetScript("OnEvent", frame.OnEvent);

function HolyStats_OnLoad(self)
	HolyStatsBG:SetVertexColor(0.2, 0.2, 0.2)
	HolyStatsFrame:SetMinResize(20,20)
	HolyStatsFrame:SetClampedToScreen(true)
	delay = 0
end

function HolyStats_OnUpdate(self, elapsed)
	if not delay
	then
		delay = 0
	end
	delay = elapsed + delay
	if(delay > 1)
	then
		delay = 0
		HolyStats_update()
		if isSpellsFrame
		then
			SpellsFrame_Update()
		end
	end
end

function HolyStats_getRegenMp()
	local meditation = { 0, 0.05, 0.10, 0.15 }
	return meditation[getTalentRank('Meditation')+1]
end

function HolyStats_update()
	if pauseUpdate
	then
		return
	end
	local base, casting = GetManaRegen()
	local delay
	if math.floor(base) > 0
	then
		regen = base
		delay = ""
	else
		delay = "+5s"
	end
	casting = HolyStats_getRegenMp() * regen
	local bonusHealing = GetSpellBonusHealing()
	local maxmana = UnitPowerMax("player" , 0)
	local mana = UnitPower("player" , 0);
	local full = maxmana/regen
	local fullin = (maxmana-mana)/regen
	local percent = 100*mana/maxmana
	local crit = GetSpellCritChance(2) + getTalentRank('Holy Specialization')

	local itemBonus = 0
	local itemRegen = 0
	for invSlot = 1, 18 do
		local itemLink = GetInventoryItemLink("player", invSlot);
		if itemLink ~= nil
		then
			local stats = GetItemStats(itemLink)
			if stats ~= nil
			then
				for k,v in pairs(stats)
				do
					if k == "ITEM_MOD_SPELL_POWER_SHORT" or k == "ITEM_MOD_SPELL_HEALING_DONE_SHORT"
					then
						itemBonus = itemBonus + v + 1
					elseif k == "ITEM_MOD_POWER_REGEN0_SHORT"
					then
						itemRegen = itemRegen + v + 1
					elseif k == "ITEM_MOD_CRIT_SPELL_RATING_SHORT"
					then
						crit = crit + v + 1
					end
				end
			end
		end
	end
	
	tmpl = [[%d%% (%ds%s)

MP5: %.1f
MP5wC: %.1f
HealBonus: %d
Crit: %.2f%%

ItemMP5wC: %.1f
ItemHealBonus: %d]]
	HolyStatsText:SetText(string.format( tmpl, percent, fullin, delay, regen*5, itemRegen + casting*5, bonusHealing, crit, itemRegen, itemBonus))

	local fontName, fontHeight, fontFlags = HolyStatsText:GetFont()
	if config['fontSize'] == nil
	then
		config['fontSize'] = fontHeight
	end
	HolyStatsText:SetFont(fontName, config['fontSize'])

	-- local posX, posY = HolyStatsFrame:GetLeft(), HolyStatsFrame:GetTop()
	-- local width = HolyStatsText:GetStringWidth()
	-- local height = HolyStatsText:GetStringHeight()
	-- HolyStatsFrame:SetWidth(width + 20)
	-- HolyStatsFrame:SetHeight(height + 30)
	-- print(posX)
	-- print(posY)
	-- HolyStatsFrame:ClearAllPoints()
	-- HolyStatsFrame:SetPoint("TOPLEFT", posX, posY)
end

function HolyStats_OnMouseDown(self, button)
	if (button == "LeftButton") then
		pauseUpdate = true
		self:StartMoving()
		return
	elseif button == "RightButton" then
		self:StartSizing()
		self.isSizing = true
		return
	elseif button == "MiddleButton" then
		if isSpellsFrame
		then
			hideSpellsFrame()
		else
			showSpellsFrame()
		end
	end
end

function HolyStats_OnMouseUp(self, button)
	self:StopMovingOrSizing()
	pauseUpdate = false
end

function showSpellsFrame()
	isSpellsFrame = true
	SpellsFrame:Show()
end

function hideSpellsFrame()
	isSpellsFrame = false
	SpellsFrame:Hide()
end



function getTalentRank(talent)
	local talents = {
		['PRIEST'] = {
			['Spiritual Healing'] = {2,15},
			['Improved Healing'] = {2,10},
			['Improved Renew'] = {2,2},
			['Mental Agility'] = {1,10},
			['Holy Specialization'] = {2,3},
			['Meditation'] = {1,8},
			['Improved Prayer of Healing'] = {2,12}
		},
		['PALADIN'] = {
			['Healing Light'] = {1,5},
			['Illumination'] = {1,9},
			['Holy Power'] = {1,13}
		}
	}

	if talents[class][talent] ~= nil 
	then
		if isTalentSim(talent)
		then
			return 3
		end

		local name, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo( talents[class][talent][1], talents[class][talent][2])
		if en(name) == talent and currentRank > 0
		then
			return currentRank
		end
	end
	
	return 0
end

function toggleTalentSim(talent)
	if isTalentSim(talent)
	then
		config['sim'][talent] = false
	else
		config['sim'][talent] = true
	end
end

function isTalentSim(talent)
	local r = false
	if config['sim'][talent] == nil or config['sim'][talent] == false
	then
		r = false
	else
		r = true
	end
	return r
end