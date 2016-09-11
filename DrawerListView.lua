--
-- Author: zhuorui
-- Date: 2016-07-19 11:27:45
--
DrawerListView = class("DrawerListView", function() return CCScrollView:create() end)

DrawerListHandler = {}
DrawerListHandler.kDrawerListNumber = 1             --注册格子数量函数
DrawerListHandler.kListCellSizeAtIndex = 2          --注册格子大小函数
DrawerListHandler.kDrawerCellSizeAtIndex = 3        --注册抽屉大小函数

--@param viewSize @class CCSize 窗口大小
--@param cellSize @class CCSize 单个格子大大小
--@param drawerSize @class CCSize 抽屉格子大小
--@param moveLength @class number 抽屉移动长度
--@param touchPriority @class number 触摸优先级
function DrawerListView:create(viewSize, cellSize, drawerSize, moveLength, touchPriority)
    local listView = DrawerListView:new()
    listView:init(viewSize, cellSize, drawerSize, moveLength, touchPriority)
    return listView
end

function DrawerListView:ctor()
	self.arrDrawerNode = {}
	self.arrMoveNode = {}
	self.moveLength = 0
	self.moveIdx = -1
	self.viewSize = CCSizeMake(0, 0)
	self.cellSize = CCSizeMake(0, 0)
    self.drawerSize = CCSizeMake(0, 0)
	self.handlerTable = {}
    self.isMoving = false
end

function DrawerListView:init(viewSize, cellSize, drawerSize, moveLength, touchPriority)
	self.viewSize = viewSize
	self.cellSize = cellSize
    self.drawerSize = drawerSize
	self.moveLength = moveLength

    self:setViewSize(viewSize)
    self.m_viewSize = viewSize
    self.touchPriority = touchPriority

    local layContainer = CCLayer:create()
    local function onTouchEvent(eventType, x, y)
        if eventType == "began" then
            self.startPos = ccp(x, y)
            return true
        elseif eventType == "moved" then

        else
            return self:onTouchEnded(ccp(x, y))
        end
    end
    layContainer:setTouchEnabled(true)
   	layContainer:registerScriptTouchHandler(onTouchEvent, false, self.touchPriority, false)
   	self:setContainer(layContainer)

    self:setTouchPriority(self.touchPriority)
end

