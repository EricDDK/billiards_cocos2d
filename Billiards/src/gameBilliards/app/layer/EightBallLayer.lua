-- Copyright (c) 2018, xiangyoushuma inc.
-- All rights reserved.
--
-- Camera param and mask
-- The engine 2D camera flag is USER1
-- 3D camera default flag is USER2
-- 2D compenent default mask is USER2, and special mask is USER3
-- And other layer's camera mask in this game are USER4,depth is 5.0
-- So the sequence by depth is 
-- layerCamera > 2D compenent camera > 3D default camera > 2D default camera > USER1 default
-- The cocos2d-x 3.10 engine's globalZOrder is ununsed on mix of (2D and 3D) 
-- or (the Various 2D and 3D hybrid mounts or other complex situations)
-- So I use 4 camera to control the render and view of this game
-- Maybe I will add more cameras to perfect this games's render & view
-- 
-- Author: Ding DeKai 2018-6-10
--

local AGamePhysicalBase = require("AGameCommon.AGamePhysicalBase")
local EightBallLayer = class("EightBallLayer", AGamePhysicalBase)

local nImg_VS                       = 110       -- VS面板
local nImg_User1                    = 111       -- 选手1
local nImg_User2                    = 112       -- 选手2
local nImg_TipBall1                 = 115       -- 指示球1
local nImg_TipBall2                 = 116       -- 指示球2
local nImg_UpBallBg                 = 117       -- 右上角的拉杆球的底
local nImg_UpBall                   = 118       -- 拉杆球
local nImg_UpBallRedPoint           = 119       -- 拉杆球红点
local nText_VS                      = 120       -- 比分文字信息(1:5)
local nBtn_Setting                  = 121       -- 设置界面
local nPanel_Setting                = 130       -- 设置黑框
local nBtn_Back                     = 131       -- 退出按钮
local nBtn_Set                      = 132       -- 设置按钮

local nSlider_PowerBar              = 21        -- 力量条
local nSprite_PowerNum              = 22        -- 力量条数值精灵
local nSlider_View                  = 24        -- 力量条屏幕中间视图

local nPanel_FineTurning            = 31        -- 微调框裁剪
local nImg_FineTurning1             = 32        -- 微调框图1
local nImg_FineTurning2             = 33        -- 微调框图2

local nImg_BallBag                  = 40        -- 球袋

local nPanel_Users                  = 51        -- 角色容器
local nImg_PowerBar                 = 52        -- 力量条容器
local nLayout_FineTurning           = 53        -- 微调框容器
local nImg_Desk                     = 54        -- *桌子
local nPanel_Tip                    = 55        -- 提示框

local nText_Tip                     = 60        -- 提示信息
local nImg_DeskTem                  = 61        -- 桌子的白色蒙底

local nPanel_BlackBg                = 250       -- 用户头像框黑色蒙底

--------------------成员变量--------------------

local m_rotateX                     = 0         -- 高低杆x
local m_rotateY                     = 0         -- 高低杆y
local mSyncFrameIndex               = 0         -- 帧同步当前帧(0.1秒同步一次)
local mTime                         = 0         -- 记录定时器总跑的时间

--------------------定时器--------------------

local m_syncBallTimeEntery = nil
local m_ballCheckStopSchedulerEntry = nil  --定时器

function EightBallLayer:ctor(isResume,isAudition)
    print("[EightBallLayer:ctor] isResume,isAudition",isResume,isAudition)
    self.isAudition = isAudition
    self:initView(isResume)
    self:registerTouchHandler()
    --self:registerEvents()
end

function EightBallLayer:initView(isResume)
    self.bg = ccui.ImageView:create("gameBilliards/eightBall/eightBall_Background_Main.png", UI_TEX_TYPE_LOCAL)
    dump(display)
    print("[EightBallLayer:initView]: x,y = ",display.cx, display.cy)
    self.bg:setPosition(cc.p(display.cx, display.cy))
    if (display.width / display.height) <= 1136 / 640 then
        self.bg:setScale(display.height / self.bg:getContentSize().height)
    else
        self.bg:setScale(display.width / self.bg:getContentSize().width)
    end
    self:addChild(self.bg)
    self.node = cc.CSLoader:createNode("gameBilliards/csb/EightBallLayer.csb")
    if self.node then
        self.node:setAnchorPoint(cc.p(0.5, 0.5))
        self.node:setPosition(display.center)
        self:addChild(self.node)

        local function btnCallback(sender, eventType)
            self:btnCallback(sender, eventType)
        end

        local panel_Users = self.node:getChildByTag(nPanel_Users)
        if panel_Users then
            local img_VS = panel_Users:getChildByTag(nImg_VS)
            self.text_Score = img_VS:getChildByTag(nText_VS)
            self.img_User1 = panel_Users:getChildByTag(nImg_User1)
            self.img_User2 = panel_Users:getChildByTag(nImg_User2)
            self.userName1 = self.img_User1:getChildByName("_Name")
            self.userName2 = self.img_User2:getChildByName("_Name")
            self.userName1:setString("")
            self.userName2:setString("")
            self.userBall1 = self.img_User1:getChildByName("_Ball")
            self.userBall2 = self.img_User2:getChildByName("_Ball")
            self.userBall1:setVisible(false)  self.userBall2:setVisible(false)
            self.userHead1 = self.img_User1:getChildByName("_Head")
            self.userHead2 = self.img_User2:getChildByName("_Head")
            self.profressTimer1 = self.img_User1:getChildByName("progressTimer_1")
            self.profressTimer2 = self.img_User2:getChildByName("progressTimer_2")
            self.tipBall1 = self.img_User1:getChildByTag(nImg_TipBall1)
            self.tipBall2 = self.img_User2:getChildByTag(nImg_TipBall2)
            local img_UpBallBg = panel_Users:getChildByTag(nImg_UpBallBg)
            self.upBall = img_UpBallBg:getChildByTag(nImg_UpBall)
            self.upBall:setTouchEnabled(true)
            self.upBall:addTouchEventListener(btnCallback)
            self.upBallRedPoint = self.upBall:getChildByTag(nImg_UpBallRedPoint)
            self.btn_Set = panel_Users:getChildByTag(nBtn_Setting)
            if self.btn_Set then
                self.btn_Set:addTouchEventListener(btnCallback)
            end
            self.blackBg = panel_Users:getChildByTag(nPanel_BlackBg)
            self.blackBg:setVisible(false)
        end
        self.img_PowerBar = self.node:getChildByTag(nImg_PowerBar)
        if self.img_PowerBar then
            self:initPowerBar(self.img_PowerBar)
            --self.img_PowerBar:setVisible(false)
        end
        self.layout_FineTurning = self.node:getChildByTag(nLayout_FineTurning)
        if self.layout_FineTurning then
            self.panel_FineTurning = self.layout_FineTurning:getChildByTag(nPanel_FineTurning)
            self.panel_FineTurning:setSwallowTouches(false)
            self.fineTurning_1 = self.panel_FineTurning:getChildByTag(nImg_FineTurning2)
            self.fineTurning_2 = self.panel_FineTurning:getChildByTag(nImg_FineTurning1)
            self.layout_FineTurning:setCameraMask(cc.CameraFlag.USER3)
            --self.layout_FineTurning:setGlobalZOrder(-1)
        end
        self.desk = self.node:getChildByTag(nImg_Desk)
        if self.desk then
            self.ballBag = self.desk:getChildByTag(nImg_BallBag)
            self.deskTemp = self.desk:getChildByTag(nImg_DeskTem)
        end
        self.panel_Tip = self.node:getChildByTag(nPanel_Tip)
        self.tip = self.panel_Tip:getChildByTag(nText_Tip)

        self.btn_reset = self.node:getChildByTag(64)
        self.btn_reset:addTouchEventListener(btnCallback)
        if not G_isDebug then
            self.btn_reset:setVisible(false)
        else
            self.btn_reset:setPosition(cc.p(1100,25))
        end

        self.btn_Watch = self.node:getChildByTag(65)
        self.btn_Watch:addTouchEventListener(btnCallback)
        -- if player:getIsGM() then
        --     self.btn_Watch:setVisible(true)
        -- else
        --     self.btn_Watch:setVisible(false)
        -- end
        self.btn_Watch:setVisible(false)

        self.panel_setting = self.node:getChildByTag(nPanel_Setting)
        if self.panel_setting then
            self.panel_setting:setCameraMask(cc.CameraFlag.USER3)
            for i=nBtn_Back,nBtn_Set do
                local btn = self.panel_setting:getChildByTag(i)
                if btn then
                    btn:addTouchEventListener(btnCallback)
                end
            end
        end
        
        self:initPhysicalInfo(isResume)
        self:initListener()
        self:adaptationLayer()

        print("init view isResume = ",isResume)
        if not isResume then
            EBGameControl:startGame()
        end
        --EBGameControl:startGame()--测试用
    end
