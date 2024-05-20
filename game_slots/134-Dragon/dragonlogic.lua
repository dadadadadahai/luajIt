-- 生肖龙游戏模块
module('Dragon', package.seeall)
-- 生肖龙所需数据库表名称
DB_Name = "game134dragon"
-- 生肖龙通用配置
GameId = 134
S = 70
W = 90
B = 6
DataFormat = {3,3,3}    -- 棋盘规格
Table_Base = import "table/game/134/table_134_hanglie"                        -- 基础行列
MaxNormalIconId = 6
LineNum = Table_Base[1].linenum
--执行生肖龙图库
function StartToImagePool(imageType)
    if imageType == 0 or imageType == 1 or imageType == 3 then
        return Normal()
    elseif imageType == 2 then
        return Special()
    end
end

function Normal()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}

    local bonusFlag = false
    local firstFlag = false
    local winMul = 0
    -- 随机是否触发免费模式
    if (math.random(10000) <= table_134_freePro[1].pro) then
        -- 免费模式
        bonusFlag = true
        local res = {}
        res.free = {}
        for i = 1, 8 do
            boards = gamecommon.CreateSpecialChessData(DataFormat,table_134_free)
            -- 计算中奖倍数
            local winlines = gamecommon.WiningLineFinalCalc(boards,table_134_payline,table_134_paytable,wilds,nowild)
            local reswinlines = {}
            reswinlines[1] = {}
            local freeMul = 0
            -- 计算中奖线金额
            for k, v in ipairs(winlines) do
                table.insert(reswinlines[1], {v.line, v.num, v.mul,v.ele})
                freeMul = sys.addToFloat(freeMul,v.mul)
            end
            -- 每一句初始化倍数
            local mulList = {}
            local sumMul = 1
            -- 特殊模式随机
            local mulInfo = table_134_freeMul[gamecommon.CommRandInt(table_134_freeMul, 'pro')]
            -- 随机显示
            local randomPoints = chessutil.NotRepeatRandomNumbers(1, 3, 3)
            for _, point in ipairs(randomPoints) do
                if mulInfo['mul'..point] > 0 then
                    table.insert(mulList,mulInfo['mul'..point])
                end
            end
            sumMul = mulInfo.sumMul
            winMul = winMul + freeMul * sumMul
            -- 生成返回数据
            table.insert(res.free,{
                boards = boards,
                reswinlines = reswinlines,
                mulList = mulList,
                sumMul = sumMul,
                winMul = freeMul * sumMul
                -- bonusFlag = bonusFlag,
                -- firstFlag = firstFlag,
            })

        end
        winMul = winMul / table_134_hanglie[1].linenum
        return res, winMul, 3
    else
        -- 普通模式
        -- 生成异形棋盘
        boards = gamecommon.CreateSpecialChessData(DataFormat,table_134_normalspin)
        -- 计算中奖倍数
        local winlines = gamecommon.WiningLineFinalCalc(boards,table_134_payline,table_134_paytable,wilds,nowild)
        local reswinlines = {}
        reswinlines[1] = {}
        winMul = 0
        -- 计算中奖线金额
        for k, v in ipairs(winlines) do
            table.insert(reswinlines[1], {v.line, v.num, v.mul,v.ele})
            winMul = sys.addToFloat(winMul,v.mul)
        end
        -- 每一句初始化倍数
        local mulList = {}
        local sumMul = 1
        -- 随机额外倍数
        local mul = table_134_normalMul[gamecommon.CommRandInt(table_134_normalMul, 'pro')].mul
        table.insert(mulList,mul)
        sumMul = mul
        winMul = winMul * sumMul
        -- 生成返回数据
        local res = {
            boards = boards,
            reswinlines = reswinlines,
            mulList = mulList,
            sumMul = sumMul,
            -- bonusFlag = bonusFlag,
            -- firstFlag = firstFlag,
        }
        winMul = winMul / table_134_hanglie[1].linenum
        return res, winMul, 1
    end
end


function Special()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}

    local bonusFlag = false
    local firstFlag = false
    local winMul = 0
    -- 随机是否触发免费模式
    if (math.random(10000) <= table_134_freePro[1].pro) then
        -- 免费模式
        bonusFlag = true
        local res = {}
        for i = 1, 8 do
            boards = gamecommon.CreateSpecialChessData(DataFormat,table_134_free)
            -- 计算中奖倍数
            local winlines = gamecommon.WiningLineFinalCalc(boards,table_134_payline,table_134_paytable,wilds,nowild)
            local reswinlines = {}
            reswinlines[1] = {}
            local freeMul = 0
            -- 计算中奖线金额
            for k, v in ipairs(winlines) do
                table.insert(reswinlines[1], {v.line, v.num, v.mul,v.ele})
                freeMul = sys.addToFloat(freeMul,v.mul)
            end
            -- 每一句初始化倍数
            local mulList = {}
            local sumMul = 1
            -- 特殊模式随机
            local mulInfo = table_134_freeMul[gamecommon.CommRandInt(table_134_freeMul, 'pro')]
            -- 随机显示
            local randomPoints = chessutil.NotRepeatRandomNumbers(1, 3, 3)
            for _, point in ipairs(randomPoints) do
                if mulInfo['mul'..point] > 0 then
                    table.insert(mulList,mulInfo['mul'..point])
                end
            end
            sumMul = mulInfo.sumMul
            winMul = winMul + freeMul * sumMul
            res.free = {}
            -- 生成返回数据
            table.insert(res.free,{
                boards = boards,
                reswinlines = reswinlines,
                mulList = mulList,
                sumMul = sumMul,
                -- bonusFlag = bonusFlag,
                -- firstFlag = firstFlag,
            })

        end
        winMul = winMul / table_134_hanglie[1].linenum
        return res, winMul, 3
    else
        -- 普通模式
        -- 生成异形棋盘
        boards = gamecommon.CreateSpecialChessData(DataFormat,table_134_normalspin)
        -- 计算中奖倍数
        local winlines = gamecommon.WiningLineFinalCalc(boards,table_134_payline,table_134_paytable,wilds,nowild)
        local reswinlines = {}
        reswinlines[1] = {}
        winMul = 0
        -- 计算中奖线金额
        for k, v in ipairs(winlines) do
            table.insert(reswinlines[1], {v.line, v.num, v.mul,v.ele})
            winMul = sys.addToFloat(winMul,v.mul)
        end
        -- 每一句初始化倍数
        local mulList = {}
        local sumMul = 1
        -- 随机额外倍数
        local mul = table_134_normalMul[gamecommon.CommRandInt(table_134_normalMul, 'pro')].mul
        table.insert(mulList,mul)
        sumMul = mul
        winMul = winMul * sumMul
        -- 生成返回数据
        local res = {
            boards = boards,
            reswinlines = reswinlines,
            mulList = mulList,
            sumMul = sumMul,
            -- bonusFlag = bonusFlag,
            -- firstFlag = firstFlag,
        }
        winMul = winMul / table_134_hanglie[1].linenum
        return res, winMul, 2
    end
end