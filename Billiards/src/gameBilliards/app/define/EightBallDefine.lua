local EightBallDefine = {}

EightBallDefine.netSynchronizationRate                  = 0.1  --网络帧同步的间隔时间（const）

----------------------------------------------------------------------------------------------------------

local ballDensity                                       = 2.7  --球体密度

local ballRestiution                                    = 0.95  --球体弹性(0-1)

local whiteBallFiction                                  = 0.2   --白球摩擦力

local ballFriction                                      = 0  --球体摩擦力

EightBallDefine.increaseVelocityTime                    = 1  --开球多久后可以开始减速

EightBallDefine.ballLinearDamping                       = 0.7  --球体线性阻尼(空气阻力)

EightBallDefine.ballLinearIncreaseMultiple              = 0.7  --当球体速度小于ballDampingValue时，速度多少

EightBallDefine.ballLinearIncreaseDoubleMultiple        = 1  --二次衰减速率减少

EightBallDefine.ballDampingValue                        = 300*300   --球体衰减速度的速度阈值(多少速度就开始摩擦力翻倍)

EightBallDefine.ballDoubleDampingValue                  = 150*150  --球体速度二次衰减

EightBallDefine.ballAngularDamping                      = 1  --球体旋转阻尼,旋转的阻力

EightBallDefine.ballRollingRate                         = 20    --球体3d滚动动画的快慢,越大是滚动1米需要的圈数越小(数值越大，滚动速度越慢)(动画速度)

----------------------------------------------------------------------------------------------------------

local borderDensity                                     = 10000000  --边界密度

local borderRestiution                                  = 0.8  --边界弹性(0-1)

local borderFriction                                    = 0.5  --边界摩擦力

----------------------------------------------------------------------------------------------------------

EightBallDefine.lineSpeedRatio                          = 16000  --直线瞬间力量系数

EightBallDefine.lineForceRatio                          = 5  --直线击打力量系数，越大力量越大

EightBallDefine.rotateForceRatio                        = 10000  --高低干力量系数，越大旋转越激烈

EightBallDefine.leftRightForceRatio                     = 300  --左右塞的力量系数

EightBallDefine.prickForceRatio                         = 10  --扎杆的旋转强度，越大旋转越强烈(弧线球)

----------------------------------------------------------------------------------------------------------

EightBallDefine.isDebug                                 = false  --调试模式，正式服关闭

local Gravity                                           = -9.8  --重力 （const）

EightBallDefine.ReservedDigit                           = 10  --精确到小数第几位

EightBallDefine.freshCount                              = 5  --刷新频率const，越高增加精度(莫动)，越高越卡，每秒检测次数 （const）

EightBallDefine.screenRefreshRate                       = EightBallDefine.freshCount*60.0  --勿动，屏幕帧率，现在是5*60=300 （const）

EightBallDefine.ballVelocityLimit                       = 4  --判断小球停止的最小速度 

----------------------------------------------------------------------------------------------------------

--白球初始位置
EightBallDefine.whiteBallOriginalPos                    = cc.p(270,273.5)

EightBallDefine.ballScale                               = 1  --球体缩放大小

EightBallDefine.radius                                  = 15  --小球半径

EightBallDefine.radius_3D                               = cc.Sprite3D:create("gameBilliards/3d_ball/ball.obj"):getContentSize().width / 2

----------------------------------------------------------------------------------------------------------

EightBallDefine.sendSetWhiteBallInterval                = 0.5  --发送重置白球位置消息间隔

EightBallDefine.sendSetCueInterval                      = 0.5  --发送重置杆子位置消息间隔

EightBallDefine.sendHitResultInterval                   = 0.5  --发送击球结果消息间隔

EightBallDefine.receiveHitWhiteBallInterval             = 1  --收到击球信息后击打延迟

EightBallDefine.operateTimer                            = 25   --定时器间隔

EightBallDefine.checkStopTimerInterval                  = 0.1  --检测停止定时器间隔

EightBallDefine.checkQuickClickInterval                 = 0.2  --判断快速点击的时间间隔

----------------------------------------------------------------------------------------------------------

