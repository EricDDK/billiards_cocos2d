local AGamePhysicalBase = require("AGameCommon.AGamePhysicalBase")
local EightBallLayer = class("EightBallLayer", AGamePhysicalBase)

local nImg_VS                       = 110  --VS面板
local nImg_User1                    = 111  --选手1
local nImg_User2                    = 112  --选手2
--local nImg_Head1                    = 113  --选手1的头
--local nImg_Head2                    = 114  --选手2的头
--local nImg_Ball1                    = 115  --选手1的球clone
--local nImg_Ball2                    = 116  --选手2的球clone
local nImg_UpBallBg                 = 117  --右上角的拉杆球的底
local nImg_UpBall                   = 118  --拉杆球
local nImg_UpBallRedPoint           = 119  --拉杆球红点
local nText_VS                      = 120  --比分文字信息(1:5)

local nSlider_PowerBar              = 21  --力量条
local nScroll_PowerCue              = 22  --力量杆裁剪容器
local nImg_PowerCue                 = 23  --力量杆图片

local nPanel_FineTurning            = 31  --微调框裁剪
local nImg_FineTurning1             = 32  --微调框图1
local nImg_FineTurning2             = 33  --微调框图2

local nImg_BallBag                  = 40  --球袋

local nPanel_Users                  = 51  --角色容器
local nImg_PowerBar                 = 52  --力量条容器
local nLayout_FineTurning           = 53  --微调框容器
local nImg_Desk                     = 54  -- * 桌子

--------------------成员变量--------------------

local mCurrentUserID                = -1 --当前操作userid
local m_rotateX                     = 0  --高低杆x
local m_rotateY                     = 0  --高低杆y
local mSyncFrameIndex               = 0  --帧同步当前帧(0.1秒同步一次)

function EightBallLayer:ctor()
    self:registerEvents()
    self:registerTouchHandler()
    self:initView()
end

function EightBallLayer:initView()
    self.bg = ccui.ImageView:create("gameBilliards/eightBall/eightBall_Background.png", UI_TEX_TYPE_LOCAL)
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
            local img_User1 = panel_Users:getChildByTag(nImg_User1)
            local img_User2 = panel_Users:getChildByTag(nImg_User2)
            self.userBall1 = img_User1:getChildByName("_Ball")
            self.userBall2 = img_User2:getChildByName("_Ball")
            self.userHead1 = img_User1:getChildByName("_Head")
            self.userHead2 = img_User2:getChildByName("_Head")
            local img_UpBallBg = panel_Users:getChildByTag(nImg_UpBallBg)
            self.upBall = img_UpBallBg:getChildByTag(nImg_UpBall)
            self.upBall:setTouchEnabled(true)
            self.upBall:addTouchEventListener(btnCallback)
            self.upBallRedPoint = self.upBall:getChildByTag(nImg_UpBallRedPoint)
        end
        self.img_PowerBar = self.node:getChildByTag(nImg_PowerBar)
        if self.img_PowerBar then
            self:initPowerBar(self.img_PowerBar)
        end
        self.layout_FineTurning = self.node:getChildByTag(nLayout_FineTurning)
        if self.layout_FineTurning then
            self.panel_FineTurning = self.layout_FineTurning:getChildByTag(nPanel_FineTurning)
            self.panel_FineTurning:setSwallowTouches(false)
            self.fineTurning_1 = self.panel_FineTurning:getChildByTag(nImg_FineTurning2)
            self.fineTurning_2 = self.panel_FineTurning:getChildByTag(nImg_FineTurning1)
        end
        self.desk = self.node:getChildByTag(nImg_Desk)
        if self.desk then
            self.ballBag = self.desk:getChildByTag(nImg_BallBag)
        end

        self.btn_reset = self.node:getChildByTag(64)
        self.btn_reset:addTouchEventListener(btnCallback)

        self:initPhysicalInfo()
        self:initListener()
        EBGameControl:startGame(self)--测试用
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
end

function EightBallLayer:receiveLeaveTable(event)
    print("EightBallLayer:receiveLeaveTable",event.tableID,event.seatID)
    
end

