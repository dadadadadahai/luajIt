--消息路由函数,管理对象
module('pockergameframe', package.seeall)
--桌面状态定义
TableStatus = {
    Empty = 1,
    Watting = 2,
    Busy = 3,
}



RoomMgr = {} --管理对象
--注册管理类
function RegisterMgrObj(gameId, PockerRoomMgrObj)
    RoomMgr[gameId] = PockerRoomMgrObj
    RegPluseObj(PockerRoomMgrObj)
end

--用户进入函数
function EnterCmd_C(gameId, gameType, uid)
    local PockerRoomobj = RoomMgr[gameId]
    print('PockerRoomobjSit,gameid=',gameId)
    if PockerRoomobj ~= nil then
        print('PockerRoomobjSit')
        PockerRoomobj:Enter(gameType, uid)
    end
end

--[[
    gameId 游戏id
    gameType 游戏类型
    uid   id
    msg  消息体
]]
function MsgHandleCmd_C(gameId, uid, msg)
    local RoomObj = RoomMgr[gameId]
    if RoomObj ~= nil then
        local gameTypeUser = RoomObj.roomUser[uid]
        if gameTypeUser ~= nil then
            local gameType = gameTypeUser.gameType
            local roomMgr = RoomObj.roomMgr[gameType]
            local tableId = roomMgr.roomUser[uid].tableId
            local tableObj = roomMgr.TableList[tableId]
            tableObj:msgHandle(uid, msg)
        end
    end
end

--用户掉线入口
function Drop(roomUser)
    if roomUser == nil then
        return
    end
    for gameid, roomObj in pairs(RoomMgr) do
        roomObj:msgUserDrop(roomUser.Id)
    end
end

--用户消息

--设置选项
-- option={
--     gameId,             --游戏id
--     gameModule,         --游戏模块
--     timePerior?,         --每桌时钟周期,默认500ms
-- }

-- --桌子子对象,导出函数
-- tableObj={
--     func msgHandle(uid,data)        --消息处理函数
--     func userSit(uid,isRobot)           --用户坐下函数 true false
--     func getUserInfo()         --返回当前桌子的玩家数{{uid,isRobot},{}}
--     func getTableStats()     --获取桌面状态 1 empty 2 waitting 3 busy
--     func Pluse(timeNow)      --时间脉冲函数 传入当前时间戳
--     func msgUserDrop(uid)      --上层用户消息
-- }

-- tableOption={
--     tableId,            --桌子id
--     gameType,            --游戏类型
--     tableCtrObj,        --上层传入对象，操作
-- }
--[[
    handle   --消息名
    data     --消息内容
]]
--牌类房间管理对象
PockerRoomMgr = {}
function PockerRoomMgr:New(option)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.gameId = option.gameId
    self.gameModule = option.gameModule
    self.latestTimePeior = 0 --上一次时间周期
    self.timePeriod = option.timePerior or 500
    self.roomMgr = {}        --房间管理 gameType
    self.roomUser = {}       --房间用户管理[uid]={uid,gameType}
    self.timeNow = 0         --现在的时间
    return obj
end

--开始初始化
function PockerRoomMgr:Init()
    --加载配置
    local zoneKey = go.config().GetConfigStr("zone_key")
    local gameId = tonumber(string.split(zoneKey, ":")[1])
    GameId = "G" .. gameId
    NUMBER_GAMEID = gameId
    gamecommon.RegGame(self.gameId, self.gameModule)
    chessroominfodb.InitUnifiedRoomInfoDb(go.gamezone.Gameid, 0, nil, nil, nil, nil, 0, 0)
    --加载配置
    gamecommon.GetModuleCfg(self.gameId, self.gameModule)
    local roomCfg = chessroominfodb.GetRoomAllInfo(go.gamezone.Gameid)
    for _, v in ipairs(roomCfg) do
        local gameType = v.roomId % 10
        --房间管理函数
        self.roomMgr[gameType] = {
            gameType = gameType,
            roomUser = {}, --用户对象 [uid] = {uid,tableId}
            TableList = {}, --桌面管理对象{latestStatusTime,tableId,obj}      --上次这种状态的持续时间,每张桌子的状态
        }
    end
    RegisterMgrObj(self.gameId, self)
end --返回当前是否应该进入时间脉冲函数