end

function EightBallLayer:registerEvents()
    self.gameEventListeners = self.gameEventListeners or { }
    self.roomEventListeners = self.roomEventListeners or { }
    self.portalEventListeners = self.portalEventListeners or { }
    local eventListeners = eventListeners or { }
    local eventRoomListeners = eventRoomListeners or { }
    local eventPortalListeners = eventPortalListeners or { }
    -- 房间内事件
    local appBase = AppBaseInstanse.Mobile_APP
    eventRoomListeners[g_Room_NTF_JOINTABLE] = handler(self, self.receiveJoinTable)-- 加入桌子
    eventRoomListeners[g_Room_NTF_LEAVETABLE] = handler(self, self.receiveLeaveTable)-- 离开桌子
    eventRoomListeners[g_Room_NTF_GAMEREADY] = handler(self, self.receiveGameReady)-- 玩家准备
    --eventRoomListeners[g_Room_NTF_GAMESTART] = handler(self, self.receiveRoomGameStart)-- 游戏开始
    eventRoomListeners[g_Room_NTF_PLAYERDISCONNECT] = handler(self, self.receivePlayerDisconnected)-- 玩家掉线啦
    eventRoomListeners[g_Room_NTF_PLAYERRECONNECT] = handler(self, self.receivePlayerConnecte)-- 玩家重连啦
    eventRoomListeners[g_Room_NTF_TABLECHAT] = handler(self, self.receiveTableChat)-- 桌子聊天
    eventRoomListeners[g_Room_NTF_ROOMMESSAGE] = handler(self, self.receiveRoomMessage)-- 房间内消息
    eventRoomListeners[g_Room_NTF_POPUPMESSAGE] = handler(self, self.receivePopupMessage)

    -- 游戏内事件
    eventListeners[g_EIGHTBALL_NTF_GAMESTART] = handler(self, self.receiveGameStart)
    eventListeners[g_EIGHTBALL_NTF_TABLEINFO] = handler(self, self.receiveTableInfo)
    eventListeners[g_EIGHTBALL_NTF_NOTICEUSEROPERATE] = handler(self, self.receiveNoticeUserOperate)
    eventListeners[g_EIGHTBALL_NTF_SETWHITEBALL] = handler(self, self.receiveSetWhiteBall)
    eventListeners[g_EIGHTBALL_NTF_SETCUEINFO] = handler(self, self.receiveSetCueInfo)
    eventListeners[g_EIGHTBALL_NTF_SYNCBALLINFO] = handler(self, self.receiveSyncBallInfo)
    eventListeners[g_EIGHTBALL_NTF_HITWHITEBALL] = handler(self, self.receiveHitWhiteBall)
    eventListeners[g_EIGHTBALL_NTF_HITBALLRESULTNTF] = handler(self, self.receiveHitBallResult)
    eventListeners[g_EIGHTBALL_NTF_GAMEOVER] = handler(self, self.receiveGameOver)
    eventListeners[g_EIGHTBALL_NTF_GAMERESUME] = handler(self, self.receiveResume)

    appBase.GameMsgCenter:addAllEventListenerByTable(eventListeners)
    appBase.RoomMsgCenter:addAllEventListenerByTable(eventRoomListeners)
    appBase.PortalMsgCenter:addAllEventListenerByTable(eventPortalListeners)

    self.roomEventListeners = eventRoomListeners
    self.gameEventListeners = eventListeners
    self.portalEventListeners = eventPortalListeners
end

