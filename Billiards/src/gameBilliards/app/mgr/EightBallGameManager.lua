EightBallGameManager = EightBallGameManager or {}

local mCurrentUserID                    = -1    -- 当前可操作userid
local mFullColorUserID                  = -1    -- 击打全色球的userid
local mHalfColorUserID                  = -1    -- 击打半色球的userid
local mGameRound                        = 0     -- 和服务器保持一致的轮次索引

--获取是不是我击球
function EightBallGameManager:returnIsMyOperate()
    --如果是练习模式，就是我
    if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
        return true
    end
    return mCurrentUserID == player:getPlayerUserID()
end

function EightBallGameManager:setCurrentUserID(args)
    if args then
        mCurrentUserID = args
    end
end

function EightBallGameManager:getCurrentUserID()
    return mCurrentUserID 
end

--封装转换小数www
local function preciseDecimalBallsInfo(v)
    v.fPositionX = GetPreciseDecimal(v.fPositionX)
    v.fPositionY = GetPreciseDecimal(v.fPositionY)
    v.fVelocityX = GetPreciseDecimal(v.fVelocityX)
    v.fVelocityY = GetPreciseDecimal(v.fVelocityY)
    v.fAngularVelocity = GetPreciseDecimal(v.fAngularVelocity)
    v.fUnevenBarsForceX = GetPreciseDecimal(v.fUnevenBarsForceX)
    v.fUnevenBarsForceY = GetPreciseDecimal(v.fUnevenBarsForceY)
    v.fPrickStrokeForceX = GetPreciseDecimal(v.fPrickStrokeForceX)
    v.fPrickStrokeForceY = GetPreciseDecimal(v.fPrickStrokeForceY)
end

--帧同步数组
local syncBallArray = {}
function EightBallGameManager:insertSyncBallArray(value,index)
    if index <= 1 then
        EightBallGameManager:clearSyncBallArray()
    end
    --保留小数点后5位
    for k,v in pairs(value.BallInfoArray) do
        v.fPositionX = GetPreciseDecimal(v.fPositionX)
        v.fPositionY = GetPreciseDecimal(v.fPositionY)
        v.fVelocityX = GetPreciseDecimal(v.fVelocityX)
        v.fVelocityY = GetPreciseDecimal(v.fVelocityY)
    end
    syncBallArray[index] = value
end

function EightBallGameManager:setSyncBallArray(event)
    syncBallArray = event
end

function EightBallGameManager:getSyncBallArray()
    return syncBallArray
end

function EightBallGameManager:clearSyncBallArray()
    syncBallArray = {}
end


--存放这一次击打的所有消息的
--@ 碰撞信息，进球信息，单次碰撞信息
--@ collisionBorderCount 碰壁次数,所有球都算
--@ firstCollisionIndex 白球首次碰撞彩色球的索引
--@ firstInHoleBall 第一个进的球的索引
local hitBallsProcessArray = {
    collisionBorderCount = 0,
    firstCollisionIndex = 0,
    firstInHoleBall = -1,
}
--处理碰撞，保存数据发送给服务端做校验
function EightBallGameManager:dealCollisionToServer(tagA,tagB)
    if tagA and tagB then
        if tagA == g_EightBallData.g_Border_Tag.border or tagB == g_EightBallData.g_Border_Tag.border then
            hitBallsProcessArray.collisionBorderCount = hitBallsProcessArray.collisionBorderCount + 1
            return
        end
        if hitBallsProcessArray.firstCollisionIndex <= 0 and (tagA == g_EightBallData.g_Border_Tag.whiteBall or tagB == g_EightBallData.g_Border_Tag.whiteBall) then
            local anotherTag = (tagA == g_EightBallData.g_Border_Tag.whiteBall and tagB or tagA )
            if anotherTag <= 15 and anotherTag >= 1 then
                hitBallsProcessArray.firstCollisionIndex = anotherTag
                print("deal Collision To Server the first collison index = ",anotherTag)
                return
            end
        end
    end
    return
end

--处理进球，保存数据发送给服务端做校验
function EightBallGameManager:dealInHoleToServer(tag)
    -- 不是白球的进球才计算
    if tag <= 15 and tag >= 1 then
        if hitBallsProcessArray.firstInHoleBall < 0 then
            hitBallsProcessArray.firstInHoleBall = tag
        end
        --练习模式处理进球，加连杆数
        if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
            EightBallGameManager:setLinkCount(true)
        end
    end
end

function EightBallGameManager:getHitBallsProcess()
    return hitBallsProcessArray
end

function EightBallGameManager:clearBallsProcess()
    hitBallsProcessArray = {
        collisionBorderCount = 0,
        firstCollisionIndex = 0,
        firstInHoleBall = - 1,
    }
