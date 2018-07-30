BilliardsAniMgr = BilliardsAniMgr or { }

-- 创建人物当前轮次动画
-- root是人物框
function BilliardsAniMgr:createUserFrameAni(rootNode, isRestart)
    local function removeAni(sp)
        if sp and not tolua.isnull(sp) then
            sp:stopAllActions()
            sp:removeFromParent()
            sp = nil
        end
    end
    if isRestart then
        removeAni(rootNode.img_User1:getChildByTag(1000))
        removeAni(rootNode.img_User2:getChildByTag(1000))
        rootNode.blackBg:setVisible(false)
        return
    end
    if EightBallGameManager:getCurrentUserID() == -1 or EBGameControl:getGameState() == g_EightBallData.gameState.practise then
        return
    end
    local root = player:getPlayerUserID() == EightBallGameManager:getCurrentUserID() and rootNode.img_User1 or rootNode.img_User2
    local blackBgRoot = player:getPlayerUserID() == EightBallGameManager:getCurrentUserID() and rootNode.img_User2 or rootNode.img_User1
    local msp = root:getChildByTag(1000)
    if msp then
        --removeAni(msp)
        return
    end
    rootNode.blackBg:setPositionX(blackBgRoot:getPositionX())
    rootNode.blackBg:setVisible(true)
    msp = cc.Sprite:create()
    local frames = display.newFrames("userFrame%02d.png", 1, 90)
    local animation = display.newAnimation(frames, 0.03)
    msp:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
    msp:setPosition(cc.p(root:getContentSize().width / 2, root:getContentSize().height / 2))
    msp:setTag(1000)
    root:addChild(msp)
end

-- 创建连杆动画
-- @ rootNode 游戏layer
-- @ nLinkCount 连杆次数
function BilliardsAniMgr:createLinkEffect(rootNode, nLinkCount)
    print(" ==========  link count is ", nLinkCount)
    local sprite = cc.Sprite:create()
    sprite:setCascadeOpacityEnabled(true)
    sprite:setGlobalZOrder(150000)

--    local emitter = cc.ParticleFlower:create()
--    if emitter then
--        sprite:addChild(emitter, 10)
--        emitter:setOpacity(0.5)
--        emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("gameBilliards/effect/stars.png"))
--        emitter:setPosition(cc.p(20, 0))
--        emitter:setLocalZOrder(-1)
--        emitter:setScale(1.5)
--    end

    local spine = sp.SkeletonAnimation:create("spine/skeleton.json", "spine/skeleton.atlas", 1)
    if spine then
        spine:setAnchorPoint(cc.p(0.5, 0.5))
        spine:setScale(1.5)
        spine:setAnimation(0, "animation", false)
        sprite:setTag(g_EightBallData.g_Border_Tag.linkSpine)
        sprite:addChild(spine)
        spine:setCascadeOpacityEnabled(false)
        spine:setLocalZOrder(5)
    end

    if nLinkCount > 9 then
        local ten = math.modf(nLinkCount / 10)
        local one = nLinkCount % 10
        local link1 = ccui.ImageView:create("img_num_" .. ten .. ".png", UI_TEX_TYPE_PLIST)
        local link2 = ccui.ImageView:create("img_num_" .. one .. ".png", UI_TEX_TYPE_PLIST)
        link1:setAnchorPoint(cc.p(0.5, 0.5))
        link1:setScale(1)
        link1:setPositionX(-100)
        sprite:addChild(link1)
        link2:setCascadeOpacityEnabled(true)
        link2:setAnchorPoint(cc.p(0.5, 0.5))
        link2:setScale(1)
        link2:setPositionX(-50)
        sprite:addChild(link2)
        link2:setCascadeOpacityEnabled(true)
    else
        local link = ccui.ImageView:create("img_num_" .. nLinkCount .. ".png", UI_TEX_TYPE_PLIST)
        if link then
            link:setAnchorPoint(cc.p(0.5, 0.5))
            link:setScale(1)
            link:setPositionX(-50)
            sprite:addChild(link)
            link:setCascadeOpacityEnabled(true)
        end
    end

    local word = ccui.ImageView:create("img_Effect_Link.png", UI_TEX_TYPE_PLIST)
    if word then
        word:setAnchorPoint(cc.p(0.5, 0.5))
        word:setScale(1)
        word:setPositionX(50)
        sprite:addChild(word)
        word:setCascadeOpacityEnabled(true)
    end
    rootNode:addChild(sprite)
    sprite:setOpacity(0)
    sprite:setPosition(cc.p(display.cx + 200, display.cy + 50))
    sprite:setCameraMask(cc.CameraFlag.USER2)

    sprite:runAction(cc.Sequence:create(
    cc.FadeIn:create(0.5),
    cc.DelayTime:create(1.5),
    cc.FadeOut:create(0.5)
    ))

    sprite:runAction(cc.Sequence:create(
    cc.MoveTo:create(0.5, cc.p(sprite:getPositionX() + 50, sprite:getPositionY())),
    cc.DelayTime:create(1.5),
    cc.MoveTo:create(0.5, cc.p(sprite:getPositionX() + 100, sprite:getPositionY()))
    ))

    sprite:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),
    cc.CallFunc:create( function()
        if sprite and not tolua.isnull(sprite) then
            sprite:stopAllActions()
            sprite:removeAllChildren()
            sprite:removeFromParent()
            sprite = nil
        end
    end )))