function EightBallLayer:receiveGameReady(event)
    print("EightBallLayer:receiveGameReady", event.userID ,event.tableID,event.seatID)
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
    dump(event)
    EBGameControl:startGame(self)
    if event.UserID == player:getPlayerUserID() then
        --我先放置球
        EBGameControl:setGameState(g_EightBallData.gameState.waiting)
        mCurrentUserID = player:getPlayerUserID()
        self.slider_PowerBar:setTouchEnabled(true)
    else
        --对方先放置球
        EBGameControl:setGameState(g_EightBallData.gameState.none)
        mCurrentUserID = -1
        self.slider_PowerBar:setTouchEnabled(false)
    end
end

function EightBallLayer:receiveSetWhiteBall(event)
    print("EightBallLayer:receiveSetWhiteBall")
    event.fPositionX = GetPreciseDecimal(event.fPositionX)
    event.fPositionY = GetPreciseDecimal(event.fPositionY)
    dump(event)
    if event.UserID ~= player:getPlayerUserID() then
        local pos = {x = event.fPositionX,y = event.fPositionY}
        self.whiteBall:whiteBallTouchBegan(self,event.fPositionX,event.fPositionY,true)
        --self.whiteBall:whiteBallTouchMoved(self,pos,true)
        self.whiteBall:whiteBallTouchEnded(self,pos,true)
    end
end

function EightBallLayer:receiveSetCueInfo(event)
    print("EightBallLayer:receiveSetCueInfo")
    event.fAngle = GetPreciseDecimal(event.fAngle)
    dump(event)
    if event.UserID ~= player:getPlayerUserID() then
        self.cue:setRotationOwn(event.fAngle,self)
    end
end

function EightBallLayer:receiveSyncBallInfo(event)
    print("EightBallLayer:receiveSyncBallInfo")
    --dump(event.BallInfoArray)
    if event.UserID ~= player:getPlayerUserID() then
        EightBallGameManager:insertSyncBallArray(event,event.FrameIndex)
    end
end

function EightBallLayer:receiveHitWhiteBall(event)
    print("EightBallLayer:receiveHitWhiteBall")
    dump(event)
    mCurrentUserID = ((player:getPlayerUserID() == event.UserID) and {player:getPlayerUserID()} or {event.UserID})[1]
    --开启定时器的回调函数
    local hitWhiteBallCallback = function(data)
        if self and not tolua.isnull(self) then
            self:openSyncBallTimeEntry()
            self:openCheckStopTimeEntry()
        end
    end
    self.slider_PowerBar:setPercent(0)
    m_rotateX = 0 m_rotateY = 0
    self.upBallRedPoint:setPosition(cc.p(m_rotateX * 30 + 29.5, m_rotateY * 30 + 29.5))
    self.cue:receiveLauchBall(event,hitWhiteBallCallback)
end

function EightBallLayer:receiveHitBallResult(event)
    print("EightBallLayer:receiveHitBallResult")
    dump(event)

end

function EightBallLayer:receiveGameOver(event)
    print("EightBallLayer:receiveGameOver")
    dump(event)

    EBGameControl:setGameRound(g_EightBallData.gameRound.none)

    -- 测试
    -----------------------------------------------------------------------------
    local _key = G_PlayerInfoList:keyFind(player:getPlayerUserID())
    local requestData = {
        tableID = G_PlayerInfoList[_key].TableID,
        seatID = G_PlayerInfoList[_key].SeatID,
    }
    ClientNetManager.getInstance():requestCmd(g_Room_REQ_GAMEREADY, requestData, G_ProtocolType.Room)
    -----------------------------------------------------------------------------

end

function EightBallLayer:receiveResume(event)
    print("EightBallLayer:receiveResume")
    dump(event)
end

function EightBallLayer:showOriginRolePanel()
    if not rmgr:getIsChangeGamePlayer() then
        dmgr:initPlayerInfoList()
    end
end

--获取是不是我击球
function EightBallLayer:returnIsMyOperate()
    --如果是练习模式，就是我
    if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
        return true
    end
    return mCurrentUserID == player:getPlayerUserID()
end

--初始化物理世界以及信息
function EightBallLayer:initPhysicalInfo()
    PhyControl:initEightBallPhysicalBorder(self)
    PhyControl:initEightBallAllBalls(self)
    self.whiteBall = self.desk:getChildByTag(g_EightBallData.g_Border_Tag.whiteBall)
    self.cue = PhyControl:initCue(self.whiteBall)
    self.routeLine = self.cue:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck)
    self.cue:setRotationOwn(0,self)
    --self.whiteBall:getPhysicsBody():setVelocity(cc.p(1000,0))
