module('Fisherman', package.seeall)
local iconRealId = 1
DB_Name = "game126fisherman"
local DataFormat = { 3, 3, 3, 3, 3 }
GameId = 126
S = 70
W = 90
U = 6
MFM = 5 --更多渔夫More fishermen
MBF = 4 --更多大鱼More big Fisherman
TWOFR = 3 --2次免费次数
SEC= 2 --second level
MPROPS = 1 -- 更多道具 More explosives, fishing hooks, and rocket launchers
Table_Base = import "table/game/126/table_126_hanglie"  
LineNum = Table_Base[1].linenum
--执行雷神2图库
function StartToImagePool(imageType)
    if imageType == 1 then
        return Normal()
    elseif imageType == 2 then
        return BuyFree()
	elseif imageType ==3 then
	--跑免费图库
		return Free()
    end
end
--增加S
function addS(boards)
	local snums = calc_S(boards)
	local needALLsNum =  table_126_buyfree[gamecommon.CommRandInt(table_126_buyfree, 'pro')].sNum
	local emptyPoses = {}
	local chessdata = boards
	local emptyPos = {}
	for col = 1, #chessdata do
		for row = 1, #chessdata[col] do
			local val = chessdata[col][row]
			if val ~= S and val ~= W then
				table.insert(emptyPos, { col, row })
			end
		end
	end
	local mass = needALLsNum - snums
	mass = mass <0 and 0 or mass
	for i = 1, mass do
		local emptyIndex = math.random(#emptyPos)
		local pos = table.remove(emptyPos, emptyIndex)
		local col, row = pos[1], pos[2]
		--生成一个倍数图标
		boards[col][row] = S
	end 
end 
--增加S
function addSfake(boards,nums)
	local snums = calc_S(boards)
	local needALLsNum =  nums
	local emptyPoses = {}
	local chessdata = boards
	local emptyPos = {}
	for col = 1, #chessdata do
		for row = 1, #chessdata[col] do
			local val = chessdata[col][row]
			if val ~= S and val ~= W then
				table.insert(emptyPos, { col, row })
			end
		end
	end
	local mass = needALLsNum - snums
	mass = mass <0 and 0 or mass
	for i = 1, mass do
		local emptyIndex = math.random(#emptyPos)
		local pos = table.remove(emptyPos, emptyIndex)
		local col, row = pos[1], pos[2]
		--生成一个倍数图标
		boards[col][row] = S
	end 
end 

function NormaltoFree()
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = gamecommon.CreateSpecialChessData(DataFormat, table_126_normalspin)
	local disInfo = {} 
	local isfake = nil 
	if math.random(10000) <5000 and false  then 
		addSfake(boards,2)
		local disboards = table.clone(boards)
		addSfake(disboards,3)
		local diswl = gamecommon.WiningLineFinalCalc(disboards,table_126_payline,table_126_paytable,wilds,nowild)
		local winLines = {}
		local  winMul = 0
		-- 计算中奖线金额
		for k, v in ipairs(diswl) do
			table.insert(winLines, {v.line, v.num, v.mul,v.ele})
			winMul = sys.addToFloat(winMul,v.mul)
		end
		local res = {
        boards = disboards,
        winLines = winLines,
        sumMul = winMul,
		}
		table.insert(disInfo,res)
		isfake = 1
	else 
		addS(boards)
	end 
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_126_payline,table_126_paytable,wilds,nowild)
    local winLines = {}
    local  winMul = 0
    -- 计算中奖线金额
    for k, v in ipairs(winlines) do
        table.insert(winLines, {v.line, v.num, v.mul,v.ele})
        winMul = sys.addToFloat(winMul,v.mul)
    end
     -- 生成返回数据
	local freetypenums = math.random(6)-1  --随机出1到5个特殊玩法
	local freetypes = {}
	local alltypes = {1,2,3,4,5}
	for i=1,freetypenums do
		local curtype = table.remove(alltypes,math.random(#alltypes))
		table.insert(freetypes,curtype)
	end

    local res = {
		isfake = isfake,
		disInfo = disInfo,
        boards = boards,
        winLines = isfake and disInfo[1].winLines or winLines,
        sumMul = isfake and disInfo[1].winMul or  winMul,
		FreeInfo  = {
				freetypes = freetypes,
				FreeNum = isfake and calc_free_nums(disInfo[1].boards) or  calc_free_nums(calc_S(boards)),
				Level = 1,
				Wnums = 0,
				MFM = table.find(freetypes,function (v,k)
					return v == MFM
				end),
				MBF = table.find(freetypes,function (v,k)
					return v == MBF
				end),
				MPROPS = table.find(freetypes,function (v,k)
					return v == MPROPS
				end),
		}
    }
	if table.find(freetypes,function (v,k)
		return v == TWOFR
	end) then 
		res.FreeInfo.FreeNum = res.FreeInfo.FreeNum + 2
	end  
	if table.find(freetypes,function (v,k)
		return v == SEC
	end) then 
		res.FreeInfo.Level = 2
		res.FreeInfo.Wnums = 4
	end  
    return res, winMul
end 
function GetLevelmul(Level)
	if Level == 4 then 
		return 10
	elseif Level ==3 then 
		return 3
	elseif Level == 2 then 
		return 2
	else 
		return 1
	end 
end 
function BuyFree()
    --默认15次
    local tFreeNum =10
    local cFreeNum = 0
    --全部u图标累计

    --普通倍数 
    local normalMul = 0
    local allresInfos = {}
	local NormaltoFreeres,NormaltoFreeMul = NormaltoFree()
	local FreeInfo = table.clone(NormaltoFreeres.FreeInfo)
	table.insert(allresInfos, NormaltoFreeres)
	tFreeNum = FreeInfo.FreeNum
    while true do
		local wilds = {}
		wilds[W] = 1
		local nowild = {}
		-- 初始棋盘
		local boards = gamecommon.CreateSpecialChessData(DataFormat, table_126_freespin)
		local winlines = gamecommon.WiningLineFinalCalc(boards,table_126_payline,table_126_paytable,wilds,nowild)
		local reswinLines = {}
		local winMul = 0
		-- 计算中奖线金额
		for k, v in ipairs(winlines) do
			table.insert(reswinLines, {v.line, v.num, v.mul,v.ele})
			winMul = sys.addToFloat(winMul,v.mul)
		end
		 -- 生成返回数据
		local res = {
			boards = boards,
			winLines = reswinLines,
			sumMul = winMul,
			iconsAttachData = {},
		}
		res.umul  = GetIconInfoU(boards,res.iconsAttachData)
		res.wNum  = calc_W(boards)
		res.wumul = res.umul*res.wNum*GetLevelmul(FreeInfo.Level)
		table.insert(allresInfos,res)
		FreeInfo.Wnums = FreeInfo.Wnums  +  res.wNum
		normalMul = normalMul +winMul  + res.wumul*10
		cFreeNum = cFreeNum + 1
        if cFreeNum >= tFreeNum  then
			local curFreeInfoWnums = FreeInfo.Wnums >12 and 12 or FreeInfo.Wnums
			local curlevel = math.floor(curFreeInfoWnums/4) +1
			if curlevel > FreeInfo.Level then 
				tFreeNum = tFreeNum + 10 * (curlevel -FreeInfo.Level )
				FreeInfo.Level = curlevel
			else 
				break
			end 
        end
    end
    --进行最终倍数计算
    local mul = normalMul +NormaltoFreeMul
    return allresInfos, mul, 2
end

function Free()
    --默认15次
    local tFreeNum = 10
    local cFreeNum = 0
    --全部u图标累计
    local allUMul = 0
    --普通倍数 就是这个json不对 是不是
    local normalMul = 0
    local cols = { 3, 3, 3, 3, 3 }
    local allresInfos = {}
	local NormaltoFreechessdata,NormaltoFreechessdataFinMul = NormaltoFree()
	table.insert(allresInfos, NormaltoFreechessdata)
    while true do
        local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols, table_126_free_1)
        iconRealId = 1
        fillCellToId(chessdata)
        --总消除数据，after触发免费后的数据
        --一次棋盘消除数据
        local disInfos = {  }
        local disId = {}
        local disInfo, tchessdata = chessdataHandle(chessdata, lastColRow, disId, true)
        table.insert(disInfos, disInfo)
        while table.empty(disInfo.dis) == false do
            disInfo, tchessdata = chessdataHandle(tchessdata, lastColRow, disId, true)
            table.insert(disInfos, disInfo)
        end
        --进行倍数图标处理,统计s个数,倍数图标返回倍数
        local sNum, uMul = mulIconFunctionAndReChess(disInfos, disId, true)
        --对棋盘数据进行最终整理,计算棋盘mul
        local FinMul = arrangeToSave(disInfos)
		local sMul =  calcSMul(sNum)
		FinMul = FinMul + sMul
		uMul = uMul == 0  and 1 or uMul
		 
		if normalMul + FinMul * uMul > 300 and FinMul >0 then 

		else
			normalMul = normalMul + FinMul * uMul
			cFreeNum = cFreeNum + 1
			table.insert(allresInfos, disInfos)
			if sNum >= 3 then
				tFreeNum = tFreeNum + 5
			end    
		end 
           
        if cFreeNum >= tFreeNum  then
            break
        end
    end
    --进行最终倍数计算
    local mul = normalMul +NormaltoFreechessdataFinMul
    return allresInfos, mul, 3
end
-- 生成U图标数据
function GetIconInfoU(boards,iconsAttachData)
    -- 初始化U图标个数
    iconsAttachData.uNum = 0
    iconsAttachData.boardsInfo = {}
    local umul = 0
    -- 遍历棋盘生成对应位置U图标的信息
    for col = 1, #DataFormat do
        for row = 1, DataFormat[col] do
            if boards[col][row] == U then
				local xxx = {col = col, row = row, mul = table_126_bmul[gamecommon.CommRandInt(table_126_bmul, 'pro6')].mul}
                table.insert(iconsAttachData.boardsInfo,xxx)
                iconsAttachData.uNum = iconsAttachData.uNum + 1
				umul = umul + xxx.mul
            end
        end
    end
	return umul 
end

-- 判断U图标是否中奖
function GetWinScoreU(iconsAttachData)
    -- U图标中奖金额
    local winMulU = 0
    for _, value in ipairs(iconsAttachData.boardsInfo) do
        winMulU = winMulU + value.mul
    end
    return winMulU
end
function Normal()
    local imageType = 1
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = gamecommon.CreateSpecialChessData(DataFormat, table_126_normalspin)
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_126_payline,table_126_paytable,wilds,nowild)
    local reswinLines = {}
    winMul = 0
    -- 计算中奖线金额
    for k, v in ipairs(winlines) do
        table.insert(reswinLines, {v.line, v.num, v.mul,v.ele})
        winMul = sys.addToFloat(winMul,v.mul)
    end
     -- 生成返回数据
    local res = {
        boards = boards,
        winLines = reswinLines,
        sumMul = winMul,
		iconsAttachData = {},
    }
	GetIconInfoU(boards,res.iconsAttachData)
	if  check_is_to_free(boards) then --如果普通随机到图库就直接不进去
		imageType = 3
	end 
	
    return res, winMul, imageType
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

function calc_W(boards)
	local sNum = 0
	for col = 1,5 do
		for row = 1,3 do
			local val = boards[col][row]
			if val == W then
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

function calc_free_nums(sNum)
    if sNum==3 then
        return 10
    elseif sNum==4 then
        return 15
    elseif sNum==5 then
        return 20
    end
    return 0
end

--打印棋盘
function printchessdata(chessdata)
    print('==========================================')
    for row = 1, 5 do
        local rowstr = ''
        for col = 1, 5 do
            if type(chessdata[col][row]) == 'table' then
                rowstr = rowstr .. chessdata[col][row].val .. ','
            else
                rowstr = rowstr .. chessdata[col][row] .. ','
            end
        end
        print(rowstr)
    end
end

