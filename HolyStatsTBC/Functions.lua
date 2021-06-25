cache = {}
sortBy = 'eff'
sortOrder = 0
isSpellsFrame = false
pauseUpdate = true
delay = 0
local _, class = UnitClass("player");

function sortKeys(data)
    local keys = {}
    for k in pairs(data) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- Spells
function setEffSpell(spell)
    config['effSpell'] = spell
end

function getEffSpell()
    return config['effSpell']
end

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

function sortData(data)
    table.sort(data, sortFunction)

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

function fancySortFunction(a, b, direction)
    if direction == 1 then
        return a > b
    else
        return a < b
    end
end

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

    local data = healingSpells
    for spell, ranks in pairs(healingSpells[class])
    do
        for rank, obj in pairs(ranks)
        do
            local meta = obj['org']

            -- mana
            local mana = meta['Mana']
            if spell == 'Heal' or spell == 'Lesser Heal' or spell == 'Greater Heal' then
                mana = mana * (1 - 0.05 * getTalentRank('Improved Healing'))
            elseif spell == 'Prayer of Healing' or spell == 'Prayer of Mending' then
                mana = mana * (1 - 0.1 * getTalentRank('Healing Prayers'))
            elseif spell == 'Healing Touch' or spell == 'Tranquility' then
                mana = mana * (1 - 0.2 * getTalentRank('Tranquil Spirit'))
            end
            if meta['hotMin'] ~= nil and meta['hotMax'] ~= nil then
                mana = mana * (1 - stanceManaReduction)
            end
            -- Instant cast spells
            if obj['org']['instant'] ~= nil then
                mana = mana * (1 - 0.02 * getTalentRank('Mental Agility'))
            end

            -- Healing Bonus
            local bonusHealing = GetSpellBonusHealing()
            if spell == 'Greater Heal' then
                bonusHealing = bonusHealing + bonusHealing * getTalentRank('Empowered Healing') * 0.04
            elseif spell == 'Flash Heal' or spell == 'Binding Heal' then
                bonusHealing = bonusHealing + bonusHealing * getTalentRank('Empowered Healing') * 0.02
            elseif spell == 'Healing Touch' then
                bonusHealing = bonusHealing + bonusHealing * getTalentRank('Empowered Touch') * 0.1
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

            -- Level penality
            local lvlPenalty = 1
            if meta.lvl < 20 then
                lvlPenalty = 1 - ((20 - meta.lvl) * 0.0375)
            end
            -- TBC
            lvlPenalty = lvlPenalty * math.min(((meta.nextLevel - 1) + 5) / UnitLevel("player"), 1)
            coeff = coeff * lvlPenalty

            -- Min/Max
            local bonusHealingCoeff = bonusHealing * coeff
            local hotMin = meta['hotMin']
            local hotMax = meta['hotMax']
            if not hotMin then
                hotMin = 0
            end
            if not hotMax then
                hotMax = 0
            end
            if hotMax > 0 and hotMin > 0 then
                bonusHealingCoeff = bonusHealingCoeff * (1 + 0.04 * getTalentRank('Empowered Rejuvenation'))
            end
            local xMin = obj['org']['Min'] + hotMin + bonusHealingCoeff
            local xMax = obj['org']['Max'] + hotMax + bonusHealingCoeff

            -- apply +% for healing spells
            xMin = xMin * (1
                    + 0.02 * getTalentRank('Spiritual Healing')
                    + 0.04 * getTalentRank('Healing Light')
                    + 0.02 * getTalentRank('Gift of Nature'))
            xMax = xMax * (1
                    + 0.02 * getTalentRank('Spiritual Healing')
                    + 0.04 * getTalentRank('Healing Light')
                    + 0.02 * getTalentRank('Gift of Nature'))

            if spell == 'Renew' or spell == 'Rejuvenation' then
                xMin = xMin * (1
                        + 0.05 * getTalentRank('Improved Renew')
                        + 0.05 * getTalentRank('Improved Rejuvenation')
                )
                xMax = xMax * (1
                        + 0.05 * getTalentRank('Improved Renew')
                        + 0.05 * getTalentRank('Improved Rejuvenation')
                )
            end

            if stanceHealing > 0 then
                xMin = xMin + stanceHealing
                xMax = xMax + stanceHealing
            end

            local tg = nil
            if obj['org']['targets'] ~= nil then
                tg = obj['org']['targets']
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