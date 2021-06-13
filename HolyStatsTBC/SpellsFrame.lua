local cache = {}
local healingSpells = {
	['PRIEST'] = {
		['Circle of Healing'] ={
			['Rank 1'] = {
				org = {
					Min = 250,
					Max = 274,
					Mana = 300,
					Cast = 0,
					BaseCast = 0,
					lvl = 70,
					targets = 5
				}
			},
			['Rank 2'] = {
				org = {
					Min = 292,
					Max = 323,
					Mana = 337,
					Cast = 0,
					BaseCast = 0,
					lvl = 70,
					targets = 5
				}
			},
			['Rank 3'] = {
				org = {
					Min = 332,
					Max = 367,
					Mana = 375,
					Cast = 0,
					BaseCast = 0,
					lvl = 70,
					targets = 5
				}
			},
			['Rank 4'] = {
				org = {
					Min = 376,
					Max = 415,
					Mana = 411,
					Cast = 0,
					BaseCast = 0,
					lvl = 70,
					targets = 5
				}
			},
			['Rank 5'] = {
				org = {
					Min = 409,
					Max = 451,
					Mana = 450,
					Cast = 0,
					BaseCast = 0,
					lvl = 70,
					targets = 5
				}
			},
		},
		['Binding Heal'] = {
			['Rank 1'] = {
				org = {
					Min = 1053,
					Max = 1350,
					Mana = 705,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 70,
					targets = 2
				}
			}
		},
		['Lesser Heal'] = {
			['Rank 1'] = {
				org = {
					Min = 47,
					Max = 58,
					Mana = 30,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 1
				}
			},
			['Rank 2'] = {
				org = {
					Min = 76,
					Max = 91,
					Mana = 45,
					Cast = 2,
					BaseCast = 2,
					lvl = 4
				}
			},
			['Rank 3'] = {
				org = {
					Min = 143,
					Max = 165,
					Mana = 75,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 10
				}
			},
		},
		Heal = {
			['Rank 1'] = {
				org = {
					Min = 307,
					Max = 353,
					Mana = 155,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 16
				}
			},
			['Rank 2'] = {
				org = {
					Min = 445,
					Max = 507,
					Mana = 205,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 28
				}
			},
			['Rank 3'] = {
				org = {
					Min = 586,
					Max = 662,
					Mana = 255,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 28
				}
			},
			['Rank 4'] = {
				org = {
					Min = 734,
					Max = 827,
					Mana = 305,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 34
				}
			}
		},
		['Greater Heal'] = {
			['Rank 1'] = {
				org = {
					Min = 924,
					Max = 1039,
					Mana = 370,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 40
				}
			},
			['Rank 2'] = {
				org = {
					Min = 1178,
					Max = 1318,
					Mana = 455,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 46
				}
			},
			['Rank 3'] = {
				org = {
					Min = 1470,
					Max = 1642,
					Mana = 545,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 52
				}
			},
			['Rank 4'] = {
				org = {
					Min = 1835,
					Max = 2044,
					Mana = 655,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 58
				}
			},
			['Rank 5'] = {
				org = {
					Min = 2066,
					Max = 2235,
					Mana = 710,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 60
				}
			},
			['Rank 6'] = {
				org = {
					Min = 2107,
					Max = 2444,
					Mana = 750,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 63
				}
			},
			['Rank 7'] = {
				org = {
					Min = 2414,
					Max = 2803,
					Mana = 825,
					Cast = 2.5,
					BaseCast = 3,
					lvl = 68
				}
			}
		},
		['Flash Heal'] = {
			['Rank 1'] = {
				org = {
					Min = 202,
					Max = 247,
					Mana = 125,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 20
				}
			},
			['Rank 2'] = {
				org = {
					Min = 269,
					Max = 325,
					Mana = 155,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 26
				}
			},
			['Rank 3'] = {
				org = {
					Min = 339,
					Max = 406,
					Mana = 185,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 32
				}
			},
			['Rank 4'] = {
				org = {
					Min = 414,
					Max = 492,
					Mana = 215,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 38
				}
			},
			['Rank 5'] = {
				org = {
					Min = 534,
					Max = 633,
					Mana = 265,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 44
				}
			},
			['Rank 6'] = {
				org = {
					Min = 662,
					Max = 783,
					Mana = 315,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 50
				}
			},
			['Rank 7'] = {
				org = {
					Min = 833,
					Max = 979,
					Mana = 380,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 56
				}
			},
			['Rank 8'] = {
				org = {
					Min = 931,
					Max = 1078,
					Mana = 400,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 61
				}
			},
			['Rank 9'] = {
				org = {
					Min = 1116,
					Max = 1295,
					Mana = 470,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 67
				}
			}
		},
		['Renew'] = {
			['Rank 1'] = {
				org = {
					Min = 45,
					Max = 45,
					Mana = 30,
					Cast = 0,
					BaseCast = 15,
					lvl = 8
				}
			},
			['Rank 2'] = {
				org = {
					Min = 100,
					Max = 100,
					Mana = 65,
					Cast = 0,
					BaseCast = 15,
					lvl = 14
				}
			},
			['Rank 3'] = {
				org = {
					Min = 175,
					Max = 175,
					Mana = 105,
					Cast = 0,
					BaseCast = 15,
					lvl = 20
				}
			},
			['Rank 4'] = {
				org = {
					Min = 245,
					Max = 245,
					Mana = 140,
					Cast = 0,
					BaseCast = 15,
					lvl = 26
				}
			},
			['Rank 5'] = {
				org = {
					Min = 315,
					Max = 315,
					Mana = 170,
					Cast = 0,
					BaseCast = 15,
					lvl = 32
				}
			},
			['Rank 6'] = {
				org = {
					Min = 400,
					Max = 400,
					Mana = 205,
					Cast = 0,
					BaseCast = 15,
					lvl = 38
				}
			},
			['Rank 7'] = {
				org = {
					Min = 510,
					Max = 510,
					Mana = 250,
					Cast = 0,
					BaseCast = 15,
					lvl = 44
				}
			},
			['Rank 8'] = {
				org = {
					Min = 650,
					Max = 650,
					Mana = 305,
					Cast = 0,
					BaseCast = 15,
					lvl = 50
				}
			},
			['Rank 9'] = {
				org = {
					Min = 810,
					Max = 810,
					Mana = 365,
					Cast = 0,
					BaseCast = 15,
					lvl = 56
				}
			},
			['Rank 10'] = {
				org = {
					Min = 970,
					Max = 970,
					Mana = 410,
					Cast = 0,
					BaseCast = 15,
					lvl = 60
				}
			},
			['Rank 11'] = {
				org = {
					Min = 1010,
					Max = 1010,
					Mana = 430,
					Cast = 0,
					BaseCast = 15,
					lvl = 65
				}
			},
			['Rank 12'] = {
				org = {
					Min = 1110,
					Max = 1110,
					Mana = 450,
					Cast = 0,
					BaseCast = 15,
					lvl = 70
				}
			},
		},
		['Prayer of Healing'] = {
			['Rank 1'] = {
				org = {
					Min = 312,
					Max = 333,
					Mana = 410,
					Cast = 3,
					BaseCast = 3,
					lvl = 60,
					targets = 5
				}
			},
			['Rank 2'] = {
				org = {
					Min = 458,
					Max = 487,
					Mana = 560,
					Cast = 3,
					BaseCast = 3,
					lvl = 60,
					targets = 5
				}
			},
			['Rank 3'] = {
				org = {
					Min = 675,
					Max = 713,
					Mana = 770,
					Cast = 3,
					BaseCast = 3,
					lvl = 60,
					targets = 5
				}
			},
			['Rank 4'] = {
				org = {
					Min = 960,
					Max = 1013,
					Mana = 1030,
					Cast = 3,
					BaseCast = 3,
					lvl = 60,
					targets = 5
				}
			},
			['Rank 5'] = {
				org = {
					Min = 1019,
					Max = 1076,
					Mana = 1070,
					Cast = 3,
					BaseCast = 3,
					lvl = 60,
					targets = 5
				}
			},
			['Rank 6'] = {
				org = {
					Min = 1251,
					Max = 1322,
					Mana = 1255,
					Cast = 3,
					BaseCast = 3,
					lvl = 68,
					targets = 5
				}
			},
		},
		['Holy Nova'] = {
			['Rank 7'] = {
				org = {
					Min = 386,
					Max = 348,
					Mana = 875,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 68,
					targets = 5
				}
			},
			['Rank 6'] = {
				org = {
					Min = 307,
					Max = 356,
					Mana = 750,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 60,
					targets = 5
				}
			},
			['Rank 5'] = {
				org = {
					Min = 239,
					Max = 276,
					Mana = 635,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 52,
					targets = 5
				}
			},
			['Rank 4'] = {
				org = {
					Min = 165,
					Max = 192,
					Mana = 520,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 44,
					targets = 5
				}
			},
			['Rank 3'] = {
				org = {
					Min = 124,
					Max = 143,
					Mana = 400,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 36,
					targets = 5
				}
			},
			['Rank 2'] = {
				org = {
					Min = 89,
					Max = 101,
					Mana = 290,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 28,
					targets = 5
				}
			},
			['Rank 1'] = {
				org = {
					Min = 54,
					Max = 63,
					Mana = 185,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 20,
					targets = 5
				}
			},
		}
	},
	['PALADIN'] = {
		['Flash of Light'] = {
			['Rank 1'] = {
				org = {
					Min = 67,
					Max = 77,
					Mana = 35,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 20
				}
			},
			['Rank 2'] = {
				org = {
					Min = 102,
					Max = 117,
					Mana = 50,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 26
				}
			},
			['Rank 3'] = {
				org = {
					Min = 153,
					Max = 171,
					Mana = 70,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 34
				}
			},
			['Rank 4'] = {
				org = {
					Min = 206,
					Max = 231,
					Mana = 90,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 42
				}
			},
			['Rank 5'] = {
				org = {
					Min = 278,
					Max = 310,
					Mana = 115,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 50
				}
			},
			['Rank 6'] = {
				org = {
					Min = 356,
					Max = 396,
					Mana = 140,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 58
				}
			},
			['Rank 7'] = {
				org = {
					Min = 458,
					Max = 513,
					Mana = 180,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 66
				}
			}
		},
		['Holy Shock'] = {
			['Rank 1'] = {
				org = {
					Min = 351,
					Max = 379,
					Mana = 335,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 1
				}
			},
			['Rank 2'] = {
				org = {
					Min = 480,
					Max = 518,
					Mana = 410,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 48
				}
			},
			['Rank 3'] = {
				org = {
					Min = 628,
					Max = 680,
					Mana = 485,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 56
				}
			},
			['Rank 4'] = {
				org = {
					Min = 777,
					Max = 841,
					Mana = 575,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 46
				}
			},
			['Rank 5'] = {
				org = {
					Min = 913,
					Max = 987,
					Mana = 650,
					Cast = 1.5,
					BaseCast = 1.5,
					lvl = 70
				}
			}
		},
		['Holy Light'] = {
			['Rank 1'] = {
				org = {
					Min = 42,
					Max = 51,
					Mana = 35,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 1
				}
			},
			['Rank 2'] = {
				org = {
					Min = 81,
					Max = 96,
					Mana = 60,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 6
				}
			},
			['Rank 3'] = {
				org = {
					Min = 167,
					Max = 196,
					Mana = 110,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 14
				}
			},
			['Rank 4'] = {
				org = {
					Min = 322,
					Max = 368,
					Mana = 190,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 22
				}
			},
			['Rank 5'] = {
				org = {
					Min = 506,
					Max = 569,
					Mana = 275,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 30
				}
			},
			['Rank 6'] = {
				org = {
					Min = 717,
					Max = 799,
					Mana = 365,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 38
				}
			},
			['Rank 7'] = {
				org = {
					Min = 968,
					Max = 1076,
					Mana = 465,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 46
				}
			},
			['Rank 8'] = {
				org = {
					Min = 1272,
					Max = 1414,
					Mana = 580,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 54
				}
			},
			['Rank 9'] = {
				org = {
					Min = 1619,
					Max = 1799,
					Mana = 660,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 60
				}
			},
			['Rank 10'] = {
				org = {
					Min = 1773,
					Max = 1971,
					Mana = 710,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 62
				}
			},
			['Rank 11'] = {
				org = {
					Min = 2196,
					Max = 2446,
					Mana = 840,
					Cast = 2.5,
					BaseCast = 2.5,
					lvl = 70
				}
			},
		}
	}
}

