-- Globals
cache = {}
sortBy = 'eff'
sortOrder = 0
isSpellsFrame = false
pauseUpdate = true
delay = 0
calcFormula = {}
local _, class = UnitClass("player");
local defaultTemplate = [[{manaPercent}% ({timeToRegen}s)

MP5: {mp5}
MP5wC: {mp5wc}
HealBonus: {healBonus}
Crit: {crit}%

ItemMP5wC: {mp5wcItem}
ItemHealBonus: {healBonusItem}]]

-- Utility
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

function sortKeys(data)
    local keys = {}
    for k in pairs(data) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

function sortData(data)
    table.sort(data, sortFunction)
    return data
end

function fancySortFunction(a, b, direction)
    if direction == 1 then
        return a > b
    else
        return a < b
    end
end

-- Calcs
function calcAdd(spell, rank, attr, source, val, change, desc)
    local colors = {
        def  = "|cFF00FF00",
        inc  = "|cFF00f1ff",
        desc = '|cFFafabff',
        reset= "|r"
    }

    if calcFormula[spell] == nil then
        calcFormula[spell] = {}
    end
    if calcFormula[spell][rank] == nil then
        calcFormula[spell][rank] = {
            min = {},
            max = {},
            mana = {},
            hb = {},
            coeff = {}
        }
    end
    local text = ''
    if source == 'Base' or change == nil then
        text = string.format("%s%s:%s %.2f", colors['def'], source, colors['reset'], val)
    else
        local sign = '+'
        if change < 0 then sign = '' end
        text = string.format("%s%s:%s %s%s%.2f %s= %.2f",
                colors['def'], source, colors['reset'], colors['inc'], sign, change, colors['reset'], val)
    end
    if desc ~= nil and desc ~= "" then
        text = string.format("%s (%s)", text, desc)
    end
    table.insert(calcFormula[spell][rank][attr], text)
end

-- Spells
function setEffSpell(spell)
    config['effSpell'] = spell
end

function getEffSpell()
    return config['effSpell']
end

function getHealingSpells()
    local spells = {}
    local i = 1
    while true do
        local spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not spellName
        then
            do
                break
            end
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
    local spellName = 'Circle of Healing'
    if isTalentSim(spellName) and spells[spellName] == nil then
        spells[spellName] = healingSpells[class][spellName]
    end

    return spells
end