function EightBallLayer:receiveJoinTable(event)
    print("EightBallLayer:receiveJoinTable",event.tableID,event.seatID)
    dmgr:playerJoinTable(event.tableID, event.seatID , event.userID)
    if player:getMyTableID() == event.tableID then
        if player:getPlayerUserID() ~= event.userID then
            local curPlayerInfo = dmgr:getPlayerInfoByTableIdAndSeatID(event.tableID, event.seatID , event.userID)
            if curPlayerInfo then
                dmgr:playerIn(curPlayerInfo)
                self:showCareerByIndex(2, curPlayerInfo.User.UserInfo.Head,curPlayerInfo.User.UserInfo.NickName)
            end
        end
    end
end

function EightBallLayer:receiveLeaveTable(event)
    print("EightBallLayer:receiveLeaveTable",event.tableID,event.seatID)
    dmgr:playerLeaveTable(event)
    if event.tableID == player:getMyTableID() then
        if event.seatID == player:getMySeatID() and event.userID == player:getPlayerUserID() then
            print("you leave the table")
            local isFinal =(self.isAudition and G_Is_Eightball_Final) and true or false
            if isFinal then
                
            else
                EBGameControl:leaveGame() 
            end
        else
            local playerInfo = dmgr:getPlayerInfoByTableIdAndSeatIdInTable(event.tableID, event.seatID)
            if playerInfo then
                if playerInfo.User.UserInfo.UserID == event.userID then
                    dmgr:playerOut(playerInfo)
                    self:showCareerByIndex(2, -1,"")
                end
            end
        end
    end
end

function EightBallLayer:receiveGameReady(event)
    print("EightBallLayer:receiveGameReady", event.userID, event.tableID, event.seatID)
    if event.userID == player:getPlayerUserID() then
        self:cleanWaitPanel()
    end
    self:showOriginRolePanel()
end

function EightBallLayer:receivePlayerDisconnected(event)
    print("EightBallLayer:receivePlayerDisconnected",event.userID)
end

function EightBallLayer:receivePlayerConnecte(event)
    print("EightBallLayer:receivePlayerConnecte",event.userID)
end

function EightBallLayer:receiveTableChat(event)
end

function EightBallLayer:receiveRoomMessage(event)
    print("[EightBallLayer:receiveRoomMessage]:message = ", event.content)
    self:cleanWaitPanel()
    player:setIsAuditionTime(true)
    if self.isAudition then
        local back = function(isOK)
            EBGameControl:leaveGame()
        end
        local dataMsgBox = {
            nodeParent = nil,
            msgboxType = MSGBOX_TYPE_UPDATE,
            msgInfo = event.content,
            callBack = back,
        }
        display.getRunningScene():addChild(require("hallcenter.widgets.CommonMsgBoxWidget").new(dataMsgBox))
    end
    --EBGameControl:leaveGame()
end

function EightBallLayer:receivePopupMessage(event)
    print("[EightBallLayer:receivePopupMessage]:message = ", event.message)
    local back = function(isOK)
        --EBGameControl:leaveGame()
    end
    local dataMsgBox = {
        nodeParent = nil,
        msgboxType = MSGBOX_TYPE_UPDATE,
        msgInfo = event.message,
        callBack = back,
    }
    display.getRunningScene():addChild(require("hallcenter.widgets.CommonMsgBoxWidget").new(dataMsgBox))
end

function EightBallLayer:receiveTableInfo(event)
    print("EightBallLayer:receiveTableInfo")
    dump(event)
end

function EightBallLayer:receiveNoticeUserOperate(event)
    print("EightBallLayer:receiveNoticeUserOperate")
    dump(event)
end

function EightBallLayer:receiveGameStart(event)
    print("EightBallLayer:receiveGameStart")
    --dump(event)
    self:restart()
    EBGameControl:startGame()
    if event.UserID == player:getPlayerUserID() then
        --我先放置球
        EBGameControl:setGameState(g_EightBallData.gameState.waiting)
        EightBallGameManager:setCurrentUserID(player:getPlayerUserID())
        BilliardsAniMgr:setSliderBarAni(true,self)
        --BilliardsAniMgr:setFineTurningAni(true,self)
        BilliardsAniMgr:setDeskTempAni(self,true)  --桌子白板
        local timerCallBack = function()
            BilliardsAniMgr:setGameTips(self,g_EightBallData.gameRound.countdown)
        end
        BilliardsAniMgr:setHeadTimerAni(self.profressTimer1,g_EightBallData.operateTimer,timerCallBack)
        BilliardsAniMgr:createUserFrameAni(self)
        self.cue.spriteLine:setVisible(true)
        self.cue.circleCheck:setVisible(true)
    else
        --对方先放置球
        EBGameControl:setGameState(g_EightBallData.gameState.waiting)
        EightBallGameManager:setCurrentUserID(event.UserID)
        BilliardsAniMgr:setSliderBarAni(false,self)
        --BilliardsAniMgr:setFineTurningAni(false,self)
        BilliardsAniMgr:setDeskTempAni(self,false)  --桌子白板
        BilliardsAniMgr:setHeadTimerAni(self.profressTimer2,g_EightBallData.operateTimer,nil)
        BilliardsAniMgr:createUserFrameAni(self)
        self.cue.spriteLine:setVisible(false)
        self.cue.circleCheck:setVisible(false)
    end
    BilliardsAniMgr:setGameStartAni(self.desk)
end

function EightBallLayer:receiveSetWhiteBall(event)
    print("EightBallLayer:receiveSetWhiteBall ",event.GameRound)

    --dump(event)

    if EightBallGameManager:getGameRound() ~= event.GameRound then return end
    event.fPositionX = GetPreciseDecimal(event.fPositionX)
    event.fPositionY = GetPreciseDecimal(event.fPositionY)
    if event.UserID ~= player:getPlayerUserID() then
        local pos = {x = event.fPositionX,y = event.fPositionY}
        self.whiteBall:whiteBallTouchBegan(self,event.fPositionX,event.fPositionY,true)
        --self.whiteBall:whiteBallTouchMoved(self,pos,true)
        self.whiteBall:whiteBallTouchEnded(self,pos,true)
    end
end

function EightBallLayer:receiveSetCueInfo(event)
    print("EightBallLayer:receiveSetCueInfo ",event.GameRound,EightBallGameManager:getGameRound())
    --dump(event)

    if EightBallGameManager:getGameRound() ~= event.GameRound then return end

    event.fAngle = GetPreciseDecimal(event.fAngle)
    if event.UserID ~= player:getPlayerUserID() then
        self.cue:receriveSetCueInfo(event.fAngle,self)
    end
