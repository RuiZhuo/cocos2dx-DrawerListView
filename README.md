# 简介
这是一个以lua编写，可以拉开抽屉的tableview扩展空间。
#创建
```
--@param viewSize @class CCSize 窗口大小
--@param cellSize @class CCSize 单个格子大大小
--@param drawerSize @class CCSize 抽屉格子大小
--@param moveLength @class number 抽屉移动长度
--@param touchPriority @class number 触摸优先级
local drawerView = DrawerListView:create(viewSize, cellSize, drawerSize, moveLength, touchPriority)

--注册格子数量
local function number()
    return 4
end

--注册对格子node进行必要的操作
local function cellAtIndex(index, cellNode)
    return cellNode
end

--注册对抽屉格子进行必要的操作
local function drawerAtIndex(index, drawerNode)
    return drawerNode
end

drawerView:registerHandler(number, DrawerListHandler.kDrawerListNumber)
drawerView:registerHandler(cellAtIndex, DrawerListHandler.kListCellSizeAtIndex)
drawerView:registerHandler(drawerAtIndex, DrawerListHandler.kDrawerCellSizeAtIndex)
drawerView:reloadData()
```
