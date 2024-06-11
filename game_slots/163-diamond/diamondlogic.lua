module('diamond', package.seeall)
local DataFormat = { 3, 3, 3, 3, 3 }
GameId = 163
S = 70
W = 90
Table_Base = import "table/game/163/table_163_hanglie"  
LineNum = Table_Base[1].linenum
--执行雷神2图库
function StartToImagePool(imageType)
    if imageType == 1 then
        return Normal()
	elseif imageType ==2 then
	--跑免费图库
		return Free()
    end
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
    -- 获取中奖线
    res.winlines = {}
    local winMul = 0
    local imageType = 1
    -- respin中奖金额
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_163_normalspin)
	-- 计算中奖倍数
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_163_payline,table_163_paytable,wilds,nowild)

	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines, {v.line, v.num, v.mul/3,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
    -- 棋盘数据
    res.boards = boards
    return res, winMul, imageType
end