end

function EightBallLayer:receiveSyncBallInfo(event)
    --print("[EightBallLayer:receiveSyncBallInfo]")
    --dump(event.BallInfoArray)
    if event.UserID ~= player:getPlayerUserID() then
        EightBallGameManager:insertSyncBallArray(event,event.FrameIndex)
    end
end

function EightBallLayer:receiveHitWhiteBall(event)
    print("EightBallLayer:receiveHitWhiteBall ",event.GameRound)
    --dump(event)
    if EightBallGameManager:getGameRound() ~= event.GameRound then return end

    local userid = ((player:getPlayerUserID() == event.UserID) and {player:getPlayerUserID()} or {event.UserID})[1]
    EightBallGameManager:setCurrentUserID(userid)
    --开启定时器的回调函数
    local hitWhiteBallCallback = function(data)
        if self and not tolua.isnull(self) then
            self.whiteBall:clearWhiteBallView()  --击打球前清除白球上的视图
            self:openSyncBallTimeEntry()
            self:openCheckStopTimeEntry()
            BilliardsAniMgr:setSliderBarAni(false, self)
            EightBallGameManager:setCanOperate(false)
        end
    end
    --停止tips动画
    local ball
    for i = 0, 15 do
        ball = self.desk:getChildByTag(i)
        if ball then
            ball:stopTipsEffect()
        end
    end
    --停止倒计时框
    BilliardsAniMgr:setGameTips(self,g_EightBallData.gameRound.exception)
    BilliardsAniMgr:setDeskTempAni(self,false)
    self.slider_PowerBar:setPercent(0)
    m_rotateX = 0 m_rotateY = 0
    self.upBallRedPoint:setPosition(cc.p(m_rotateX * 30 + 29.5, m_rotateY * 30 + 29.5))
    self.cue:receiveLauchBall(event,hitWhiteBallCallback)
    
    local progressTimer = player:getPlayerUserID() == event.UserID and self.profressTimer1 or self.profressTimer2
    BilliardsAniMgr:setHeadTimerAni(progressTimer,0,nil)
    BilliardsAniMgr:createUserFrameAni(self,true)
end

function EightBallLayer:receiveHitBallResult(event)
    print("EightBallLayer:receiveHitBallResult")
    --dump(event)
    EightBallGameManager:setGameRound(event.GameRound)

    local progressTimer1 = player:getPlayerUserID() == event.UserID and self.profressTimer1 or self.profressTimer2
    local progressTimer2 = player:getPlayerUserID() == event.UserID and self.profressTimer2 or self.profressTimer1
    local timerCallBack = function()
        BilliardsAniMgr:setGameTips(self,-2)
    end
    BilliardsAniMgr:setHeadTimerAni(progressTimer1,g_EightBallData.operateTimer,timerCallBack)
    BilliardsAniMgr:setHeadTimerAni(progressTimer2,0,nil)
    BilliardsAniMgr:createUserFrameAni(self,true)

    EightBallGameManager:clearBallsProcess()
    -- 清除本地球过程统计数组
    EightBallGameManager:setBallsResultPos(event)

    if not m_ballCheckStopSchedulerEntry and not EightBallGameManager:getIsSyncHitResult() then
        local delayTime = event.WholeFrame * g_EightBallData.netSynchronizationRate - mTime
        delayTime = delayTime > 0 and delayTime or 0
        print(" the delay time of sync hit result = ", delayTime, event.WholeFrame,mTime)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime + g_EightBallData.receiveHitWhiteBallInterval --[[+ g_EightBallData.receiveHitWhiteBallInterval--]]),
        cc.CallFunc:create( function()
            EightBallGameManager:syncHitResult(self)
        end )))
    end
end

function EightBallLayer:receiveGameOver(event)
    print("EightBallLayer:receiveGameOver")
    dump(event)
    EBGameControl:setGameState(g_EightBallData.gameState.gameOver)
    --必须是海选+总决赛才是true
    local isFinal = (self.isAudition and G_Is_Eightball_Final) and true or false
    print("isFinal = ",isFinal,self.isAudition,G_Is_Eightball_Final)
    display.getRunningScene():addChild(require("gameBilliards.app.layer.EightBallGameOverLayer").new(event,isFinal))
    BilliardsAniMgr:createUserFrameAni(self, true)
    BilliardsAniMgr:setHeadTimerAni(self.profressTimer1, 0, nil)
    BilliardsAniMgr:setHeadTimerAni(self.profressTimer2, 0, nil)
    -- 测试
    -----------------------------------------------------------------------------
--    local _key = G_PlayerInfoList:keyFind(player:getPlayerUserID())
--    local requestData = {
--        tableID = G_PlayerInfoList[_key].TableID,
--        seatID = G_PlayerInfoList[_key].SeatID,
--    }
--    ClientNetManager.getInstance():requestCmd(g_Room_REQ_GAMEREADY, requestData, G_ProtocolType.Room)
    -----------------------------------------------------------------------------

end

function EightBallLayer:receiveResume(event)
    print("EightBallLayer:receiveResume")
    dump(event)
    self:cleanWaitPanel()
    self:showOriginRolePanel()
    EBGameControl:dealGameResume(event)
end

function EightBallLayer:showOriginRolePanel()
    local showPos
    dmgr:initPlayerInfoList()
    local playerList = dmgr:getDeskPlayerInfoList()
    print("(player:getMySeatID()+3)%2 ",(player:getMySeatID() + 1) % 2 + 1)

    if #playerList > 1 then
        for i = 1, #playerList do
            if playerList[i].SeatID == player:getMySeatID() then
                self:showCareerByIndex(1, playerList[i].User.UserInfo.Head, playerList[i].User.UserInfo.NickName)
            else
                self:showCareerByIndex(2, playerList[i].User.UserInfo.Head, playerList[i].User.UserInfo.NickName)
            end
        end
    end
end