--@边界刚体属性
EightBallDefine.borderPhysicsMaterial                   = cc.PhysicsMaterial(borderDensity, borderRestiution, borderFriction)
--@球体刚体属性
EightBallDefine.ballPhysicsMaterial                     = cc.PhysicsMaterial(ballDensity, ballRestiution, ballFriction)
--@白球刚体属性
EightBallDefine.whilteBallPhysicsMaterial               = cc.PhysicsMaterial(ballDensity, ballRestiution, whiteBallFiction)

----------------------------------------------------------------------------------------------------------

EightBallDefine.inBagPos                                = cc.p(-15, 487)

EightBallDefine.auditionWinScore                        = 2

EightBallDefine.auditionLoseScore                       = -1

EightBallDefine.HitColor = {
    notMy               = -1,       --不是我的回合
    none                = 0,        --初始
    full                = 1,        --该打全色
    half                = 2,        --该打花色
    black               = 3,        --该打黑球
}

EightBallDefine.word = {
    your                = 1,        --该你击球
    full                = 2,        --你将击打全色球
    half                = 3,        --你将击打花色球
}

EightBallDefine.sound = {
    ball                = 1,
    cue                 = 2,
    pocket              = 3,
    fineTurning         = 4,
    back                = 5,
}

EightBallDefine.ballState = {
    stop                = 0,
    run                 = 1,
    inHole              = 2
}

EightBallDefine.gameState = {
    practise            = -1,       --练习模式(比赛还没开始)
    none                = 0,        --初始(等待开始或者等待他人动作)
    waiting             = 1,        -- 比赛开始放置白球
    hitBall             = 2,        -- 击球阶段
    setWhite            = 3,        -- 设置白球(犯规后的设置白球)
    gameOver            = 4,        -- 游戏结束
}

EightBallDefine.gameRound = {
    countdown           = -2,       --不是判断，只是倒计时的函数result索引
    practise            = -1,       --练习模式(比赛还没开始)
    none                = 0,        --初始
    foul                = 1,        --犯规，交换击球
    keep                = 2,        --继续击球
    change              = 3,        --交换击球
    gameOver            = 4,        --比赛结束(黑八进了)
    restart             = 5,        --首杆进黑八
    exception           = 6,        --异常情况(在倒计时框中是关闭倒计时)
}

EightBallDefine.g_GZOrder = {
    ball                = 0,        --球体Z轴
    render3D            = 0,        --3D刚体Z轴
    cue                 = 0,        --杆Z轴
    heighLight          = -1,      --高光Z轴
    checkLine           = 2000,     --碰撞检测线Z轴
    powerBar            = 20000,    --碰撞检测线Z轴
    whiteHand           = 2001,     --拿起白球白手Z轴
    forbidden           = 2000,     --禁止放置白球Z轴
}

EightBallDefine.g_Layer_Tag = {
    mainLayer           = 1000,
    commonLayer         = 2000,
    whiteBallLayer      = 3000,
}

EightBallDefine.g_Border_Tag = {
    whiteBall           = 0,
    one                 = 1,
    two                 = 2,
    three               = 3,
    four                = 4,
    five                = 5,
    six                 = 6,
    seven               = 7,
    eight               = 8,
    nine                = 9,
    ten                 = 10,
    eleven              = 11,
    twelve              = 12,
    thirteen            = 13,
    fourteen            = 14,
    fifteen             = 15,

    texture3D           = 8,
    timer               = 9,
    clockParticle       = 10,
    tipsTimer           = 11,

    whiteShadow         = 20,
    forbidden           = 21,
    moveHand            = 22,
    tips                = 23,
    linkSpine           = 24,

    border              = 100,
    hole                = 200,
    bagBorder           = 225,
    bagBottom           = 226,
    cueCheck            = 250,
    lineCheck           = 300,
    circleCheck         = 350,
    circleShadow        = 351,
    whiteBallLine       = 352,
    colorBallLine       = 353,
    whiteCollisionLine  = 400,
    ballCollisionLine   = 450,
    heighLight          = 1000,
    cue                 = 1500,
}

return EightBallDefine
