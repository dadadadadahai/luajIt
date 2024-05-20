-- 金牛游戏模块
module('Mouse', package.seeall)
-- 金牛所需数据库表名称
DB_Name = "game133mouse"
-- 金牛通用配置
GameId = 133
S = 70
W = 90
B = 6
DataFormat = {3,3,3}    -- 棋盘规格
Table_Base = import "table/game/133/table_133_hanglie"                        -- 基础行列
Table_mulPro = import "table/game/133/table_133_mulPro"  
spuriousPro  =  Table_mulPro and  (Table_mulPro[1].spuriousPro or 100  ) or 100
MaxNormalIconId = 6
LineNum = Table_Base[1].linenum
local iconRealId = 1
local freeNum = 0
--执行金牛图库
function StartToImagePool(imageType)
	if imageType == 2 then 
		return  Free()
	end
    return Normal()
end

function Free()

        -- 获取W元素
        local wilds = {}
        wilds[W] = 1
        local nowild = {}
        -- 初始棋盘
        local boards = {}
		local imageType = 2
        local bonusFlag = true
        local firstFlag = false
        local winMul = 0
        -- 普通模式
        -- 生成异形棋盘
        boards = gamecommon.CreateSpecialChessData(DataFormat,table_133_free)
        -- 计算中奖倍数
       
		-- 检查是否进入福鼠模式 先强制给图库有问题
		boards[2] = {90,90,90}
        for row = 1, DataFormat[2] do
             if boards[2][row] ~= W then 
				bonusFlag = false
				imageType = 1
				break
			 end 
        end
		 local winlines = gamecommon.WiningLineFinalCalc(boards,table_133_payline,table_133_paytable,wilds,nowild)
        local reswinlines = {}
        reswinlines[1] = {}
        winMul = 0
        -- 计算中奖线金额
        for k, v in ipairs(winlines) do
            table.insert(reswinlines[1], {v.line, v.num, v.mul,v.ele})
            winMul = sys.addToFloat(winMul,v.mul)
        end
        -- 生成返回数据
        local res = {
            boards = boards,
            reswinlines = reswinlines,
            mulList = mulList,
            sumMul = winMul,
			isfake =  0
        }
		res.extraData = {
			bonusFlag = bonusFlag,  -- 福牛是否触发
			fullIconFlag = false,             -- 十倍是否触发
		}
        return res, winMul, imageType
end

function Normal()

        -- 获取W元素
        local wilds = {}
        wilds[W] = 1
        local nowild = {}
        -- 初始棋盘
        local boards = {}
		local imageType = 2
        local bonusFlag = true
        local firstFlag = false
        local winMul = 0
        -- 普通模式
        -- 生成异形棋盘
        boards = gamecommon.CreateSpecialChessData(DataFormat,table_133_normalspin)
        -- 计算中奖倍数
        local winlines = gamecommon.WiningLineFinalCalc(boards,table_133_payline,table_133_paytable,wilds,nowild)
        local reswinlines = {}
        reswinlines[1] = {}
        winMul = 0
        -- 计算中奖线金额
        for k, v in ipairs(winlines) do
            table.insert(reswinlines[1], {v.line, v.num, v.mul,v.ele})
            winMul = sys.addToFloat(winMul,v.mul)
        end
		-- 检查是否进入福牛模式
		
        for row = 1, DataFormat[2] do
             if boards[2][row] ~= W then 
				bonusFlag = false
				imageType = 1
				break
			 end 
        end
        -- 生成返回数据
        local res = {
            boards = boards,
            reswinlines = reswinlines,
            mulList = mulList,
            sumMul = winMul,
			isfake =  (math.random(10000) > spuriousPro   and 0 or 1 )  
        }
		 
		res.extraData = {
			bonusFlag = bonusFlag,  -- 福牛是否触发
			fullIconFlag = false,             -- 十倍是否触发
		}
        return res, winMul, imageType
end