function EightBallLayer:showCareerByIndex(nIndex, nHead ,nickName)
    if nHead < 0 and nIndex == 2 then
        self.userHead2:setVisible(false)
        self.userName2:setString("")
        return
    end
    local head = nIndex == 1 and self.userHead1 or self.userHead2
    local name = nIndex == 1 and self.userName1 or self.userName2
    if head then
        head:setVisible(true)
        head:loadTexture(tool.getHeadImgById(nHead, true), UI_TEX_TYPE_LOCAL)
        head:setContentSize(cc.size(136, 136))
    end
    if name then
        name:setString(nickName)
    end
end

--初始化物理世界以及信息
function EightBallLayer:initPhysicalInfo(isResume)
    PhyControl:initEightBallPhysicalBorder(self)
    PhyControl:initEightBallAllBalls(self,isResume)
    self.whiteBall = self.desk:getChildByTag(g_EightBallData.g_Border_Tag.whiteBall)
    self.cue = PhyControl:initCue(self.whiteBall)
    self.routeLine = self.cue:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck)
    self.cue:setRotationOwn(0,self)
end

--创建监听
function EightBallLayer:initListener()
    EBGameControl:initListener(self)
    EBGameControl:initCheckCollisionListener(self)
end

--初始化力量条
function EightBallLayer:initPowerBar(img_PowerBar)
    local function percentChangedEvent(sender, eventType)
        --练习模式击打过了不允许使用，比赛模式，不可操作也不可以使用
        if (EBGameControl:getGameState() == g_EightBallData.gameState.practise and m_ballCheckStopSchedulerEntry)
        or (EBGameControl:getGameState() ~= g_EightBallData.gameState.practise and not EightBallGameManager:getCanOperate()) then
            self.slider_PowerBar:setPercent(0)
            self.cue:setPercent(0)
            return
        end
        --松开滑动条
        if eventType == ccui.SliderEventType.slideBallUp then
            if self.slider_PowerBar:getPercent() > 0 then
                EightBallGameManager:setCanRefreshBallAni(true)
                self.cue:launchBall(self.slider_PowerBar:getPercent(), self.desk, m_rotateX, m_rotateY)
                BilliardsAniMgr:setDeskTempAni(self, false)
                self.slider_PowerBar:setPercent(0)
                self.cue:setPercent(0)
                -- 练习模式不打开定时器,连续打开两次会卡
                if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
                    BilliardsAniMgr:setGameTips(self,g_EightBallData.gameRound.exception)
                    self:openCheckStopTimeEntry()
                end
                m_rotateX = 0 m_rotateY = 0
                self.upBallRedPoint:setPosition(cc.p(m_rotateX * 30 + 29.5, m_rotateY * 30 + 29.5))
                if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
                    BilliardsAniMgr:setSliderBarAni(false,self)
                end
            else
                self.slider_PowerBar:setPercent(0)
                self.cue:setPercent(0)
            end
            self.slider_View:setVisible(false)
            self.slider_View:setPercent(0)
            self.whiteBall:getPhysicsBody():setCategoryBitmask(0x01)
            self.whiteBall:getPhysicsBody():setContactTestBitmask(0x01)
            self.whiteBall:getPhysicsBody():setCollisionBitmask(0x03)
        --滑动条percent发生改变
        elseif eventType == ccui.SliderEventType.percentChanged or eventType == ccui.SliderEventType.slideBallDown then
            local percent = self.slider_PowerBar:getPercent()
            self.slider_View:setPercent(percent)
            self.cue:setPercent(percent)
            self.slider_View:setVisible(true)
            BilliardsAniMgr:createPowerNumEffet(self.powerNum, percent)
        end
    end
    self.slider_PowerBar = img_PowerBar:getChildByTag(nSlider_PowerBar)
    self.slider_PowerBar:setSwallowTouches(true)
    self.slider_PowerBar:addEventListener(percentChangedEvent)
    
    self.slider_View = self.node:getChildByTag(nSlider_View)
    self.slider_View:setTouchEnabled(false)
    self.slider_View:setVisible(false)
    self.powerNum = self.slider_View:getChildByTag(nSprite_PowerNum)
    self.powerNum:setCameraMask(cc.CameraFlag.USER3)
end

local mSpeedCount = 0
--帧数刷新重置球状态(滚动，速度，旋转，3D渲染等等)
--@isCollision 是否是碰撞触发的
function EightBallLayer:refreshBallsAni(isCollision)
    --性能损耗太大
    --self.whiteBall:adjustHighLight()  -- 只调整白球的高光效果
    if not isCollision then
        mSpeedCount = mSpeedCount + 1
        if mSpeedCount >= 10 then
            mSpeedCount = 0
        else
            return
        end
    end
    local ball
    for i = 0, 15 do
        ball = self.desk:getChildByTag(i)
        if ball then
            ball:adjustBallSpeed(mTime)
        end
    end
end

--单独刷新球
function EightBallLayer:refreshBallAni(tagA,tagB)
    local ball
    if tagA >= 0 and tagA <= 15 then
        ball = self.desk:getChildByTag(tagA)
        if ball then
            ball:adjustBallSpeed(mTime)
            if ball:getBallState() == g_EightBallData.ballState.stop then
                ball:setBallState(g_EightBallData.ballState.run) 
            end
        end
    end
    if tagB >= 0 and tagB <= 15 then
        ball = self.desk:getChildByTag(tagB)
        if ball then
            ball:adjustBallSpeed(mTime)
            if ball:getBallState() == g_EightBallData.ballState.stop then
                ball:setBallState(g_EightBallData.ballState.run) 
            end
        end
    end
end

--回调回来的设置高低杆系数
function EightBallLayer:setPullNum(posX, posY)
    print("setPullNum = ", posX, posY)
    m_rotateX = posX
    m_rotateY = posY
    self.upBallRedPoint:setPosition(cc.p(m_rotateX*30+29.5,m_rotateY*30+29.5))
end

---------------------------------------------------  ↓  UI  ↓  --------------------------------------------------------------------

function EightBallLayer:btnCallback(sender, eventType)
    local nTag = sender:getTag()
    if eventType == TOUCH_EVENT_BEGAN then
        sender:setScale(1.05)
    elseif eventType == TOUCH_EVENT_ENDED then
        sender:setScale(1.0)
        amgr.playEffect("hall_res/button.mp3")
        if nTag == 64 then
            self:resetBalls()
        elseif nTag == 65 then
            self:watch()
        elseif nTag == nImg_UpBall then
            self:openWhiteBallLayer()
        elseif nTag == nBtn_Setting then
            self:openSettingNode()
        elseif nTag == nBtn_Back then
            self:goBack()
        elseif nTag == nBtn_Set then
            self:openSettingLayer()
            self:openSettingNode()
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        
    elseif eventType == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end