function calculateSpells()
    -- Holy Specialization - spell crit %1 * 5
    -- Mental Agility - instant casts 2% * 5
    -- Improved Renew - renew 5% * 3
    -- Improved Healing - mana cost Lesser Heal, Heal, Greater Heal 5% * 3
    -- Improved Prayer of Healing - mana cost Prayer of Healing 10% * 2
    -- Spiritual Guidance - healing by 5% * 5 of Spirit [included in bonus healing]
    -- Spritual Healing - healing spells 2% * 5
    -- Empowered Healing - Greater Heal +4% * 5 hb; Flash Heal and Binding Heal +2% * 5 hb
    -- Druid:
    --  Implemented:
    --      ['Tranquil Spirit'] Reduce mana of Healing Touch / Tranquility by 2% [x1-5]
    --      ['Improved Rejuvenation'] Rejuvenation heal +5% [x1-3]
    --      ['Gift of Nature'] All healing spells +2% [x1-5]
    --      ['Empowered Touch'] Healing Touch +10% to HealBonus [x1-2]
    --      ['Empowered Rejuvenation'] HoTs HealBonus +4% [x1-5]
    --      ['Tree of Life'] Increase healing received by 25% of Spirit; Mana cost of some spells -20%
    --  Not needed:
    --      ['Naturalist'] Reduce cast time of Healing Touch by 0.1s [x1-5]
    --      ['Intensity'] 10% Mana to continue while casting [x1-3]
    local stanceHealing = 0
    local stanceManaReduction = 0
    if class == 'DRUID' and GetShapeshiftForm() == 6 then
        local base, stat, posBuff, negBuff = UnitStat("player", 5) -- Spirit
        stanceHealing = stat * 0.25
        stanceManaReduction = 0.2
    end
    calcFormula = {}
    local data = healingSpells
    for spell, ranks in pairs(healingSpells[class])
    do
        for rank, obj in pairs(ranks)
        do
            local meta = obj['org']
            -- mana
            local mana = meta['Mana']
            calcAdd(spell, rank, 'mana', 'Base', mana, 0)
            if spell == 'Heal' or spell == 'Lesser Heal' or spell == 'Greater Heal' then
                local change = mana * (0.05 * getTalentRank('Improved Healing'))
                mana = mana - change
                calcAdd(spell, rank, 'mana', 'Improved Healing', mana, -change, getTalentRank('Improved Healing') .. '*5%')
            elseif spell == 'Prayer of Healing' or spell == 'Prayer of Mending' then
                local change = mana * (0.1 * getTalentRank('Healing Prayers'))
                mana = mana - change
                calcAdd(spell, rank, 'mana', 'Healing Prayers', mana, -change,getTalentRank('Healing Prayers') .. '*10%')
            elseif spell == 'Healing Touch' or spell == 'Tranquility' then
                local change = mana * (0.2 * getTalentRank('Tranquil Spirit'))
                mana = mana - change
                calcAdd(spell, rank, 'mana', 'Tranquil Spirit', mana, -change, getTalentRank('Tranquil Spirit') .. '*5%')
            end
            if meta['hotMin'] ~= nil and meta['hotMax'] ~= nil and stanceManaReduction > 0 then
                local change = mana * stanceManaReduction
                mana = mana - change
                calcAdd(spell, rank, 'mana', 'Tree Form', mana, -change, '20%')
            end
            -- Instant cast spells
            if obj['org']['instant'] ~= nil then
                local change = mana * (0.02 * getTalentRank('Mental Agility'))
                mana = mana - change
                calcAdd(spell, rank, 'mana', 'Mental Agility', mana, -change, getTalentRank('Mental Agility') .. '*2%')
            end

            -- Healing Bonus
            local bonusHealing = GetSpellBonusHealing()
            calcAdd(spell, rank, 'hb', 'Base', bonusHealing)
            if spell == 'Greater Heal' then
                local change = bonusHealing * getTalentRank('Empowered Healing') * 0.04
                bonusHealing = bonusHealing + change
                calcAdd(spell, rank, 'hb', 'Empowered Healing', bonusHealing, change, getTalentRank('Empowered Healing') .. '*4%')
            elseif spell == 'Flash Heal' or spell == 'Binding Heal' then
                local change = bonusHealing * getTalentRank('Empowered Healing') * 0.02
                bonusHealing = bonusHealing + change
                calcAdd(spell, rank, 'hb', 'Empowered Healing', bonusHealing, change, getTalentRank('Empowered Healing') .. '*2%')
            elseif spell == 'Healing Touch' then
                local change = bonusHealing * getTalentRank('Empowered Touch') * 0.1
                bonusHealing = bonusHealing + change
                calcAdd(spell, rank, 'hb', 'Empowered Touch', bonusHealing, change, getTalentRank('Empowered Touch') .. '*10%')
            end

            -- Coefficiency
            local coeff = meta.BaseCast / 3.5
            if spell == 'Circle of Healing' then
                coeff = meta.BaseCast / 3.5 / 2
            elseif spell == 'Renew' then
                coeff = meta.BaseCast / 15
            elseif spell == 'Prayer of Healing' then
                coeff = meta.BaseCast / 3.5 / 3
            elseif spell == 'Holy Nova' then
                coeff = meta.BaseCast / 3.5 / 3 / 2
            end
            calcAdd(spell, rank, 'coeff', 'Base', coeff)

            -- Level penality
            local lvlPenalty = 1
            if meta.lvl < 20 then
                lvlPenalty = 1 - ((20 - meta.lvl) * 0.0375)
                calcAdd(spell, rank, 'coeff', '(Level penalty [<20])', lvlPenalty)
            end
            -- TBC
            local lvlPenaltyTBC = math.min(((meta.nextLevel - 1) + 5) / UnitLevel("player"), 1)
            lvlPenalty = lvlPenalty * lvlPenaltyTBC
            calcAdd(spell, rank, 'coeff', '(Level penalty [TBC])', lvlPenaltyTBC)
            --calcAdd(spell, rank, 'coeff', '(Level penalty [Total])', lvlPenalty)
            calcAdd(spell, rank, 'coeff', 'Coeff - Level penalty', coeff * lvlPenalty, (coeff * lvlPenalty) - coeff)
            coeff = coeff * lvlPenalty

            -- Min/Max
            local bonusHealingCoeff = bonusHealing * coeff
            calcAdd(spell, rank,'hb', 'coeff', bonusHealingCoeff, bonusHealingCoeff - bonusHealing, math.floor(coeff*100) .. "%")
            local hotMin = meta['hotMin']
            local hotMax = meta['hotMax']
            if not hotMin then
                hotMin = 0
            end
            if not hotMax then
                hotMax = 0
            end
            if hotMax > 0 and hotMin > 0 then
                local change = bonusHealingCoeff * 0.04 * getTalentRank('Empowered Rejuvenation')
                bonusHealingCoeff = bonusHealingCoeff + change
                if getTalentRank('Empowered Rejuvenation') > 0 then
                    calcAdd(spell, rank, 'hb', 'Empowered Rejuvenation', bonusHealingCoeff, change, getTalentRank('Empowered Rejuvenation') .. '*4%')
                end
            end
            calcAdd(spell, rank, 'min', 'Base', obj['org']['Min'] + hotMin)
            calcAdd(spell, rank, 'max', 'Base', obj['org']['Max'] + hotMax)
            local xMin = obj['org']['Min'] + hotMin + bonusHealingCoeff
            local xMax = obj['org']['Max'] + hotMax + bonusHealingCoeff
            calcAdd(spell, rank, 'min', 'Healing Bonus', xMin, bonusHealingCoeff)
            calcAdd(spell, rank, 'max', 'Healing Bonus', xMax, bonusHealingCoeff)
            -- apply +% for healing spells
            for tal, inc in pairs({['Spiritual Healing'] = 2, ['Healing Light'] = 4, ['Gift of Nature'] = 2}) do
                if getTalentRank(tal) > 0 then
                    local changeMin = xMin * inc / 100 * getTalentRank(tal)
                    local changeMax = xMax * inc / 100 * getTalentRank(tal)
                    xMin = xMin + changeMin
                    xMax = xMax + changeMax
                    calcAdd(spell, rank, 'min', tal, xMin, changeMin, getTalentRank(tal) .. '*' .. inc ..  '%')
                    calcAdd(spell, rank, 'max', tal, xMax, changeMax, getTalentRank(tal) .. '*' .. inc ..  '%')
                end
            end


            if spell == 'Renew' or spell == 'Rejuvenation' then
                for tal, inc in pairs({['Improved Renew'] = 5, ['Improved Rejuvenation'] = 5}) do
                    if getTalentRank(tal) > 0 then
                        local changeMin = xMin * inc / 100 * getTalentRank(tal)
                        local changeMax = xMax * inc / 100 * getTalentRank(tal)
                        xMin = xMin + changeMin
                        xMax = xMax + changeMax
                        calcAdd(spell, rank, 'min', tal, xMin, changeMin, getTalentRank(tal) .. '*' .. inc ..  '%')
                        calcAdd(spell, rank, 'max', tal, xMax, changeMax, getTalentRank(tal) .. '*' .. inc ..  '%')
                    end
                end
            end

            if stanceHealing > 0 then
                xMin = xMin + stanceHealing
                xMax = xMax + stanceHealing
                calcAdd(spell, rank, 'min', "Tree Form", xMin, stanceHealing,'25% * Spirit')
                calcAdd(spell, rank, 'max', "Tree Form", xMax, stanceHealing,'25% * Spirit')
            end

            local tg = nil
            if obj['org']['targets'] ~= nil then
                tg = obj['org']['targets']
                calcFormula[spell][rank]['final'] = {
                    min = xMin,
                    max = xMax
                }
            end
            data[class][spell][rank] = {
                ['Min'] = xMin,
                ['Max'] = xMax,
                ['Mana'] = mana,
                ['Cast'] = obj['org']['Cast'],
                ['BaseCast'] = obj['org']['BaseCast'],
                ['lvl'] = obj['org']['lvl'],
                ['targets'] = tg,
                ['org'] = obj['org'],
                ['direct'] = obj['org']['direct'],
                ['coeff'] = coeff,
                ['hb'] = bonusHealingCoeff
            }
        end
    end

    healingSpells = data
