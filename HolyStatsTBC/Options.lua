local hollystatsOptions = {
    name = "HolyStatsTBC",
    handler = HolyStatsTBC,
    type = "group",
	childGroups = "tab",
    args = {
        tab1 = {
            type = "group",
            name = "UI",
			width = "full",
			order = 1,
			args = {
				mainWindowFontSizeSlider = {
				    type = "range",
				    name = "Main Window Font Size",
				    order = 1,
				    min = 1,
				    max = 20,
				    step = 0.1,
				    get = function(info) return config['ui']['mainWindowFont'] end,
				    set = function(info, val) config['ui']['mainWindowFont'] = val end,
				},
				mainWindowBGColor = {
				    type = "color",
				    name = "Main Window Background Color",
				    order = 2,
				    width = "full",
				    get = function(info)
				        bgcolor = config['ui']['mainWindowBGColor']
				        return bgcolor[1], bgcolor[2], bgcolor[3], 1.0
				    end,
				    set = function(info, r, g, b, a)
				        HolyStatsBG:SetVertexColor(r, g, b, config['ui']['mainWindowAlpha'])
				        config['ui']['mainWindowBGColor'] = {r, g, b, 1.0}
				    end,
				},
				mainWindowFontColor = {
				    type = "color",
				    name = "Main Window Font Color",
				    order = 3,
				    hasAlpha = true,
				    width = "full",
				    get = function(info)
				        bgcolor = config['ui']['mainWindowFontColor']
				        return bgcolor[1], bgcolor[2], bgcolor[3], bgcolor[4]
				    end,
				    set = function(info, r, g, b, a)
				        HolyStatsText:SetTextColor(r, g, b, a)
				        config['ui']['mainWindowFontColor'] = {r, g, b, a}
				    end,
				},
				mainWindowAlphaSlider = {
				    type = "range",
				    name = "Main Window Aplha",
				    order = 4,
				    min = 0,
				    max = 100,
				    step = 1,
				    get = function(info) return config['ui']['mainWindowAlpha'] * 100 end,
				    set = function(info, val) config['ui']['mainWindowAlpha'] = val / 100 end,
				},
				spacer1 = {
				    type = "description",
				    name = " ",
				    width = "full",
				    order = 5,
				},
				spellsWindowFontSizeSlider = {
				    type = "range",
				    name = "Spells Window Font Size",
				    order = 6,
				    min = 1,
				    max = 20,
				    step = 0.1,
				    get = function(info) return config['ui']['spellsWindowFont'] end,
				    set = function(info, val) config['ui']['spellsWindowFont'] = val end,
				},
				spacer2 = {
				    type = "description",
				    name = " ",
				    width = "full",
				    order = 7,
				},
				resetButton = {
				    type = "execute",
				    name = "Reset window size and position",
				    order = 7,
				    func = function() resetPosition() end,
				}
			}
		},
        tab2 = {
            type = "group",
            name = "Talent Simulation",
			width = "full",
			order = 2,
			args = {
			}
		},
		tab3 = {
		    type = "group",
		    name = "Spells",
		    width = "full",
		    order = 3,
		    args = {
                efficiencyBasedOn = {
                    type = "select",
                    name = "Efficiency calculation based on [=100%]",
                    order = 1,
                    values = function(info)
                        spells = getHealingSpells()
                        r = {}
                        for a, spell in pairs(sortKeys(spells))
                        do
                            for a, rank in pairs(sortKeys(spells[spell]))
                            do
                                val = spell .. ' (' .. rank .. ')'
                                r[val] = val
                            end
                        end
                        return r
                    end,
                    get = function(info) return getEffSpell() end,
                    set = function(info, val) setEffSpell(val) end,
                    style = "dropdown"
                },
				spacer3 = {
				    type = "description",
				    name = " ",
				    width = "full",
				    order = 2,
				},
				spellMarks = {
				    type = "description",
				    name = "Spell Marks",
				    width = "full",
				    order = 3,
				    fontSize = 'large'
				},
		    }
		}
	}
}

function HolyStatsTBC:OnInitialize()
    configTalentSim()
    configSpellMarks()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("HolyStatsTBC", hollystatsOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HolyStatsTBC"):SetParent(InterfaceOptionsFramePanelContainer)
end

function configTalentSim()
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
        func = function()
            toggleTalentSim(self.value)
        end
        hollystatsOptions['args']['tab2']['args'][talent] = {
            type = 'toggle',
            name = talent,
            get = function(info) return isTalentSim(talent) end,
            set = function(info, val) toggleTalentSim(talent, val) end,
        }
    end
end

function configSpellMarks()
    for i = 1, 5, 1 do
        nameLabel = 'spellMarkName' .. i
        avgLabel = 'spellMarkAvg' .. i
        spacerLabel = 'spellSpacer' .. i
        hollystatsOptions['args']['tab3']['args'][nameLabel] = {
            type = "input",
            name = "Spell Mark " .. i .. " Name",
            order = (i-1)*3 + 4,
            get = function(info) return config['spellMarks'][i]['name'] end,
            set = function(info, val) config['spellMarks'][i]['name'] = val end,
            pattern = ""
        }
        hollystatsOptions['args']['tab3']['args'][avgLabel] = {
            type = "range",
            name = "Spell Mark " .. i .. " Average Heal",
            order = (i-1)*3 + 5,
            min = 0,
            max = 6000,
            step = 100,
            get = function(info) return config['spellMarks'][i]['avg'] end,
            set = function(info, val) config['spellMarks'][i]['avg'] = val end,
        }
        hollystatsOptions['args']['tab3']['args'][spacerLabel] = {
            type = "description",
            name = " ",
            width = "full",
            order = (i-1)*3 + 6,
        }

    end
end


SLASH_HOLYSTATS1 = '/holystats'
function SlashCmdList.HOLYSTATS(msg)
	InterfaceOptionsFrame_OpenToCategory("HolyStatsTBC")
	InterfaceOptionsFrame_OpenToCategory("HolyStatsTBC")
end