end


--@ 保存服务器发送的击球统计结果
--@ 调整所有球的位置精度
local ballsResultArray = {}
local isSyncHitResult = false  --是否同步过数据，一个数据包同步一次
function EightBallGameManager:setBallsResultPos(event)
    ballsResultArray = event
    isSyncHitResult = false
end

function EightBallGameManager:getBallsResultPos()
    return ballsResultArray
end

function EightBallGameManager:getIsSyncHitResult()
    return isSyncHitResult
end

--击球结果同步数组
local switch = {
    [g_EightBallData.gameRound.none] = function()
        print("\n       result is none \n")
        EBGameControl:setGameState(g_EightBallData.gameState.none)
    end,
    [g_EightBallData.gameRound.foul] = function()
        print("\n           result is foul \n")
        --第一轮次就打进白球，重新摆白球进行击打
        if ballsResultArray.RountCount == 0 then
            EBGameControl:setGameState(g_EightBallData.gameState.waiting)
        else
            EBGameControl:setGameState(g_EightBallData.gameState.setWhite)
        end
    end,
    [g_EightBallData.gameRound.keep] = function()
        print("\n           result is keep \n")
        EBGameControl:setGameState(g_EightBallData.gameState.hitBall)
    end,
    [g_EightBallData.gameRound.change] = function()
        print("\n           result is change \n")
        EBGameControl:setGameState(g_EightBallData.gameState.hitBall)
    end,
    [g_EightBallData.gameRound.gameOver] = function()
        print("\n           result is gameOver \n")
        EBGameControl:setGameState(g_EightBallData.gameState.gameOver)
    end,
    [g_EightBallData.gameRound.restart] = function()
        print("\n           result is restart \n")
        EBGameControl:setGameState(g_EightBallData.gameState.waiting)
    end,
}
-- 同步一下结果，所有球位置修正
--@ rootNode 游戏主layer
function EightBallGameManager:syncHitResult(rootNode, isResume)
    print("EightBallGameManager syncHitResult",debug.traceback())
    if isSyncHitResult and not isResume then
        return
    end
    if not isResume then
        isSyncHitResult = true
    end
    -- 白球进洞处理
    print("EightBallGameManager:syncHitResult ", EBGameControl:getGameState(), ballsResultArray.UserID)
    if rootNode.whiteBall:getIsInHole() then
        print("whiteball is in hall !! ")
        EBGameControl:dealWhiteBallInHole()
    end

    -- 练习模式不走同步击球结果
    -- 如果ballsResultArray.UserID不存在就说明消息还没回来，这时候需要return出来等待消息回来主动调用此函数
    -- userid是空也代表存在异常，解决了击打者击打完会出现杆子0.5秒再消失的bug
    if EBGameControl:getGameState() == g_EightBallData.gameState.practise
        or not next(ballsResultArray) or not ballsResultArray.UserID then
        return
    end

    EightBallGameManager:setCurrentUserID(ballsResultArray.UserID)

    print("this round hit ball userid = ", ballsResultArray.UserID)
    if ballsResultArray.UserID == player:getPlayerUserID() then
        -- 我的回合
        BilliardsAniMgr:setSliderBarAni(true, rootNode)
        --BilliardsAniMgr:setFineTurningAni(true, rootNode)
    else
        -- 对方回合，我等
        BilliardsAniMgr:setSliderBarAni(false, rootNode)
        --BilliardsAniMgr:setFineTurningAni(false, rootNode)
    end
    -- 设置我的击球颜色
    EightBallGameManager:setColorUserID(ballsResultArray.FullColorUserID, ballsResultArray.HalfColorUserID, rootNode)
    -- result获取比赛当前状态
    local func = switch[ballsResultArray.Result]
    if func then
        func()
    end

    BilliardsAniMgr:setGameTips(rootNode, ballsResultArray.Result)
    -- 黑色提示框
    EightBallGameManager:setCanOperate(true)
    -- 可以操作了

    -- 首杆黑八进洞，重新摆放球开始比赛
    if ballsResultArray.Result == g_EightBallData.gameRound.restart then
        EBGameControl:startGame()
        if player:getPlayerUserID() == EightBallGameManager:getCurrentUserID() then
            rootNode.whiteBall:dealWhiteBallInHole()
        end
        return
        -- 换你击球动画
    elseif (ballsResultArray.Result == g_EightBallData.gameRound.change or ballsResultArray.Result == g_EightBallData.gameRound.foul)
        and player:getPlayerUserID() == mCurrentUserID then
        BilliardsAniMgr:createWordEffect(rootNode, g_EightBallData.word.your)
        -- 换你击球文字动画
    end

    -- 显示连杆动画
    if ballsResultArray.LinkCount and ballsResultArray.LinkCount > 1 then
        BilliardsAniMgr:createLinkEffect(rootNode, ballsResultArray.LinkCount)
    end

    -- 结束同步最后同步一下结果函数
    if ballsResultArray and next(ballsResultArray) then
        local ballsArray = ballsResultArray.BallInfoArray
        local ball
        -- 白球进洞或者击打犯规，处理白球进洞流程，单一入口
        if rootNode.whiteBall:getIsInHole() or ballsResultArray.Result == g_EightBallData.gameRound.foul then
            EBGameControl:dealWhiteBallInHole()
        else
            rootNode.whiteBall:setBallsResultState(ballsArray[g_EightBallData.g_Border_Tag.whiteBall + 1], rootNode)
        end
        for i = 1, 15 do
            ball = rootNode.desk:getChildByTag(i)
            if ball then
                ball:setBallsResultState(ballsArray[i + 1], rootNode)
                -- 断线重连后要同步球状态
                if isResume then
                    ball:setIsInHoleByPos(ballsArray[i + 1].fPositionX, ballsArray[i + 1].fPositionY)
                    ball:setVisible(true)
                end
            end
        end
    end

    rootNode.cue:setRotationOwn(0, rootNode)  -- 击球结束同步一下结果
    rootNode.cue:setCueLineCircleVisible(true)
    rootNode.cue:setRotationOwn(0, rootNode)
    BilliardsAniMgr:createUserFrameAni(rootNode)
    EBGameControl:dealTipBalls()  --处理头像框指示球
    EBGameControl:setSuitCuePos()  --设置合适的杆位置
    EBGameControl:doChangeRound()  --交换对手事件
    if ballsResultArray.Result ~= g_EightBallData.gameRound.foul then
        rootNode.whiteBall:clearWhiteBallView()  --清除白球表面tips
    end

    -- 球体底层提示框架（这里是三目，当前轮需要是我）
    -- value = 1 打全色  || value = 2 打半色
    local value =(mFullColorUserID == player:getPlayerUserID() and mCurrentUserID == player:getPlayerUserID()) and 1
    or((mHalfColorUserID == player:getPlayerUserID() and mCurrentUserID == player:getPlayerUserID()) and 9 or 0)
    if value == 1 or value == 9 then
        for i = value, value + 6 do
            local ball = rootNode.desk:getChildByTag(i)
            if ball then
                ball:startTipsEffect()
            end
        end
    end
    ballsResultArray = { }
    EightBallGameManager:setCanRefreshBallAni(false)
