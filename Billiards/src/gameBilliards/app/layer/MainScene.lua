--local MainScene = class("MainScene", cc.load("mvc").ViewBase)

--function MainScene:onCreate()
--    amgr.playMusic("bg_menu.mp3", true)
--    local layer = require(g_myGameName .. "/app/layer/gameBilliardsMainLayer").new()
--    if layer then
--        self:addChild(layer)
--    end
--end

--function MainScene:physicalMethod(m,a,v0,t,m1,m2,v1,v2,Vx,Ux)
--   --牛顿第二定律:
--   --f = m * a
--   local f = m * a 
--   --速度与加速度关系公式:
--   local vt = v0 + a * t
--   --地面摩擦力与运动物体的方向相反, 阻碍物体的向前运动.
--   --动量守恒

--   local m1 * v1 + m2 * v2 = m1 * v1' + m2 * v2'

--   --完全弹性碰撞 
--   --动能没有损失, 则满足如下公式

--   1/2 * m1 * v1^2 + 1/2 * m2 * v2^2 = 1/2 * m1 * v1'^2 + 1/2 * m2 * v2'^2

--   --前后物体的动能保持均衡, 没有其他能量的转化.

--   v1' = [(m1-m2) * v1 + 2 * m2 * v2] / (m1 + m2)
--　 v2' = [(m2-m1) * v2 + 2 * m1 * v1] / (m1 + m2)

--    --完全非弹性碰撞
--    --则存在其他能量的转化, 动能不守恒. 且此时两物体粘连, 速度一致, 即v1'=v2', 此时动能损失最大
--    --检测球与球碰撞
--    (x1 - x2) ^ 2 + (y1 - y2) ^ 2 <= (2*r) ^ 2

--    --检测球与球台边框碰撞
--   -- x轴上满足动量守恒

--　　m1 * Vx + m2 * Ux = m1 * Vx' + m2 * Ux'

--    --并假定两球碰撞是完全弹性碰撞, 两球质量相等m1=m2, 依据基础物理知识篇的结论

--　　Vx' = [(m1-m2) * Vx + 2 * m2 * Ux] / (m1 + m2) = Ux
--　　Ux' = [(m2-m1) * Ux + 2 * m1 * Vx] / (m1 + m2) = Vx

--　　--在X轴方向, 两球交换速度, 而在Y轴方向, 两球分速度不变.
--　　Vy' = Vy
--　　Uy' = Uy
--    --最终碰撞后的速度公式为:

--　　V' = Vx' + Vy' = Ux + Vy
--　　U' = Ux' + Uy' = Vx + Uy

--    --球与边框的碰撞反应 
--    --假定碰撞碰撞平面为x轴

--　　Vx' = Vx
--　　Vy' = -Vy

--　　--最终速度公式为

--　　V' = Vx' + Vy' = Vx - Vy

--    --这个时间间隔(time_interval), 由游戏的FPS来确定. 以24帧为例, 每40毫秒刷新一次.
--　　--对于台球本身而言, 若以该time_interval为更新周期, 使得运动的球体满足:

--　　Vt = V0 + a * t

--　　--运行距离为

--　　S = V0 * t + 1/2 * a * t^2.

--　　--然后来检测球体是否发生了碰撞, 然后进行碰撞反应处理. 看似没有问题.
--end

--function update(time_interval)

--    while time_interval > 0:
--        -- 碰撞检测
--        if detectionCollide(time_interval, least_time, ball_pairs):
--            --/ 游戏更新least_time
--            billiards.update(least_time)
--            -- 对碰撞的两球进行碰撞反应
--            collideReaction(ball_pairs=>(ball, other))
--            --// time_interval 减少 least_time
--            time_interval -= least_time
--        else：
--            --// 游戏更新least_time
--            billiards.update(time_interval)
--            time_interval = 0
--end

----碰撞检测算法
--function detectionCollide(time_interval, least_time, ball_pairs)
--    res = false;
--    least_time = time_interval;

--    foreach ball in billiards:
--        foreach otherBall in billiards:
--            --// 求出两球的距离
--            S = distance(ball, otherBall)
--            --// 以某一球作为参考坐标系, 则令一球速度向量变为 U’=U-V
--            --// 在圆心的直线作为x轴
--            Ux(relative) = Ux(other ball) - Vx(ball)
--            --//  若该方向使得两球远离, 则直接忽略
--            if Ux(relative) < 0：
--                continue
--            --//  某该方向使得两球接近, 则可求其碰撞的预期时间点
--            A' = 2 * A; // 加速度为原来的两倍

