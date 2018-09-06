--
local LayerWidgetBase = require("hallcenter.controllers.LayerWidgetBase")
local EightBallGameOverLayer = class("EightBallGameOverLayer", LayerWidgetBase)

-- @isFinal 是否是总决赛
function EightBallGameOverLayer:ctor(event,isFinal)
    self:registerTouchHandler()
    self:initView(event,isFinal)
end

function EightBallGameOverLayer:initView(event,isFinal)
--    event = { }
--    event.WinUserID = 2486410
--    event.WinScore = 3000
    self:setName("GameOverLayer")
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    if layer then
        self:addChild(layer)
    end
    self.node = cc.CSLoader:createNode("gameBilliards/csb/EightBallGameOverLayer.csb")
    if self.node then
        tool.playLayerAni(self.node)
        self:addChild(self.node)

        local function btnCallback(sender, eventType)
            self:btnCallback(sender, eventType)
        end

        self.player1 = self.node:getChildByName("Panel_Player_1")
        self.player2 = self.node:getChildByName("Panel_Player_2")

        self.btn_BackHall = self.node:getChildByName("Button_BackHall")
        self.btn_Again = self.node:getChildByName("Button_Again")
        self.btn_BackGM = self.node:getChildByName("Button_Back_GM")
        self.btn_BackHall:addTouchEventListener(btnCallback)
        self.btn_Again:addTouchEventListener(btnCallback)
        if self.btn_BackGM then
            self.btn_BackGM:setVisible(false)
            self.btn_BackGM:addTouchEventListener(btnCallback)
        end
        if isFinal then
            self.btn_BackHall:setVisible(false)
            self.btn_Again:setVisible(false)
            if player:getIsGM() then
                self.btn_BackGM:setVisible(true)
            end
        end
    end
    self:initGameInfo(event)
    self:initGameOverAni(event)
end

function EightBallGameOverLayer:initGameInfo(event)
    local deskPlayerList = dmgr:getDeskPlayerInfoList()
    --dump(deskPlayerList)
    local opponent = {
        { head = 0, nickName = "default" },
        { head = 0, nickName = "default" }
    }
    if #deskPlayerList > 1 then
        for i = 1, 2 do
            for j=1,#deskPlayerList do
                if deskPlayerList[j].SeatID == i-1 then
                    opponent[i].head = deskPlayerList[j].User.UserInfo.Head
                    opponent[i].nickName = deskPlayerList[j].User.UserInfo.NickName
                end
            end
        end
    end

    local mySeatID = player:getMySeatID()
    local pos1 = mySeatID == 0 and 1 or 2
    local pos2 = pos1 == 1 and 2 or 1
    if event then
        local index
        if player:getIsGM() then
            index = event.WinSeatID == player:getMySeatID() and 1 or 2
        else
            index = event.WinUserID == player:getPlayerUserID() and 1 or 2
        end
        local playerWin = self.node:getChildByName("Panel_Player_" .. index)
        local playerLose = self.node:getChildByName("Panel_Player_" ..(index == 1 and 2 or 1))
        self.player1:getChildByName("Head"):loadTexture(tool.getHeadImgById(opponent[pos1].head, true), UI_TEX_TYPE_LOCAL)
        self.player2:getChildByName("Head"):loadTexture(tool.getHeadImgById(opponent[pos2].head, true), UI_TEX_TYPE_LOCAL)
        self.player1:getChildByName("NickName"):setString(tostring(opponent[pos1].nickName))
        self.player2:getChildByName("NickName"):setString(tostring(opponent[pos2].nickName))
        if player:getIsGM() then
            index = event.WinSeatID == player:getMySeatID() and 1 or 2
        else
            index = event.WinUserID == player:getPlayerUserID() and 1 or 2
        end
        playerWin:getChildByName("Winner"):setVisible(true)
        playerLose:getChildByName("Winner"):setVisible(false)
        if event.WinScore == 2 then
            playerWin:getChildByName("WinScore"):setString("+" .. g_EightBallData.auditionWinScore)
            playerLose:getChildByName("WinScore"):setString(g_EightBallData.auditionLoseScore)
        else
            playerWin:getChildByName("WinScore"):setString("+" .. event.WinScore)
            playerLose:getChildByName("WinScore"):setString("-" .. event.WinScore) 
        end
    end
end

function EightBallGameOverLayer:initGameOverAni(event)
    BilliardsAniMgr:setGameOverAni((event.WinUserID == player:getPlayerUserID() and true or false), self.node)
end

-- 返回大厅
function EightBallGameOverLayer:goBackHall()
    EBGameControl:setGameState(g_EightBallData.gameState.none)
    EBGameControl:leaveGame()
end

-- 再来一局
function EightBallGameOverLayer:playAgain()
    if not player:getIsGM() then
        EBGameControl:setGameState(g_EightBallData.gameState.practise)
        local _key = G_PlayerInfoList:keyFind(player:getPlayerUserID())
        local requestData = {
            tableID = G_PlayerInfoList[_key].TableID,
            seatID = G_PlayerInfoList[_key].SeatID,
        }
        ClientNetManager.getInstance():requestCmd(g_Room_REQ_GAMEREADY, requestData, G_ProtocolType.Room)
    end
    EBGameControl:startGame()
    tool.closeLayerAni(self.node, self)
end

function EightBallGameOverLayer:goBack()
    tool.closeLayerAni(self.node, self)
end

function EightBallGameOverLayer:btnCallback(sender, eventType)
    local nTag = sender:getTag()
    if eventType == TOUCH_EVENT_BEGAN then
        sender:setScale(1.05)
    elseif eventType == TOUCH_EVENT_ENDED then
        sender:setScale(1.0)
        amgr.playEffect("hall_res/button.mp3")
        if nTag == 196 then
            self:goBackHall()
        elseif nTag == 197 then
            self:playAgain()
        elseif nTag == 198 then
            self:goBack()
        end
    elseif eventType == TOUCH_EVENT_MOVED then

    elseif eventType == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end
end

function EightBallGameOverLayer:onEnter()
    self:set3DCamera()
end

function EightBallGameOverLayer:onExit()

end

return EightBallGameOverLayer