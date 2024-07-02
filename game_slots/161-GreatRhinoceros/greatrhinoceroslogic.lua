module('GreatRhinoceros', package.seeall)

-- 大象通用配置
GameId = 161
S = 70
W = 90
U = 9
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

function initU(boards)
	local emptyPos = {1,2,3,4,5}
	local cols={}
	local colnums = table_161_bonusPro[gamecommon.CommRandInt(table_161_bonusPro, 'pro')].num
	for i = 1, colnums , 1 do
		local curcol =  table.remove(emptyPos, math.random(#emptyPos))
		table.insert(cols,curcol)
		for row = 1, #boards[curcol] do
			 boards[curcol][row] = U
		end
		
	end
	return cols 
end 
function calc_U(boards)
	local Nums = 0
	for col = 1,5 do
		for row = 1,3 do
			local val = boards[col][row]
			if val == U then
				Nums = Nums + 1
			end
		end
	end
	return  Nums 
      
end 
function addU(boards,nums)
	local emptyPos = {}
	for col = 1, 5 , 1 do
		for row = 1, #boards[col] do
			local val = boards[col][row]
			if val == 0 then
				table.insert(emptyPos, { col, row })
			end 
		end

	end
	for i = 1, nums , 1 do
		local pos =table.remove(emptyPos, math.random(#emptyPos))  
		local col, row = pos[1], pos[2]
		boards[col][row] =  U 
	end

	
end 
function NormaltoBonus()
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
	local cols = initU(boards)
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
	res.cols = cols 
    return res, winMul
end 
function initcolsboards(cols)
	local initboards = {}
	for i=1,5,1 do
		initboards[i]={}
		for j=1,3,1 do
			initboards[i][j]= 0 
		end 
	end 
	for _,v in ipairs(cols) do
		for j=1,3,1 do
			initboards[v][j]= U
		end 
	end
	return initboards
end



function lastBonus(boards)
   -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
   
    -- 生成返回数据
    local res = {}
    -- 获取中奖线
    res.winlines = {}
    local winMul = 0
    -- respin中奖金额
	for col = 1, 5 , 1 do
		for row = 1, #boards[col] do
			local val = boards[col][row]
			if val == 0 then
				boards[col][row] = math.random(8)
			end 
		end

	end
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
    return res, winMul	
end 

function firstBonus(boards)
    -- 生成返回数据
    local res = {}
    -- 棋盘数据
    res.boards = boards
    return res	
end 

function bonus()
    local tFreeNum = 3
    local cFreeNum = 0
	local allInfos = {}
	local allwinMul = 0 
	local UInfos = {}
	local ntfres,ntfwinmul = NormaltoBonus()
	allwinMul = allwinMul + ntfwinmul
	local cols = ntfres.cols
	local maxUnums = math.random(10,12)
	local initboards =initcolsboards(cols)
	local firstres = firstBonus(initboards)
	table.insert(allInfos, firstres)
	while true do	
		-- 初始棋盘
		
		-- 生成返回数据
		local res = {}
		-- respin中奖金额
		local boards  = table.clone(initboards)
		local numsU = calc_U(boards)
		if numsU < maxUnums then 
			local addUnum = table_161_UPro[gamecommon.CommRandInt(table_161_UPro, 'pro')].num
			local canaddUnum = maxUnums- numsU
			if addUnum > canaddUnum then addUnum = canaddUnum end  
			if addUnum > 0 then 
				tFreeNum = tFreeNum + 1
				addU(boards,addUnum)
			end 
		end 
		-- 棋盘数据

		initboards = table.clone(boards)
		cFreeNum = cFreeNum + 1
		res.boards = boards
		table.insert(allInfos, res)
		if cFreeNum >= tFreeNum then
            break
        end
	end 
	local lastres,lastwinmul = lastBonus(initboards)
	allwinMul = allwinMul + lastwinmul
	table.insert(allInfos, lastres)
	ntfres.allInfos = allInfos
    return ntfres, allwinMul,3
end
function addS(boards,nums)
	local emptyPos = {}
	for col = 2, 4 , 1 do
		local curemptyPos = {}
		for row = 1, #boards[col] do
			local val = boards[col][row]
			if val ~= S then
				table.insert(curemptyPos, { col, row })
			end 
		end
		if #curemptyPos >0 then
			table.insert(emptyPos, curemptyPos)
		end 
	end
	for i = 1, nums , 1 do
		local curempty =  table.remove(emptyPos, math.random(#emptyPos))
		local pos =table.remove(curempty, math.random(#curempty))  
		local col, row = pos[1], pos[2]
		boards[col][row] =  S 
	end

	
end 

function RecordU(boards,info)
	for col = 1, #boards , 1 do
		for row = 1, #boards[col] do
			local val = boards[col][row]
			local ID = col*10+row
			if val == U and table.empty(info[ID])  then
				info[ID] =  { col, row }
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
	addS(boards,3)
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_161_payline,table_161_paytable,wilds,nowild)
	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
    -- 棋盘数据
    res.boards = boards
	res.winMul = winMul
	res.SMul = calc_S_mul(boards)
	winMul  = winMul + res.SMul
    return res, winMul
end 

function specilboards(UInfos)
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
	local emptyPos = {}
	for col = 1, #boards , 1 do
		for row = 1, #boards[col] do
			local val = boards[col][row]
			if val ~= U then
				table.insert(emptyPos, { col, row })
			end 
		end
	end
	local sepUInfos = {}
	local nums = table.nums(UInfos)
	for i = 1, nums , 1 do
		local pos =  table.remove(emptyPos, math.random(#emptyPos))
		local col, row = pos[1], pos[2]
		boards[col][row] =  U 
		table.insert(sepUInfos,{col,row})
	end
	
	local winlines = gamecommon.WiningLineFinalCalc(boards,table_161_payline,table_161_paytable,wilds,nowild)
	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
    -- 棋盘数据
    res.boards = boards
	res.winMul = winMul
	res.UInfos = sepUInfos
    return res, winMul
end 

function Free()
	local tFreeNum = 10
    local cFreeNum = 0
	local allInfos = {}
	local allwinMul = 0 
	local UInfos = {}
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
		boards = gamecommon.CreateSpecialChessData(DataFormat,table_161_free)
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
		RecordU(boards,UInfos)
		if  not table.empty(UInfos) then
			res.UInfos = {}
			for _,v in pairs(UInfos) do
				table.insert(res.UInfos,v)
			end
		end 
		
		allwinMul = allwinMul + winMul 
		cFreeNum = cFreeNum + 1
		if cFreeNum >= tFreeNum and not table.empty(UInfos) then --最后一次
			local sepres,sepwinmul = specilboards(UInfos)
			res.sepres = sepres
			allwinMul = allwinMul + sepwinmul
        end
		table.insert(allInfos, res)
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
function check_is_to_free(boards)
	local sNum = calc_S(boards)
	return  sNum >= 3
end 

function calc_S_mul(boards)
	local sNum = calc_S(boards)
	return  sNum >=2 and 40  or 0
      
end 


