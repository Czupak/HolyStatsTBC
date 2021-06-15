local addonName = 'HolyStatsTBC'
local optionsFrame = CreateFrame("FRAME")
optionsFrame.name = addonName
optionsFrame:Hide()
optionsFrame:SetScript("OnShow", function(optionsFrame)
    local function newCheckbox(label, description, onClick)
		local check = CreateFrame("CheckButton", "CCDCheck" .. label, optionsFrame, "InterfaceOptionsCheckButtonTemplate")
		check:SetScript("OnClick", function(self)
			local tick = self:GetChecked()
			onClick(self, tick and true or false)
		end)
		check.label = _G[check:GetName() .. "Text"]
		check.label:SetText(label)
		check.tooltipText = label
		check.tooltipRequirement = description
		return check
	end

    local function newEditbox(label, description, onClick)
		local eb = CreateFrame("EditBox", "HSEB" .. label, optionsFrame, "InputBoxTemplate")
        -- check:SetScript("OnEnterPressed", function(self, value)
        --     print("ENTER")
        --     print(value)
		-- 	-- local tick = self:GetChecked()
		-- 	-- onClick(self, tick and true or false)
		-- end)
		-- check.label = _G[check:GetName() .. "Text"]
		-- check.label:SetText(label)
		-- check.tooltipText = label
        -- check.tooltipRequirement = description
        eb:SetWidth(200)
        eb:SetHeight(5)
		return eb
	end

    local function newSlider(label, configKey, onClick)
        local sl = CreateFrame("Slider", "HSSlider" .. label, optionsFrame, "HorizontalSliderTemplate")
        sl:SetMinMaxValues(1, 20)
        sl:SetValueStep(1)
        sl:SetOrientation("HORIZONTAL")
        -- sl:Enable()
        sl:SetWidth(250)
        sl:SetHeight(4)
        sl:SetValue(config['ui'][configKey])
        sl:SetScript("OnValueChanged", function(self)
			local val = self:GetValue()
            onClick(self, val)
        end)
		return sl
	end

	local function optionSlider(text, refPoint, name, configKey)
        local label = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("TOPLEFT", refPoint, "BOTTOMLEFT", 0, -20)
        label:SetText(text)
        local slider = newSlider(
            name,
            configKey,
            function(self, value)
                if value ~= nil and value > 0
                then
                    config['ui'][configKey] = math.floor(value + 0.50)
                    self:SetValue(config['ui'][configKey])
                end
            end)
        slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -10)
        return slider
	end

    -- HEADER
	local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(addonName)

    -- Sliders
    local anchor = optionSlider("Main Window Font Size", title, 'mwfSlider', 'mainWindowFont')
    anchor = optionSlider("Main Window Aplha", anchor, 'mwaSlider', 'mainWindowAlpha')
    anchor = optionSlider("Spells Font Size", anchor, "swfSlider", "spellsWindowFont")

    -- Reset window size and position
    local resetButton = CreateFrame("Button", "ResetButtonFrame", optionsFrame, "UIPanelButtonTemplate")
	resetButton:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
	resetButton:SetScript("OnClick", function()
		resetPosition()
	end)
	resetButton:SetText('Reset window size and position')
	resetButton:SetWidth(170)

    fontLabel = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontLabel:SetPoint("TOPLEFT", resetButton, "BOTTOMLEFT", -2, -16)
    fontLabel:SetText("Simulate talents")
    
    -- Simulate
    local dropdown = CreateFrame("Frame", "Simulate", optionsFrame, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -8)
	dropdown.initialize = function()
	    local function addEntry(name)
            local dd = {}
                dd.text = name
                dd.value = name
                dd.func = function(self)
                    toggleTalentSim(self.value)
                    self.checked = isTalentSim(self.value)
                    SimulateTalentList:SetText(getTalentSimString())
                end
                dd.checked = isTalentSim(dd.text)
            UIDropDownMenu_AddButton(dd)
            end
        for talent,a in pairs(getClassTalents())
        do
            addEntry(talent)
        end
	end

    local list = optionsFrame:CreateFontString('SimulateTalentList', "ARTWORK", "GameFontNormalSmall")
    list:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 8, -8)
    list:SetTextColor(1 ,1 ,1)
	list:SetText(getTalentSimString())

    -- Efficiency
    fontLabel = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontLabel:SetPoint("TOPLEFT", list, "BOTTOMLEFT", -10, -16)
    fontLabel:SetText("Efficiency calculation based on [=100%]")

    dropdown_eff = CreateFrame("Frame", "EffSpell", optionsFrame, "UIDropDownMenuTemplate")
	dropdown_eff:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -8)
	dropdown_eff.initialize = function()
		local dd = {}
            -- dd.checked = isTalentSim(dd.text)
        spells = getHealingSpells()
        for a,spell in pairs(sortKeys(spells))
        do
            for a,rank in pairs(sortKeys(spells[spell]))
            do
                dd.text = spell .. ' (' .. rank .. ')'
                dd.value = spell .. ' (' .. rank .. ')'
                dd.rank = rank
                dd.func = function(self)
                    setEffSpell(self.value)
                    -- self.checked = isCooldownIgnored(self.value)
                    if getEffSpell()
                    then
                        EfficiencyList:SetText(getEffSpell())
                    end
                end
                UIDropDownMenu_AddButton(dd)
            end
		end
	end

    local list_eff = optionsFrame:CreateFontString('EfficiencyList', "ARTWORK", "GameFontNormalSmall")
    list_eff:SetPoint("TOPLEFT", dropdown_eff, "BOTTOMLEFT", 8, -8)
    list_eff:SetTextColor(1,1,1)
	if(getEffSpell())
    then
        list_eff:SetText(getEffSpell())
    else
        list_eff:SetText('')
    end
	list_eff:SetJustifyH("LEFT")


    optionsFrame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(optionsFrame)

SLASH_HOLYSTATS1 = '/holystats'
function SlashCmdList.HOLYSTATS(msg)
	InterfaceOptionsFrame_OpenToCategory(addonName)
	InterfaceOptionsFrame_OpenToCategory(addonName)
end

function resetPosition()
    HolyStatsFrame:SetSize(150,180)
    HolyStatsFrame:SetPoint("TOPLEFT",UIParent,"CENTER",-50,50)
    SpellsFrame:SetPoint("TOPLEFT",UIParent,"CENTER",-50,50)
    SpellsFrameConfig:SetPoint("TOPLEFT",UIParent,"CENTER",-50,50)
end