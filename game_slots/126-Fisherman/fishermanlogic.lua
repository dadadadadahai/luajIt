module('Fisherman', package.seeall)
DB_Name = "game126fisherman"
local DataFormat = { 3, 3, 3, 3, 3 }
GameId = 126
S = 70
W = 90
U = 6
--增加S
MFM = 5 --更多渔夫More fishermen
MBF = 4 --更多大鱼More big Fisherman
TWOFR = 3 --2次免费次数
SEC= 2 --second level
MPROPS = 1 -- 更多道具 More explosives, fishing hooks, and rocket launchers
FAKETYPES= {
1, --在普通模式中，只要出现2个SCATTER图标，就有机会通过随机功能将另一个符号带到屏幕上。
2, --屏幕上的SCATTER可以向下移动一个位置而不从转盘内消失，则会出发一次重新旋转，带有scatter的转轴会向下移动一个位置，没有scatter的转轴将会重新旋转
3, --如果屏幕上出现了渔夫但是没有出现大鱼符，那么免费旋转结束时，大鱼现金符号可以通过炸药出现再随机位置
4, --如果屏幕上出现了大鱼但是没有渔夫符号，那么在免费旋转结束时，出现的额鱼钩会钓起一个随机转轴，从而把渔夫符号带到转盘内。。
5, --如果屏幕上出现了渔夫符号而没有大鱼时，在免费旋转结束时会随机出现火箭筒动画，从而将屏幕上除渔夫符号外的所有符号变成其他符号
}
Table_Base = import "table/game/126/table_126_hanglie"  
FAKEPRO = import "table/game/126/table_126_fakepro" 
FREETYPES = import "table/game/126/table_126_freetypes" 
LineNum = Table_Base[1].linenum
--执行雷神2图库
    local wilds = {}
    wilds[W] = 1
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