local sortBy = 'eff'
local sortOrder = 0
local _, class = UnitClass("player")

function SpellsFrame_OnLoad(self)
	SpellsFrameBG:SetVertexColor(0.2, 0.2, 0.2)
	self:SetMinResize(20,20)
	self:SetClampedToScreen(true)
	local offset = 0

	local btn_toggle = CreateFrame("Button", nil, SpellsFrame,"UIPanelButtonTemplate")
	btn_toggle:SetPoint("TOPLEFT", -20, 1)
	btn_toggle:SetScript("OnClick", function()
		toggleSpellsFrameConfig()
	end)
	btn_toggle:SetText('?')
	btn_toggle:SetWidth(20)

	local btn_close = CreateFrame("Button", nil, SpellsFrame, "UIPanelButtonTemplate")
	btn_close:SetPoint("TOPLEFT", -20, -21)
	btn_close:SetScript("OnClick", function()
		toggleSpellsFrame()
	end)
	btn_close:SetText('x')
	btn_close:SetWidth(20)

	local columns = {
		{ name = 'spell', width = 110 },
		{ name = 'rank', width = 50 },
		{ name = 'min', width = 40 },
		{ name = 'max', width = 40 },
		{ name = 'avg', width = 40 },
		{ name = 'mana', width = 40 },
		{ name = 'eff', width = 40 },
		{ name = 'hbcoeff', width = 40 },
		{ name = 'hb', width = 40 },
		{ name = 'hbp', width = 40 }
	}
	SpellsFrameTextSpell1:SetWidth(columns[1]['width'])
	for _,col in pairs(columns)
	do
		local btn = CreateFrame("Button", nil, self,"UIPanelButtonTemplate")
		btn:SetPoint("TOPLEFT", offset, 1)
		btn:SetScript("OnClick", function()
			if sortBy ~= col['name']
			then
				sortBy = col['name']
				sortOrder = 1
			else
				if sortOrder == 1
				then
					sortOrder = 0
				else 
					sortOrder = 1
				end
			end
			SpellsFrame_Update()
		end)
		btn:SetText(col['name'])
		btn:SetWidth(col['width'])
		offset = offset + col['width']
	end
