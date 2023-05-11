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