--            --// 取两者最小的时间点
--            delta_time = min(time_interval, Ux(relative) / Ax’)
--            --// 预期距离 小于 两球距离，则在time_interval中不会发生碰撞
--            if 1/2 * Ax’ * delta_time ^ 2 + Ux(relative) * delta_time < S - 2*r:
--                continue

--            --/--/ 解一元二次方程, 使用二分搜索逼近求解
--            res_time <= slove(1/2 * Ax’ * x ^ 2 + Ux(relative) * x = S - 2 * r)

--            if res_time < least_time:
--                ball_pairs <= (ball, otherBall)
--                least_time = res_time
--                res = true

--        foreach wall in billiards:
--            S = distance(ball, wall)
--            --// 设垂直于平面的方向为x轴
--            if Vx < 0:
--                continue

--            --// 取两者最小的时间点
--            delta_time = min(time_interval, Vx / Ax)
--            --// 预期距离 小于 两球距离，则在time_interval中不会发生碰撞
--            if 1/2 * Ax * delta_time ^ 2 + Vx * delta_time < S - r:
--                continue

--            --// 解一元二次方程, 使用二分搜索逼近求解 
--            res_time <= slove(1/2 * A * x ^ 2 + Vx * x = S - r)

--            if res_time < least_time:
--                ball_pairs <= (ball, walll)
--                least_time = res_time
--                res = true

--    return res
-- end