end

-- 力量条数值显示
-- param@ root 三个数字的父节点
-- param@ num 力量大小
function BilliardsAniMgr:createPowerNumEffet(root, num)
    local hundred = math.modf(num / 100)
    local ten = math.modf(num / 10)%10
    local one = num % 10
    if hundred == 0 then
        root:getChildByName("num1"):setVisible(false)
        if ten == 0 or ten == 10 then
            root:getChildByName("num2"):setVisible(false)
        else
            root:getChildByName("num2"):loadTexture("img_num_" .. ten .. ".png", UI_TEX_TYPE_PLIST)
            root:getChildByName("num2"):setVisible(true)
        end
    else
        root:getChildByName("num1"):loadTexture("img_num_" .. hundred .. ".png", UI_TEX_TYPE_PLIST)
        root:getChildByName("num1"):setVisible(true)
        root:getChildByName("num2"):loadTexture("img_num_" .. ten .. ".png", UI_TEX_TYPE_PLIST)
        root:getChildByName("num2"):setVisible(true)
    end
    root:getChildByName("num3"):loadTexture("img_num_" .. one .. ".png", UI_TEX_TYPE_PLIST)
    root:getChildByName("num3"):setVisible(true)
end

--  创建屏幕中间提示信息(该你击球，你将击打花色求等)
-- @ rootNode 游戏图层
-- @ nType 枚举 = g_EightBallData.word
function BilliardsAniMgr:createWordEffect(rootNode, nType)
    local spineWord
    if nType == g_EightBallData.word.your then
        spineWord = cc.Sprite:createWithSpriteFrameName("eightBall_Word_YourRound.png")
    elseif nType == g_EightBallData.word.full then
        spineWord = cc.Sprite:createWithSpriteFrameName("eightBall_Word_HitHalfBall.png")
    elseif nType == g_EightBallData.word.half then
        spineWord = cc.Sprite:createWithSpriteFrameName("eightBall_Word_HitFullBall.png")
    end
    spineWord:setCascadeOpacityEnabled(true)
    spineWord:setGlobalZOrder(150000)
    local spine = sp.SkeletonAnimation:create("spine/skeleton.json", "spine/skeleton.atlas", 1)
    if spine then
        spine:setAnchorPoint(cc.p(0.5, 0.5))
        spine:setScale(1.5)
        spine:setAnimation(0, "animation", false)
        spine:setPosition(cc.p(spineWord:getContentSize().width / 2, spineWord:getContentSize().height / 2))
        spineWord:addChild(spine)
        spine:setCascadeOpacityEnabled(false)
        spine:setLocalZOrder(5)
    end
    spineWord:setOpacity(0)
    spineWord:setPosition(cc.p(display.cx - 100, display.cy))
    spineWord:setCameraMask(cc.CameraFlag.USER2)

    rootNode:addChild(spineWord)

    spineWord:runAction(cc.Sequence:create(
    cc.FadeIn:create(0.3),
    cc.DelayTime:create(1),
    cc.FadeOut:create(0.3)
    ))

    spineWord:runAction(cc.Sequence:create(
    cc.MoveTo:create(0.3, cc.p(spineWord:getPositionX() + 100, spineWord:getPositionY())),
    cc.DelayTime:create(1),
    cc.MoveTo:create(0.3, cc.p(spineWord:getPositionX() + 200, spineWord:getPositionY()))
    ))

    spineWord:runAction(cc.Sequence:create(cc.DelayTime:create(1.65),
    cc.CallFunc:create( function()
        if spineWord and not tolua.isnull(spineWord) then
            spineWord:stopAllActions()
            spineWord:removeAllChildren()
            spineWord:removeFromParent()
            spineWord = nil
        end
    end )))
