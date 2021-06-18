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
		if config['sim'] == nil
		then
			config['sim'] = {}
		end
		if config['ui'] == nil
		then
		    config['ui'] = {}
		end

        for i, key in pairs({'mainWindowFont', 'mainWindowAlpha', 'spellsWindowFont', 'mainWindowBGColor', 'mainWindowFontColor'}) do
            if config['ui'][key] == nil
            then
                if key == 'mainWindowAlpha' then
                    config['ui'][key] = 100
                elseif key == 'mainWindowBGColor' then
                    config['ui'][key] = {0.2, 0.2, 0.2, 1.0}
                elseif key == 'mainWindowFontColor' then
                    config['ui'][key] = {1, 1, 1, 1}
                else
                    config['ui'][key] = 12
                end
            end
        end
        if config['spellMarks'] == nil then
            config['spellMarks'] = {}
            for i = 1, 5, 1 do
                table.insert(config['spellMarks'], {name = '', avg = 99999999})
            end
        end

		HolyStats_OnLoad(HolyStats)
		SpellsFrameConfig_OnLoad(SpellsFrameConfig)
	end
end
frame:SetScript("OnEvent", frame.OnEvent);

function HolyStats_OnLoad(self)
    bgColor = config['ui']['mainWindowBGColor']
	HolyStatsBG:SetVertexColor(bgColor[1], bgColor[2], bgColor[3], config['ui']['mainWindowAlpha'])
	HolyStatsFrame:SetMinResize(20,20)
	HolyStatsFrame:SetClampedToScreen(true)

	local btn_toggle = CreateFrame("Button", nil, HolyStatsFrame,"UIPanelButtonTemplate")
	btn_toggle:SetPoint("TOPLEFT", -20, 1)
	btn_toggle:SetScript("OnClick", function()
		toggleSpellsFrame()
	end)
	btn_toggle:SetText('?')
	btn_toggle:SetWidth(20)

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
	HolyStatsText:SetFont(fontName, config['ui']['mainWindowFont'])
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
		toggleSpellsFrame()
	end
end

function HolyStats_OnMouseUp(self, button)
	self:StopMovingOrSizing()
	pauseUpdate = false
end

function toggleSpellsFrame()
	if isSpellsFrame
	then
		hideSpellsFrame()
	else
		showSpellsFrame()
	end
end

function showSpellsFrame()
	isSpellsFrame = true
	SpellsFrame:Show()
end

function hideSpellsFrame()
	isSpellsFrame = false
	SpellsFrame:Hide()
end

function getClassTalents()
	local talents = {
		['PRIEST'] = {
			['Spiritual Healing'] = {2, 16, 5},
			['Improved Healing'] = {2, 10, 3},
			['Improved Renew'] = {2, 2, 3},
			['Mental Agility'] = {1, 11, 5},
			['Holy Specialization'] = {2, 3, 5},
			['Meditation'] = {1, 9, 3},
			['Healing Prayers'] = {2, 12, 2},
			['Divine Fury'] = {2, 5, 5},
			['Empowered Healing'] = {2, 20, 5},
			['Circle of Healing'] = {2, 21, 1}
		},
		['PALADIN'] = {
			['Healing Light'] = {1, 5, 3},
			['Illumination'] = {1, 9, 5},
			['Holy Power'] = {1, 15, 5}
		}
	}
    return talents[class]
end

function getTalentRank(talent)
	local talents = getClassTalents()
	if talents[talent] ~= nil
	then
		if isTalentSim(talent)
		then
			return talents[talent][3]
		end

		local name, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo( talents[talent][1], talents[talent][2])
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
	if config['sim'][talent] == nil or config['sim'][talent] == false
	then
		return false
	else
		return true
	end
end

function getTalentSimString()
    simArr = {}
    for talent, value in pairs(config['sim']) do
        if isTalentSim(talent)
        then
            table.insert(simArr, talent)
        end
    end
    return table.concat(simArr, "\n")
end

function resetPosition()
    HolyStatsFrame:SetSize(150, 180)
    HolyStatsFrame:ClearAllPoints()
    HolyStatsFrame:SetPoint("TOPLEFT", "UIParent", "CENTER", -50, 50)
    SpellsFrame:ClearAllPoints()
    SpellsFrame:SetPoint("TOPLEFT", "UIParent", "CENTER", -50, 50)
    SpellsFrameConfig:ClearAllPoints()
    SpellsFrameConfig:SetPoint("TOPLEFT", "UIParent" ,"CENTER", -50, 50)
end