end


--击打白球结果数组,暂时存放结果数据用，被同步端结束击打会自动调用
--@ event.fAngularVelocity 这里是白球的当前rotation，不是角速度了！！！
local hitWhiteBallResult = nil
function EightBallGameManager:setHitWhiteResult(event)
    for k,v in pairs(event.BallInfoArray) do
        preciseDecimalBallsInfo(v)
    end
    hitWhiteBallResult = event
end

function EightBallGameManager:getHitWhiteResult()
    return hitWhiteBallResult
end

--是否打全色球
function EightBallGameManager:setColorUserID(fullColorUserID,halfColorUserID,rootNode)
    print("EightBallGameManager:setColorUserID My",mFullColorUserID,mHalfColorUserID)
    print("EightBallGameManager:setColorUserID Game",fullColorUserID,halfColorUserID)
    -- 播放击打全色还是花色动画
    if mFullColorUserID == -1 or mHalfColorUserID == -1 then
        if player:getPlayerUserID() == fullColorUserID then
            BilliardsAniMgr:createWordEffect(rootNode, g_EightBallData.word.full)
        elseif player:getPlayerUserID() == halfColorUserID then
            BilliardsAniMgr:createWordEffect(rootNode, g_EightBallData.word.half)
        end
    end
    mFullColorUserID = fullColorUserID
    mHalfColorUserID = halfColorUserID
end

function EightBallGameManager:getColorUserID()
    return mFullColorUserID,mHalfColorUserID
end

--获取我的颜色，1是全色，2是半色，3是全打完了该打黑色球了
function EightBallGameManager:getMyColor()
    local myColor = g_EightBallData.HitColor.none
    --还没判断好谁打全色球谁打半色球,或者不是我的轮次，自动白色圈圈
    if mFullColorUserID == -1 or mHalfColorUserID == -1 or mCurrentUserID ~= player:getPlayerUserID() then
        myColor = g_EightBallData.HitColor.notMy
    elseif player:getPlayerUserID() == mFullColorUserID then
        myColor = g_EightBallData.HitColor.full
        if EBGameControl:getIsBallAllInHole(myColor) then
            myColor = g_EightBallData.HitColor.black
        end
    elseif player:getPlayerUserID() == mHalfColorUserID then
        myColor = g_EightBallData.HitColor.half
        if EBGameControl:getIsBallAllInHole(myColor) then
            myColor = g_EightBallData.HitColor.black
        end
    else
        myColor = g_EightBallData.HitColor.none
    end
    return myColor