function NormaltoFree()

  
    -- 初始棋盘
    local boards = gamecommon.CreateSpecialChessData(DataFormat, table_126_normalspin)
	local disInfo = {} 
	local isfake = nil 
	if math.random(10000) < FAKEPRO[1].pro   then 
		isfake = 1
		addSfake(boards,2,isfake)
		addfakeres1(boards,disInfo)
	elseif  math.random(10000) < FAKEPRO[2].pro   then 
		isfake = 2
		addSfake(boards,2,isfake)
		addfakeres2(boards,disInfo,false)
	else 
		addS(boards)
	end 
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_126_payline,table_126_paytable,wilds,{})
    local winLines = {}
    local  winMul = 0
    -- 计算中奖线金额
    for k, v in ipairs(winlines) do
        table.insert(winLines, {v.line, v.num, v.mul,v.ele})
        winMul = sys.addToFloat(winMul,v.mul)
    end
     -- 生成返回数据
	local freetypes = {}
	for i=1,5 do
		if  math.random(10000)< FREETYPES[i].pro   then  
			table.insert(freetypes,i)
		end 
	end

    local res = {
		isfake = isfake,
		disInfo = disInfo,
        boards = boards,
        winLines = isfake and disInfo[#disInfo].winLines or winLines,
        sumMul = isfake and disInfo[#disInfo].sumMul or  winMul,
		FreeInfo  = {
				freetypes = freetypes,
				FreeNum = isfake and calc_free_nums(calc_S(disInfo[#disInfo].boards)) or  calc_free_nums(calc_S(boards)),
				Level = 1,
				Wnums = 0,
				MFM = table.find(freetypes,function (v,k)
					return v == MFM
				end),
				MBF = table.find(freetypes,function (v,k)
					return v == MBF
				end),
				TWOFR = table.find(freetypes,function (v,k)
					return v == TWOFR
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

		-- 初始棋盘
		local boards = gamecommon.CreateSpecialChessData(DataFormat, table_126_freespin)
		local disInfo = {} 
		local isfake =  addfakeres345(boards,disInfo)
		local winlines = gamecommon.WiningLineFinalCalc(boards,table_126_payline,table_126_paytable,wilds,{})
		local reswinLines = {}
		local winMul = 0
		-- 计算中奖线金额
		for k, v in ipairs(winlines) do
			table.insert(reswinLines, {v.line, v.num, v.mul,v.ele})
			winMul = sys.addToFloat(winMul,v.mul)
		end
		local curboards = isfake  and disInfo[#disInfo].boards or boards
		 -- 生成返回数据
		local res = {
			isfake = isfake,
			disInfo = disInfo,
			boards = boards,
			winLines = isfake and disInfo[#disInfo].winLines or  reswinLines,
			sumMul = isfake and disInfo[#disInfo].sumMul or  winMul,
			iconsAttachData = {},
		}
		res.umul  = GetIconInfoU(curboards,res.iconsAttachData,true)
		res.wNum  = calc_W(curboards)
		res.wumul = res.umul*res.wNum*GetLevelmul(FreeInfo.Level)
		table.insert(allresInfos,res)
		FreeInfo.Wnums = FreeInfo.Wnums  +  res.wNum
		normalMul = normalMul +res.sumMul  + res.wumul*10
		cFreeNum = cFreeNum + 1
        if cFreeNum >= tFreeNum  then
			local curFreeInfoWnums = FreeInfo.Wnums >12 and 12 or FreeInfo.Wnums
			local curlevel = math.floor(curFreeInfoWnums/4) +1
			if curlevel > FreeInfo.Level then 
				local curTWOFR = FreeInfo.TWOFR  and 2 or 0
				tFreeNum = tFreeNum + (10+curTWOFR )* (curlevel -FreeInfo.Level )
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

function Normal()
    local imageType = 1

    -- 初始棋盘
    local boards = gamecommon.CreateSpecialChessData(DataFormat, table_126_normalspin)
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_126_payline,table_126_paytable,wilds,{})
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




function addS(boards)
	local snums = calc_S(boards)
	local needALLsNum =  table_126_buyfree[gamecommon.CommRandInt(table_126_buyfree, 'pro')].sNum
	local emptyPoses = {}
	local chessdata = boards
	local emptyPos = {}
	for col = 1, #chessdata do
		emptyPos[col] = {}
		for row = 1, #chessdata[col] do
			local val = chessdata[col][row]
			if val ~= S and val ~= W then
				table.insert(emptyPos[col], { col, row })
			end
		end
	end
	local mass = needALLsNum - snums
	mass = mass <0 and 0 or mass
	for i = 1, mass do
		local emptyIndex = math.random(#emptyPos)
		local emptycol = table.remove(emptyPos, emptyIndex)
		local pos = table.remove(emptycol, math.random(#emptycol))
		local col, row = pos[1], pos[2]
		--生成一个倍数图标
		boards[col][row] = S
	end 
end 
--增加S
function addSfake(boards,nums,faketype)
	local snums = calc_S(boards)
	local needALLsNum =  nums
	local emptyPoses = {}
	local chessdata = boards
	local emptyPos = {}
	for col = 1, #chessdata do
		local curemptyPos = {}
		for row = 1, #chessdata[col] do
			local val = chessdata[col][row]
			if val ~= S and val ~= W and curemptyPos and ( faketype == 1 or (faketype == 2 and row >1 ) )  then
				table.insert(curemptyPos, { col, row })
			end
			if val == S then 
				curemptyPos = nil 
			end 
		end
		if not table.empty(curemptyPos) then 
			table.insert(emptyPos,curemptyPos)
		end 
	end
	local mass = needALLsNum - snums
	mass = mass <0 and 0 or mass
	for i = 1, mass do
		local emptyIndex = math.random(#emptyPos)
		local emptycol = table.remove(emptyPos, emptyIndex)
		local pos = table.remove(emptycol, math.random(#emptycol))
		local col, row = pos[1], pos[2]
		--生成一个倍数图标
		boards[col][row] = S
	end 
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
-- 生成U图标数据
function GetIconInfoU(boards,iconsAttachData,isfree)
    -- 初始化U图标个数
	local pro = isfree and 'pro2' or 'pro1'
	
    iconsAttachData.uNum = 0
    iconsAttachData.boardsInfo = {}
    local umul = 0
    -- 遍历棋盘生成对应位置U图标的信息
    for col = 1, #DataFormat do
        for row = 1, DataFormat[col] do
            if boards[col][row] == U then
				local xxx = {col = col, row = row, mul = table_126_bmul[gamecommon.CommRandInt(table_126_bmul, pro)].mul}
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

function calc_dayu(boards)
	local sNum = 0
	for col = 1,5 do
		for row = 1,3 do
			local val = boards[col][row]
			if val == U then
				sNum = sNum + 1
			end
		end
	end
	return  sNum 
      
end 
--渔夫
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

 --在普通模式中，只要出现2个SCATTER图标，就有机会通过随机功能将另一个符号带到屏幕上。
function addfakeres1(boards,disInfo)
	local disboards = table.clone(boards)
	addSfake(disboards,3,1)
	local diswl = gamecommon.WiningLineFinalCalc(disboards,table_126_payline,table_126_paytable,wilds,{})
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
	FAKEPRO[1].pro = 0
end 

function dischessdata(chessdata)
   local emptyPos = {}
	local minrow = 3
	for col = 1, #chessdata do
		local hasS = false 
		for row = 1, #chessdata[col] do
			local val = chessdata[col][row]
			if val == S then 
				if row < minrow then
					minrow = row
				end 
				table.insert(emptyPos,{col=col,Spos ={ col, row } })
				chessdata[col][1] = 0 
				hasS = true
				break
			end 
		end
		if not hasS then 
			for row = 1, #chessdata[col] do
				chessdata[col][row] = 0 
			end 
		end 
	end
	return emptyPos,minrow
end

function dropFillZero(data)
    local dlen = #data
    for i = 1, dlen do
        if data[i] == 0 then
            local endTo = 0
            local startTo = i
            for q = i + 1, dlen do
                if data[q] ~= 0 then
                    endTo = q
                    break
                end
            end
            if endTo > 0 then
                for q = startTo, dlen do
                    data[q]     = data[endTo]
                    data[endTo] = 0
                    endTo       = endTo + 1
                    if endTo > dlen then
                        break
                    end
                end
            else
                break
            end
        end
    end
end
function reChessHandle(chessdata)
	local disboards = gamecommon.CreateSpecialChessData(DataFormat, table_126_normalspin)
    for col = 1, #chessdata do
		for row = 1, #chessdata[col] do
			local val = chessdata[col][row]
			if val == 0 then 
			chessdata[col][row] = disboards[col][row]
			end 
		end 
    end
end
--屏幕上的SCATTER可以向下移动一个位置而不从转盘内消失，则会出发一次重新旋转，带有scatter的转轴会向下移动一个位置，没有scatter的转轴将会重新旋转
function addfakeres2(cboards,disInfo,isfake)
	local boards = table.clone(cboards)
	while true do
		local chessdata = table.clone(boards)
		--消除处理
		local emptyPos ,minrow = dischessdata(chessdata)
		  --zero下落处理
        for i,v in ipairs(emptyPos) do
            dropFillZero(chessdata[v.col])
        end
        --棋盘重新填充处理
        reChessHandle(chessdata)
		minrow = minrow - 1
		if minrow > 1 then 
			if math.random(10000) < 5000 then
				if not isfake then 
					addSfake(chessdata,3,1)
				end 
			end 
		else 
			if not isfake then 
				addSfake(chessdata,3,1)
			end 
		end 
		
		local diswl = gamecommon.WiningLineFinalCalc(chessdata,table_126_payline,table_126_paytable,wilds,{})
		local winLines = {}
		local  winMul = 0
		-- 计算中奖线金额
		for k, v in ipairs(diswl) do
			table.insert(winLines, {v.line, v.num, v.mul,v.ele})
			winMul = sys.addToFloat(winMul,v.mul)
		end
		local res = {
			boards = chessdata,
			winLines = winLines,
			sumMul = winMul,
		}
		table.insert(disInfo,res)
		boards = chessdata
		if minrow == 1 then
			break
		end 
	end 
		FAKEPRO[2].pro = 0
end 


function  addfakeres345(boards,disInfo)
	local isfake = nil 
	local wnum = calc_W(boards) --渔夫
	local unum = calc_dayu(boards)--大雨
	if  wnum >0 and unum >0 then 
		return isfake
	end
	if wnum >0 and unum == 0  then 
		if math.random(10000) < FAKEPRO[3].pro  then 
	    	addfakeres3(boards,disInfo)
			FAKEPRO[3].pro = 0
			return 3
		end 
		if math.random(10000) < FAKEPRO[5].pro  then 
			addfakeres5(boards,disInfo)
			FAKEPRO[5].pro = 0
			return 5
		end 
	end 
	if wnum ==0 and unum >0  then 
		if math.random(10000) < FAKEPRO[4].pro  then 
	    	addfakeres4(boards,disInfo)
			FAKEPRO[4].pro = 0
			return 4
		end 
	end 
	
	return isfake
end 
--如果屏幕上出现了渔夫但是没有出现大鱼符，那么免费旋转结束时，大鱼现金符号可以通过炸药出现再随机位置
function  addfakeres3(boards,disInfo)
	local disboards = table.clone(boards)
	local needALLsNum = table_126_bpro[gamecommon.CommRandInt(table_126_bpro, 'pro')].num
	local emptyPoses = {}
	local emptyPos = {}
	for col = 1, #disboards do
		emptyPos[col] = {}
		for row = 1, #disboards[col] do
			local val = disboards[col][row]
			if  val ~= W then
				table.insert(emptyPos[col], { col, row })
			end
		end
	end
	local mass = needALLsNum 
	mass = mass <0 and 0 or mass
	for i = 1, mass do
		local emptyIndex = math.random(#emptyPos)
		local emptycol = table.remove(emptyPos, emptyIndex)
		local pos = table.remove(emptycol, math.random(#emptycol))
		local col, row = pos[1], pos[2]
		--生成一个倍数图标
		disboards[col][row] = U
	end 
	
	local diswl = gamecommon.WiningLineFinalCalc(disboards,table_126_payline,table_126_paytable,wilds,{})
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
		
	
end 
--如果屏幕上出现了大鱼但是没有渔夫符号，那么在免费旋转结束时，出现的额鱼钩会钓起一个随机转轴，从而把渔夫符号带到转盘内。。
function  addfakeres4(boards,disInfo)
	local disboards = table.clone(boards)
	local emptyPoses = {}
	local emptyPos = {}
	for col = 1, #disboards do
		emptyPos[col] = {}
		for row = 1, #disboards[col] do
			local val = disboards[col][row]
			if  val ~= U then
				table.insert(emptyPos[col], { col, row })
			end
		end
	end

	local emptyIndex = math.random(#emptyPos)
	local emptycol = table.remove(emptyPos, emptyIndex)
	local pos = table.remove(emptycol, math.random(#emptycol))
	local col, row = pos[1], pos[2]
	--生成一个倍数图标
	disboards[col][row] = W

	
	local diswl = gamecommon.WiningLineFinalCalc(disboards,table_126_payline,table_126_paytable,wilds,{})
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
	
end 
 --如果屏幕上出现了渔夫符号而没有大鱼时，在免费旋转结束时会随机出现火箭筒动画，从而将屏幕上除渔夫符号外的所有符号变成其他符号
function  addfakeres5(boards,disInfo)
	local chessdata = table.clone(boards)
	for col = 1, #chessdata do
		for row = 1, #chessdata[col] do
			local val = chessdata[col][row]
			if val ~= W then 
				chessdata[col][row] = 0 
			end 
		end
		
	end

	--棋盘重新填充处理
	reChessHandle(chessdata)

	local diswl = gamecommon.WiningLineFinalCalc(chessdata,table_126_payline,table_126_paytable,wilds,{})
	local winLines = {}
	local  winMul = 0
	-- 计算中奖线金额
	for k, v in ipairs(diswl) do
		table.insert(winLines, {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
	local res = {
		boards = chessdata,
		winLines = winLines,
		sumMul = winMul,
	}
	table.insert(disInfo,res)
end 