-- function Initialize(const b2SimplexCache* cache,  
--        const b2DistanceProxy* proxyA, const b2Sweep& sweepA,  
--        const b2DistanceProxy* proxyB, const b2Sweep& sweepB,  
--        float32 t1)  
--    {  
--        --//赋值代理  
--        m_proxyA = proxyA;  
--        m_proxyB = proxyB;  
--        --// 获取缓存中的顶点数，并验证  
--        int32 count = cache->count;  
--        b2Assert(0 < count && count < 3);  
--        --//赋值扫频  
--        m_sweepA = sweepA;  
--        m_sweepB = sweepB;  
--        --//获取变换  
--        b2Transform xfA, xfB;  
--        m_sweepA.GetTransform(&xfA, t1);  
--        m_sweepB.GetTransform(&xfB, t1);  
--        --//一个顶点  
--        if (count == 1)  
--        {  
--            --//赋值，获得A、B的局部顶点  
--            m_type = e_points;  
--            b2Vec2 localPointA = m_proxyA->GetVertex(cache->indexA[0]);  
--            b2Vec2 localPointB = m_proxyB->GetVertex(cache->indexB[0]);  
--            --//获取变换后的A、B点  
--            b2Vec2 pointA = b2Mul(xfA, localPointA);  
--            b2Vec2 pointB = b2Mul(xfB, localPointB);  
--            --//获取从B到的A的向量，返回其长度，并标准化  
--            m_axis = pointB - pointA;  
--            float32 s = m_axis.Normalize();  
--            return s;  
--        }  
--        else if (cache->indexA[0] == cache->indexA[1])  
--        {  
--            --// 两个点在B上和一个在A上  
--            --//赋值，获取B上的两个局部顶点  
--            m_type = e_faceB;  
--            b2Vec2 localPointB1 = proxyB->GetVertex(cache->indexB[0]);  
--            b2Vec2 localPointB2 = proxyB->GetVertex(cache->indexB[1]);  
--            --//获取B2到B1形成向量的垂直向量，并标准化  
--            m_axis = b2Cross(localPointB2 - localPointB1, 1.0f);  
--            m_axis.Normalize();  
--            --//获取法向量  
--            b2Vec2 normal = b2Mul(xfB.q, m_axis);  
--            --// 获取B1到B2的中间点  
--            m_localPoint = 0.5f * (localPointB1 + localPointB2);  
--            b2Vec2 pointB = b2Mul(xfB, m_localPoint);  
--            --// 获取局部点A，并求得点A  
--            b2Vec2 localPointA = proxyA->GetVertex(cache->indexA[0]);  
--            b2Vec2 pointA = b2Mul(xfA, localPointA);  
--            --// 获取距离  
--            float32 s = b2Dot(pointA - pointB, normal);  
--            --// 距离为负，置反  
--            if (s < 0.0f)  
--            {  
--                m_axis = -m_axis;  
--                s = -s;  
--            }  
--            return s;  
--        }  
--        else  
--        {  
--            --// 两个点在A上和一个或者两个点在B上  
--            m_type = e_faceA;  
--            b2Vec2 localPointA1 = m_proxyA->GetVertex(cache->indexA[0]);  
--            b2Vec2 localPointA2 = m_proxyA->GetVertex(cache->indexA[1]);  
--            --//获取A2到A1形成向量的垂直向量，并标准化  
--            m_axis = b2Cross(localPointA2 - localPointA1, 1.0f);  
--            m_axis.Normalize();  
--            --//获取法向量  
--            b2Vec2 normal = b2Mul(xfA.q, m_axis);  
--            --//获取A1和A2的中间点  
--            m_localPoint = 0.5f * (localPointA1 + localPointA2);  
--            b2Vec2 pointA = b2Mul(xfA, m_localPoint);  
--            --//获取局部点，并求得点B  
--            b2Vec2 localPointB = m_proxyB->GetVertex(cache->indexB[0]);  
--            b2Vec2 pointB = b2Mul(xfB, localPointB);  
--            --//获取距离，并处理  
--            float32 s = b2Dot(pointB - pointA, normal);  
--            if (s < 0.0f)  
--            {  
--                m_axis = -m_axis;  
--                s = -s;  
--            }  
--            return s;  
--        }  
--    }  
--    --[[************************************************************************** 
--    * 功能描述：寻找最小距离 
--    * 参数说明：indexA ：点A的索引 
--                indexB ：点B的索引 
--                t      ：时间值 
--    * 返 回 值： 最小距离 
--    **************************************************************************/]]--  
--    function FindMinSeparation(int32* indexA, int32* indexB, float32 t) const  
--    {  
--        --//声明变换A、B，用于获取在t时间里获得窜改变换  
--        b2Transform xfA, xfB;  
--        m_sweepA.GetTransform(&xfA, t);  
--        m_sweepB.GetTransform(&xfB, t);  
--        --//处理不同的类型  
--        switch (m_type)  
--        {  
--        case e_points:                                --//点  
--            {  
--                --//通过转置旋转m_axis获取单纯形支撑点的方向向量  
--                b2Vec2 axisA = b2MulT(xfA.q,  m_axis);  
--                b2Vec2 axisB = b2MulT(xfB.q, -m_axis);  
--                --//通过方向向量获取局部顶点的索引  
--                *indexA = m_proxyA->GetSupport(axisA);  
--                *indexB = m_proxyB->GetSupport(axisB);  
--                --//通过索引获取局部顶点  
--                b2Vec2 localPointA = m_proxyA->GetVertex(*indexA);  
--                b2Vec2 localPointB = m_proxyB->GetVertex(*indexB);  
--                --//通过变换局部点获取两形状之间的顶点  
--                b2Vec2 pointA = b2Mul(xfA, localPointA);  
--                b2Vec2 pointB = b2Mul(xfB, localPointB);  
--                --//求两形状的间距，并返回。  
--                float32 separation = b2Dot(pointB - pointA, m_axis);  
--                return separation;  
--            }  

--        case e_faceA:                              //面A  
--            {  
--                --//通过转置旋转m_axis获取单纯形支撑点的方向向量  
--                --//通过变换局部点获取当前图形的点  
--                b2Vec2 normal = b2Mul(xfA.q, m_axis);  
--                b2Vec2 pointA = b2Mul(xfA, m_localPoint);  
--                --//通过转置旋转m_axis获取单纯形支撑点的方向向量  
--                b2Vec2 axisB = b2MulT(xfB.q, -normal);  
--                --//通过索引获取局部顶点  
--                *indexA = -1;  
--                *indexB = m_proxyB->GetSupport(axisB);  
--                --//通过变换局部点获形状B的顶点  
--                b2Vec2 localPointB = m_proxyB->GetVertex(*indexB);  
--                b2Vec2 pointB = b2Mul(xfB, localPointB);  
--                --//求两形状的间距，并返回。  
--                float32 separation = b2Dot(pointB - pointA, normal);  
--                return separation;  
--            }  

--        case e_faceB:                             --//面B  
--            {  
--                --//通过转置旋转m_axis获取单纯形支撑点的方向向量  
--                --//通过变换局部点获取当前图形的点  
--                b2Vec2 normal = b2Mul(xfB.q, m_axis);  
--                b2Vec2 pointB = b2Mul(xfB, m_localPoint);  
--                --//通过转置旋转m_axis获取单纯形支撑点的方向向量  
--                b2Vec2 axisA = b2MulT(xfA.q, -normal);  
--                --//通过索引获取局部顶点  
--                *indexB = -1;  
--                *indexA = m_proxyA->GetSupport(axisA);  
--                --//通过变换局部点获形状A的顶点  
--                b2Vec2 localPointA = m_proxyA->GetVertex(*indexA);  
--                b2Vec2 pointA = b2Mul(xfA, localPointA);  
--                --//求两形状的间距，并返回。  
--                float32 separation = b2Dot(pointA - pointB, normal);  
--                return separation;  
--            }  

--        default:  
--            b2Assert(false);  
--            *indexA = -1;  
--            *indexB = -1;  
--            return 0.0f;  
--        }  
--    }  
--    --[[/************************************************************************** 
--    * 功能描述：当前时间步里两形状的距离 
--    * 参数说明：indexA ：点A的索引 
--                indexB ：点B的索引 
--                t      ：时间值 
--    * 返 回 值： 当前时间步里两形状的距离 
--    **************************************************************************/]]--
--    function Evaluate(int32 indexA, int32 indexB, float32 t) const  
--    {  
--        b2Transform xfA, xfB;  
--        m_sweepA.GetTransform(&xfA, t);  
--        m_sweepB.GetTransform(&xfB, t);  

--        switch (m_type)  
--        {  
--        case e_points:                                --//点  
--            {  
--                --//通过转置旋转m_axis获取顶点的方向向量  
--                b2Vec2 axisA = b2MulT(xfA.q,  m_axis);  
--                b2Vec2 axisB = b2MulT(xfB.q, -m_axis);  
--                --//通过变换局部点获形状A、B的顶点  
--                b2Vec2 localPointA = m_proxyA->GetVertex(indexA);  
--                b2Vec2 localPointB = m_proxyB->GetVertex(indexB);  
--                --//获取当前时间步内的两形状上的点  
--                b2Vec2 pointA = b2Mul(xfA, localPointA);  
--                b2Vec2 pointB = b2Mul(xfB, localPointB);  
--                --//计算间距，并返回间距  
--                float32 separation = b2Dot(pointB - pointA, m_axis);  
--                return separation;  
--            }  

--        case e_faceA:                                 --//面A  
--            {  
--                //旋转m_axis向量，获取法向量，同时根据局部点求形状A上的点  
--                b2Vec2 normal = b2Mul(xfA.q, m_axis);  
--                b2Vec2 pointA = b2Mul(xfA, m_localPoint);  
--                //通过转置旋转m_axis获取单纯形支撑点的方向向量  
--                b2Vec2 axisB = b2MulT(xfB.q, -normal);  
--                //通过索引获取局部顶点，进而通过变换局部点获取当前时间步内的点  
--                b2Vec2 localPointB = m_proxyB->GetVertex(indexB);  
--                b2Vec2 pointB = b2Mul(xfB, localPointB);  
--                //获取间距  
--                float32 separation = b2Dot(pointB - pointA, normal);  
--                return separation;  
--            }  

--        case e_faceB:                                 --//面B  
--            {  
--                --//旋转m_axis向量，获取法向量，同时根据局部点求形状B上的点  
--                b2Vec2 normal = b2Mul(xfB.q, m_axis);  
--                b2Vec2 pointB = b2Mul(xfB, m_localPoint);  
--                --//通过转置旋转m_axis获取单纯形支撑点的方向向量  
--                b2Vec2 axisA = b2MulT(xfA.q, -normal);  
--                --//通过索引获取局部顶点，进而通过变换局部点获取当前时间步内的点  
--                b2Vec2 localPointA = m_proxyA->GetVertex(indexA);  
--                b2Vec2 pointA = b2Mul(xfA, localPointA);  
--                --//获取间距  
--                float32 separation = b2Dot(pointA - pointB, normal);  
--                return separation;  
--            }  

--        default:  
--            b2Assert(false);  
--            return 0.0f;  
--        }  
--    }  

--    const b2DistanceProxy* m_proxyA;          --//代理A  
--    const b2DistanceProxy* m_proxyB;          --//代理B  
--    b2Sweep m_sweepA, m_sweepB;               --//扫描A、B  
--    Type m_type;                              --//类型变量  
--    b2Vec2 m_localPoint;                      --//局部点  
--    b2Vec2 m_axis;                            --//方向向量，主要用于变换次向量之后求形状的顶点  
--};  

--return MainScene

