-- 老虎游戏模块
module('Tiger', package.seeall)
-- 老虎所需数据库表名称
DB_Name = "game127tiger"
-- 老虎通用配置
GameId = 127
S = 70
W = 90
B = 6
DataFormat = {3,3,3}    -- 棋盘规格
Table_Base = import "table/game/127/table_127_hanglie"                        -- 基础行列
MaxNormalIconId = 10
LineNum = Table_Base[1].linenum
-- 构造数据存档
function Get(gameType,uid)
    -- 获取老虎模块数据库信息
    local tigerInfo = unilight.getdata(DB_Name, uid)
    -- 没有则初始化信息
    if table.empty(tigerInfo) then
        tigerInfo = {
            _id = uid, -- 玩家ID
            gameRooms = {}, -- 游戏类型
        }
        unilight.savedata(DB_Name,tigerInfo)
    end
    if gameType == nil then
        return tigerInfo
    end
    -- 没有初始化房间信息
    if table.empty(tigerInfo.gameRooms[gameType]) then
        tigerInfo.gameRooms[gameType] = {
            betIndex = 1, -- 当前玩家下注下标
            betMoney = 0, -- 当前玩家下注金额
            boards = {}, -- 当前模式游戏棋盘
            respin = {}, -- respin游戏信息
        }
        unilight.update(DB_Name,uid,tigerInfo)
    end
    return tigerInfo.gameRooms[gameType]
end
-- 保存数据存档
function SaveGameInfo(uid,gameType,roomInfo)
    -- 获取老虎模块数据库信息
    local tigerInfo = unilight.getdata(DB_Name, uid)
    tigerInfo.gameRooms[gameType] = roomInfo
    unilight.update(DB_Name,uid,tigerInfo)
end

-- 判断是否中了10倍大奖
function IsAllWinPoints(boards,res)
	local firstIcon = 0
	for col = 1,#DataFormat do
		for row = 1,DataFormat[col] do
			-- 缓存第一个不是空白和W的图标
			if firstIcon == 0 and boards[col][row] ~= W then
				firstIcon = boards[col][row]
			end
			if boards[col][row] ~= W and (boards[col][row] ~= firstIcon or boards[col][row] == 0 ) then
				return false 
			end
		end
	end
	res.bigWinIcon = firstIcon
    return true
end

-- 包装返回信息
function GetResInfo(uid, tigerInfo, gameType, tringerPoints)
    -- 克隆数据表
    tigerInfo = table.clone(tigerInfo)
    tringerPoints = tringerPoints or {}
    -- 模块信息
    local boards = {}
    if table.empty(tigerInfo.boards) == false then
        boards = {tigerInfo.boards}
    end
    local respin = {}
    if not table.empty(tigerInfo.respin) then
        respin = {
            totalTimes = tigerInfo.respin.totalTimes, -- 总次数
            lackTimes = tigerInfo.respin.lackTimes, -- 剩余游玩次数
            tWinScore = tigerInfo.respin.tWinScore, -- 总共已经赢得的钱
            respinIconId = tigerInfo.respin.respinIconId, -- 总共已经赢得的钱
            respinMul = tigerInfo.respin.respinMul, -- 总共已经赢得的钱
        }
    end
    local res = {
        errno = 0,
        -- 是否满线
        bAllLine = table_127_hanglie[1].linenum,
        -- 获取玩家下注金额范围 下注配置
        betConfig = gamecommon.GetBetConfig(gameType,table_127_hanglie[1].linenum),
        -- 下注索引
        betIndex = tigerInfo.betIndex,
        -- 全部下注金额
        payScore = tigerInfo.betMoney,
        -- 已赢的钱
        -- winScore = tigerInfo.winScore,
        winlines = tigerInfo.winlines,
        -- 面板格子数据
        boards = boards,
        -- 独立调用定义
        features={respin = respin},
        respin = respin,
    }
    return res
end