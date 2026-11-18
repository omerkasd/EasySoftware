# LinoriaLib Fork

A fork of [LinoriaLib](https://github.com/violin-suzutsuki/LinoriaLib), a Roblox UI library.

Based on the maintained fork by [mstudio45](https://github.com/mstudio45/LinoriaLib).
Original library by violin-suzutsuki, inspired by Splix (matas3535), BBot and others.

Licensed under MIT — see [LICENSE](LICENSE).

## What this fork adds

**Font selector** — the menu font can be changed at runtime from the Themes groupbox.
Fifteen fonts are available and the choice is saved with custom themes.

**Menu transparency** — a 0–90% slider that makes the window body, tab container and
groupboxes see-through. Text and outlines stay opaque so the menu stays readable.

**Search box** — an input in the title bar. Typing filters toggles, sliders, dropdowns
and buttons across every tab; groupboxes with no match are hidden. Clearing the box
restores everything, including elements you had hidden yourself.

## Setup

```lua
local repo = "https://raw.githubusercontent.com/USERNAME/REPO/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "My Menu",
    Center = true,
    AutoShow = true,
    Resizable = true,  -- drag the bottom-right corner to resize
    Searchable = true, -- title bar search box (default: true)
})
```

Add the settings UI to a tab to get the font dropdown and transparency slider:

```lua
local SettingsTab = Window:AddTab("Settings")

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyToTab(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)
```

## API

```lua
Library:SetFont("Gotham")          -- font name or an Enum.Font value
Library:SetTransparency(0.4)       -- 0 = opaque, 1 = invisible
Window:ApplySearch("aimbot")       -- filter programmatically
Window:ClearSearch()               -- clear the box and restore everything
```

`Library.DragBlockers` holds frames that must never start a window drag. Insert your own
frame into it if you add controls to the title bar.

## Before you publish

Change `BaseURL` near the top of `Library.lua` to point at your own repository:

```lua
local BaseURL = "https://raw.githubusercontent.com/USERNAME/REPO/refs/heads/main/"
```

It is used to download the cursor, dropdown arrow and colour picker images from
`assets/`. Left unchanged, your fork depends on someone else's repository staying up.

## Known limits

Changing the font does not re-measure text that was sized when the menu was built.
Tab buttons are recalculated, but tooltip and some label widths can be slightly off
with proportional fonts. `Code` and `RobotoMono` are unaffected.

Transparency stacks across layers (window, container, groupbox), so the slider value
is not a linear measure of how see-through the menu looks.

## Credits

- violin-suzutsuki — original LinoriaLib
- matas3535 — Splix, the original inspiration
- mstudio45 — maintained fork, menu resizing, extended functionality
- Stefanuk, RectangularObject — extended functionality and bug fixes
