-- 兔子游戏模块
module('Rabbit', package.seeall)
-- 兔子所需数据库表名称
DB_Name = "game132rabbit"
-- 兔子通用配置
GameId = 132
S = 70
W = 90
U = 80
DataFormat = {3,4,3}    -- 棋盘规格
Table_Base = import "table/game/132/table_132_hanglie"                        -- 基础行列
MaxNormalIconId = 6
LineNum = Table_Base[1].linenum
-- 构造数据存档
function Get(gameType,uid)
    -- 获取兔子模块数据库信息
    local rabbitInfo = unilight.getdata(DB_Name, uid)
    -- 没有则初始化信息
    if table.empty(rabbitInfo) then
        rabbitInfo = {
            _id = uid, -- 玩家ID
            gameRooms = {}, -- 游戏类型
        }
        unilight.savedata(DB_Name,rabbitInfo)
    end
    if gameType == nil then
        return rabbitInfo
    end
    -- 没有初始化房间信息
    if table.empty(rabbitInfo.gameRooms[gameType]) then
        rabbitInfo.gameRooms[gameType] = {
            betIndex = 1, -- 当前玩家下注下标
            betMoney = 0, -- 当前玩家下注金额
            boards = {}, -- 当前模式游戏棋盘
            free = {}, -- 免费游戏信息
            wildNum = 0, -- 棋盘是否有W图标
            BuyFreeNumS = 0, -- 是否购买免费:购买出来的免费图标个数
            iconsAttachData = {}, -- 附加数据 iconB:棋盘B图标信息(位置、倍数)
            -- collect = {}, -- 收集信息
        }
        unilight.update(DB_Name,uid,rabbitInfo)
    end
    return rabbitInfo.gameRooms[gameType]
end
-- 保存数据存档
function SaveGameInfo(uid,gameType,roomInfo)
    -- 获取兔子模块数据库信息
    local rabbitInfo = unilight.getdata(DB_Name, uid)
    rabbitInfo.gameRooms[gameType] = roomInfo
    unilight.update(DB_Name,uid,rabbitInfo)
end
-- 生成棋盘
function GetBoards(uid,gameId,gameType,isFree,rabbitInfo)
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}
    -- 生成返回数据
    local res = {}
    -- 普通游戏
    local betInfo = {
        betindex = rabbitInfo.betIndex,
        betchips = rabbitInfo.betMoney,
        gameId = gameId,
        gameType = gameType,
    }
    -- 判断是否进入免费
    if isFree == false and  (math.random(10000) <= table_132_respinPro[1].pro or GmProcess()) then
        -- 普通则触发免费初始化
        rabbitInfo.free.totalTimes = table_132_respinPro[1].num                 -- 总次数
        rabbitInfo.free.lackTimes = table_132_respinPro[1].num - 1              -- 剩余游玩次数
        rabbitInfo.free.tWinScore = 0                                           -- 已经赢得的钱
        isFree = true
    end
    -- 是否触发保底机制
    local isMininumGuarantee = false
    local mininumGuaranteeMulList = {}
    if isFree then
        local uNum = table_132_respinIcon[gamecommon.CommRandInt(table_132_respinIcon, 'pro')].uNum
        -- 判断保底
        uNum, isMininumGuarantee, mininumGuaranteeMulList = GetMinimumGuarantee(uNum, rabbitInfo)
        local uList = chessutil.NotRepeatRandomNumbers(1, 10, uNum)
        --进行排序
        table.sort(uList, function(a, b)
            return a < b
        end)
        local insertPoint = 0
        local listPoint = 1
        -- 遍历棋盘对应位置插入U图标
        for col = 1, #DataFormat do
            for row = 1, DataFormat[col] do
                if boards[col] == nil then
                    boards[col] = {}
                end
                insertPoint = insertPoint + 1
                if insertPoint == uList[listPoint] then
                    boards[col][row] = U
                    listPoint = listPoint + 1
                else
                    boards[col][row] = 88
                end
            end
        end
    else
        -- 生成异形棋盘
        boards = gamecommon.CreateSpecialChessData(DataFormat,gamecommon.GetSpin(uid,gameId,gameType,betInfo))
    end
    -- 根据棋盘中U图标生成对应数据
    GetIconInfoU(boards,rabbitInfo.iconsAttachData,isMininumGuarantee,mininumGuaranteeMulList)

    -- 计算中奖倍数
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_132_payline,table_132_paytable,wilds,nowild)

    -- 中奖金额
    res.winScore = 0
    -- 触发位置
    res.tringerPoints = {}
    -- 获取中奖线
    res.winlines = {}
    res.winlines[1] = {}
    -- 计算中奖线金额
    for k, v in ipairs(winlines) do
        local addScore = v.mul * rabbitInfo.betMoney / table_132_hanglie[1].linenum
        res.winScore = res.winScore + addScore
        table.insert(res.winlines[1], {v.line, v.num, addScore,v.ele})
    end

    -- 判断U图标中奖金额
    local winScoreU = GetWinScoreU(rabbitInfo.betMoney,rabbitInfo.iconsAttachData)
    res.winScore = res.winScore + winScoreU

    -- 棋盘数据保存数据库对象中 外部调用后保存数据库
    rabbitInfo.boards = boards
    -- 棋盘数据
    res.boards = boards
    -- 棋盘附加数据
    res.iconsAttachData = rabbitInfo.iconsAttachData
    res.isFree = isFree
    res.extraData = {
    }
    return res
