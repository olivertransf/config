-- Simple Window Manager for Hammerspoon
-- Load required extensions
hs.spaces = require("hs.spaces")

-- Auto-reload configuration when files change
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Window Manager loaded")

-- Window Management Functions
-- Menu bar height (typically 24-30px on macOS)
local MENUBAR_HEIGHT = 25

local function moveWindow(direction)
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local fullFrame = screen:fullFrame()
    local frame = screen:frame() -- This should exclude menu bar, but we'll be explicit
    
    -- Use frame if it already excludes menu bar, otherwise use fullFrame with offset
    local usableFrame = {
        x = fullFrame.x,
        y = fullFrame.y + MENUBAR_HEIGHT,
        w = fullFrame.w,
        h = fullFrame.h - MENUBAR_HEIGHT
    }
    
    if direction == "left" then
        win:setFrame({
            x = usableFrame.x,
            y = usableFrame.y,
            w = usableFrame.w / 2,
            h = usableFrame.h
        })
    elseif direction == "right" then
        win:setFrame({
            x = usableFrame.x + usableFrame.w / 2,
            y = usableFrame.y,
            w = usableFrame.w / 2,
            h = usableFrame.h
        })
    elseif direction == "up" then
        win:setFrame({
            x = usableFrame.x,
            y = usableFrame.y,
            w = usableFrame.w,
            h = usableFrame.h / 2
        })
    elseif direction == "down" then
        win:setFrame({
            x = usableFrame.x,
            y = usableFrame.y + usableFrame.h / 2,
            w = usableFrame.w,
            h = usableFrame.h / 2
        })
    elseif direction == "maximize" then
        win:setFrame(usableFrame)
    elseif direction == "center" then
        win:centerOnScreen()
    end
end

local function moveToQuarter(quarter)
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local fullFrame = screen:fullFrame()
    
    -- Use usable frame that excludes menu bar
    local usableFrame = {
        x = fullFrame.x,
        y = fullFrame.y + MENUBAR_HEIGHT,
        w = fullFrame.w,
        h = fullFrame.h - MENUBAR_HEIGHT
    }
    
    if quarter == "topleft" then
        win:setFrame({
            x = usableFrame.x,
            y = usableFrame.y,
            w = usableFrame.w / 2,
            h = usableFrame.h / 2
        })
    elseif quarter == "topright" then
        win:setFrame({
            x = usableFrame.x + usableFrame.w / 2,
            y = usableFrame.y,
            w = usableFrame.w / 2,
            h = usableFrame.h / 2
        })
    elseif quarter == "bottomleft" then
        win:setFrame({
            x = usableFrame.x,
            y = usableFrame.y + usableFrame.h / 2,
            w = usableFrame.w / 2,
            h = usableFrame.h / 2
        })
    elseif quarter == "bottomright" then
        win:setFrame({
            x = usableFrame.x + usableFrame.w / 2,
            y = usableFrame.y + usableFrame.h / 2,
            w = usableFrame.w / 2,
            h = usableFrame.h / 2
        })
    end
end


-- Hotkey Bindings
-- Window halves
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function() moveWindow("left") end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function() moveWindow("right") end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", function() moveWindow("up") end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Down", function() moveWindow("down") end)

-- Window quarters
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Q", function() moveToQuarter("topleft") end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function() moveToQuarter("topright") end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "A", function() moveToQuarter("bottomleft") end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function() moveToQuarter("bottomright") end)

-- Maximize and center
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function() moveWindow("maximize") end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function() moveWindow("center") end)

-- Toggle through windows of current application
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", function() toggleWindowsOfCurrentApp() end)

-- Space switching: use hs.spaces.gotoSpace so spaces 3+ work (macOS often only honors Ctrl+1/Ctrl+2)
local lastSpaceSwitchAt = 0
local spaceCloseTimer = nil
local function switchToSpace(spaceNumber)
    local now = hs.timer.secondsSinceEpoch()
    if now - lastSpaceSwitchAt < 0.6 then return end
    lastSpaceSwitchAt = now
    local spaceIDs = hs.spaces.spacesForScreen()
    if not spaceIDs or not spaceIDs[spaceNumber] then return end
    if spaceCloseTimer then spaceCloseTimer:stop() end
    hs.spaces.gotoSpace(spaceIDs[spaceNumber])
    spaceCloseTimer = hs.timer.doAfter(hs.spaces.MCwaitTime + 0.2, function()
        hs.spaces.closeMissionControl()
        spaceCloseTimer = nil
    end)
end

local function nextSpace()
    -- Use Control+Right arrow to switch to next space
    hs.eventtap.keyStroke({"ctrl"}, "right")
end

local function previousSpace()
    -- Use Control+Left arrow to switch to previous space
    hs.eventtap.keyStroke({"ctrl"}, "left")
end

-- Space switching hotkeys
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Tab", function() nextSpace() end)
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "Tab", function() previousSpace() end)

-- Switch to specific spaces using Ctrl+Opt+Z/X/C/V/B/N/M,/,.
hs.hotkey.bind({"ctrl", "alt"}, "Z", function() switchToSpace(1) end)
hs.hotkey.bind({"ctrl", "alt"}, "X", function() switchToSpace(2) end)
hs.hotkey.bind({"ctrl", "alt"}, "C", function() switchToSpace(3) end)
hs.hotkey.bind({"ctrl", "alt"}, "V", function() switchToSpace(4) end)
hs.hotkey.bind({"ctrl", "alt"}, "B", function() switchToSpace(5) end)
hs.hotkey.bind({"ctrl", "alt"}, "N", function() switchToSpace(6) end)
hs.hotkey.bind({"ctrl", "alt"}, "M", function() switchToSpace(7) end)
hs.hotkey.bind({"ctrl", "alt"}, ",", function() switchToSpace(8) end)
hs.hotkey.bind({"ctrl", "alt"}, ".", function() switchToSpace(9) end)

-- Center window with padding (80% of screen size)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Space", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local fullFrame = screen:fullFrame()
    
    -- Use usable frame that excludes menu bar
    local usableFrame = {
        x = fullFrame.x,
        y = fullFrame.y + MENUBAR_HEIGHT,
        w = fullFrame.w,
        h = fullFrame.h - MENUBAR_HEIGHT
    }
    
    -- Use 80% of screen width and height
    local padding = 0.06 -- 10% padding on each side
    local newWidth = usableFrame.w * (1 - 2 * padding)
    local newHeight = usableFrame.h * (1 - 2 * padding)
    
    win:setFrame({
        x = usableFrame.x + (usableFrame.w - newWidth) / 2,
        y = usableFrame.y + (usableFrame.h - newHeight) / 2,
        w = newWidth,
        h = newHeight
    })
end)