end

function getSpells(spells)
    local data = {}
    cache['maxeff'] = 0
    for _, spell in pairs(sortKeys(spells))
    do
        for _, rank in pairs(sortKeys(spells[spell]))
        do
            if config['effSpell'] ~= nil and config['effSpell'] == spell .. ' (' .. rank .. ')'
            then
                -- FIXME
                local meta = spells[spell][rank]
                cache['maxeff'] = (meta.Min + meta.Max) / 2 / meta.Mana
            end

            if not isSpellIgnored(spell, rank)
            then
                local meta = spells[spell][rank]
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
                    if meta.targets ~= nil
                    then
                        targets = ' (x' .. tostring(tarNum) .. ')'
                    end

                    local avg = (cMin + cMax) / 2
                    local eff = avg / meta.Mana
                    local healingBonusPercentOfTotal = (meta['hb']) * 100 / avg

                    local entry = {
                        ['spell'] = spell .. targets,
                        ['rank'] = rank,
                        ['mana'] = math.ceil(meta.Mana),
                        ['min'] = cMin,
                        ['max'] = cMax,
                        ['avg'] = avg,
                        ['eff'] = eff,
                        ['hbcoeff'] = meta['coeff'] * 100,
                        ['hb'] = meta['hb'],
                        ['hbp'] = healingBonusPercentOfTotal,
                        ['mark'] = '',
                        ['direct'] = spells[spell][rank]['direct']
                    }
                    table.insert(data, entry)
                    if config['effSpell'] ~= nil and config['effSpell'] == spell .. ' (' .. rank .. ')' then
                        cache['maxeff'] = eff
                    end
                end
            end
        end
    end
    data = markSpells(data)
    if sortBy ~= nil
    then
        data = sortData(data)
    end
    return data
