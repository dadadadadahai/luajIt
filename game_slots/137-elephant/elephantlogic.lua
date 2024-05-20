-- 大象游戏模块
module('Elephant', package.seeall)
-- 大象所需数据库表名称
DB_Name = "game137elephant"
-- 大象通用配置
GameId = 137
S = 70
W = 90
U = 80
DataFormat = {3,3,3,3,3}    -- 棋盘规格
Table_Base = import "table/game/137/table_137_hanglie"                        -- 基础行列
MaxNormalIconId = 6
NeedAddWildNum = 3          -- 免费中需要收集W个数
OneAddWildMul = 2           -- 免费中每次收集满增加倍数
MaxWildMul = 20             -- 免费中最多收集倍数上限
LineNum = Table_Base[1].linenum
local iconRealId = 1
local freeNum = 0
--执行大象图库
function StartToImagePool(imageType)
    return Normal()
end

function Free(freeLackNum)
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}
    local freeInfo = {}
    local wildNum = 0
    local totalMul = 0
    -- 生成返回数据
    while true do
        if freeLackNum <= 0 then
            break
        end
        freeLackNum = freeLackNum - 1
        -- 生成异形棋盘
        boards = gamecommon.CreateSpecialChessData(DataFormat,Elephant['table_137_free'])
    
        -- 获取中奖线
        local winPoints = {}
        -- 计算中奖倍数
        local resWinPoints,winMuls  = gamecommon.SpecialAllLineFinal(boards,wilds,nowild,table_137_paytable)
        winPoints[1] = resWinPoints
        -- 获取中奖线
        local wMul = 2
        local wildPoints = {}
        local wNum = 0
        -- 统计W个数
        for col = 1, #boards do
            for row = 1, #boards[col] do
                if boards[col][row] == W then
                    table.insert(wildPoints,{line = col, row = row})
                    wNum = wNum + 1
                end
            end
        end
        wildNum = wildNum + wNum
        -- 根据W个数匹配倍数
        wMul = wMul + math.floor(wildNum / NeedAddWildNum) * OneAddWildMul
        if wMul > MaxWildMul then
            wMul = MaxWildMul
        end
        local winMul = 0
        local winEle = {}
        for i, v in ipairs(winMuls) do
            winMul = sys.addToFloat(winMul,v.mul)
            table.insert(winEle,{ele = v.ele,mul = v.mul})
        end
        local res = {
            boards = boards,                    --棋盘图标
            winPoints = winPoints,              --中奖下标
            wMul = wMul,                        --本轮的W倍数
            winMul = winMul,                    --本轮的普通倍数
            wildNum = wildNum,                  --W个数
            winEle = winEle,
        }
        table.insert(freeInfo,res)
        -- 增加倍数
        totalMul = sys.addToFloat(totalMul,(winMul * wMul))
    end
    return freeInfo,totalMul
end

function Normal()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}
    -- 生成返回数据
    local res = {}
    -- 生成异形棋盘
    boards = gamecommon.CreateSpecialChessData(DataFormat,table_137_normalspin)
    local elephantInfo = {
        betMoney = 1,
        free = {},
    }
    -- 计算中奖倍数
    local winPoints,winMuls  = gamecommon.SpecialAllLineFinal(boards,wilds,nowild,table_137_paytable)
    -- -- 中奖金额
    -- res.winScore = 0
    -- 获取中奖线
    res.winPoints = {}
    res.winPoints[1] = winPoints


    
    -- 触发位置
    res.tringerPoints = {}
    res.winEle = {}
    local winMul = 0
    for i, v in ipairs(winMuls) do
        winMul = sys.addToFloat(winMul,v.mul)
        table.insert(res.winEle,{ele = v.ele,mul = v.mul})
    end
    res.normalMul = winMul
    -- 棋盘数据保存数据库对象中 外部调用后保存数据库
    elephantInfo.boards = boards
    -- 判断是否中Free
    local free
    res.tringerPoints.freeTringerPoints,free = GetFree(elephantInfo)
    res.freeTotalTime = free.totalTimes or 0
    -- 棋盘数据
    res.boards = boards
    local imageType = 1
    if free.totalTimes ~= nil and free.totalTimes > 0 then
        res.freeInfo,res.freeMul = Free(free.lackTimes)
        winMul = winMul + res.freeMul
        imageType = 2
    end

    return res, winMul, imageType
end

-- 判断是否触发免费
function GetFree(elephantInfo)
    local sNum = 0
    -- 触发免费位置
    local freeTringerPoints = {}
    -- 统计S个数
    for col = 1, #elephantInfo.boards do
        for row = 1, #elephantInfo.boards[col] do
            if elephantInfo.boards[col][row] == S then
                table.insert(freeTringerPoints,{line = col, row = row})
                sNum = sNum + 1
            end
        end
    end
    local free = {}
    for i, sNumInfo in ipairs(table_137_freenum) do
        if sNum == sNumInfo.sNum then
            free = {
                totalTimes = sNumInfo.freeNum,
                lackTimes = sNumInfo.freeNum,
                tWinScore = 0,
                wildNum = 0,
            }
            break
        end
    end
    return freeTringerPoints,free
end