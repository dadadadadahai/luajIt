-- 金牛游戏模块
module('GoldCow', package.seeall)
-- 金牛所需数据库表名称
DB_Name = "game131goldcow"
-- 金牛通用配置
GameId = 131
S = 70
W = 90
B = 6
DataFormat = {3,4,3}    -- 棋盘规格
Table_Base = import "table/game/131/table_131_hanglie"                        -- 基础行列
Table_mulPro = import "table/game/131/table_131_mulPro"  
spuriousPro  =   Table_mulPro[1].spuriousPro or 100
MaxNormalIconId = 6
LineNum = Table_Base[1].linenum
local iconRealId = 1
local freeNum = 0
--执行金牛图库
function StartToImagePool(imageType)
	if imageType == 2 then 
		return  Free()
	elseif imageType == 3 then 
		return   FullIcon()
	end
    return Normal()
end
function Free()
	 -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    
    -- 生成返回数据
   
    local bonusFlag = false
    -- 十倍是否触发
    local fullIconFlag = false
	local allres = {}
    -- 生成异形棋盘
	-- 计算中奖线金额
	local winMul = 0
    local iconId = table_131_bonusIconPro[gamecommon.CommRandInt(table_131_bonusIconPro, 'pro')].iconId
		local res = {}
		-- 初始棋盘
        local boards = {}
        boards = gamecommon.CreateSpecialChessData(DataFormat,GoldCow['table_131_free'])
        -- 替换第一列和第三列
        local colNum = {1,3}
        for _, col in ipairs(colNum) do
            for row = 1, DataFormat[col] do
                boards[col][row] = iconId
            end
        end
        -- 计算中奖倍数
        local winlines = gamecommon.WiningLineFinalCalc(boards,table_131_payline,table_131_paytable,wilds,nowild)
		-- 触发位置
		res.tringerPoints = {}
		-- 获取中奖线
		res.winlines =  {}
		
	
		for k, v in ipairs(winlines) do
			table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
			winMul = sys.addToFloat(winMul,v.mul)
		end

		-- 十倍判断
		local firstIconId = 0
		local mulFlag = true
		for col = 1, #DataFormat do
			for row = 1, DataFormat[col] do
				if firstIconId == 0 and boards[col][row] ~= W then
					firstIconId = boards[col][row]
				end
				if boards[col][row] ~= W and boards[col][row] ~= firstIconId then
					mulFlag = false
					break
				end
			end
		end
		
		-- 增加获奖金额
		if mulFlag then
			fullIconFlag = true
			winMul = winMul * 10
		end

		-- 棋盘数据
		res.boards = boards
		res.isfake = 0
		res.extraData = {
			bonusFlag = true,  -- 福牛是否触发
			fullIconFlag = fullIconFlag,             -- 十倍是否触发
		}
		
    return res, winMul, 2
end 
function FullIcon()
	local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}
    -- 生成返回数据
    local res = {}
    local bonusFlag = false
    -- 十倍是否触发
    local fullIconFlag = true
   
    local miniNum = 0

	local iconId = table_131_mulIcon[gamecommon.CommRandInt(table_131_mulIcon, 'pro')].iconId
	for col = 1, #DataFormat do
		 boards[col]= {}
		for row = 1, DataFormat[col] do
			boards[col][row] = iconId
		end
	end
  

    -- 计算中奖倍数
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_131_payline,table_131_paytable,wilds,nowild)


    -- 触发位置
    res.tringerPoints = {}
    -- 获取中奖线
    res.winlines = {}
    -- 计算中奖线金额
    local winMul = 0
    for k, v in ipairs(winlines) do
        table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
        winMul = sys.addToFloat(winMul,v.mul)
    end

    -- 十倍判断
    local firstIconId = 0
    local mulFlag = true
    for col = 1, #DataFormat do
        for row = 1, DataFormat[col] do
            if firstIconId == 0 and boards[col][row] ~= W then
                firstIconId = boards[col][row]
            end
            if boards[col][row] ~= W and boards[col][row] ~= firstIconId then
                mulFlag = false
                break
            end
        end
    end
    
    -- 增加获奖金额
    if mulFlag then
        winMul = winMul * 10
		fullIconFlag = true
    end
    -- 棋盘数据
    res.boards = boards
	res.isfake = 0
    res.extraData = {
        bonusFlag = bonusFlag,  -- 福牛是否触发
        fullIconFlag = fullIconFlag,             -- 十倍是否触发
    }
    return res, winMul, 3
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
    local bonusFlag = false
    -- 十倍是否触发
    local fullIconFlag = false
   

    -- 生成异形棋盘
    boards = gamecommon.CreateSpecialChessData(DataFormat,table_131_normalspin)
    local miniNum = 0
    -- 计算中奖倍数
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_131_payline,table_131_paytable,wilds,nowild)

    -- 触发位置
    res.tringerPoints = {}
    -- 获取中奖线
    res.winlines = {}
    -- 计算中奖线金额
    local winMul = 0
    for k, v in ipairs(winlines) do
        table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
        winMul = sys.addToFloat(winMul,v.mul)
    end

    -- 十倍判断
    local firstIconId = 0
    local mulFlag = true
    for col = 1, #DataFormat do
        for row = 1, DataFormat[col] do
            if firstIconId == 0 and boards[col][row] ~= W then
                firstIconId = boards[col][row]
            end
            if boards[col][row] ~= W and boards[col][row] ~= firstIconId then
                mulFlag = false
                break
            end
        end
    end
    
    -- 增加获奖金额
    if mulFlag then
		fullIconFlag = true
        winMul = winMul * 10
    end
	res.isfake =  0
	if not fullIconFlag and winMul == 0 then 
		res.isfake = (math.random(10000) > spuriousPro   and 0 or  2 ) 
		if res.isfake == 1 then  --福牛
			-- 替换第一列和第三列
			local iconIds =  table.series(table_131_bonusIconPro,function (v)
				return v.iconId
			end) 	
			local iconId = table.remove(iconIds,math.random(#iconIds))
			local colNum = {1,3}
			for _, col in ipairs(colNum) do
				for row = 1, DataFormat[col] do
					boards[col][row] = iconId
				end
			end
			for row = 1, DataFormat[2] do
				if boards[2][row] == iconId or boards[2][row] == W then 
					boards[2][row] = iconIds[math.random(#iconIds)]
				end 
			end
		elseif res.isfake == 2 then --十倍
			local iconIds =  table.series(table_131_bonusIconPro,function (v)
				return v.iconId
			end) 	
			local iconId = table.remove(iconIds,math.random(#iconIds))
			local colNum = {1,2}
			for _, col in ipairs(colNum) do
				for row = 1, DataFormat[col] do
					boards[col][row] = iconId
				end
			end
			for row = 1, DataFormat[3] do
				if boards[3][row] == iconId or boards[3][row] == W then 
					boards[3][row] = iconIds[math.random(#iconIds)]
				end 
			end
		end 
	end 
    -- 棋盘数据
    res.boards = boards
    res.extraData = {
        bonusFlag = bonusFlag,  -- 福牛是否触发
        fullIconFlag = fullIconFlag,             -- 十倍是否触发
		
    }
	
    return res, winMul, 1
end