end

function SpellsFrame_OnMouseDown(self, button)
	if (button == "LeftButton") then
		self:StartMoving()
		return
	elseif button == "RightButton" then
		self:StartSizing()
		self.isSizing = true
		return
	elseif button == "MiddleButton" then
		hideSpellsFrame()
	end
end

function SpellsFrame_OnMouseUp(self, button)
	self:StopMovingOrSizing()
end

function SpellsFrame_Update()
	calculateSpells()
	local spells = getHealingSpells()
	local data = getSpells(spells)
	printData(data)
end

activeSpells = {}

function getHealingSpells()
	local spells = {}
	local i = 1
	while true do
		local spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		if not spellName
		then
			do break end
		end
		spellName = en(spellName)
		spellSubName = en(spellSubName)

		if healingSpells[class][spellName] ~= nil and healingSpells[class][spellName][spellSubName] ~= nil
		then
			if spells[spellName] == nil
			then
				spells[spellName] = {}
			end
			spells[spellName][spellSubName] = healingSpells[class][spellName][spellSubName]
		end
		i = i + 1
	end
	return spells
end
	
function sortKeys(data)
	local keys = {}
	for k in pairs(data)
	do
		table.insert(keys, k)
	end
	table.sort(keys)

	return keys
end

function calculateSpells()
	-- Mental Agility - instant casts 2% * 5
	-- Improved Renew - renew 5% * 3
	-- Improved Healing - mana cost Lesser Heal, Heal, Greater Heal 5% * 3
	-- Improved Prayer of Healing - mana cost Prayer of Healing 10% * 2
	-- Spiritual Guidance - healing by 5% * 5 of Spirit [included in bonus healing]
	-- Spritual Healing - healing spells 2% * 5
	local bonus = 0
	local spellRank = getTalentRank('Spiritual Healing')
	if spellRank > 0
	then
		bonus = 0.02 * spellRank
	end

	local spellRank = getTalentRank('Healing Light')
	if spellRank > 0
	then
		bonus = 0.04 * spellRank
	end

	local manaCost = 0
	spellRank = getTalentRank('Improved Healing')
	if spellRank > 0
	then
		manaCost = 0.05 * spellRank
	end

	local renew = 0
	spellRank = getTalentRank('Improved Renew')
	if spellRank > 0
	then
		renew = 0.05 * spellRank
	end

	local instantMana = 0
	spellRank = getTalentRank('Mental Agility')
	if spellRank > 0
	then
		instantMana = 0.02 * spellRank
	end

	local data = healingSpells
	for spell, ranks in pairs(healingSpells[class])
	do
		for rank, obj in pairs(ranks)
		do
			local mana = obj['org']['Mana']
			if spell == 'Heal' or spell == 'Lesser Heal' or spell == 'Greater Heal'
			then
				mana = obj['org']['Mana']*(1-manaCost)
			end
			if spell == 'Prayer of Healing'
			then
				mana = obj['org']['Mana'] * (1 - getTalentRank('Improved Prayer of Healing') * 0.1)
			end
			if spell == 'Holy Nova'
			then
				mana = obj['org']['Mana']*(1-instantMana)
			end

			local xMin = obj['org']['Min']
			local xMax = obj['org']['Max']
			if spell ~= 'Holy Shock'
			then
				xMin = xMin*(1+bonus)
				xMax = xMax*(1+bonus)
			end

			if spell == 'Renew'
			then
				mana = obj['org']['Mana']*(1-instantMana)
				xMin = obj['org']['Min']*(1+bonus+renew)
				xMax = obj['org']['Max']*(1+bonus+renew)
			end

			local tg = nil
			if obj['org']['targets'] ~= nil
			then
				tg = obj['org']['targets']
			end
			data[class][spell][rank] = {
				Min = xMin,
				Max = xMax,
				Mana = mana,
				Cast = obj['org']['Cast'],
				BaseCast = obj['org']['BaseCast'],
				lvl = obj['org']['lvl'],
				targets = tg,
				org = obj['org']
			}
		end
	end

	healingSpells = data
