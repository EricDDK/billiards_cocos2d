local EightBallDefine = {}

EightBallDefine.netSynchronizationRate                  = 0.1  --网络帧同步的间隔时间（const）

----------------------------------------------------------------------------------------------------------

local ballDensity                                       = 1  --球体密度

local ballRestiution                                    = 0.95  --球体弹性(0-1)

local whiteBallFiction                                  = 0.05   --白球摩擦力

local ballFriction                                      = 0  --球体摩擦力

EightBallDefine.ballLinearDamping                       = 0.5  --球体线性阻尼(空气阻力)

EightBallDefine.ballLinearIncreaseMultiple              = 1.5  --当球体速度小于ballDampingValue时，速度减少速率的倍数

EightBallDefine.ballLinearIncreaseDoubleMultiple        = 2  --二次衰减速率减少倍数

EightBallDefine.ballDampingValue                        = 250*250   --球体衰减速度的速度阈值(多少速度就开始摩擦力翻倍)

EightBallDefine.ballDoubleDampingValue                  = 150*150  --球体速度二次衰减

EightBallDefine.ballAngularDamping                      = 1  --球体旋转阻尼,旋转的阻力

EightBallDefine.ballRollingRate                         = 10    --球体3d滚动动画的快慢,越大是滚动1米需要的圈数越小(数值越大，滚动速度越慢)(动画速度)

----------------------------------------------------------------------------------------------------------

local borderDensity                                     = 10000000  --边界密度

local borderRestiution                                  = 0.7  --边界弹性(0-1)

local borderFriction                                    = 1  --边界摩擦力

----------------------------------------------------------------------------------------------------------

EightBallDefine.lineSpeedRatio                          = 13  --直线瞬间力量系数

EightBallDefine.lineForceRatio                          = 2000  --直线击打力量系数，越大力量越大

EightBallDefine.rotateForceRatio                        = 5000  --高低干力量系数，越大旋转越激烈

EightBallDefine.leftRightForceRatio                     = 150  --左右塞的力量系数

EightBallDefine.prickForceRatio                         = 100  --扎杆的旋转强度，越大旋转越强烈(弧线球)

----------------------------------------------------------------------------------------------------------

EightBallDefine.isDebug                                 = false  --调试模式，正式服关闭

local Gravity                                           = -9.8  --重力 （const）

EightBallDefine.freshCount                              = 5  --刷新频率const，越高增加精度(莫动)，越高越卡，每秒检测次数 （const）

EightBallDefine.screenRefreshRate                       = EightBallDefine.freshCount*60.0  --勿动，屏幕帧率，现在是5*60=300 （const）

EightBallDefine.ballVelocityLimit                       = 2  --判断小球停止的最小速度 

----------------------------------------------------------------------------------------------------------

--白球初始位置
EightBallDefine.whiteBallOriginalPos                    = cc.p(270,273.5)

EightBallDefine.ballScale                               = 1  --球体缩放大小

EightBallDefine.radius                                  = 15  --小球半径

EightBallDefine.radius_3D                               = cc.Sprite3D:create("gameBilliards/3d_ball/ball.obj"):getContentSize().width / 2

----------------------------------------------------------------------------------------------------------

EightBallDefine.sendSetWhiteBallInterval                = 0.5  --发送重置白球位置消息间隔

EightBallDefine.sendSetCueInterval                      = 0.5  --发送重置杆子位置消息间隔

----------------------------------------------------------------------------------------------------------

--@边界刚体属性
EightBallDefine.borderPhysicsMaterial                   = cc.PhysicsMaterial(borderDensity, borderRestiution, borderFriction)
--@球体刚体属性
EightBallDefine.ballPhysicsMaterial                     = cc.PhysicsMaterial(ballDensity, ballRestiution, ballFriction)
--@白球刚体属性
EightBallDefine.whilteBallPhysicsMaterial               = cc.PhysicsMaterial(ballDensity, ballRestiution, whiteBallFiction)

----------------------------------------------------------------------------------------------------------

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
    practise            = -1,       --练习模式(比赛还没开始)
    none                = 0,        --初始
    foul                = 1,        --犯规，交换击球
    keep                = 2,        --继续击球
    change              = 3,        --交换击球
    gameOver            = 4,        --比赛结束(黑八进了)
    restart             = 5,        --首杆进黑八
    exception           = 6,        --异常情况
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

    whiteShadow         = 20,
    forbidden           = 21,
    moveHand            = 22,
    tips                = 23,

    border              = 100,
    hole                = 200,
    cueCheck            = 250,
    lineCheck           = 300,
    circleCheck         = 350,
    circleShadow        = 351,
    whiteCollisionLine  = 400,
    ballCollisionLine   = 450,
    heighLight          = 1000,
    cue                 = 1500,
}

return EightBallDefine