end

-- Spells: Spell Ignore
function isSpellIgnored(spell, rank)
    if myIgnoredSpells[spell] == nil then
        myIgnoredSpells[spell] = {}
    end
    if myIgnoredSpells[spell][rank] == nil then
        return false
    else
        return myIgnoredSpells[spell][rank]
    end
end

function toggleSpellIgnore(spell, rank)
    if myIgnoredSpells[spell] == nil then
        myIgnoredSpells[spell] = {}
    end
    if isSpellIgnored(spell, rank) then
        myIgnoredSpells[spell][rank] = false
    else
        myIgnoredSpells[spell][rank] = true
    end
end

-- Spells: Spell Marks
function getSpellMarks()
    return config['spellMarks']
end

function markSpells(data)
    marks = getSpellMarks()
    for idx, _ in pairs(marks) do
        marks[idx]['diff'] = 999999999999
        marks[idx]['idx'] = -1
    end
    for idxMarks, _ in pairs(marks) do
        for idxData, entry in pairs(data) do
            local isUsed = false
            for idxTmp, _ in pairs(marks) do
                if marks[idxTmp]['idx'] == idxData then
                    isUsed = true
                end
            end
            if entry['direct'] ~= nil and not isUsed then
                if marks[idxMarks]['diff'] > math.abs(marks[idxMarks]['avg'] - entry['avg']) then
                    marks[idxMarks]['diff'] = math.abs(marks[idxMarks]['avg'] - entry['avg'])
                    marks[idxMarks]['idx'] = idxData
                end
            end
        end
    end

    for idx, _ in pairs(marks) do
        if marks[idx]['idx'] > -1 and data[marks[idx]['idx']]['mark'] == "" then
            data[marks[idx]['idx']]['mark'] = marks[idx]['name']
        end
    end
    return data
end