end

--  设置力量条的进场出场动画
--@ isEnabled 是否是可以点击状态,动画状态
--@ m_MainLayer 游戏图层
function BilliardsAniMgr:setSliderBarAni(isEnabled, m_MainLayer)
    print(" setSliderBarAni ",isEnabled)
    BilliardsAniMgr:setFineTurningAni(isEnabled, m_MainLayer)
    m_MainLayer.slider_View:setVisible(false)
    m_MainLayer.img_PowerBar:stopAllActions()
    local nodeWidth = m_MainLayer.node:getContentSize().width
    local childWidth = m_MainLayer.img_PowerBar:getContentSize().width
    if isEnabled then
        local posX = 1136 +(display.width - nodeWidth) / 2
        if posX ~= m_MainLayer.img_PowerBar:getPositionX() then
            m_MainLayer.img_PowerBar:setPositionX(posX - childWidth)
            return
        end
        m_MainLayer.slider_PowerBar:setTouchEnabled(true)
        m_MainLayer.img_PowerBar:setPositionX(posX)
        m_MainLayer.img_PowerBar:runAction(cc.MoveTo:create(0.5, cc.p(posX - childWidth, m_MainLayer.img_PowerBar:getPositionY())))
    else
--        if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
--            return
--        end
        local posX = 1136 +(display.width - nodeWidth) / 2 - childWidth
        if posX ~= m_MainLayer.img_PowerBar:getPositionX() then
            m_MainLayer.img_PowerBar:setPositionX(posX + childWidth)
            return
        end
        if EBGameControl:getGameState() ~= g_EightBallData.gameState.practise then
            m_MainLayer.slider_PowerBar:setTouchEnabled(false)
        end
        m_MainLayer.img_PowerBar:setPositionX(posX)
         m_MainLayer.img_PowerBar:runAction(cc.MoveTo:create(0.5, cc.p(posX + childWidth, m_MainLayer.img_PowerBar:getPositionY())))
    end
end

-- 设置微调框的进场出场动画
-- @ isEnabled 是否可以点击状态,动画状态
-- @ m_MainLayer 游戏图层
function BilliardsAniMgr:setFineTurningAni(isEnabled, m_MainLayer)
    m_MainLayer.layout_FineTurning:stopAllActions()
    local nodeWidth = m_MainLayer.node:getContentSize().width
    local childWidth = m_MainLayer.layout_FineTurning:getContentSize().width
    if isEnabled then
        local posX = 0 -(display.width - nodeWidth) / 2
--        if posX ~= m_MainLayer.layout_FineTurning:getPositionX() then
--            m_MainLayer.layout_FineTurning:setPositionX(posX + childWidth)
--            return
--        end
        m_MainLayer.layout_FineTurning:setPositionX(posX)
        m_MainLayer.layout_FineTurning:runAction(cc.MoveTo:create(0.5, cc.p(posX + childWidth, m_MainLayer.layout_FineTurning:getPositionY())))
    else
        local posX = 0 -(display.width - nodeWidth) / 2
--        if posX ~= m_MainLayer.layout_FineTurning:getPositionX() then
--            m_MainLayer.layout_FineTurning:setPositionX(posX - childWidth)
--            return
--        end
        m_MainLayer.layout_FineTurning:setPositionX(posX+childWidth)
        m_MainLayer.layout_FineTurning:runAction(cc.MoveTo:create(0.5, cc.p(posX - childWidth, m_MainLayer.layout_FineTurning:getPositionY())))
    end
end

--比赛开始动画
function BilliardsAniMgr:setGameStartAni(rootBg)
    local spine = sp.SkeletonAnimation:create("gameBilliards/effect/bisaikaishi_tx.json", "gameBilliards/effect/bisaikaishi_tx.atlas", 1)
    if spine then
        spine:setAnchorPoint(cc.p(0.5, 0.5))
        spine:setScale(1)
        spine:setAnimation(0, "bisaikaishi", false)
        spine:setPosition(cc.p(rootBg:getContentSize().width / 2, rootBg:getContentSize().height / 2+50))
        spine:setCameraMask(cc.CameraFlag.USER2)
        spine:setGlobalZOrder(100000)
        rootBg:addChild(spine)
    end
end

