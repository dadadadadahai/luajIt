module('Fisherman', package.seeall)
DB_Name = "game126fisherman"
local DataFormat = { 3, 3, 3, 3, 3 }
GameId = 126
S = 70
W = 90
U = 6

Table_Base = import "table/game/126/table_126_hanglie"  
FAKEPRO = import "table/game/126/table_126_fakepro" 
FREETYPES = import "table/game/126/table_126_freetypes" 
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


function NormaltoFree()
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
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
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_126_payline,table_126_paytable,wilds,nowild)
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
				FreeNum = isfake and calc_free_nums(disInfo[#disInfo].boards) or  calc_free_nums(calc_S(boards)),
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
		local nowild = {}
		-- 初始棋盘
		local boards = gamecommon.CreateSpecialChessData(DataFormat, table_126_freespin)
		local disInfo = {} 
		local isfake =  addfakeres345(boards,disInfo)
		local winlines = gamecommon.WiningLineFinalCalc(boards,table_126_payline,table_126_paytable,wilds,nowild)
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
		normalMul = normalMul +res..sumMul  + res.wumul*10
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

