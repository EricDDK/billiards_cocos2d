
-- Author Ding

local AGamePhysicalBase = class("AGamePhysicalBase",cc.load("mvc").ViewBase)



function AGamePhysicalBase:registerTouchHandler()
    local function eventHandler(eventType)
        if eventType == "enter" then
            self:onEnter()
        elseif eventType == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(eventHandler)
end

function AGamePhysicalBase:onEnter()
    
end

function AGamePhysicalBase:onExit()
    
end

return AGamePhysicalBase