end

--创建监听
function EightBallLayer:initListener()
    EBGameControl:initListener(self)
    EBGameControl:initCheckCollisionListener(self)
end

--初始化力量条
function EightBallLayer:initPowerBar(img_PowerBar)
    local function percentChangedEvent(sender, eventType)
        if eventType == ccui.SliderEventType.slideBallUp then
            self.cue:launchBall(self.slider_PowerBar:getPercent(),self.desk,m_rotateX,m_rotateY)
            self.slider_PowerBar:setPercent(0)
            self.cue:setPercent(0)
            --练习模式不打开定时器,连续打开两次会卡
            if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
                self:openCheckStopTimeEntry()
            end
            m_rotateX = 0 m_rotateY = 0 
            self.upBallRedPoint:setPosition(cc.p(m_rotateX*30+29.5,m_rotateY*30+29.5))
        elseif eventType == ccui.SliderEventType.percentChanged then
            self.cue:setPercent(self.slider_PowerBar:getPercent())
        end
    end
    self.slider_PowerBar = img_PowerBar:getChildByTag(nSlider_PowerBar)
    self.slider_PowerBar:setSwallowTouches(true)
    self.slider_PowerBar:addEventListener(percentChangedEvent)
end

local speedCount = 0
--帧数刷新重置球状态(滚动，速度，旋转，3D渲染等等)
--@isCollision 是否是碰撞触发的
function EightBallLayer:refreshBallAni(isCollision)
    self.whiteBall:adjustHighLight()  -- 只调整白球的高光效果 
    if not isCollision then
        speedCount = speedCount + 1
        if speedCount >= 10 then
            speedCount = 0
        else
            return
        end
    end
    for i = 0, 15 do
        local ball = self.desk:getChildByTag(i)
        if ball then
            ball:adjustBallSpeed()
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
        elseif nTag == nImg_UpBall then
            self:openWhiteBallLayer()
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        
    elseif eventType == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end
end

--测试用的重置界面按钮事件
function EightBallLayer:resetBalls()
    EBGameControl:startGame(self)
    EBGameControl:setGameState(g_EightBallData.gameState.practise)
end

--打开高低杆界面
function EightBallLayer:openWhiteBallLayer()
    display.getRunningScene():addChild(require("gameBilliards.app.layer.gamebilliardsWhiteBallLayer").new(self,m_rotateX,m_rotateY))
end

---------------------------------------------------  ↑  UI  ↑  --------------------------------------------------------------------

local m_sybcBallTimeEntery = nil
--开启帧同步定时器
function EightBallLayer:openSyncBallTimeEntry()
    local function synchronizeUpdate(dt)
        mSyncFrameIndex = mSyncFrameIndex + 1
        -- 这是我的击球,负责发送就可以
        if mCurrentUserID == player:getPlayerUserID() then
            -- 这是对手的击球，我需要接受并且判断有没有问题再进行补充发送
            EBGameControl:sendSyncBalls(mSyncFrameIndex)
        else
            local syncArray = EightBallGameManager:getSyncBallArray()
            print("the deal with receive sync frame index = ", mSyncFrameIndex)
            if syncArray and #syncArray > mSyncFrameIndex then
                for i = 0, 15 do
                    local ball = self.desk:getChildByTag(i)
                    if ball then
                        local value = syncArray[mSyncFrameIndex].BallInfoArray
                        ball:syncBallState(value[i + 1])
--                        if i == 0 then
--                            _print("sync whiteBall pos = ",value[i+1].fPositionX,value[i+1].fPositionY)
--                        end
                    end
                end
            else
                
            end
        end
    end
    self:closeSyncBallTimeEnter()  --防止开两个定时器导致泄漏
    m_sybcBallTimeEntery = cc.Director:getInstance():getScheduler():scheduleScriptFunc(synchronizeUpdate, g_EightBallData.netSynchronizationRate, false)
end

--关闭帧同步定时器
function EightBallLayer:closeSyncBallTimeEnter()
    if m_sybcBallTimeEntery then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(m_sybcBallTimeEntery)
        m_sybcBallTimeEntery = nil
        EBGameControl:sendSyncBalls(mSyncFrameIndex)
    end
    mSyncFrameIndex = 0