end

local test = 1
--测试用的重置界面按钮事件
function EightBallLayer:resetBalls()
    EBGameControl:ballInHole(0, self.desk:getChildByTag(g_EightBallData.g_Border_Tag.hole))
--    if 1==1 then
--        BilliardsAniMgr:createLinkEffect(self,15)
--    end
--    if 1 == 1 then
--        local timerCallBack = function(data)
--            BilliardsAniMgr:setGameTips(self,-2)
--        end
--        EBGameControl:setGameState(2)
--        BilliardsAniMgr:setHeadTimerAni(self.profressTimer1, 20, timerCallBack)
--        return
--    end
    -- self:receiveGameOver(nil)
    -- EBGameControl:setSuitCuePos()
    -- BilliardsAniMgr:setHeadTimerAni(self.profressTimer1,20,nil)
    -- if 1==1 then
    --     local ball = self.desk:getChildByTag(test)
    --     if ball then
    --         ball:setBallState(g_EightBallData.ballState.inHole)
    --         ball:resetForceAndEffect()
    --         ball:setPosition(cc.p(-15,487))
    --         ball:getPhysicsBody():applyForce(cc.p(-100000,-1000000),cc.p(0,0))
    --     end
    --     test = test + 1
    --     return
    -- end
    ------------------------------------------------------------------------------------------------------------------
    --    rmgr:setIsChangeGamePlayer(false)
    --    local _key = G_PlayerInfoList:keyFind(player:getPlayerUserID())
    --    local requestData = {
    --        tableID = G_PlayerInfoList[_key].TableID,
    --        seatID = G_PlayerInfoList[_key].SeatID,
    --    }
    --    ClientNetManager.getInstance():requestCmd(g_Room_REQ_LEAVETABLE, requestData, G_ProtocolType.Room)
    ------------------------------------------------------------------------------------------------------------------
    -- BilliardsAniMgr:createLinkEffect(self,test)
    -- BilliardsAniMgr:createWordEffect(self,test)
    -- test = test + 1

--    self.slider_PowerBar:setTouchEnabled(true)
--    self:restart()
--    EBGameControl:startGame()
end

--观战
function EightBallLayer:watch()
    display.getRunningScene():addChild(require("hallcenter.widgets.Audition.EightBallFinalGM").new())
end

--打开高低杆界面
function EightBallLayer:openWhiteBallLayer()
    if (EightBallGameManager:getCanOperate() and EightBallGameManager:getCurrentUserID() == player:getPlayerUserID())
    or EBGameControl:getGameState() == g_EightBallData.gameState.practise then
        display.getRunningScene():addChild(require("gameBilliards.app.layer.gamebilliardsWhiteBallLayer").new(self,m_rotateX,m_rotateY))
    end
end

local mIsSettingNode = false  --处理设置界面
function EightBallLayer:getIsSettingNode() return mIsSettingNode end
--放下设置界面
function EightBallLayer:openSettingNode()
    local posX = 0 -(display.width - self.node:getContentSize().width) / 2
    local posY = display.height -(display.height - self.node:getContentSize().height) / 2
    local height = self.panel_setting:getContentSize().height
    if not mIsSettingNode then
        print("setting ben pos = ", posX, posY, height)
        self.panel_setting:setPosition(cc.p(posX, posY))
        local func1 = cc.MoveTo:create(0.15, cc.p(posX, posY - height - 30))
        local func2 = cc.MoveTo:create(0.03, cc.p(posX, posY - height + 10))
        local func3 = cc.MoveTo:create(0.02, cc.p(posX, posY - height))
        self.panel_setting:runAction(cc.Sequence:create(func1, func2, func3))
        mIsSettingNode = true
    else
        self.panel_setting:setPosition(cc.p(posX, posY - height))
        self.panel_setting:runAction(cc.MoveTo:create(0.15, cc.p(posX, posY + height)))
        mIsSettingNode = false
    end
end

-- 返回大厅
function EightBallLayer:goBack()
    if player:getIsGM() then
        EBGameControl:leaveGame()
    end
    local isFinal =(self.isAudition and G_Is_Eightball_Final) and true or false
    if EBGameControl:getGameState() == g_EightBallData.gameState.practise or EBGameControl:getGameState() == g_EightBallData.gameState.gameOver then
        EBGameControl:leaveGame()
    else
        if isFinal then
            tool.openNetTips("决赛房间不能退出!")
        else
            local backCallback = function()
                rmgr:setIsChangeGamePlayer(false)
                local _key = G_PlayerInfoList:keyFind(player:getPlayerUserID())
                local requestData = {
                    tableID = G_PlayerInfoList[_key].TableID,
                    seatID = G_PlayerInfoList[_key].SeatID,
                }
                ClientNetManager.getInstance():requestCmd(g_Room_REQ_LEAVETABLE, requestData, G_ProtocolType.Room)
                if self and not tolua.isnull(self) then
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create( function()
                        EBGameControl:leaveGame()
                    end )))
                end
            end
            local str = "现在退出不返还台费，\n你确定要退出嘛？"
            display.getRunningScene():addChild(require("gameBilliards.app.layer.BilliardsCommonLayer").new(backCallback, str))
        end
    end
end

--打开设置界面
function EightBallLayer:openSettingLayer()
    display.getRunningScene():addChild(require("gameBilliards.app.layer.EightBallSettingLayer").new())
end

--游戏重新开始
function EightBallLayer:restart()
    local function closeGameOverLayer()
        print("local func closeGameOverLayer")
        local layer = display.getRunningScene():getChildByName("GameOverLayer")
        if layer then
            print("local func closeGameOverLayer, layer is exist")
            layer:stopAllActions()
            layer:removeFromParent()
            layer = nil
        end
    end
    --closeGameOverLayer()
    EBGameControl:setGameState(g_EightBallData.gameState.practise)
    EightBallGameManager:initialize()
    -- 初始化一些游戏step成员变量
    mIsSettingNode = false
    self:resetHeadFrame()
    self:closeSyncBallTimeEnter()
    self:closeCheckStopTimeEntry()
    --player:setIsAuditionTime(false)
