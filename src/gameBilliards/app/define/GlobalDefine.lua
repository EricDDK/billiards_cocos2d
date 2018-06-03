--全局常量，物理属性

g_NetSynchronization_Rate = 0.1  --网络帧同步的间隔时间（const）

----------------------------------------------------------------------------------------------------------

local ballDensity = 1  --球体密度

local ballRestiution = 0.95  --球体弹性(0-1)

local whiteBallFiction = 0.05   --白球摩擦力
local ballFriction = 0  --球体摩擦力

ballLinearDamping = 0.5  --球体线性阻尼(空气阻力)

ballLinearIncreaseMultiple = 2  --当球体速度小于ballDampingValue时，速度减少速率的倍数

ballDampingValue = 250   --球体衰减速度的速度阈值(多少速度就开始摩擦力翻倍)

ballAngularDamping = 1  --球体旋转阻尼,旋转的阻力

ballRollingRate = 10    --球体3d滚动动画的快慢,越大是滚动1米需要的圈数越小(数值越大，滚动速度越慢)(动画速度)

----------------------------------------------------------------------------------------------------------

local borderDensity = 100000000000  --边界密度

local borderRestiution = 0.7  --边界弹性(0-1)

local borderFriction = 1  --边界摩擦力

----------------------------------------------------------------------------------------------------------

lineSpeedRatio = 13  --直线瞬间力量系数

lineForceRatio = 3000  --直线击打力量系数，越大力量越大

rotateForceRatio = 5000  --高低干力量系数，越大旋转越激烈

leftRightForceRatio = 150  --左右塞的力量系数

prickForceRatio = 100  --扎杆的旋转强度，越大旋转越强烈(弧线球)

----------------------------------------------------------------------------------------------------------

isDebug = false  --调试模式，正式服关闭

circlePI = 3.1415927  --圆周率，π （const）

local Gravity = -9.8  --重力 （const）

freshCount = 20  --刷新频率const，越高增加精度(莫动)，越高越卡，每秒检测次数 （const）

screenRefreshRate = freshCount*60.0  --勿动，屏幕帧率，现在是5*60=300 （const）

g_Velocity_Limit = 0.2  --判断小球停止的最小速度 

----------------------------------------------------------------------------------------------------------

--@边界刚体属性
borderPhysicsMaterial = cc.PhysicsMaterial(borderDensity, borderRestiution, borderFriction)
--@球体刚体属性
ballPhysicsMaterial = cc.PhysicsMaterial(ballDensity, ballRestiution, ballFriction)
whilteBallPhysicsMaterial = cc.PhysicsMaterial(ballDensity, ballRestiution, whiteBallFiction)

--白球初始位置
whiteBallOriginalPos = cc.p(355,300)

ballScale = 0.2  --球体缩放大小

g_ball_define = {
    
}

g_game_state = {
    Putting = 0,  --摆球
    Break = 1, --开球
    Over = 2,  --比赛结束
}

g_Border_Tag = {
    whiteBall = 0,
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    ten = 10,
    eleven = 11,
    twelve = 12,
    thirteen = 13,
    fourteen = 14,
    fifteen = 15,
    border = 100,
    hole = 200,
    cueCheck = 250,
    lineCheck = 300,
    circleCheck = 350,
    whiteCollisionLine = 400,
    ballCollisionLine = 450
}

cueZOrder = 200  --杆子的Z轴坐标
lineZOrder = 199  --直线的Z轴坐标
circleZOrder = 201  --圆圈的Z轴坐标
whiteCollisionLineOrder = 202  --白球碰撞检测线坐标
ballCollisionLineOrder = 203  --彩球碰撞检测线坐标