function DrawerListView:onTouchEnded(pos)
    if ccpDistance(self.startPos, pos) > 10 then
        return 
    end

    if self.isMoving then
        return
    end

	local worldPos = self:convertToWorldSpace(ccp(0, 0))
	local touchRect = CCRectMake(worldPos.x, worldPos.y, self.viewSize.width, self.viewSize.height)

    if not touchRect:containsPoint(pos) then
        return 
    end

    for k, v in pairs(self.arrDrawerNode)do
    	local _pos = v:convertToWorldSpace(ccp(0, 0))
    	local _rect = CCRectMake(_pos.x - self.cellSize.width / 2,  _pos.y - self.cellSize.height / 2, 
    							self.cellSize.width, self.cellSize.height)
    	if _rect:containsPoint(pos) then
    		-- cclog("touch "..k)
            self.isMoving = true
            if k == self:numberOfCellsInDrawerView() then
                self:setContentOffsetInDuration(ccp(-self.moveLength, 0), 0.3)
            end
            if self.moveIdx > 0 then
                local preMoveNode = self.arrDrawerNode[self.moveIdx]
                local drawerNode = self.arrDrawerNode[self.moveIdx - 1]:getChildByTag(100)
                if preMoveNode then
                    local action = CCMoveBy:create(0.3, ccp(-self.moveLength, 0))
                    preMoveNode:runAction(action)
                end

                if drawerNode then
                    local actMove = CCMoveBy:create(0.3, ccp(-self.moveLength, 0))
                    local actHide = CCHide:create()
                    local actDelay = CCDelayTime:create(0.1)    
                    local actCallback = CCCallFunc:create(function() self.isMoving = false end)

                    local arrSeq = CCArray:create()
                    arrSeq:addObject(actMove)
                    arrSeq:addObject(actHide)
                    arrSeq:addObject(actDelay)
                    arrSeq:addObject(actCallback)

                    local actionSeq = CCSequence:create(arrSeq)
                    drawerNode:runAction(actionSeq)
                end
            end

    		if self.moveIdx ~= k + 1 then
	    		local moveNode = self.arrDrawerNode[k + 1]
                if moveNode then
    	    		local actMove = CCMoveBy:create(0.3, ccp(self.moveLength, 0))
    	    		moveNode:runAction(actMove)
                end	
                self.moveIdx = k + 1

                local drawerNode = self.arrDrawerNode[k]:getChildByTag(100)
                drawerNode:setVisible(true)
                local actMove = CCMoveBy:create(0.3, ccp(self.moveLength, 0))
                local actDelay = CCDelayTime:create(0.1)
                local actCallback = CCCallFunc:create(function() self.isMoving = false end)

                local arrSeq = CCArray:create()
                arrSeq:addObject(actMove)
                arrSeq:addObject(actDelay)
                arrSeq:addObject(actCallback)

                local actionSeq = CCSequence:create(arrSeq)
                drawerNode:runAction(actionSeq)

                -- local layContainer = self:getContainer()
                -- local _, _, _w, _h = layContainer:boundingBoxLUA()
                -- layContainer:setContentSize(CCSizeMake(_w + self.moveLength, _h))
            else 
                self.moveIdx = -1	

                -- local layContainer = self:getContainer()        
                -- local _, _, _w, _h = layContainer:boundingBoxLUA()
                -- layContainer:setContentSize(CCSizeMake(_w -self.moveLength, _h))	
    		end
            return
    	end
    end
end

function DrawerListView:insertDrawerNode(node)
	table.insert(self.arrDrawerNode, node)
end

function DrawerListView:numberOfCellsInDrawerView()
	return self.handlerTable[DrawerListHandler.kDrawerListNumber]()
end

function DrawerListView:listCellAtIndex(index)
	local cellNode = CCNode:create()
	return self.handlerTable[DrawerListHandler.kListCellSizeAtIndex](index, cellNode)
end

function DrawerListView:drawerCellAtIndex(index)
    local cellNode = CCNode:create()
    return self.handlerTable[DrawerListHandler.kDrawerCellSizeAtIndex](index, cellNode)
end

function DrawerListView:registerHandler(func, handlerId)
	self.handlerTable[handlerId] = func
end

function DrawerListView:reloadData()
	local cellCount = self:numberOfCellsInDrawerView()
    local width = cellCount * self.cellSize.width + self.moveLength
    local layContainer = self:getContainer()
    layContainer:removeAllChildrenWithCleanup(true)
    layContainer:setContentSize(CCSizeMake(width, self.viewSize.height))
    -- self:setContainer(layContainer)
    self:setDirection(kCCScrollViewDirectionHorizontal)

	self.arrDrawerNode = {}
	self.arrMoveNode = {}

    for i = 1, cellCount do
    	self:insertDrawerNode(self:listCellAtIndex(i))
    	local drawerNode = self.arrDrawerNode[i]
    	if i == 1 then
	    	drawerNode:setPosition(self.cellSize.width / 2, self.viewSize.height / 2)
    		layContainer:addChild(drawerNode)
    	else
    		local parentNode = self.arrDrawerNode[i - 1] 
	    	drawerNode:setPosition(self.cellSize.width, 0)
	    	parentNode:addChild(drawerNode)
     	end

        local drawerChirldNode = self:drawerCellAtIndex(i)
        drawerChirldNode:setPosition(self.cellSize.width / 2 - self.drawerSize.width / 2, 0)
        drawerChirldNode:setVisible(false)
        drawerNode:addChild(drawerChirldNode, -100, 100)
    end
end