end


--游戏轮次索引
function EightBallGameManager:setGameRound(gameRound)
    if not gameRound then
        print(" set game round param = null ",gameRound)
        return
    end
    mGameRound = gameRound
end

function EightBallGameManager:getGameRound()
    return mGameRound
end


local mCanOperate = true  --是否可以操作界面
function EightBallGameManager:setCanOperate(canOperate)
    mCanOperate = canOperate
end

function EightBallGameManager:getCanOperate()
    return mCanOperate
end


-- 练习模式使用，连击数
local mLinkCount = 0  --连击数
local canCalcurateLinkCount = true  --可以连杆数自加1嘛
function EightBallGameManager:setLinkCount(isInHole)
    if isInHole and canCalcurateLinkCount then
        mLinkCount = mLinkCount + 1
        canCalcurateLinkCount = false
    else
        mLinkCount = 0
    end
end

function EightBallGameManager:getLinkCount()
    --说明没有进球，所以连杆数变0
    if canCalcurateLinkCount then
        mLinkCount = 0
    end
    print("   getLinkCount   = ",mLinkCount)
    return mLinkCount
end

function EightBallGameManager:resetCanCalcurateLinkCount()
    canCalcurateLinkCount = true
end


--控制刷新球滚动状态，减少开销
local mCanRefreshBallAni = false
function EightBallGameManager:setCanRefreshBallAni(canRefresh)
    mCanRefreshBallAni = canRefresh
end

function EightBallGameManager:getCanRefreshBallAni()
    return mCanRefreshBallAni
end


--初始化函数
function EightBallGameManager:initialize()
    mCurrentUserID = -1
    syncBallArray = {}
    ballsResultArray = {}
    isSyncHitResult = false
    hitWhiteBallResult = nil
    mFullColorUserID = -1
    mHalfColorUserID = -1
    mCanOperate = true
    mLinkCount = 0
    mCanRefreshBallAni = false
    mGameRound = 0
end

local effectSwitch = {
    [g_EightBallData.sound.ball] = function ()
        return "gameBilliards/sound/BallHit.mp3"
    end,
    [g_EightBallData.sound.cue] = function ()
        return "gameBilliards/sound/CueHit.mp3"
    end,
    [g_EightBallData.sound.pocket] = function ()
        return "gameBilliards/sound/Pocket.mp3"
    end,
    [g_EightBallData.sound.fineTurning] = function ()
        return "gameBilliards/sound/Fine_Tuning.mp3"
    end,
    [g_EightBallData.sound.back] = function ()
        return "gameBilliards/sound/Billiards_Bg_2.mp3"
    end,
}

function EightBallGameManager:playEffectByIndex(index,volume)
    local funcEffect = effectSwitch[index]
    --if volume then
        amgr.playEffectByVolume(funcEffect(),volume)
--    else
--        amgr.playEffectByVolume(funcEffect())
--    end
end

function EightBallGameManager:playEffectByTag(tagA,tagB,velocity)
    if velocity > 1000 then
        velocity = 1.0
    else
        velocity = velocity/1000
    end
    if tagA and tagB then
        -- 这是球和球的碰撞
        if tagA <= 15 and tagB <= 15 then
            if velocity then
                EightBallGameManager:playEffectByIndex(g_EightBallData.sound.ball,velocity)
            else
                EightBallGameManager:playEffectByIndex(g_EightBallData.sound.ball,1.0)
            end
        elseif tagA == g_EightBallData.g_Border_Tag.hole or tagB == g_EightBallData.g_Border_Tag.hole then
            EightBallGameManager:playEffectByIndex(g_EightBallData.sound.pocket,1.0)
        end
    end
end

local effectRes = {
    "gameBilliards/sound/BallHit.mp3",
    "gameBilliards/sound/CueHit.mp3",
    "gameBilliards/sound/Pocket.mp3",
}
--预加载音频
function EightBallGameManager:preLoadBilliardsEffect()
    amgr.preloadEffect(effectRes)
end

function EightBallGameManager:init()
    --mCanPlayMusic,mCanPlayEffect,mCanViberate = amgr.getMusicAndEffectEnable()
end

return EightBallGameManager