
-- Example code to get Zoom attendees using Accessibility API
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "z", function()
--   local zoomWindow = hs.window.find('Zoom Meeting')
--   if zoomWindow then
--     local zoomApp = zoomWindow:application()
--     local zoomAXApp = hs.axuielement.applicationElement(zoomApp)
--     local attendeesList = zoomAXApp:elementSearch({subrole = "AXOutline", role = "AXTable"})
--     if attendeesList then
--       for i, attendee in ipairs(attendeesList:children()) do
--         local name = attendee:attributeValue("AXTitle")
--         print(name)
--       end
--     end
--   end
-- end)

function printAXTree(element, level)
    level = level or 0
    local indent = string.rep("  ", level)

    if element then
        print(indent .. tostring(element))
        for k, v in pairs(element:allAttributeValues()) do
            print(indent .. "  " .. k .. ": " .. tostring(v))
        end

        local children = element:attributeValue("AXChildren")
        if children then
            for _, child in ipairs(children) do
                printAXTree(child, level + 1)
            end
        end
    end
end

function printAXTreeWithAttributes(element, level)
    level = level or 0
    local indent = string.rep("  ", level)

    if element then
        print(indent .. tostring(element))
        local attributeNames = element:attributeNames()
        for _, attributeName in ipairs(attributeNames) do
            local value = element:attributeValue(attributeName)
            print(indent .. "  " .. attributeName .. ": " .. tostring(value))
        end

        local children = element:attributeValue("AXChildren")
        if children then
            for _, child in ipairs(children) do
                printAXTreeWithAttributes(child, level + 1)
            end
        end
    end
end

function getAllNeighbors(elementsList)
    local neighbors = {}
    for i, elementWrapper in ipairs(elementsList) do
        local element = elementWrapper.element
        local parent = element:attributeValue("AXParent")
        local children = parent:attributeValue("AXChildren")
        neighbors[i] = children
    end
    return neighbors
end

function findAllElementsWithText(element, searchText, path)
    path = path or {}
    table.insert(path, tostring(element))

    local foundElements = {}

    local attributeNames = element:attributeNames()
    for _, attributeName in ipairs(attributeNames) do
        local value = element:attributeValue(attributeName)
        if value and type(value) == "string" and string.find(value, searchText) then
            print("Found element with text '" .. searchText .. "' in path:")
            print(table.concat(path, " -> "))
            table.insert(foundElements, {element = element, path = path})
            break
        end
    end

    local children = element:attributeValue("AXChildren")
    if children then
        for _, child in ipairs(children) do
            local newPath = {table.unpack(path)}
            local childFoundElements = findAllElementsWithText(child, searchText, newPath)
            for _, foundElement in ipairs(childFoundElements) do
                table.insert(foundElements, foundElement)
            end
        end
    end

    return foundElements
end


function findAllElementsWithText_unknown(element, searchText, path)
    path = path or {}
    table.insert(path, tostring(element))

    local foundElements = {}

    local title = element:attributeValue("AXTitle")
    if title and string.find(title, searchText) then
        print("Found element with text '" .. searchText .. "' in path:")
        print(table.concat(path, " -> "))
        table.insert(foundElements, {element = element, path = path})
    end

    local children = element:attributeValue("AXChildren")
    if children then
        for _, child in ipairs(children) do
            local newPath = {table.unpack(path)}
            local childFoundElements = findAllElementsWithText(child, searchText, newPath)
            for _, foundElement in ipairs(childFoundElements) do
                table.insert(foundElements, foundElement)
            end
        end
    end

    return foundElements
end

function findAllElementsWithText2(element, searchText)
    local results = {}

    if element.attributeNames and element:attributeNames():contains("AXValue") and tostring(element:attributeValue("AXValue")):find(searchText) then
        table.insert(results, element)
    end

    if element.attributeNames and element:attributeNames():contains("AXChildren") then
        for _, child in ipairs(element:attributeValue("AXChildren")) do
            for _, foundElement in ipairs(findAllElementsWithText(child, searchText)) do
                table.insert(results, foundElement)
            end
        end
    end

    return results
end

function indexOf(tbl, item)
    for key, value in ipairs(tbl) do
        if value == item then
            return key
        end
    end
    return -1
end

function findAllElementsWithText3(element, searchText, role)
    local results = {}

    local attrNames = element:attributeNames()
    if attrNames and indexOf(attrNames, "AXRole") ~= -1 and element:attributeValue("AXRole") == role and indexOf(attrNames, "AXValue") ~= -1 and tostring(element:attributeValue("AXValue")):find(searchText) then
        table.insert(results, element)
    end

    if attrNames and indexOf(attrNames, "AXChildren") ~= -1 then
        for _, child in ipairs(element:attributeValue("AXChildren")) do
            for _, foundElement in ipairs(findAllElementsWithText(child, searchText, role)) do
                table.insert(results, foundElement)
            end
        end
    end

    return results
end

function printAttributesForFoundElements(elements)
    if type(elements) ~= "table" or elements.element then
        elements = {elements}
    end

    for _, foundElementData in ipairs(elements) do
        local foundElement = foundElementData.element
        local attributeNames = foundElement:attributeNames()
        print("Attributes for element at path: " .. table.concat(foundElementData.path, " -> "))
        for _, attributeName in ipairs(attributeNames) do
            local value = foundElement:attributeValue(attributeName)
            print(attributeName, value)
        end
        print("\n")
    end