function BilliardsAniMgr:setGameOverAni(isWin, rootBg)
    local spine
    if isWin then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/flash/yuan010.png", "res/flash/yuan010.plist", "res/flash/yuan01.ExportJson")
        local spine = ccs.Armature:create("yuan01")
        spine:setPosition(cc.p(display.cx, display.cy+50))
        spine:setScale(3.0)
        spine:setLocalZOrder(-1)
        --spine:setCameraMask(cc.CameraFlag.USER2)
        spine:getAnimation():play("Animation1")
        rootBg:addChild(spine)
    else
        spine = sp.SkeletonAnimation:create("gameBilliards/effect/jiesuan_shibai.json", "gameBilliards/effect/jiesuan_shibai.atlas", 1)
        spine:setAnimation(0, "jiesuan_shibai", true)
        spine:setScale(0.5)
        spine:setPosition(cc.p(rootBg:getContentSize().width / 2, rootBg:getContentSize().height / 2 + 180))
        rootBg:addChild(spine)
    end
end

-- 提示框信息
function BilliardsAniMgr:setGameTips(m_MainLayer,result)
    --倒计时
    local timer = m_MainLayer.tip:getChildByTag(g_EightBallData.g_Border_Tag.tipsTimer)
    if not timer then
        timer = ccui.ImageView:create()
        timer:setTag(g_EightBallData.g_Border_Tag.tipsTimer)
        local size = m_MainLayer.tip:getContentSize()
        timer:setPositionX(timer:getPositionX() + 50)
        --timer:setPosition(cc.p(size.width/2,size.height/2))
        m_MainLayer.tip:addChild(timer)
        local word = cc.Sprite:create("gameBilliards/eightBall/eightBall_Word_Timer.png")
        word:setPosition(cc.p(-75,40))
        timer:addChild(word)
    end
    timer:stopAllActions()
    timer:setVisible(false)

    local currentUserID = EightBallGameManager:getCurrentUserID()
    local panel_Tip = m_MainLayer.panel_Tip
    if result == g_EightBallData.gameRound.foul then
        if currentUserID ~= -1 and currentUserID == player:getPlayerUserID() then
            m_MainLayer.tip:setString("击球犯规，请放置自由球")
        elseif currentUserID ~= -1 and currentUserID ~= player:getPlayerUserID() then
            m_MainLayer.tip:setString("击球犯规，对手放置自由球")
        else
            return
        end
    elseif result == g_EightBallData.gameRound.keep then
        if (currentUserID ~= -1 and currentUserID ~= player:getPlayerUserID()) --[[or EightBallGameManager:getColorUserID() <= 0]] then
            m_MainLayer.tip:setString("继续击球")
        else
            return
        end
    elseif result == g_EightBallData.gameRound.change then
        m_MainLayer.tip:setString("正常击球，交换击球权")
    elseif result == g_EightBallData.gameRound.restart then
        m_MainLayer.tip:setString("首杆进黑八，重新开始本局")
    elseif result == g_EightBallData.gameRound.countdown then
        if EightBallGameManager:getCurrentUserID() ~= player:getPlayerUserID() then
            return
        end
        timer:setVisible(true)
        m_MainLayer.tip:setString("")
        timer:setScale(0.9)
        timer:loadTexture("img_num_3.png",UI_TEX_TYPE_PLIST)
        timer:runAction(cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function ()
                timer:loadTexture("img_num_2.png",UI_TEX_TYPE_PLIST)
            end),
            cc.DelayTime:create(1),
            cc.CallFunc:create(function ()
                timer:loadTexture("img_num_1.png",UI_TEX_TYPE_PLIST)
            end),
            cc.DelayTime:create(1),
            cc.CallFunc:create(function ()
                timer:loadTexture("img_num_0.png",UI_TEX_TYPE_PLIST)
            end),
            cc.DelayTime:create(1),
            cc.CallFunc:create(function ()
                if timer and not tolua.isnull(timer) then
                    timer:stopAllActions()
                    timer:setVisible(false)
                    panel_Tip:runAction(cc.MoveTo:create(0.3, cc.p(display.cx, 0 -(display.height - m_MainLayer.node:getContentSize().height) / 2)))
                end
            end)
        ))
        panel_Tip:runAction(cc.MoveTo:create(0.3, cc.p(display.cx, 0 -(display.height - m_MainLayer.node:getContentSize().height) / 2 + panel_Tip:getContentSize().height)))
        return
    else
        m_MainLayer.tip:setString("")
        panel_Tip:setPosition(cc.p(display.cx, 0 -(display.height - m_MainLayer.node:getContentSize().height) / 2))
        return
    end
    local nodeHeight = m_MainLayer.node:getContentSize().height
    local childHeight = panel_Tip:getContentSize().height
    if panel_Tip then
        panel_Tip:stopAllActions()
        panel_Tip:setPosition(cc.p(display.cx, 0 -(display.height - nodeHeight) / 2))
        panel_Tip:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.3, cc.p(display.cx, 0 -(display.height - nodeHeight) / 2 + childHeight)),
        cc.DelayTime:create(1),
        cc.CallFunc:create( function()
            panel_Tip:runAction(cc.MoveTo:create(0.3, cc.p(display.cx, 0 -(display.height - nodeHeight) / 2)))
        end )
        ))
    end