end

local m_ballMoveSchedulerEntry = nil  --定时器
--检测球停止定时器
function EightBallLayer:openCheckStopTimeEntry()
    print("****************openCheckStopTimeEntry****************")
    local function checkCueVisibleState(dt)
        local isAllBallStop = false  --球是否全部停止
        for i = 0, 15 do
            local ball = self.desk:getChildByTag(i)
            if ball then
                local isBallStop = ball:checkIsStop()
                if isBallStop then
                    ball:resetForceAndEffect()
                elseif isBallStop == false then
                    isAllBallStop = true
                end
            end
        end
        if not isAllBallStop then
            print("all of the balls are stopped")
            for i = 0, 15 do
                local ball = self.desk:getChildByTag(i)
                if ball then
                    ball:resetForceAndEffect()
                end
            end
            if self and not tolua.isnull(self) then
                if self.desk:getChildByTag(0):getBallState() ~= g_EightBallData.ballState.inHole  then
                    self.cue:setCueLineCircleVisible(true)
                end
                self:closeCheckStopTimeEntry()
                self:closeSyncBallTimeEnter()
            end
        end
    end
    self:closeCheckStopTimeEntry() --防止开两个定时器导致泄漏
    m_ballMoveSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(checkCueVisibleState, 0.1, false)
end

--关闭检测球停止定时器
function EightBallLayer:closeCheckStopTimeEntry()
    print("****************closeCheckStopTimeEntry******************")
    if m_ballMoveSchedulerEntry then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(m_ballMoveSchedulerEntry)
        m_ballMoveSchedulerEntry = nil
    end
    EBGameControl:sendHitBallsResult(mCurrentUserID) --发送击球结果消息
end

function EightBallLayer:onEnter()
    print("EightBallLayer:onEnter")
    rmgr.registerEvents()
     g_IsSendRequest = true
    -- 开始发送房间心跳包
    ClientNetManager.getInstance():keepRoomAlive()
    ClientNetManager.getInstance():Connect("192.168.0.250", 19838, G_ProtocolType.EIGHTBALL)

    DisplayObserver.getInstance():addDisplayByName("EightBallLayer",self)
    --加载3D物理
    self.camera = require("gameBilliards/app/common/Camera3D").new(false,3.0,cc.CameraFlag.USER2)
    self:addChild(self.camera)
    local physics3DWorld = cc.Director:getInstance():getRunningScene():getPhysics3DWorld()
    physics3DWorld:setGravity(cc.vec3(0.0,0.0,0.0))
    --加载2D物理
    if g_EightBallData.isDebug then cc.Director:getInstance():getRunningScene():getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL) end
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, 0))
    local function physicsFixedUpdate(delta)
        for i = 1, g_EightBallData.freshCount do
            cc.Director:getInstance():getRunningScene():getPhysicsWorld():step(1 / g_EightBallData.screenRefreshRate)
        end
        self:refreshBallAni()
    end
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setAutoStep(false)
    self.node:scheduleUpdateWithPriorityLua(physicsFixedUpdate, 0)
end

function EightBallLayer:onExit()
    print("EightBallLayer:onExit")

    --测试
    ------------------------------------------------------------------------------------------------------------------
    rmgr:setIsChangeGamePlayer(false)
    local _key = G_PlayerInfoList:keyFind(player:getPlayerUserID())
    local requestData = {
        tableID = G_PlayerInfoList[_key].TableID,
        seatID = G_PlayerInfoList[_key].SeatID,
    }
    ClientNetManager.getInstance():requestCmd(g_Room_REQ_LEAVETABLE, requestData, G_ProtocolType.Room)
    ------------------------------------------------------------------------------------------------------------------

    ClientNetManager.getInstance():requestCmd(g_Room_REQ_LEAVETABLE, requestData, G_ProtocolType.Room)
    ClientNetManager.getInstance():closeRoomAlive()
    ClientNetManager.getInstance():Close(G_ProtocolType.Room)
    DisplayObserver.getInstance():delDisplayByName("EightBallLayer")
    if self and not tolua.isnull(self) then
        self:stopAllActions()
        self:removeEvents()
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