end

--头像框重置
function EightBallLayer:resetHeadFrame()
    local panel_User = self.node:getChildByTag(nPanel_Users)
    if panel_User then
        for j = 1, 2 do
            local headFrame = panel_User:getChildByTag(nImg_User1 + j - 1)
            if headFrame then
                for i = 1, 15 do
                    local ballTip = headFrame:getChildByTag(i)
                    if ballTip then
                        ballTip:setVisible(false)
                    end
                end
            end
        end
        BilliardsAniMgr:createUserFrameAni(self, true) --去除头像框动画
    end
end

--适配
function EightBallLayer:adaptationLayer()
    self.img_PowerBar:setPositionX(self.img_PowerBar:getPositionX() -(display.width - self.node:getContentSize().width) / 2 - self.img_PowerBar:getContentSize().width)
    self.layout_FineTurning:setPositionX(self.layout_FineTurning:getPositionX() +(display.width - self.node:getContentSize().width) / 2 + self.layout_FineTurning:getContentSize().width)
    self.panel_Tip:setPosition(cc.p(display.cx, 0 -(display.height - self.node:getContentSize().height) / 2))
    self.panel_setting:setPosition(cc.p( 0-(display.width - self.node:getContentSize().width) / 2 , display.height + (display.height - self.node:getContentSize().height) / 2))
    --    if (display.width / display.height) < 1136 / 640 then

    --    elseif (display.width / display.height) >= 1136 / 640 then

    --    end
end

---------------------------------------------------  ↑  UI  ↑  --------------------------------------------------------------------

--@ 获取定时器是否在跑,同步
--@ 用以处理，白球以及蓄力槽点击事件不可以触发 
function EightBallLayer:getTimeEntryIsRunning()
    if m_syncBallTimeEntery or m_ballCheckStopSchedulerEntry then
        return true
    end
    return false
end

--开启帧同步定时器
function EightBallLayer:openSyncBallTimeEntry()
    local function synchronizeUpdate(dt)
        mSyncFrameIndex = mSyncFrameIndex + 1

        ----------------------------------------------------------------------------------------------------------------------------------
--        --测试输出
--        if mSyncFrameIndex == 1 then
--            _print("!!!!!!!!!!!!!!!!!!!!!!!",self.whiteBall:getPositionX(),self.whiteBall:getPositionY())
--        end
        ----------------------------------------------------------------------------------------------------------------------------------

        -- 这是我的击球,负责发送就可以
        if EightBallGameManager:getCurrentUserID() == player:getPlayerUserID() then
            -- 这是对手的击球，我需要接受并且判断有没有问题再进行补充发送
            EBGameControl:sendSyncBalls(mSyncFrameIndex)
        else
            local syncArray = EightBallGameManager:getSyncBallArray()
            --_print("the deal with receive sync frame index = ", mSyncFrameIndex)

            ----------------------------------------------------------------------------------------------------------------------------------