-- Talents
function getClassTalents()
    local talents = {
        ['PRIEST'] = {
            ['Spiritual Healing'] = { 2, 16, 5 },
            ['Improved Healing'] = { 2, 10, 3 },
            ['Improved Renew'] = { 2, 2, 3 },
            ['Mental Agility'] = { 1, 11, 5 },
            ['Holy Specialization'] = { 2, 3, 5 },
            ['Meditation'] = { 1, 9, 3 },
            ['Healing Prayers'] = { 2, 12, 2 },
            ['Divine Fury'] = { 2, 5, 5 },
            ['Empowered Healing'] = { 2, 20, 5 },
            ['Circle of Healing'] = { 2, 21, 1 }
        },
        ['PALADIN'] = {
            ['Healing Light'] = { 1, 5, 3 },
            ['Illumination'] = { 1, 9, 5 },
            ['Holy Power'] = { 1, 15, 5 }
        },
        ['DRUID'] = {
            ['Naturalist'] = { 3, 3, 5 },
            ['Intensity'] = { 3, 6, 3 },
            ['Tranquil Spirit'] = { 3, 9, 5 },
            ['Improved Rejuvenation'] = { 3, 10, 3 },
            ['Gift of Nature'] = { 3, 12, 5 },
            ['Empowered Touch'] = { 3, 14, 2 },
            ['Empowered Rejuvenation'] = { 3, 19, 5 },
            ['Tree of Life'] = { 3, 20, 1 }
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

        local name, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(talents[talent][1], talents[talent][2])
        if en(name) == talent and currentRank > 0
        then
            return currentRank
        end
    end

    return 0
end

-- Talents: Talent Sim
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

-- Get Summary
function HolyStats_getRegenMp()
    local meditation = { 0, 0.05, 0.10, 0.15 }
    return meditation[getTalentRank('Meditation') + 1]
end

function getSummaryData()
    local base, casting = GetManaRegen()
    local delay, regen = "", 0
    if math.floor(base) > 0
    then
        regen = base
    else
        delay = "+5s"
    end
    casting = HolyStats_getRegenMp() * regen
    local bonusHealing = GetSpellBonusHealing()
    local maxmana = UnitPowerMax("player", 0)
    local mana = UnitPower("player", 0);
    local full = maxmana / regen
    local fullin = (maxmana - mana) / regen
    local percent = 100 * mana / maxmana
    if not percent or percent > 100 then
        percent = 0
    end
    local typePerClass = {
        ['PRIEST'] = 2, -- Holy
        ['PALADIN'] = 2,-- Holy
        ['DRUID'] = 4   -- Nature
    }
    if typePerClass[class] == nil then
        class = 'PRIEST'
    end
    local critBonus = 0
    for _, tal in pairs({'Holy Specialization', 'Natural Perfection'}) do
        if isTalentSim(tal) then
            critBonus = critBonus + getTalentRank(tal)
        end
    end
    local crit = GetSpellCritChance(typePerClass[class]) + critBonus
    local itemBonus = 0
    local itemRegen = 0
    for invSlot = 1, 18 do
        local itemLink = GetInventoryItemLink("player", invSlot);
        if itemLink ~= nil
        then
            local stats = GetItemStats(itemLink)
            if stats ~= nil
            then
                for k, v in pairs(stats)
                do
                    if k == "ITEM_MOD_SPELL_POWER_SHORT" or k == "ITEM_MOD_SPELL_HEALING_DONE_SHORT"
                    then
                        itemBonus = itemBonus + v + 1
                    elseif k == "ITEM_MOD_POWER_REGEN0_SHORT"
                    then
                        itemRegen = itemRegen + v + 1
                        --elseif k == "ITEM_MOD_CRIT_SPELL_RATING_SHORT"
                        --then
                        --    -- FIXME
                        --    crit = crit + v + 1
                    end
                end
            end
        end
    end
    local data = {
        ['manaPercent'] = string.format("%d", percent),
        ['timeToRegen'] = string.format("%d", fullin),
        ['mp5'] = string.format("%.1f", regen * 5),
        ['mp5wc'] = string.format("%.1f", itemRegen + casting * 5),
        ['healBonus'] = string.format("%d", bonusHealing),
        ['crit'] = string.format("%.2f", crit),
        ['mp5wcItem'] = string.format("%.1f", itemRegen),
        ['healBonusItem'] = string.format("%d", itemBonus)
    }
    return data
end

-- Options
function resetPosition()
    HolyStatsFrame:SetSize(150, 180)
    HolyStatsFrame:ClearAllPoints()
    HolyStatsFrame:SetPoint("TOPLEFT", "UIParent", "CENTER", -50, 50)
    FancySpellsFrame:ClearAllPoints()
    FancySpellsFrame:SetPoint("TOPLEFT", "UIParent", "CENTER", -50, 50)
    SpellsFrameConfig:ClearAllPoints()
    SpellsFrameConfig:SetPoint("TOPLEFT", "UIParent", "CENTER", -50, 50)
end

function openOptions()
    InterfaceOptionsFrame_OpenToCategory("HolyStatsTBC")
    InterfaceOptionsFrame_OpenToCategory("HolyStatsTBC")
end

-- Templates
function getTemplate(name)
    return config['ui']['mainWindowTemplate']
end

function setTemplate(name, tmpl)
    config['ui']['mainWindowTemplate'] = tmpl
end

function getTemplateMap()
    local templateMap = {
        ['mp5'] = "Mana per 5s",
        ['manaPercent'] = "Mana Percent",
        ['timeToRegen'] = 'Time to full mana regen',
        ['mp5wc'] = "Mana per 5s, while casting",
        ['healBonus'] = 'Heal Bonus',
        ['crit'] = 'Critical spell chance',
        ['mp5wcItem'] = 'Item MP5',
        ['healBonusItem'] = 'Item Heal Bonus'
    }
    return templateMap
end

function getTemplateTranslate(name)
    local tmpl = getTemplate(name)
    local summary = getSummaryData()
    for key, _ in pairs(getTemplateMap()) do
        tmpl = tmpl:gsub(string.format("{%s}",key), summary[key])
    end
    return tmpl
end

function getTemplateUsage(name)
    local usage = {""}
    for key, desc in pairs(getTemplateMap()) do
        table.insert(usage, string.format("%s{%s}|r: %s%s", "|cFF00f1ff", key, "|cFF00FF00", desc))
    end
    return table.concat(usage, "\n")
end

function resetTemplate()
    config['ui']['mainWindowTemplate'] = defaultTemplate
end

-- HolyStatsTBC Events
function HolyStatsTBC:OnEnable()
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

    for i, key in pairs({ 'mainWindowFont', 'mainWindowAlpha', 'spellsWindowFont', 'mainWindowBGColor',
                          'mainWindowFontColor', 'mainWindowTemplate', 'spellsWindowColWidthMP' }) do
        if config['ui'][key] == nil
        then
            if key == 'mainWindowAlpha' then config['ui'][key] = 100
            elseif key == 'mainWindowBGColor' then config['ui'][key] = { 0.2, 0.2, 0.2, 1.0 }
            elseif key == 'mainWindowFontColor' then config['ui'][key] = { 1, 1, 1, 1 }
            elseif key == 'mainWindowTemplate' then config['ui'][key] = defaultTemplate
            elseif key == 'spellsWindowColWidthMP' then config['ui'][key] = 1
            else
                config['ui'][key] = 12
            end
        end
    end
    if config['spellMarks'] == nil then
        config['spellMarks'] = {}
        for i = 1, 5, 1 do
            table.insert(config['spellMarks'], { name = '', avg = 99999999 })
        end
    end
    pauseUpdate = false
    HolyStats_OnLoad(HolyStats)
    FancySpellsFrame_Init()
    SpellsFrameConfig_OnLoad(SpellsFrameConfig)
    HolyStatsFrame:SetScript("OnUpdate", HolyStats_OnUpdate)
    setupOptions()
end

function HolyStats_OnLoad(self)
    bgColor = config['ui']['mainWindowBGColor']
    HolyStatsBG:SetVertexColor(bgColor[1], bgColor[2], bgColor[3], config['ui']['mainWindowAlpha'])
    HolyStatsFrame:SetMinResize(20, 20)
    HolyStatsFrame:SetClampedToScreen(true)

    local buttons = {
        {
            name = "Toggle Spells Frame",
            texture = "Interface\\ICONS\\Spell_Holy_Heal",
            func = toggleSpellsFrame,
            pos = {
                -0, -1
            },
            text = ''
        }, {
            name = "Toggle Spells Frame Config",
            texture = "Interface\\SPELLBOOK\\Spellbook-Icon",
            func = toggleSpellsFrameConfig,
            pos = {
                -0, -16
            },
            text = ''
        }, {
            name = "Open Options",
            texture = "Interface\\Buttons\\UI-OptionsButton",
            func = openOptions,
            pos = {
                -0, -31
            },
            text = ''
        }
    }
    for _, button in pairs(buttons) do
        local btnObj = CreateFrame("Button", nil, HolyStatsFrame)
        btnObj:SetNormalTexture(button['texture'])
        btnObj:SetPoint("TOPLEFT", button['pos'][1], button['pos'][2])
        btnObj:SetScript("OnClick", button['func'])
        btnObj:SetText(button['text'])
        btnObj:SetWidth(15)
        btnObj:SetHeight(15)
    end

    delay = 0
end

function HolyStats_OnUpdate(self, elapsed)
    if not delay
    then
        delay = 0
    end
    delay = elapsed + delay
    if (delay > 1)
    then
        delay = 0
        HolyStats_update()
        if isSpellsFrame
        then
            FancySpellsFrame_Update()
        end
    end
end


function HolyStats_update()
    if pauseUpdate
    then
        return
    end
    HolyStatsText:SetText(getTemplateTranslate('MainWindow'))
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
end

function hideSpellsFrame()
    isSpellsFrame = false
    FancySpellsFrame:Hide()
end


-- Fancy Spells Frame
local FancyColumns = { 'spell', 'rank', 'mark', 'min', 'max', 'avg', 'mana', 'eff', 'hbcoeff', 'hb', 'hbp' }
local colsTmpl = {
    ["width"] = 50,
    ["align"] = "CENTER",
    ["color"] = {
        ["r"] = 1.0,
        ["g"] = 0.3,
        ["b"] = 0.4,
        ["a"] = 1.0
    },
    ["colorargs"] = nil,
    ["bgcolor"] = {
        ["r"] = 0.0,
        ["g"] = 0.13,
        ["b"] = 0.20,
        ["a"] = 1.0
    },
    ["defaultsort"] = "dsc",
    ["DoCellUpdate"] = nil,
}

function copy(t)
    local target = {}
    for k, v in pairs(t) do
        if type(t[k]) == 'table' then
            target[k] = copy(t[k])
        else
            target[k] = v
        end
    end
    return target
end

function fillInFancySpellsFrame(fancyData)
    ScrollingTable:SetData(fancyData)
end

function prepareFancySpellsData()
    calculateSpells()
    local spells = getHealingSpells()
    local data = getSpells(spells)
    local scrollData = {}
    for _, entry in pairs(data)
    do
        local scrollRow = {
            ["cols"] = {},
            ["DoCellUpdate"] = nil,
        }
        for _, key in pairs(FancyColumns) do
            if key == 'eff' then
                entry[key] = entry[key] * 1000 / cache['maxeff']
                entry[key] = math.floor(entry[key] + 0.5)
                entry[key] = entry[key] / 10
            elseif key == 'avg' or key == 'hb' or key == 'min' or key == 'max' or key == 'hbcoeff' or key == 'hbp' then
                entry[key] = math.floor(entry[key] + 0.5)
            elseif key == 'hbp' or key == 'hbcoeff' then
                entry[key] = string.format("%d%%", entry[key])
            end
            local newRow = {
                ["value"] = entry[key],
                ["color"] = getCellColor(entry, key),
                ["DoCellUpdate"] = nil,
            }
            table.insert(scrollRow["cols"], newRow)
        end
        table.insert(scrollData, scrollRow)
    end
    return scrollData
end

function getCellColor(entry, key)
    local colors = {
        _default = {
            ["r"] = 1.0,
            ["g"] = 0.9,
            ["b"] = 0.5,
            ["a"] = 1.0
        },
        _marked = {
            ["r"] = 0.86,
            ["g"] = 0.41,
            ["b"] = 0.27,
            ["a"] = 1.0
        },
        spell = {
            ["r"] = 0.9,
            ["g"] = 0.9,
            ["b"] = 0.9,
            ["a"] = 1.0
        },
        rank = {
            ["r"] = 1.0,
            ["g"] = 1.0,
            ["b"] = 1.0,
            ["a"] = 1.0
        },
        mark = {
            ["r"] = 0.86,
            ["g"] = 0.41,
            ["b"] = 0.27,
            ["a"] = 1.0
        },
        min = {
            ["r"] = 1.0,
            ["g"] = 0.8,
            ["b"] = 0.2,
            ["a"] = 1.0
        },
        max = {
            ["r"] = 1.0,
            ["g"] = 0.8,
            ["b"] = 0.2,
            ["a"] = 1.0
        },
        mana = {
            ["r"] = 0.0,
            ["g"] = 0.9,
            ["b"] = 0.9,
            ["a"] = 1.0
        },
        avg = {
            ["r"] = 0.6,
            ["g"] = 1.0,
            ["b"] = 0.5,
            ["a"] = 1.0
        },
        eff = {
            ["r"] = 0.1,
            ["g"] = 0.8,
            ["b"] = 0.0,
            ["a"] = 1.0
        },
        hbcoeff = {
            ["r"] = 1.0,
            ["g"] = 0.9,
            ["b"] = 0.5,
            ["a"] = 1.0
        },
        hb = {
            ["r"] = 1.0,
            ["g"] = 0.9,
            ["b"] = 0.5,
            ["a"] = 1.0
        },
        hbp = {
            ["r"] = 1.0,
            ["g"] = 0.9,
            ["b"] = 0.5,
            ["a"] = 1.0
        },
    }
    local marked = entry['mark']
    if marked ~= "" then
        return colors['_marked']
    end
    if colors[key] ~= nil then
        return colors[key]
    else
        return colors['default']
    end
end

function FancySpellsFrame_Init()
    if not FancySpellsFrame then
        print('Not ready')
        return
    end
    local columns = {}
    for _, col in pairs(FancyColumns) do
        local colsFresh = copy(colsTmpl)
        colsFresh['name'] = col
        colsFresh["sortnext"] = _ + 1

        if col == 'spell' then
            colsFresh['width'] = 120 *  getColWidthMP()
        else
            colsFresh['width'] = colsFresh['width'] *  getColWidthMP()
        end
        if col == 'min' or col == 'max' or col == 'mana' or col == 'hbcoeff' or col == 'hb' then
            colsFresh["bgcolor"] = {
                ["r"] = 0.0,
                ["g"] = 0.11,
                ["b"] = 0.20,
                ["a"] = 1.0
            }
        end
        table.insert(columns, colsFresh)
    end
    columns[#columns]['sortnext'] = 1
    ScrollingTable = ScrollingTableModule:CreateST(columns, 12, config['ui']['spellsWindowFont'], nil, FancySpellsFrame)
    FancySpellsFrame_Update()
    ScrollingTable:RegisterEvents({
        ["OnClick"] = showTooltip
    });
    ScrollingTable.frame:SetMovable(true)
    ScrollingTable:RegisterEvents({
        ["OnMouseDown"] = ScrollingTable_OnMouseDown,
        ["OnMouseUp"] = ScrollingTable_OnMouseUp
    });
end

function getColWidthMP()
    return config['ui']['spellsWindowColWidthMP']
end

function setColWidthMP(val)
    config['ui']['spellsWindowColWidthMP'] = val
end

function ScrollingTable_OnMouseDown(self, button)
    pauseUpdate = true
    FancySpellsFrame:StartMoving()
end

function ScrollingTable_OnMouseUp(self, button)
    FancySpellsFrame:StopMovingOrSizing()
    pauseUpdate = false
end

function FancySpellsFrame_Update()
    local fancyData = prepareFancySpellsData()
    fillInFancySpellsFrame(fancyData)
end

function showTooltip(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
    local columnMap = { 'spell', 'rank', 'mark', 'min', 'max', 'avg', 'mana', 'eff', 'hbcoeff', 'hb', 'hbp' }
    if row ~= nil or realrow ~= nil then
        local celldata = data[realrow].cols[column].value;
        local spell = data[realrow].cols[1].value
        local rank = data[realrow].cols[2].value
        local tooltip = nil
        if column == 4 or column == 5 or column == 7 or column == 9 or column == 10 then
            tooltip = prepareHealingTooltip(spell, rank, columnMap[column])
            GameTooltip:ClearLines();
            GameTooltip:SetOwner(cellFrame, "ANCHOR_BOTTOM");
            for _, tt in pairs(tooltip) do
                GameTooltip:AddLine(tt);
            end
            GameTooltip:Show();
            return true
        end
    end
end

function prepareHealingTooltip(spell, rank, attr)
    local columnMap = { min = 'min', max = 'max', mana = 'mana', hbcoeff = 'coeff', hb = 'hb' }
    local tt = {}
    local _, class = UnitClass("player");
    local targets = spell:match(' %(x(%d)%)')
    spell = spell:gsub(' %(x%d%)', '')
    if calcFormula[spell] ~= nil and calcFormula[spell][rank] ~= nil and calcFormula[spell][rank][columnMap[attr]] ~= nil then
        if healingSpells[class][spell][rank]['targets'] ~= nil and (attr == 'min' or attr == 'max') and targets then
            local finalAttr = calcFormula[spell][rank]['final'][attr]
            calcAdd(spell, rank, attr, 'Targets x' .. targets, finalAttr * targets, finalAttr * (targets - 1))
        end
        tt = calcFormula[spell][rank][columnMap[attr]]
    else
        table.insert(tt, 'No calc')
    end
    return tt
end
