module('GreatRhinoceros', package.seeall)

-- 大象通用配置
GameId = 161
S = 70
W = 90
DataFormat = {3,3,3,3,3}    -- 棋盘规格
Table_Base = import "table/game/161/table_161_hanglie"                        -- 基础行列

LineNum = Table_Base[1].linenum

--执行雷神2图库
function StartToImagePool(imageType)
    if imageType == 1 then
        return Normal()
	elseif imageType ==2 then
	--跑免费图库
		return Free()
	elseif imageType ==3 then
	--跑免费图库
		return bonus()
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
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_161_normalspin)
	-- 计算中奖倍数
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_161_payline,table_161_paytable,wilds,nowild)
	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
    -- 棋盘数据
    res.boards = boards
	res.winMul = winMul
    return res, winMul, imageType
end

function bonus()
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
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_161_normalspin)
	addGOLDSEVEN(boards,true)
	-- 计算中奖倍数
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_161_payline,table_161_paytable,wilds,nowild)
	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
	if calc_GSeven(boards) >= 3 then 
		imageType = 3
		local curbonus = table_161_bonusPro[gamecommon.CommRandInt(table_161_bonusPro, 'pro')]
		res.bonus = {}
		res.bonus.mul = curbonus.mul  
		res.bonus.info = {}
		local curbonusinfo = {}
		for i = 1,4 do
			if i ~= curbonus.ID then
				table.insert(curbonusinfo,i)
				table.insert(curbonusinfo,i)
			end 
		end
		curbonusinfo =table.shuffle(curbonusinfo)
		local maxnums = math.random(0,6)
		for i=1,maxnums do
			table.insert(res.bonus.info,table.remove(curbonusinfo,1))
		end
		table.insert(res.bonus.info,curbonus.ID)
		table.insert(res.bonus.info,curbonus.ID)
		res.bonus.info =table.shuffle(res.bonus.info)
		table.insert(res.bonus.info,curbonus.ID)
		winMul = winMul + res.bonus.mul
	else
		print("@@@@@@@@@@@@@@@@@@@@")
	end 
    -- 棋盘数据
    res.boards = boards
    return res, winMul, imageType
end
function addS(boards,isfree)
	local emptyPos = {}
	for col = 1, #boards , 2 do
		emptyPos[col] = {}
		for row = 1, #boards[col] do
			local val = boards[col][row]
			if val ~= S then
				table.insert(emptyPos[col], { col, row })
			end 
		end
	end
	if not isfree and #emptyPos> 0 then 
		for i = 1, #boards , 2 do
			if #emptyPos > 0 then
				local curempty =  emptyPos[i]
				local emptyIndex = math.random(#curempty)
				local pos = curempty[emptyIndex]
				local col, row = pos[1], pos[2]
				boards[col][row] =  S 
			end
		end
        
	end 
	if  isfree then 
		 local mass = table_161_freeSPro[gamecommon.CommRandInt(table_161_freeSPro, 'pro')].num
		if mass >0 then 
			local curmass = 0 
			for i = 1, #boards , 2 do
				if #emptyPos > 0 then
					curmass = curmass + 1
					local curempty =  emptyPos[i]
					local emptyIndex = math.random(#curempty)
					local pos = curempty[emptyIndex]
					local col, row = pos[1], pos[2]
					boards[col][row] =  S 
				end
				if curmass == mass then 
					break
				end 
			end
		end 
	end 
end 

function addSfake(boards)
	local emptyPos = {}
	for col = 1, 3 , 2 do
		emptyPos[col] = {}
		for row = 1, #boards[col] do
			local val = boards[col][row]
			if val ~= S then
				table.insert(emptyPos[col], { col, row })
			end 
		end
	end
	if  #emptyPos> 0 then 
		for i = 1, 3 , 2 do
			if #emptyPos > 0 then
				local curempty =  emptyPos[i]
				local emptyIndex = math.random(#curempty)
				local pos = curempty[emptyIndex]
				local col, row = pos[1], pos[2]
				boards[col][row] =  S 
			end
		end
	end 
	
end 

function NormaltoFree()
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
    -- respin中奖金额
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_161_normalspin)
	-- 计算中奖倍数
	addS(boards)
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_161_payline,table_161_paytable,wilds,nowild)
	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
    -- 棋盘数据
    res.boards = boards
	res.winMul = winMul
    return res, winMul
end 

function Free()
	local tFreeNum = 8
    local cFreeNum = 0
	local allInfos = {}
	local allwinMul = 0 
	local ntfres,ntfwinmul = NormaltoFree()
	table.insert(allInfos, ntfres)
	while true do	
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
		boards = gamecommon.CreateSpecialChessData(DataFormat,table_161_normalspin)
		addS(boards,true)
		-- 计算中奖倍数
		local winlines = gamecommon.WiningLineFinalCalc(boards,table_161_payline,table_161_paytable,wilds,nowild)
		if math.random(10000)<table_161_freebonusPro[1].pro then --是否在免费游戏中触发bonus 
			addGOLDSEVEN(boards,true)
			winlines = gamecommon.WiningLineFinalCalc(boards,table_161_payline,table_161_paytable,wilds,nowild)
		else 
			addGOLDSEVEN(boards)
		end 
	
		-- 计算中奖线金额
		for k, v in ipairs(winlines) do
			table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
			winMul = sys.addToFloat(winMul,v.mul)
		end
		-- 棋盘数据
		res.boards = boards

		if calc_GSeven(boards) >= 3 then 
			local curbonus = table_161_bonusPro[gamecommon.CommRandInt(table_161_bonusPro, 'freepro')]
			res.bonus = {}
			res.bonus.mul = curbonus.mul  
			res.bonus.info = {}
			local curbonusinfo = {}
			for i = 1,4 do
				if i ~= curbonus.ID then
					table.insert(curbonusinfo,i)
					table.insert(curbonusinfo,i)
				end 
			end
			curbonusinfo =table.shuffle(curbonusinfo)
			local maxnums = math.random(0,6)
			for i=1,maxnums do
				table.insert(res.bonus.info,table.remove(curbonusinfo,1))
			end
			table.insert(res.bonus.info,curbonus.ID)
			table.insert(res.bonus.info,curbonus.ID)
			res.bonus.info =table.shuffle(res.bonus.info)
			table.insert(res.bonus.info,curbonus.ID)
			winMul = winMul + res.bonus.mul
		end 
		res.winMul = winMul
		allwinMul = allwinMul + winMul 
        table.insert(allInfos, res)
		if check_is_to_free(boards) then
			tFreeNum = tFreeNum + 8
		end 
		cFreeNum = cFreeNum + 1
		if cFreeNum >= tFreeNum then
            break
        end
	end 
	allwinMul = allwinMul + ntfwinmul
    return allInfos, allwinMul, 2
end

function calc_S(boards)
	local sNum = 0
	for col = 1,5 do
		for row = 1,3 do
			local val = boards[col][row]
			if val == S then
				sNum = sNum + 1
			end
		end
	end
	return  sNum 
      
end 

function calc_GSeven(boards)
	local sNum = 0
	for col = 1,5 do
		for row = 1,3 do
			local val = boards[col][row]
			if val == GOLDSEVEN then
				sNum = sNum + 1
			end
		end
	end
	return  sNum 
      
end 

function check_is_to_free(boards)
	local sNum = calc_S(boards)
	return  sNum >= 3
end 