end

--桌子白色摆放球的指示框
--@param isEnabled 是否需要亮出来
function BilliardsAniMgr:setDeskTempAni(m_MainLayer, isEnabled)
    m_MainLayer.deskTemp:stopAllActions()
    m_MainLayer.deskTemp:setOpacity(0)
    if isEnabled then
        if EBGameControl:getGameState() == g_EightBallData.gameState.practise or EightBallGameManager:getCurrentUserID() == player:getPlayerUserID() then
            m_MainLayer.deskTemp:setVisible(true)
            m_MainLayer.deskTemp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1), cc.FadeOut:create(1))))
        else
            m_MainLayer.deskTemp:setVisible(false)
        end
    else
        m_MainLayer.deskTemp:setVisible(false)
    end
end

-- 设置头像框的倒计时
function BilliardsAniMgr:setHeadTimerAni(Bg, leftTime, callback)
    --if EBGameControl:getGameState() ~= g_EightBallData.gameState.practise then
        local size = Bg:getContentSize()
        local ProgressTimerAction = Bg:getChildByTag(g_EightBallData.g_Border_Tag.timer)
        if not ProgressTimerAction then
            local sprite = cc.Sprite:create("gameBilliards/eightBall/eightBall_ProgressTimer_Bg.png")
            ProgressTimerAction = cc.ProgressTimer:create(sprite)
            ProgressTimerAction:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            ProgressTimerAction:setPosition(cc.p(Bg:getContentSize().width / 2, Bg:getContentSize().height / 2))
            ProgressTimerAction:setAnchorPoint(cc.p(0.5, 0.5))
            ProgressTimerAction:setReverseDirection(true)
            ProgressTimerAction:setTag(g_EightBallData.g_Border_Tag.timer)
            Bg:addChild(ProgressTimerAction)
        end

        local particle = Bg:getChildByTag(g_EightBallData.g_Border_Tag.clockParticle)
        if not particle then
            particle = cc.ParticleSystemQuad:create("gameBilliards/effect/ClockMove.plist")
            particle:setLifeVar(2)
		    particle:setDuration(-1)
            particle:setTag(g_EightBallData.g_Border_Tag.clockParticle)
		    Bg:addChild(particle)
        end
        particle:setPosition(cc.p(size.width /2 ,size.height-2))
	    particle:setVisible(true)
	    particle:stopAllActions()

        local seq = cc.Sequence:create(
			cc.MoveBy:create(leftTime / 8 , cc.p(size.width /2, 0)),
			cc.MoveBy:create(leftTime / 4 , cc.p(0, -size.height+2)),
			cc.MoveBy:create(leftTime / 4 , cc.p(-size.width+2, 0)),
			cc.MoveBy:create(leftTime / 4 , cc.p(0, size.height-2)),
            cc.CallFunc:create(function ( ... )
				--最后3秒调用
                print("last 3 seconds !")
                --amgr.playViberate(0.3)
                if callback then
                    callback()
                end
			end),
			cc.MoveBy:create(leftTime / 8 , cc.p(size.width /2-1, 0)),
			cc.CallFunc:create(function ( ... )
				particle:setVisible(false)
			end)
		)
	    particle:runAction(seq)

        if leftTime <= 0 then
            ProgressTimerAction:setPercentage(0)
            ProgressTimerAction:stopAllActions()
            particle:setVisible(false)
            return
        end

        local wholeTime = leftTime * 5
        if leftTime > 20 then
            wholeTime = 100
        end
        local progressTo = cc.ProgressFromTo:create(leftTime, wholeTime, 0)
        local clear = cc.CallFunc:create( function()
            
        end )

        ProgressTimerAction:runAction(cc.Sequence:create(progressTo, clear))
    --end
end

--指示球设置
function BilliardsAniMgr:setTipBallsAni(root,tipBalls,index,pos)
    if root then
        local tip = tipBalls[index]
        if tip then
            root:addChild(tip)
            tip:setPositionX()
        end
    end
end

function BilliardsAniMgr:init()

end

return BilliardsAniMgr