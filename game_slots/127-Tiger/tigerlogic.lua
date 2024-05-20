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
Table_mulPro = import "table/game/127/table_127_mulPro"  
spuriousPro  =   Table_mulPro[1].spuriousPro or 100
MaxNormalIconId = 10
LineNum = Table_Base[1].linenum
--执行金牛图库
function StartToImagePool(imageType)
	if imageType == 2 then 
		return Free()
	elseif imageType == 3 then
		return FullIcon()
	end 
    return Normal()
end
function FullIcon()
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
    res.winlines[1] = {}
    local winMul = 0
    local imageType = 1
    -- respin中奖金额
    res.respinWinScore = 0
    res.bigWinIcon = -1
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_127_normalspin)
	local iconId = table_127_mulIcon[gamecommon.CommRandInt(table_127_mulIcon, 'pro')].iconId
	for col = 1, #DataFormat do
		for row = 1, DataFormat[col] do
			boards[col][row] = iconId
		end
	end
	res.bigWinIcon = iconId
	res.respinFlag = false
	-- 计算中奖倍数
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_127_payline,table_127_paytable,wilds,nowild)

	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines[1], {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end

	if IsAllWinPoints(boards,res) then
		winMul = winMul * 10
		imageType = 3
	end
	winMul = winMul 
    

    -- 棋盘数据
    res.boards = boards
	res.isfake = false
    return res, winMul, imageType
end 
function Free()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
	local imageType = 2
    -- 生成返回数据
    local res = RespinFinalBoards()
	local winMul = res.winMul
	    -- 最终棋盘
    local boards = table.clone(res.boards)

	local resultRespinInfo = AheadRespin(res)
	local resultRespin = resultRespinInfo.resultRespin
	res.respin = resultRespinInfo.bres
    -- 棋盘数据
    res.winlines = resultRespin.winlines
	res.boards = resultRespin.boards
	res.isfake = false
    return res, winMul, imageType
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
    res.winlines[1] = {}
    local winMul = 0
    local imageType = 1
    -- respin中奖金额
    res.bigWinIcon = -1
   
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_127_normalspin)
	res.respinFlag = false
	-- 计算中奖倍数
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_127_payline,table_127_paytable,wilds,nowild)

	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines[1], {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end

	if IsAllWinPoints(boards,res) then
		winMul = winMul * 10
		imageType = 3
	end
	winMul = winMul 
  
    -- 棋盘数据
    res.boards = boards
	res.isfake = (math.random(10000) <= spuriousPro   and true or false )
    return res, winMul, imageType
end