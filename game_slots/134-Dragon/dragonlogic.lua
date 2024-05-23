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
Table_mulPro = import "table/game/134/table_134_mulPro"  
spuriousPro  =  Table_mulPro and  (Table_mulPro[1].spuriousPro or 100  ) or 100
MaxNormalIconId = 6
LineNum = Table_Base[1].linenum
--执行金龙图库 0 普通 1 正常 2免费
function StartToImagePool(imageType)
	if imageType == 2 then 
		return  Free()
	elseif imageType == 3 then 
		return  NormalSpecial()
	end
    return Normal()
end

function Free()
	local tFreeNum = 8
    local cFreeNum = 0
	local allInfos = {}
	local allwinMul = 0 
      -- 获取W元素
	 while true do	
        local wilds = {}
        wilds[W] = 1
        local nowild = {}
        -- 初始棋盘
        local boards = {}
        local winMul = 0
        -- 普通模式
        -- 生成异形棋盘
        boards = gamecommon.CreateSpecialChessData(DataFormat,table_134_free)
        -- 计算中奖倍数
	    local winlines = gamecommon.WiningLineFinalCalc(boards,table_134_payline,table_134_paytable,wilds,nowild)
        local reswinlines = {}
        -- 计算中奖线金额
        for k, v in ipairs(winlines) do
            table.insert(reswinlines, {v.line, v.num, v.mul,v.ele})
            winMul = sys.addToFloat(winMul,v.mul)
        end
				-- 检查是否进入触发特殊倍率
		local mulList = {}
		local randomnum = math.random(2)+1

	        -- 特殊模式随机
        local mulInfo = table_134_freeMul[gamecommon.CommRandInt(table_134_freeMul, 'pro')]
        -- 随机显示
        for i=1,3 do
            if mulInfo['mul'..i] > 0 then
                table.insert(mulList,mulInfo['mul'..i])
            end
        end
        local totalmul = mulInfo.sumMul
		
		winMul = winMul * totalmul 
        -- 生成返回数据
        local res = {
            boards = boards,
            reswinlines = reswinlines,
            mulList = mulList,
            sumMul = winMul,
        }
		allwinMul = allwinMul + winMul
		cFreeNum = cFreeNum + 1
        table.insert(allInfos, res)
		if cFreeNum >= tFreeNum then
            break
        end
	end 
	--allInfos.isFree = true
    return allInfos, allwinMul, 2
end

function Normal()
	-- 获取W元素
	local wilds = {}
	wilds[W] = 1
	local nowild = {}
	-- 初始棋盘
	local allInfos = {}
	local boards = {}
	local winMul = 0
	-- 普通模式
	-- 生成异形棋盘
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_134_normalspin)
	-- 计算中奖倍数
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_134_payline,table_134_paytable,wilds,nowild)
	local reswinlines = {}
	winMul = 0
	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(reswinlines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
	-- 检查是否进入触发特殊倍率
	local mulList = {}
	if winMul >0 then  --普通模式不触发倍成
	--[[	if math.random(10000) <= table_134_mulPro[1].pro then 
			for i=1,1 do
				local mul =table_134_normalMul[gamecommon.CommRandInt(table_134_normalMul,'pro')].mul 
				winMul = winMul * mul 
				table.insert(mulList,mul)
			end
		end --]]
	else
		for i=1,1 do
			local mul =table_134_normalMul[gamecommon.CommRandInt(table_134_normalMul,'pro')].mul 
			table.insert(mulList,mul)
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
	table.insert(allInfos, res)
	return allInfos, winMul, 1
end

function NormalSpecial()
	-- 获取W元素
	local wilds = {}
	wilds[W] = 1
	local nowild = {}
	-- 初始棋盘
	local allInfos = {}
	local boards = {}
	local winMul = 0
	-- 普通模式
	-- 生成异形棋盘
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_134_normalspin)
	-- 计算中奖倍数
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_134_payline,table_134_paytable,wilds,nowild)
	local reswinlines = {}
	winMul = 0
	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(reswinlines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
	-- 检查是否进入触发特殊倍率
	local mulList = {}
	for i=1,1 do
		local mul =table_134_normalMul[gamecommon.CommRandInt(table_134_normalMul,'pro')].mul 
		winMul = winMul * mul 
		table.insert(mulList,mul)
	end

	-- 生成返回数据
	local res = {
		boards = boards,
		reswinlines = reswinlines,
		mulList = mulList,
		sumMul = winMul,
		isfake =  (math.random(10000) > spuriousPro   and 0 or 1 )  
	}
	table.insert(allInfos, res)
	return allInfos, winMul, 3
end