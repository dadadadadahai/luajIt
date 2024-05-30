
module('MasterJoker', package.seeall)
DB_Name = "game164masterjoker"

GameId = 164
S = 70
W = 90
DataFormat = {1,1,1,1,1}    -- 棋盘规格
Table_Base = import "table/game/164/table_164_hanglie"                        -- 基础行列
--执行金牛图库
function StartToImagePool(imageType)
    return Normal()
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
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_164_normalspin)
	-- 计算中奖倍数
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_164_payline,table_164_paytable,wilds,nowild)

	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
    -- 棋盘数据
    res.boards = boards
    return res, winMul, imageType
end