function PockerRoomMgr:IsPluse(timeNow)
    self.timeNow = timeNow
    if timeNow - self.latestTimePeior >= self.timePeriod then
        self.latestTimePeior = timeNow
        return true
    else
        return false
    end
end

--当前执行时间脉冲
function PockerRoomMgr:Pluse(timeNow)
    if self:IsPluse(timeNow) then
        for gameType, roomObj in pairs(self.roomMgr) do
            for tableid, tableobj in ipairs(roomObj.TableList) do
                tableobj.obj:Pluse(timeNow / 1000)
            end
        end
    end
end

--成功返回 true false 用户进入消息处理
function PockerRoomMgr:Enter(gameType, uid)
    if self.roomUser[uid] ~= nil then
        gameType = self.roomUser[uid].gameType
    end
    local tableId = 0
    local roomMgr = self.roomMgr[gameType]
    local roomUser = roomMgr.roomUser[uid]
    if roomUser ~= nil then
        tableId = roomUser.tableId
    end
    if tableId == 0 then
        --进入分桌逻辑
        tableId = self:DistributionTable(gameType, roomMgr.TableList)
    end
    print('tableId='..tableId)
    local obj = roomMgr.TableList[tableId].obj
    obj:userSit(uid, false)
    self.roomUser[uid] = { uid = uid, gameType = gameType }
    roomMgr.roomUser[uid] = { uid = uid, tableId = tableId }
    --上层加锁
end

--分配桌子
function PockerRoomMgr:DistributionTable(gameType, TableList)
    --处于等待状态的桌子
    local maxTimeTableobj = {}
    for tableId, tableobj in ipairs(TableList) do
        local obj = tableobj.obj
        if obj:getTableStats() == TableStatus.Watting then
            if table.empty(maxTimeTableobj) then
                maxTimeTableobj = tableobj
            elseif maxTimeTableobj.latestStatusTime > tableobj.latestStatusTime then
                maxTimeTableobj = tableobj
            end
        end
    end
    if table.empty(maxTimeTableobj) == false then
        --进入桌子
        return maxTimeTableobj.tableId
    end
    for tableId, tableobj in ipairs(TableList) do
        local obj = tableobj.obj
        if obj:getTableStats() == TableStatus.Empty then
            return tableobj.tableId
        end
    end
    --新加入桌子
    local tableoption = {
        tableId = #TableList + 1,
        tableCtrObj = self,
        gameType = gameType,
        timeNow = os.msectime()/1000,
    }
    table.insert(TableList, { 
        tableId = tableoption.tableId, obj = self.gameModule:New(tableoption) })
    return tableoption.tableId
end

--桌子状态改变回调
function PockerRoomMgr:TableStatusChange(gameType, tableId)
    local roomMgr = self.roomMgr[gameType]
    roomMgr.TableList[tableId].latestStatusTime = os.time()
end

--用户离开消息处理
function PockerRoomMgr:msgUserDrop(uid)
    if self.roomUser[uid] ~= nil then
        local gameType = self.roomUser[uid].gameType
        local tableId = self.roomMgr[gameType].roomUser[uid].tableId
        self.roomMgr.TableList[tableId]:msgUserDrop(uid)
    end
end

--用户离开调用函数
function PockerRoomMgr:UserLeave(uid)
    local gameType = self.roomUser[uid].gameType
    self.roomMgr[gameType].roomUser[uid] = nil
    self.roomUser[uid] = nil
    --上层解锁
end
--广播消息
function PockerRoomMgr:BrdTableMsg(obj,handle,data)
    local playinfos = obj:getUserInfo()
    for i=1,#playinfos do
        if playinfos[i].isRobot==false then
            SendMsg(playinfos[i].uid,handle,data)
        end
    end
end
--[[
    会送坐下消息
]]
function SendUserSitInfo(uid,tableId,chairId,nickName,headUrl,Scene)
    local data={
        tableId = tableId,
        chairId = chairId,
        nickName = nickName,
        headUrl = headUrl,
        Scene = Scene,
    }
    gamecommon.SendNet(uid,'PockerEnterCmd_S',data)
end
--[[
    handle   --消息名
    data     --消息内容
]]
--发送部分
function SendMsg(uid,handle,data)
    local cmd={}
    local d={
        handle=handle,
        data=data,
    }
    gamecommon.SendNet(uid,'MsgHandleCmd_S',d)
end
