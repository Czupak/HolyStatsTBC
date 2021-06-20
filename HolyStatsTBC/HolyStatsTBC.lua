HolyStatsTBC = LibStub("AceAddon-3.0"):NewAddon("HolyStatsTBC")

local prefix = "|cffffa500MP5|cff1784d1Regen|r: "
local regen
local delay
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

	local btnSpellsFrame = CreateFrame("Button", nil, HolyStatsFrame, "UIPanelButtonTemplate")
	btnSpellsFrame:SetPoint("TOPLEFT", -20, -21)
	btnSpellsFrame:SetScript("OnClick", function()
		toggleSpellsFrame()
	end)
	btnSpellsFrame:SetText('S')
	btnSpellsFrame:SetWidth(20)

	local btnSpellsConfig = CreateFrame("Button", nil, HolyStatsFrame,"UIPanelButtonTemplate")
	btnSpellsConfig:SetPoint("TOPLEFT", -20, -41)
	btnSpellsConfig:SetScript("OnClick", function()
		toggleSpellsFrameConfig()
	end)
	btnSpellsConfig:SetText('C')
	btnSpellsConfig:SetWidth(20)

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
			FancySpellsFrame_Update()
			--SpellsFrame_Update()
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
	FancySpellsFrame:Show()
	--SpellsFrame:Show()
end

function hideSpellsFrame()
	isSpellsFrame = false
	FancySpellsFrame:Hide()
	--SpellsFrame:Hide()
end


