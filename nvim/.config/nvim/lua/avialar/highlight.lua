-- Highlighting groups

local cmd = vim.cmd
local colors = require("catppuccin.palettes").get_palette()

local bg = function(group, col)
    cmd("hi " .. group .. " guibg=" .. col)
end

local fg = function(group, col)
    cmd("hi " .. group .. " guifg=" .. col)
end

local fg_bg = function(group, fgcol, bgcol)
    cmd("hi " .. group .. " guifg=" .. fgcol .. " guibg=" .. bgcol)
end

local clear = colors.surface0
local mid = colors.mantle
local dark = colors.crust

-- Telescope

fg_bg("TelescopeBorder", dark, dark)
fg_bg("TelescopePromptBorder", clear, clear)

fg_bg("TelescopePromptPrefix", colors.flamingo, clear)
fg_bg("TelescopePromptNormal", colors.text, clear)

bg("TelescopeNormal", dark)
bg("TelescopePreviewNormal", mid)
fg_bg("TelescopePreviewBorder", mid, mid)

fg_bg("TelescopePreviewTitle", dark, colors.green)
fg_bg("TelescopePromptTitle", dark, colors.peach)
fg_bg("TelescopeResultsTitle", dark, dark)

bg("TelescopeSelection", clear)

-- NeoTree

fg_bg("NeoTreeWinSeparator", mid, mid)

-- VirtColumn

fg("VirtColumn", clear)
