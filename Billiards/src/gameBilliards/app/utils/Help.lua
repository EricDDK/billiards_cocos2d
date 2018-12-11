help = { }

---------------------- ↓ 字符串操作 ↓ --------------------------

-- 分离字符
-- 将每个字符分离出来，放到table中，一个单元内一个字符
function StringToTable(s)
    local tb = { }

    --[[
    UTF8的编码规则：
    1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
    2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中
    3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字)
    ]]
    for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(tb, utfChar)
    end
    return tb
end

-- 计算字符数
-- 获取字符串长度，设一个中文长度为2，其他长度为1
function GetUTFLen(s)
    local sTable = StringToTable(s)

    local len = 0
    local charLen = 0

    for i = 1, #sTable do
        local utfCharLen = string.len(sTable[i])
        if utfCharLen > 1 then
            --长度大于1的就认为是中文
            charLen = 2
        else
            charLen = 1
        end
        len = len + charLen
    end
    return len
end

--根据图片长度获得size长度
function GetUTFStrWidth(str)
    local sTable = StringToTable(str)
    local len = 0
    local charLen = 0
    for i = 1, #sTable do
        local utfCharLen = string.len(sTable[i])
        if utfCharLen > 1 then
            --长度大于1的就认为是中文
            charLen = 35*0.7
        else
            charLen = 20*0.7
        end
        len = len + charLen
    end
    return len
end

-- 获取指定字符个数的字符串的实际长度，设一个中文长度为2，其他长度为1，count:-1表示不限制
function GetUTFLenWithCount(s, count)
    local sTable = StringToTable(s)

    local len = 0
    local charLen = 0
    local isLimited =(count >= 0)

    for i = 1, #sTable do
        local utfCharLen = string.len(sTable[i])
        if utfCharLen > 1 then
            -- 长度大于1的就认为是中文
            charLen = 2
        else
            charLen = 1
        end

        len = len + utfCharLen

        if isLimited then
            count = count - charLen
            if count <= 0 then
                break
            end
        end
    end
    return len
end  

-- 截取指定长度
-- 截取指定字符个数的字符串，超过指定个数的，截取，然后添加...
function GetMaxLenString(s, maxLen)
    local len = GetUTFLen(s)

    local dstString = s
    -- 超长，裁剪，加...
    if len > maxLen then
        dstString = string.sub(s, 1, GetUTFLenWithCount(s, maxLen))
        dstString = dstString .. "..."
    end

    return dstString
end  

---------------------- ↑ 字符串操作 ↑ --------------------------

