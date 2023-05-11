function printElement(element, indent)
    indent = indent or 0
    local indentString = string.rep(" ", indent * 4)

    local title = element:attributeValue("AXTitle")
    local role = element:attributeValue("AXRole")
    print(indentString .. tostring(element) .. " (Role: " .. tostring(role) .. ", Title: " .. tostring(title) .. ")")

    local children = element:attributeValue("AXChildren")
    if children then
        for _, child in ipairs(children) do
            printElement(child, indent + 1)
        end
    end
end

print("Printing Zoom AXUI hierarchy:")
printElement(zoomAXApp)


function printElement(element, indent)
    indent = indent or 0
    local indentString = string.rep(" ", indent * 4)

    local title = element:attributeValue("AXTitle")
    local role = element:attributeValue("AXRole")
    print(indentString .. tostring(element) .. " (Role: " .. tostring(role) .. ", Title: " .. tostring(title) .. ")")

    local children = element:attributeValue("AXChildren")
    if children then
        for _, child in ipairs(children) do
            printElement(child, indent + 1)
        end
    end
end

if zoomWindow then
    local zoomAXWindow = hs.axuielement.windowElement(zoomWindow)
    print("Printing Zoom main window AXUI hierarchy:")
    printElement(zoomAXWindow)
else
    print("Zoom main window not found.")
end

-- 2023-05-09 15:57:12: Printing Zoom main window AXUI hierarchy:
-- 2023-05-09 15:57:12: hs.axuielement: AXWindow (0x600000465c78) (Role: AXWindow, Title: Zoom Meeting)
-- 2023-05-09 15:57:12:     hs.axuielement: AXTabGroup (0x6000004063b8) (Role: AXTabGroup, Title: nil)
-- 2023-05-09 15:57:12:         hs.axuielement: AXTabGroup (0x600000425778) (Role: AXTabGroup, Title: nil)
-- 2023-05-09 15:57:12:         hs.axuielement: AXTabGroup (0x600000427e78) (Role: AXTabGroup, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXScrollArea (0x600000405478) (Role: AXScrollArea, Title: nil)
-- 2023-05-09 15:57:12:         hs.axuielement: AXOutline (0x600000419cf8) (Role: AXOutline, Title: nil)
-- 2023-05-09 15:57:12:             hs.axuielement: AXRow (0x60000041af78) (Role: AXRow, Title: nil)
-- 2023-05-09 15:57:12:                 hs.axuielement: AXCell (0x60000041b3f8) (Role: AXCell, Title: nil)
-- 2023-05-09 15:57:12:                     hs.axuielement: AXStaticText (0x6000004001b8) (Role: AXStaticText, Title: nil)
-- 2023-05-09 15:57:12:                     hs.axuielement: AXImage (0x6000004011b8) (Role: AXImage, Title: )
-- 2023-05-09 15:57:12:                     hs.axuielement: AXImage (0x600000400cf8) (Role: AXImage, Title: )
-- 2023-05-09 15:57:12:                     hs.axuielement: AXImage (0x600000400b78) (Role: AXImage, Title: )
-- 2023-05-09 15:57:12:             hs.axuielement: AXRow (0x600000419d78) (Role: AXRow, Title: nil)
-- 2023-05-09 15:57:12:                 hs.axuielement: AXCell (0x600000402b78) (Role: AXCell, Title: nil)
-- 2023-05-09 15:57:12:                     hs.axuielement: AXStaticText (0x600000465a38) (Role: AXStaticText, Title: nil)
-- 2023-05-09 15:57:12:                     hs.axuielement: AXImage (0x600000464638) (Role: AXImage, Title: )
-- 2023-05-09 15:57:12:                     hs.axuielement: AXImage (0x600000467178) (Role: AXImage, Title: )
-- 2023-05-09 15:57:12:                     hs.axuielement: AXImage (0x600000467778) (Role: AXImage, Title: )
-- 2023-05-09 15:57:12:             hs.axuielement: AXColumn (0x600000419438) (Role: AXColumn, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXButton (0x600000407e78) (Role: AXButton, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXButton (0x6000004044f8) (Role: AXButton, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXButton (0x600000405cf8) (Role: AXButton, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXUnknown (0x600000407338) (Role: AXUnknown, Title: nil)
-- 2023-05-09 15:57:12:         hs.axuielement: AXButton (0x600000465938) (Role: AXButton, Title: nil)
-- 2023-05-09 15:57:12:         hs.axuielement: AXStaticText (0x6000004679b8) (Role: AXStaticText, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXSplitter (0x600000405578) (Role: AXSplitter, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXButton (0x6000004073f8) (Role: AXButton, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXButton (0x6000004077b8) (Role: AXButton, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXButton (0x600000404e38) (Role: AXButton, Title: nil)
-- 2023-05-09 15:57:12:     hs.axuielement: AXStaticText (0x600000405f38) (Role: AXStaticText, Title: nil)


zoomApp = nil
zoomWindow = nil

for _, app in ipairs(hs.application.runningApplications()) do
    if app:name():find("zoom.us") then
        zoomApp = app
        break
    end
end

if zoomApp then
    print("Zoom app found: " .. zoomApp:name())
    local windows = zoomApp:allWindows()
    for _, window in ipairs(windows) do
        if window:title() == "Zoom Meeting" then
            zoomWindow = window
            break
        end
    end

    if zoomWindow then
        print("Zoom main window found: " .. zoomWindow:title())
    else
        print("Zoom main window not found.")
    end
else
    print("Zoom app not found.")
end