--            --测试输出
--            if mSyncFrameIndex == 1 then
--                _print("the white ball local pos is ",self.whiteBall:getPositionX(),self.whiteBall:getPositionY())
--                _print("the white ball sync  pos is ",syncArray[1].BallInfoArray[1].fPositionX,syncArray[1].BallInfoArray[1].fPositionY)
--                _print("the white ball local velocity is ",self.whiteBall:getVelocity().x,self.whiteBall:getVelocity().y)
--                _print("the white ball sync  velocity is ",syncArray[1].BallInfoArray[1].fVelocityX,syncArray[1].BallInfoArray[1].fVelocityY)
--            end
            ----------------------------------------------------------------------------------------------------------------------------------

            local ball
            --_print(" the count of sync ball array = ",#syncArray,mSyncFrameIndex)
            if syncArray and #syncArray > mSyncFrameIndex then
                local array = syncArray[mSyncFrameIndex].BallInfoArray
                for i=1,#array do
                    ball = self.desk:getChildByTag(array[i].Tag)
                    if ball then
                        ball:syncBallState(array[i])
                    end
                end
            else
                
            end
        end
    end
    self:closeSyncBallTimeEnter()  --防止开两个定时器导致泄漏
    m_syncBallTimeEntery = cc.Director:getInstance():getScheduler():scheduleScriptFunc(synchronizeUpdate, g_EightBallData.netSynchronizationRate, false)
end

--关闭帧同步定时器
function EightBallLayer:closeSyncBallTimeEnter()
    if m_syncBallTimeEntery then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(m_syncBallTimeEntery)
        m_syncBallTimeEntery = nil
        EBGameControl:sendSyncBalls(mSyncFrameIndex)
    end
    mSyncFrameIndex = 0
end

--检测球停止定时器
function EightBallLayer:openCheckStopTimeEntry()
    --_print("****************openCheckStopTimeEntry****************")
    local function checkCueVisibleState(dt)
        mTime = mTime + g_EightBallData.checkStopTimerInterval
        local isAllBallStop = true  --球是否全部停止
        local ball
        --local isBallStop
        for i = 0, 15 do
            ball = self.desk:getChildByTag(i)
            if ball then
                if ball:checkIsStop() then
                    if ball:getBallState() == g_EightBallData.ballState.run then
                        ball:resetForceAndEffect() 
                    end
                else
                    isAllBallStop = false
                end
            end
        end

        if isAllBallStop then
            if self and not tolua.isnull(self) then
                --练习模式下处理
                if not self.whiteBall:getIsInHole() and EBGameControl:getGameState() == g_EightBallData.gameState.practise then
                    self.cue:setCueLineCircleVisible(true)
                    self.cue:setRotationOwn(self.cue:getRotation(),self)
                    if EightBallGameManager:getLinkCount() > 1 then
                        BilliardsAniMgr:createLinkEffect(self,EightBallGameManager:getLinkCount())
                    end

                    EightBallGameManager:resetCanCalcurateLinkCount() --再次允许连杆数自加1
                end

                --练习模式直接关闭定时器
                if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
                    BilliardsAniMgr:setSliderBarAni(true,self)
                    self:closeCheckStopTimeEntry()
                    EightBallGameManager:setCanRefreshBallAni(false)
                    EBGameControl:checkRestartGame()
                end

                if EBGameControl:getGameState() == g_EightBallData.gameState.practise and self.whiteBall:getIsInHole() then
                    self.whiteBall:runAction(cc.Sequence:create(cc.DelayTime:create(g_EightBallData.sendHitResultInterval),cc.CallFunc:create(function ()
                        EBGameControl:dealWhiteBallInHole()
                    end)))
                end

                if not m_syncBallTimeEntery then
                    return
                end

                local ball
                print("all of the balls are stopped")
                for i = 0, 15 do
                    ball = self.desk:getChildByTag(i)
                    if ball then
                        ball:resetForceAndEffect()
                    end
                end
                self:runAction(cc.Sequence:create(cc.DelayTime:create(g_EightBallData.sendHitResultInterval),cc.CallFunc:create(function ()
                    EBGameControl:sendHitBallsResult(EightBallGameManager:getCurrentUserID()) --发送击球结果消息
                end)))
                self:closeSyncBallTimeEnter()
            end
            self.whiteBall:runAction(cc.Sequence:create(cc.DelayTime:create(g_EightBallData.sendHitResultInterval),cc.CallFunc:create(function ()
                self:closeCheckStopTimeEntry()
                --比赛模式下处理
                if EBGameControl:getGameState() ~= g_EightBallData.gameState.practise then
                    EightBallGameManager:syncHitResult(self) --同步一下击球结果，所有球位置
                end
            end)))
        end
    end
    self:closeCheckStopTimeEntry() --防止开两个定时器导致泄漏
    mTime = 0
    m_ballCheckStopSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(checkCueVisibleState, g_EightBallData.checkStopTimerInterval, false)
end

--关闭检测球停止定时器
function EightBallLayer:closeCheckStopTimeEntry()
    --_print("############   closeCheckStopTimeEntry #############")
    if m_ballCheckStopSchedulerEntry then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(m_ballCheckStopSchedulerEntry)
        m_ballCheckStopSchedulerEntry = nil
    end
end

function EightBallLayer:isTimeEnteryStop()
    return m_ballCheckStopSchedulerEntry and false or true
end

function EightBallLayer:onEnter()
    print("EightBallLayer:onEnter")
    --DisplayObserver.getInstance():addDisplayByName("EightBallLayer", self)
    G_IsInGame = true
    self:restart()

    --预加载声音
    EightBallGameManager:preLoadBilliardsEffect()

    --------------------------------------------------------------------------------------------------------------------------
    --如果是海选
    if self.isAudition then
        if G_Is_Eightball_Final then
          
        else
            rmgr:connectAuditionRoom(G_GameType.EIGHTBALL)
        end
    elseif G_isTestBilliards then
    --elseif 1==1 then
        -- 测试
        --rmgr.registerEvents()
        g_IsSendRequest = true
        -- 开始发送房间心跳包
        --ClientNetManager.getInstance():keepRoomAlive()
       
    else
        -- if not G_Game_Resume then
        --     rmgr:connectRoom()
        -- else
        --     rmgr:resumeToConnectRoom()
        --     G_Game_Resume = false
        -- end
    end
    --------------------------------------------------------------------------------------------------------------------------
    -- 加载3D物理
    self.camera = require("gameBilliards/app/common/Camera3D").new(false, 3.0, cc.CameraFlag.USER2)
    self:addChild(self.camera)
    self.camera3 = require("gameBilliards/app/common/Camera3D").new(false, 4.0, cc.CameraFlag.USER3)
    self:addChild(self.camera3)
    local physics3DWorld = cc.Director:getInstance():getRunningScene():getPhysics3DWorld()
    physics3DWorld:setGravity(cc.vec3(0.0, 0.0, 0.0))
    -- 加载2D物理
    if g_EightBallData.isDebug then cc.Director:getInstance():getRunningScene():getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL) end
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, 0))
    local function physicsFixedUpdate(delta)
        if not EightBallGameManager:getCanRefreshBallAni() then return end  -- 特定条件不跑物理世界，性能更优化
        for i = 1, g_EightBallData.freshCount do
            cc.Director:getInstance():getRunningScene():getPhysicsWorld():step(1 / g_EightBallData.screenRefreshRate)
        end
        self:refreshBallsAni()
    end
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setAutoStep(false)
    self.node:scheduleUpdateWithPriorityLua(physicsFixedUpdate, 0)
end

function EightBallLayer:onExit()
    print("EightBallLayer:onExit")
    --DisplayObserver.getInstance():delDisplayByName("EightBallLayer")
    G_IsInGame = false
     --测试
    ------------------------------------------------------------------------------------------------------------------
--   rmgr:setIsChangeGamePlayer(false)
--   local _key = G_PlayerInfoList:keyFind(player:getPlayerUserID())
--   local requestData = {
--       tableID = G_PlayerInfoList[_key].TableID,
--       seatID = G_PlayerInfoList[_key].SeatID,
--   }
--   ClientNetManager.getInstance():requestCmd(g_Room_REQ_LEAVETABLE, requestData, G_ProtocolType.Room)
    ------------------------------------------------------------------------------------------------------------------

    self:closeSyncBallTimeEnter()
    self:closeCheckStopTimeEntry()
    ClientNetManager.getInstance():requestCmd(g_Room_REQ_LEAVETABLE, requestData, G_ProtocolType.Room)
    ClientNetManager.getInstance():closeRoomAlive()
    ClientNetManager.getInstance():Close(G_ProtocolType.Room)
    mTipBalls = {}
    if self and not tolua.isnull(self) then
        if self.camera then
            self.camera = nil
        end
        if self.camera3 then
            self.camera3 = nil
        end
        --self:restart()
        self:stopAllActions()
        self:removeEvents()
    end
end

function EightBallLayer:cleanWaitPanel()
    print("[EightBallLayer] cleanWaitPanel")
    if tool.cleanLoadingEffect then
        tool:cleanLoadingEffect()
    end
end

-- 移除注册事件
function EightBallLayer:removeEvents()
    local appBase = AppBaseInstanse.Mobile_APP
    appBase.RoomMsgCenter:removeListenerByTable(self.roomEventListeners)
    appBase.GameMsgCenter:removeListenerByTable(self.gameEventListeners)
    appBase.PortalMsgCenter:removeListenerByTable(self.portalEventListeners)
end

return EightBallLayer