function urLenCode(_str)
    _str = string.gsub(_str, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(_str, " ", "+")
end

--移除字符串，是否是所有的
function table.removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end

--@根据value来增删改差
--@增删改查时间复杂度都为O(1)
--value可以直接删除最后一个
function table.dictionarySetByValue()
    local reverse = { }
    local set = { }
    return setmetatable(set, {
        __index =
        {
            insert = function(set, value)
                if not reverse[value] then
                    table.insert(set, value)
                    reverse[value] = table.getn(set)
                end
            end,
            remove = function(set, value)
                local index = reverse[value]
                if index then
                    reverse[value] = nil
                    local top = table.remove(set)
                    if top ~= value then
                        reverse[top] = index
                        set[index] = top
                    end
                end
            end,

            find = function(set, value)
                local index = reverse[value]
                return(index and true or false)
            end,
        }
    } )
end  

--创建增删改查复杂度都为O(1)的table
--利用了一个额外的数组reverse，来保存数组s中每个数据在s中的位置，相当于以空间换时间
--@ 这里删除还可以优化，table.remove实现过于复杂，希望可以只删除table中最后一个(已实现)
function table.dictionarySetByUserID()
    local reverse = { }
    local set = { }
    return setmetatable(set, {
        __index =
        {
            insert = function(set, value)
                if not reverse[value.User.UserInfo.UserID] then
                    table.insert(set, value)
                    reverse[value.User.UserInfo.UserID] = table.getn(set)
                end
            end,
            remove = function(set, value)
                local index = reverse[value]
                if index then
                    reverse[value] = nil
                    set[index] = {} --这样删除的时间复杂度也是O(1)
--                    table.remove(set,index)
--                    for k,v in pairs(reverse) do
--                        if v > index then
--                            reverse[k] = v - 1
--                        end
--                    end
                end
            end,
            find = function(set, value)
                local index = reverse[value]
                return(set[index] and set[index] or false)
            end,
            keyFind = function(set, value)
                local index = reverse[value]
                return (index and index or false)
            end,
        }
    } )
end

function KeepADecimal(num)
    return math.floor(num*100+0.5)*0.01
end

--判断园是否和矩形碰撞
function circleIntersectRect(_circle_pt, _rect,_width,_height,_radius)
    local cx = nil
    local cy = nil
    local circle_pt = {}
    local rect = {}
    circle_pt.x = _circle_pt.x
    circle_pt.y = _circle_pt.y
    rect.width = _width
    rect.height = _height
    rect.x = _rect.x
    rect.y = _rect.y

    --print("====",rect.x,rect.y,circle_pt.x,circle_pt.y)
    -- Find the point on the collision box closest to the center of the circle  
    if circle_pt.x < rect.x then
        cx = rect.x  
    elseif circle_pt.x > rect.x + rect.width then  
        cx = rect.x + rect.width
    else
        cx = circle_pt.x
    end
  
    if circle_pt.y < rect.y then
        cy = rect.y
    elseif circle_pt.y > rect.y + rect.height then
        cy = rect.y + rect.height
    else
        cy = circle_pt.y
    end
    print("=====",cc.pGetDistance(circle_pt, cc.p(cx, cy)),_radius)
    if cc.pGetDistance(circle_pt, cc.p(cx, cy)) < _radius then
        return true
    end
    return false
end

function help.twoDistance(X1,Y1,X2,Y2)
    return math.pow((math.pow((X1 - X2), 2) + math.pow((Y1 - Y2), 2)), 0.5)
end

function help.rot(x1,y1,x2,y2)
    local value = (y1-y2)/(x1-x2)
    return math.atan(value)*180/math.pi
end

function help.computeCollision(w, h, r, newrx, newry)
      local dx = math.min(newrx, w * 0.5)
      local dx1 = math.max(dx, -w * 0.5)
      local dy = math.min(newry, h * 0.5)
      local dy1 = math.max(dy, -h * 0.5)
      return (dx1 - newrx) * (dx1 - newrx) + (dy1 - newry) * (dy1 - newry) <= r * r
end

function help.getNewRx_Ry(x1,y1,x2,y2,rotation)
    local json = {}
    local distance = help.twoDistance(x1,y1,x2,y2)
    --计算最新角度（与X轴的角度），同数学X Y轴
    local newrot = help.rot(x1,y1,x2,y2) - rotation
    local newRx = math.cos(newrot/180*math.pi) * distance
    local newRy = math.sin(newrot/180*math.pi) * distance
    json.newRx = newRx
    json.newRy = newRy
    return json
end

--判断直线和边框的碰撞点
--@rotate 旋转角度，数学角度
--@whitePos 白球的node相对位置
--@radius 球体半径
--@return 位置 bool:是否是与长相碰撞
function help.checkCollisionPointBetweenLines(rotate, whitePos,radius)
    local _tableX, _tableY = 207.5, 99.5  -- 桌子在Node的x,y
    local _tableWidth, _tableHeight = 930 - 208, 475 - 101  -- 桌子border的长宽
    if rotate <= 90 then
        rotate = rotate / 180 * math.pi
        local _traH = math.tan(rotate) *(_tableWidth + _tableX - whitePos.x)
        if _traH <= _tableHeight + _tableY - whitePos.y then
            return _traH/math.sin(rotate)-radius/math.cos(rotate),false
        else
            return (_tableY + _tableHeight - whitePos.y)/math.sin(rotate)-radius/math.sin(rotate),true
        end
    elseif rotate <= 180 then
        rotate = (180- rotate) / 180 * math.pi
        local _traH = (whitePos.x-_tableX)*math.tan(rotate)
        if _traH <= _tableHeight + _tableY - whitePos.y then
            return _traH/math.sin(rotate)-radius/math.cos(rotate),false
        else
            return (_tableY + _tableHeight - whitePos.y)/math.sin(rotate)-radius/math.sin(rotate),true
        end
    elseif rotate <= 270 then
        rotate = (rotate - 180) / 180 * math.pi
        local _traH = (whitePos.x-_tableX)*math.tan(rotate)
        if _traH <= whitePos.y-_tableY then
            return _traH/math.sin(rotate)-radius/math.cos(rotate),false
        else
            return (whitePos.y-_tableY)/math.sin(rotate)-radius/math.sin(rotate),true
        end
    elseif rotate <= 360 then
        rotate = (360 - rotate) / 180 * math.pi
        local _traH = (_tableX+_tableWidth-whitePos.x)*math.tan(rotate)
        if _traH <= whitePos.y-_tableY then
            return (_tableX+_tableWidth-whitePos.x)/math.cos(rotate)-radius/math.cos(rotate),false
        else
            return (whitePos.y-_tableY)/math.sin(rotate)-radius/math.sin(rotate),true
        end
    end
    return 0
end

--点到直线最短距离
function help.getShortestDistanceBetweenPointAndLine(rotate,ballPos,whitePos,radius)
    local A,B,C = help.getLineEquation(rotate / 180 * math.pi, whitePos)
    local _verticalLine = math.abs(A*ballPos.x+B*ballPos.y+C)/math.sqrt(A*A+B*B)
    return math.sqrt(4*radius*radius-_verticalLine*_verticalLine)
end

--获取射线的方程式 return y=kx+b
function help.getLineEquation(rotate, whitePos)
    local A = -math.tan(rotate)
    local B = 1
    local C = math.tan(rotate)*whitePos.x - whitePos.y
    return A,B,C
end

--根据亮点获取在一个圆上的交点
--@whiteCollisionPoint 白球的node坐标
--@ballCollisionPoint 彩球的node坐标
--@radius 球的半径
function help.getPointOnCircle(_self,_whiteCollisionPoint,_ballCollisionPoint,radius)
    print("====",_ballCollisionPoint.x,_whiteCollisionPoint.x,_ballCollisionPoint.y,_whiteCollisionPoint.y)
    if _ballCollisionPoint.x >= _whiteCollisionPoint.x and _ballCollisionPoint.y >= _whiteCollisionPoint.y then
        return _self.node:convertToNodeSpace(cc.p((1.5*_ballCollisionPoint.x-0.5*_whiteCollisionPoint.x),
        (_whiteCollisionPoint.y+1.5*(math.sqrt(4*_radius*_radius-math.pow(_ballCollisionPoint.x-_whiteCollisionPoint.x,2))))))
    elseif _ballCollisionPoint.x >= _whiteCollisionPoint.x and _ballCollisionPoint.y >= _whiteCollisionPoint.y then
        
    elseif _ballCollisionPoint.x >= _whiteCollisionPoint.x and _ballCollisionPoint.y >= _whiteCollisionPoint.y then
        
    elseif _ballCollisionPoint.x >= _whiteCollisionPoint.x and _ballCollisionPoint.y >= _whiteCollisionPoint.y then
        
    end
end

--@ params
--@ completeCallback: 完成回调
--@ animation: 加载完成动画
--@ loop: 是否循环
function help.skeletonCreate( jsonPath, atlasPath, scale, params )
	local skeleton = sp.SkeletonAnimation:create(jsonPath, atlasPath, scale)
	if params then
		if params.animation then
			skeleton:setAnimation(0, params.animation, params.loop)
		end
		if params and params.completeCallback then
			-- skeleton:setCompleteListener(function ( ... )
			-- 	params.completeCallback()
			-- end)
			
			skeleton:registerSpineEventHandler(function (...)
		        params.completeCallback(...)
		    end, sp.EventType.ANIMATION_COMPLETE)
			
			print("TODO completeCallback")
		end
	end
	return skeleton
end

return help