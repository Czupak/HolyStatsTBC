local ScrollingTableModule = LibStub("ScrollingTable");
FancySpellsFrame = CreateFrame("Frame", "FancySpellsFrame", UIParent)
FancySpellsFrame:SetMinResize(20, 20)
FancySpellsFrame:SetClampedToScreen(true)
FancySpellsFrame:SetSize(100, 100)
FancySpellsFrame:SetMovable(true)
FancySpellsFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT")
FancySpellsFrame:Hide()
ScrollingTable = nil

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

function HolyStatsTBC:OnEnable()
    FancySpellsFrame_Init()
end

function FancySpellsFrame_Init()
    local columns = {}
    for _, col in pairs(FancyColumns) do
        local colsFresh = copy(colsTmpl)
        colsFresh['name'] = col
        colsFresh["sortnext"] = _ + 1

        if col == 'spell' then
            colsFresh['width'] = 120
        end
        table.insert(columns, colsFresh)
    end
    columns[#columns]['sortnext'] = 1
    ScrollingTable = ScrollingTableModule:CreateST(columns, 12, config['ui']['spellsWindowFont'], nil, FancySpellsFrame)
    FancySpellsFrame_Update()
    ScrollingTable.frame:SetMovable(true)
    ScrollingTable:RegisterEvents({
        ["OnMouseDown"] = ScrollingTable_OnMouseDown,
        ["OnMouseUp"] = ScrollingTable_OnMouseUp
    });
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