end

function setEffSpell(spell)
	-- print("Set eff spell to [" .. spell .. "]")
	config['effSpell'] = spell
end

function getEffSpell()
	return config['effSpell']
end

function getSpells(spells)
	local toFrame = ''
	local data = {}
	cache['maxeff'] = 0
	for a,spell in pairs(sortKeys(spells))
	do
		for a,rank in pairs(sortKeys(spells[spell]))
		do
			if config['effSpell'] ~= nil and config['effSpell'] == spell .. ' (' ..rank .. ')'
			then
				-- FIXME
				local meta = spells[spell][rank]

				local coeff = meta.BaseCast / 3.5
				if spell == 'Renew'
				then
					coeff = meta.BaseCast / 15
				end
				if spell == 'Holy Nova'
				then
					coeff = coeff / 3 / 2
				end
				local bonusHealing = GetSpellBonusHealing()
				local cMin = meta.Min
				local cMax = meta.Max
				local avg = (cMin + cMax) / 2
				local avgHB = avg + bonusHealing * coeff
				local eff = avgHB / meta.Mana
				cache['maxeff'] = eff
			end


			if not isSpellIgnored(spell, rank)
			then
				local meta = spells[spell][rank]
				local hb = 0
				local bonusHealing = GetSpellBonusHealing()
				local coeff = meta.BaseCast / 3.5
				if spell == 'Renew'
				then
					coeff = meta.BaseCast / 15
				end
				if spell == 'Prayer of Healing'
				then
					coeff = coeff / 3
				end
				if spell == 'Holy Nova'
				then
					coeff = coeff / 3 / 2
				end
				local lvlPenality = 1
				if meta.lvl < 20
				then
					lvlPenality = 1 - ((20 - meta.lvl) * 0.0375)
				end
				coeff = coeff * lvlPenality
				local mana = math.ceil(meta.Mana)
				hbp = bonusHealing * coeff
				
				local loopTargets = 1
				if meta.targets ~= nil
				then
					loopTargets = meta.targets
				end 
				for tarNum = 1, loopTargets
				do
					local targets = ''
					local cMin = meta.Min * tarNum
					local cMax = meta.Max * tarNum
					if meta.targets ~=nil
					then
						targets = ' (x' .. tostring(tarNum) .. ')'
					end

					local avg = (cMin + cMax) / 2
					local mMin = cMin + bonusHealing * coeff
					local mMax = cMax + bonusHealing * coeff
					local avgHB = avg + bonusHealing * coeff
					local eff = avgHB / meta.Mana
					hb = (avgHB - avg) * 100 / avgHB
					
					local entry = {
						['spell'] = spell .. targets,
						['rank'] = rank,
						['mana'] = mana,
						['min'] = mMin,
						['max'] = mMax,
						['avg'] = avgHB,
						['eff'] = eff,
						['hbcoeff'] = coeff * 100,
						['hb'] = hbp,
						['hbp'] = hb
					}
					table.insert(data, entry)
					if cache['maxeff'] < eff and config['effSpell'] == nil -- and config['effSpell'] == spell .. ' (' ..rank .. ')'
					then
						cache['maxeff'] = eff
					end
				end
			end
		end
	end

	if sortBy ~= nil 
	then
		data = sortData(data)
	end
	return data
