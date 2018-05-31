BilliardsAniMgr = BilliardsAniMgr or { }


-- 创建连杆动画
-- @ rootNode 游戏layer
-- @ nLinkCount 连杆次数
function BilliardsAniMgr:createLinkEffect(rootNode, nLinkCount)
    print(" ==========  link count is ", nLinkCount)
    local sprite = cc.Sprite:create()
    sprite:setCascadeOpacityEnabled(true)
    sprite:setGlobalZOrder(150000)

    local emitter = cc.ParticleFlower:create()
    if emitter then
        sprite:addChild(emitter, 10)
        emitter:setOpacity(0.5)
        emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("gameBilliards/effect/stars.png"))
        emitter:setPosition(cc.p(20, 0))
        emitter:setLocalZOrder(-1)
        emitter:setScale(1.5)
    end

    local spine = sp.SkeletonAnimation:create("spine/skeleton.json", "spine/skeleton.atlas", 1)
    if spine then
        spine:setAnchorPoint(cc.p(0.5, 0.5))
        spine:setScale(1.5)
        spine:setAnimation(0, "animation", true)
        sprite:addChild(spine)
        spine:setCascadeOpacityEnabled(false)
        spine:setLocalZOrder(5)
    end

    if nLinkCount > 9 then
        local ten = math.modf(nLinkCount / 10)
        local one = nLinkCount % 10
        local link1 = ccui.ImageView:create("gameBilliards/eightBall/img_num_" .. ten .. ".png", UI_TEX_TYPE_LOCAL)
        local link2 = ccui.ImageView:create("gameBilliards/eightBall/img_num_" .. one .. ".png", UI_TEX_TYPE_LOCAL)
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
        local link = ccui.ImageView:create("gameBilliards/eightBall/img_num_" .. nLinkCount .. ".png", UI_TEX_TYPE_LOCAL)
        if link then
            link:setAnchorPoint(cc.p(0.5, 0.5))
            link:setScale(1)
            link:setPositionX(-50)
            sprite:addChild(link)
            link:setCascadeOpacityEnabled(true)
        end
    end

    local word = ccui.ImageView:create("gameBilliards/eightBall/img_Effect_Link.png", UI_TEX_TYPE_LOCAL)
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

--  创建屏幕中间提示信息(该你击球，你将击打花色求等)
-- @ rootNode 游戏图层
-- @ nType 枚举 = g_EightBallData.word
function BilliardsAniMgr:createWordEffect(rootNode, nType)
    local spineWord
    if nType == g_EightBallData.word.your then
        spineWord = cc.Sprite:create("gameBilliards/eightBall/eightBall_Word_YourRound.png")
    elseif nType == g_EightBallData.word.full then
        spineWord = cc.Sprite:create("gameBilliards/eightBall/eightBall_Word_HitHalfBall.png")
    elseif nType == g_EightBallData.word.half then
        spineWord = cc.Sprite:create("gameBilliards/eightBall/eightBall_Word_HitFullBall.png")
    end
    spineWord:setCascadeOpacityEnabled(true)
    spineWord:setGlobalZOrder(150000)
    local spine = sp.SkeletonAnimation:create("spine/skeleton.json", "spine/skeleton.atlas", 1)
    if spine then
        spine:setAnchorPoint(cc.p(0.5, 0.5))
        spine:setScale(1.5)
        spine:setAnimation(0, "animation", true)
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

function BilliardsAniMgr:init()

end

return BilliardsAniMgr