end

-- function printAttributesForFoundElements(neighborsList)
--     for i, neighbors in ipairs(neighborsList) do
--         for j, neighbor in ipairs(neighbors) do
--             print("Attributes for neighbor " .. j .. " of element " .. i .. ":")
--             local allAttributes = neighbor:allAttributeValues()
--             for attr, value in pairs(allAttributes) do
--                 print(attr, value)
--             end
--             print("\n")
--         end
--     end
-- end

function printParticipantTitles(element)
    local attributes = element:allAttributeValues()
    local role = attributes.AXRole
    local title = attributes.AXTitle

    if role == "AXStaticText" and title then
        print("Participant title: " .. title)
    end

    local children = attributes.AXChildren
    if children then
        for _, child in ipairs(children) do
            printParticipantTitles(child)
        end
    end
end


--New code from here
function findParticipantListElement(element)
    local queue = {element}

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local role = current:attributeValue("AXRole")
        local description = current:attributeValue("AXDescription")

        if role == "AXOutline" and description == "Participants list" then
            return current
        end

        local children = current:attributeValue("AXChildren")
        if children then
            for _, child in ipairs(children) do
                table.insert(queue, child)
            end
        end
    end

    return nil
end

function getParticipantTitleFromRow(row)
    local cells = row:attributeValue("AXChildren")
    for _, cell in ipairs(cells) do
        local staticTexts = cell:attributeValue("AXChildren")
        for _, staticText in ipairs(staticTexts) do
            local title = staticText:attributeValue("AXValue") -- change this line
            if title then
                return title
            end
        end
    end
    return nil
end

local printedParticipants = {} -- Create a table to store printed participant names

function logParticipantNames(participantListElement)
    hs.printf("Checking for new participants...")
    local rows = participantListElement:attributeValue("AXRows")
    for _, row in ipairs(rows) do
        local title = getParticipantTitleFromRow(row)
        if title and not printedParticipants[title] then
            print("New participant: " .. title)
            printedParticipants[title] = true
        end
    end
end


function shallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

--Couldn't get this function to work, does not report changes
function observeParticipantListChanges(participantListElement, pid)
    local observer = hs.axuielement.observer.new(pid)

    observer:callback(function(_, _, element, event)
        if event == "AXRowCountChanged" then
            logParticipantNames(participantListElement)
        end
    end)

    observer:addWatcher(participantListElement, "AXRowCountChanged")
    observer:start()
    return observer
end

--This function replaces observeParticipantListChanges
function startMonitoringParticipantList(participantListElement, interval)
    local previousRowCount = #participantListElement:attributeValue("AXRows")

    local function checkForChanges()
        local currentRowCount = #participantListElement:attributeValue("AXRows")

        if currentRowCount ~= previousRowCount then
            logParticipantNames(participantListElement)
            previousRowCount = currentRowCount
        end
    end

    local timer = hs.timer.new(interval, checkForChanges)
    timer:start()

    local function stopMonitoring()
        timer:stop()
    end

    return timer, stopMonitoring
end



-- Main code that is executed
local hs_window = require("hs.window")

local zoomWindow = hs.window.find('Zoom Meeting')
local zoomApp = zoomWindow:application()
local zoomAXApp = hs.axuielement.applicationElement(zoomApp)

if zoomWindow then
    local zoomAXWindow = hs.axuielement.windowElement(zoomWindow)
    local participantListElement = findParticipantListElement(zoomAXWindow)

    if participantListElement then
        local rows = participantListElement:attributeValue("AXRows")
        print("Printing participant titles:")
        for _, row in ipairs(rows) do
            local title = getParticipantTitleFromRow(row)
            if title then
                print("Participant title: " .. title)
                printedParticipants[title] = true
            end
        end
        _, stopMonitoring = startMonitoringParticipantList(participantListElement, 2)


    else
        print("Participants list not found.")
    end
else
    print("Zoom main window not found.")
end


--observer:stop()

-- function getAllNeighbors(element)
--     local neighbors = {}
--     local parent = element:attributeValue("AXParent")
--     if parent then
--         local siblings = parent:attributeValue("AXChildren")
--         if siblings then
--             for _, sibling in ipairs(siblings) do
--                 if sibling ~= element then
--                     table.insert(neighbors, sibling)
--                 end
--             end
--         end
--     end
--     return neighbors
-- end

-- function getAllNeighbors(elementWrapper)
--     local element = elementWrapper.element
--     local parent = element:attributeValue("AXParent")
--     local children = parent:attributeValue("AXChildren")
--     return children
-- end


-- local element = hs.axuielement.new(someElement)
-- local neighbors = getAllNeighbors(element)
-- for _, neighbor in ipairs(neighbors) do
--     print(neighbor)
-- end

-- zoomWindow = hs.window.find('Zoom')
-- zoomApp = zoomWindow:application()
-- zoomAXApp = hs.axuielement.applicationElement(zoomApp)

-- local fennel = require("fennel") -- Fixed: pass the string "fennel"

-- allow requiring of fennel modules
-- table.insert(package.loaders or package.searchers, fennel.searcher)

-- fennel.dofile("init.fnl", { allowedGlobals = false })