end

function printData(data)
	local keys = {'spell', 'rank', 'mana', 'min', 'max', 'avg', 'eff', 'hbcoeff', 'hb', 'hbp'}
	local col = {}
	for _,key in pairs(keys)
	do
		col[key] = {}
	end
	
	for i, entry in pairs(data)
	do
		for _,key in pairs(keys)
		do
			if key == 'eff'
			then
				entry[key] = entry[key] * 1000 / cache['maxeff']
				entry[key] = math.floor(entry[key]+0.5)
				entry[key] = entry[key] / 10
			end
			if key == 'avg' or key == 'hb' or key == 'min' or key == 'max' or key == 'hbcoeff' or key == 'hbp'
			then
				entry[key] = math.floor(entry[key]+0.5)
			end
			if key == 'hbp' or key == 'hbcoeff'
			then
				entry[key] = string.format("%d%%", entry[key])
			end
			table.insert(col[key], entry[key])
		end
	end

	SpellsFrameTextSpell1:SetText( table.concat(col['spell'], "\n"))
	SpellsFrameTextRank1:SetText(table.concat(col['rank'], "\n"))
	SpellsFrameTextMana1:SetText(table.concat(col['mana'], "\n"))
	SpellsFrameTextMin1:SetText(table.concat(col['min'], "\n"))
	SpellsFrameTextMax1:SetText(table.concat(col['max'], "\n"))
	SpellsFrameTextAvg1:SetText(table.concat(col['avg'], "\n"))
	SpellsFrameTextEff1:SetText(table.concat(col['eff'], "\n"))
	SpellsFrameTextHBCoeff1:SetText(table.concat(col['hbcoeff'], "\n"))
	SpellsFrameTextHB1:SetText(table.concat(col['hb'], "\n"))
	SpellsFrameTextHBp1:SetText(table.concat(col['hbp'], "\n"))

	local fontName, fontHeight, fontFlags = SpellsFrameTextSpell1:GetFont()
	if config['fontSizeSpell'] == nil
	then
		config['fontSizeSpell'] = fontHeight
	end

	SpellsFrameTextSpell1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextRank1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextMana1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextMin1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextMax1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextAvg1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextEff1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextHBCoeff1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextHB1:SetFont(fontName, config['fontSizeSpell'])
	SpellsFrameTextHBp1:SetFont(fontName, config['fontSizeSpell'])
	-- SpellsFrameBG:SetWidth( 8 * 40 + 160 )
	-- print('W: ' .. tostring(8 * 40 + 160))
	-- print('H: ' .. tostring(SpellsFrameTextSpell1:GetHeight()))
	-- SpellsFrameBG:SetHeight(SpellsFrameTextSpell1:GetHeight()+40)
end

function sortData(data)
	table.sort( data, sortFunction )

	return data
end

function sortFunction(a, b)
	if (a[sortBy] == b[sortBy]) and (a['spell'] == b['spell'])
	then
		if sortOrder == 1
		then 
			return a['rank'] < b['rank']
		else
			return a['rank'] > b['rank']
		end
	end
	if sortOrder == 1
	then
		return a[sortBy] < b[sortBy]
	else
		return a[sortBy] > b[sortBy]
	end
end