end

-- 生成U图标数据
function GetIconInfoU(boards,iconsAttachData)
    -- 初始化U图标个数
    iconsAttachData.uNum = 0
    iconsAttachData.boardsInfo = {}
    local listpoint = 0
    -- 遍历棋盘生成对应位置U图标的信息
    for col = 1, #DataFormat do
        for row = 1, DataFormat[col] do
            if boards[col][row] == U then
                table.insert(iconsAttachData.boardsInfo,{col = col, row = row, mul = table_132_uPro[gamecommon.CommRandInt(table_132_uPro, 'pro')].mul})
                iconsAttachData.uNum = iconsAttachData.uNum + 1
            end
        end
    end
end

-- 判断U图标是否中奖
function GetWinScoreU(iconsAttachData)
    if iconsAttachData.uNum < 5 then
        return 0
    end
    -- U图标中奖金额
    local winMulU = 0
    for _, value in ipairs(iconsAttachData.boardsInfo) do
        winMulU = winMulU + value.mul
    end
    return winMulU
end

-- 判断FreeRespin中途是否满足保底
function GetMinimumGuarantee(uNum, rabbitInfo)
    local deficiencyMul = 0
    -- 在中途和结尾判断保底
    if rabbitInfo.free.lackTimes == math.floor(rabbitInfo.free.totalTimes / 2) then
        -- 中途判断保底
        deficiencyMul = 3 - rabbitInfo.free.tWinScore / rabbitInfo.betMoney
    elseif rabbitInfo.free.lackTimes == 0 then
        -- 在结尾判断保底
        deficiencyMul = 5 - rabbitInfo.free.tWinScore / rabbitInfo.betMoney
    end
    if deficiencyMul > 0 then
        -- 获取随机图标个数列表
        local respinIconList = {}
        for _, value in ipairs(table_132_respinIcon) do
            if value.uNum > 5 then
                table.insert(respinIconList,value)
            end
        end
        -- 获取倍数列表
        local mulList = {}
        local mulRandomList = {}
        for i = 1, 10 do
            -- 获取保底U图标个数
            uNum = respinIconList[gamecommon.CommRandInt(respinIconList, 'pro')].uNum
            local sumMul = 0
            local randomList = {}
            -- 随机图标倍数
            for id = 1, uNum do
                local mul = table_132_uPro[gamecommon.CommRandInt(table_132_uPro, 'pro')].mul
                sumMul = sumMul + mul
                table.insert(randomList,mul)
            end
            -- 如果满足中途的最小保底 则直接返回
            if sumMul == deficiencyMul then
                return uNum ,true ,randomList
            end
            table.insert(mulRandomList,{mulList = randomList,sumMul = sumMul,uNum = uNum})
        end

        -- 十次随机后选择最接近的保底倍数
        table.sort(mulRandomList, function(a, b)
            return deficiencyMul - a.sumMul > deficiencyMul - b.sumMul
        end)
        for id, value in ipairs(mulRandomList) do
            if value.sumMul >= deficiencyMul then
                -- 返回保底数据
                return value.uNum, true, value.mulList
            end
        end
    end
    return uNum, false, {}
end

-- 包装返回信息
function GetResInfo(uid, rabbitInfo, gameType, tringerPoints)
    -- 克隆数据表
    rabbitInfo = table.clone(rabbitInfo)
    tringerPoints = tringerPoints or {}
    -- 模块信息
    local boards = {}
    if table.empty(rabbitInfo.boards) == false then
        boards = {rabbitInfo.boards}
    end
    local free = {}
    if not table.empty(rabbitInfo.free) then
        free = {
            totalTimes = rabbitInfo.free.totalTimes, -- 总次数
            lackTimes = rabbitInfo.free.lackTimes, -- 剩余游玩次数
            tWinScore = rabbitInfo.free.tWinScore, -- 总共已经赢得的钱
            tringerPoints = {tringerPoints.freeTringerPoints} or {},
        }
    end
    local res = {
        errno = 0,
        -- 是否满线
        bAllLine = table_132_hanglie[1].linenum,
        -- 获取玩家下注金额范围 下注配置
        betConfig = gamecommon.GetBetConfig(gameType,table_132_hanglie[1].linenum),
        -- 下注索引
        betIndex = rabbitInfo.betIndex,
        -- 全部下注金额
        payScore = rabbitInfo.betMoney,
        -- 已赢的钱
        -- winScore = rabbitInfo.winScore,
        -- 面板格子数据
        boards = boards,
        -- 附加面板数据
        iconsAttachData = rabbitInfo.iconsAttachData,
        -- 独立调用定义
        features={free = free},
    }
    return res
end