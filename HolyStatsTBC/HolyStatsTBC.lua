HolyStatsTBC = LibStub("AceAddon-3.0"):NewAddon("HolyStatsTBC")

-- FancySpellsFrame
ScrollingTableModule = LibStub("ScrollingTable");
FancySpellsFrame = CreateFrame("Frame", "FancySpellsFrame", UIParent)
FancySpellsFrame:SetMinResize(20, 20)
FancySpellsFrame:SetClampedToScreen(true)
FancySpellsFrame:SetSize(100, 100)
FancySpellsFrame:SetMovable(true)
FancySpellsFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 100, 100)
FancySpellsFrame:Hide()
ScrollingTable = nil
