module('fruitparty2', package.seeall)
local iconRealId = 1
local cols = { 7, 7, 7, 7, 7, 7, 7 }
-- 定义棋盘大小
local ROWS = 7
local COLS = 7

function StartToImagePool(imageType)
     if imageType == 1 then
        return Normal()
    elseif imageType == 2 then
        --跑免费图库
        return BuyFree()
	elseif imageType ==3 then
	--跑免费图库
		return Free()
    end
end
local GetDisinfoMul=function(disInfo)
	local mul = 0
	for _,value in ipairs(disInfo) do
		mul = mul + value.mul
	end
	return mul
end
function NormaltoFree()

    --table_162_normalspin_1
    local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols, table_162_normalspin_1)
    iconRealId = 1
    --棋盘进行id预处理
    fillCellToId(chessdata)
    --总消除数据，after触发免费后的数据
    local disInfos = {}
    local disId = {}
    local disInfo, tchessdata = chessdataHandle(chessdata, lastColRow, disId)
    table.insert(disInfos, disInfo)
    local mul = GetDisinfoMul(disInfo)
    while table.empty(disInfo.dis) == false and mul<=300 do
        disInfo, tchessdata = chessdataHandle(tchessdata, lastColRow, disId)
        mul = mul + GetDisinfoMul(disInfo)
        table.insert(disInfos, disInfo)
    end
    local mul = 0
    --进行倍数图标处理,统计s个数,倍数图标返回倍数
    local sNum  = mulIconFunctionAndReChess_N(disInfos, disId)
    --对棋盘数据进行最终整理,计算最终mul
    local FinMul = arrangeToSave(disInfos)
    local sMul =  calcSMul(sNum)
	FinMul = FinMul + sMul
    return disInfos, FinMul
end 
function calcSMul(sNum)
    if sNum==3 then
        return 6
    elseif sNum==4 then
        return 10
    elseif sNum==5 then
        return 20
	elseif sNum==6 then
		return 40
	elseif sNum==7 then
		return 200
    end
    return 0
end

function CalcFreeNum(sNum)
    if sNum==3 then
        return 10
    elseif sNum==4 then
        return 12
    elseif sNum==5 then
        return 15
	elseif sNum==6 then
		return 20
	elseif sNum==7 then
		return 25
    end
    return 0
end

function BuyFree()
    --默认15次
    local tFreeNum =10
    local cFreeNum = 0
    --全部u图标累计
    local allUMul = 0
    --普通倍数  
    local normalMul = 0
    local allDisInfos = {}
	local NormaltoFreechessdata,NormaltoFreechessdataFinMul = NormaltoFree()
	tFreeNum  = CalcFreeNum(get_sNum(NormaltoFreechessdata) )
	table.insert(allDisInfos, NormaltoFreechessdata)
    while true do
        local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols, table_162_free_1) --table_162_free_1
        iconRealId = 1
        fillCellToId(chessdata)
        --总消除数据，after触发免费后的数据
        --一次棋盘消除数据
        local disInfos = {  }
        local disId = {}
		--printchessdata(chessdata)
        local disInfo, tchessdata = chessdataHandle(chessdata, lastColRow, disId, true)
	--	printchessdata(tchessdata)
        table.insert(disInfos, disInfo)
        while table.empty(disInfo.dis) == false do
            disInfo, tchessdata = chessdataHandle(tchessdata, lastColRow, disId, true)
		--	printchessdata(tchessdata)
            table.insert(disInfos, disInfo)
        end
 
        --进行倍数图标处理,统计s个数,倍数图标返回倍数
        local sNum = mulIconFunctionAndReChess(disInfos, disId, true)
        --对棋盘数据进行最终整理,计算棋盘mul
        local FinMul = arrangeToSave(disInfos)
		local sMul =  calcSMul(sNum)
		if normalMul + FinMul + sMul > 300 and FinMul >0 then 



		else
			normalMul = normalMul + FinMul + sMul
			cFreeNum = cFreeNum + 1
			table.insert(allDisInfos, disInfos)
			if sNum >= 3 then
				tFreeNum = tFreeNum + 5
			end
		end
        if cFreeNum >= tFreeNum then
            break
        end
    end
    --进行最终倍数计算
    local mul = normalMul +NormaltoFreechessdataFinMul
    return allDisInfos, mul, 2
end

function Free()
    --默认10次
    local tFreeNum =10
    local cFreeNum = 0
    --全部u图标累计
    local allUMul = 0
    --普通倍数  
    local normalMul = 0
    local allDisInfos = {}
	local NormaltoFreechessdata,NormaltoFreechessdataFinMul = NormaltoFree()
	tFreeNum  = CalcFreeNum(get_sNum(NormaltoFreechessdata) )
	table.insert(allDisInfos, NormaltoFreechessdata)
    while true do
        local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols, table_162_free_1) --table_162_free_1
        iconRealId = 1
        fillCellToId(chessdata)
        --总消除数据，after触发免费后的数据
        --一次棋盘消除数据
        local disInfos = {  }
        local disId = {}
		--printchessdata(chessdata)
        local disInfo, tchessdata = chessdataHandle(chessdata, lastColRow, disId, true)
	--	printchessdata(tchessdata)
        table.insert(disInfos, disInfo)
        while table.empty(disInfo.dis) == false do
            disInfo, tchessdata = chessdataHandle(tchessdata, lastColRow, disId, true)
		--	printchessdata(tchessdata)
            table.insert(disInfos, disInfo)
        end
 
        --进行倍数图标处理,统计s个数,倍数图标返回倍数
        local sNum = mulIconFunctionAndReChess(disInfos, disId, true)
        --对棋盘数据进行最终整理,计算棋盘mul
        local FinMul = arrangeToSave(disInfos)
		local sMul =  calcSMul(sNum)
		if normalMul + FinMul > 300 and FinMul >0 then 



		else
			normalMul = normalMul + FinMul +sMul
			cFreeNum = cFreeNum + 1
			table.insert(allDisInfos, disInfos)
			if sNum >= 3 then
				tFreeNum = tFreeNum + 5
			end
		end
        if cFreeNum >= tFreeNum then
            break
        end
    end
    --进行最终倍数计算
    local mul = normalMul +NormaltoFreechessdataFinMul
    return allDisInfos, mul, 3
end

function Normal()
    --table_162_normalspin_1
    local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols, table_162_normalspin_1)
    iconRealId = 1
	--[[chessdata = {
	{1,1,1,2,2,2,1},
	{2,7,4,3,1,6,3},
	{3,3,1,6,6,1,2},
	{6,90,4,4,1,6,6},
	{2,3,5,2,3,4,1},
	{4,5,1,7,1,1,3},
	{2,3,4,1,2,5,4}}--]]
     --棋盘进行id预处理
    fillCellToId(chessdata)
    --总消除数据，after触发免费后的数据
    local disInfos = {  }
    local disId = {}
    local disInfo, tchessdata = chessdataHandle(chessdata, lastColRow, disId)
    table.insert(disInfos, disInfo)
    local mul = GetDisinfoMul(disInfo)
    while table.empty(disInfo.dis) == false and mul<=300 do
        disInfo, tchessdata = chessdataHandle(tchessdata, lastColRow, disId)
        mul = mul + GetDisinfoMul(disInfo)
        table.insert(disInfos, disInfo)
    end
    local imageType = 1
    --对棋盘数据进行最终整理,计算最终mul
    local FinMul = arrangeToSave(disInfos)
	if  get_sNum(disInfos) >=3 then --如果普通随机到图库就直接不进去
		imageType = 3
	end
    return disInfos, FinMul, imageType
end

function   get_sNum(disInfos)
	local chessdata = disInfos[#disInfos].chessdata --找到最后一幅图
	local sNum = 0
	for col = 1, #chessdata do
		for row = 1, #chessdata[col] do
			local Id = chessdata[col][row].Id
			local val = chessdata[col][row].val
			if val == 70 then
				sNum = sNum + 1
			end
		end
	end
	return  sNum 
      
end 
--对数据进行整理保存
function arrangeToSave(disInfos)
    local FinMul = 0
    for _, disInfo in ipairs(disInfos) do
        for _, dis in ipairs(disInfo.dis) do
            FinMul = FinMul + dis.mul
        end
    end
    return FinMul
end
function mulIconFunctionAndReChess_N(disInfos, disId)
    --随机获取需要产生的倍数图标的个数
    local field = 'gailvfree'
	local nummul = 'num'
	local tmpPoolConfig = {}
    for _, value in ipairs(table_mul_gamety1) do
		if value[nummul] >= table_162_freenum[1].normalIconNum and value[nummul]>=0 then
		table.insert(tmpPoolConfig,{
			num = value[nummul],
			gailv = value[field]
		})
        end
    end
	
    local mulNum = tmpPoolConfig[gamecommon.CommRandInt(tmpPoolConfig, 'gailv')].num
    local changeToMul = {} --Id To iconsAttachData
    local sNum = 0
    --按照消除棋盘位置留空
    if mulNum > 0 then
        local emptyPoses = {}
        for index, disInfo in ipairs(disInfos) do
            local lastIdMap = {}
            local chessdata = disInfo.chessdata
            local emptyPos = {}
            sNum = 0
            for col = 1, #chessdata do
                for row = 1, #chessdata[col] do
                    local Id = chessdata[col][row].Id
                    local val = chessdata[col][row].val
                    if disId[Id] == nil and lastIdMap[Id] == nil and val ~= 70 then
                        table.insert(emptyPos, { col, row })
                        disId[Id] = 1
                    end
                    if val == 70 then
                        sNum = sNum + 1
                    end
                end
            end
            table.insert(emptyPoses, emptyPos)
            lastIdMap = disInfo.iDMap
        end
		local mass = mulNum - sNum
		mass = mass <0 and 0 or mass
        for i = 1, mass do
            --随机哪个棋盘
            if #emptyPoses <= 0 then
                break
            end
            local boardIndex = math.random(#emptyPoses)
            local emptyPos = emptyPoses[boardIndex]
            if table.empty(emptyPos) then
                table.remove(emptyPoses, boardIndex)
            else
                local emptyIndex = math.random(#emptyPos)
                if #emptyPos > 0 and emptyIndex > 0 then
                    local pos = emptyPos[emptyIndex]
                    table.remove(emptyPos, emptyIndex)
                    if #emptyPos <= 0 then
                        table.remove(emptyPoses, boardIndex)
                    end
                    local col, row = pos[1], pos[2]
                    --生成一个倍数图标
                    local oldId = disInfos[boardIndex].chessdata[col][row].Id
                    local uIcon = { Id = iconRealId, val = 70, mul = 0 }
                    iconRealId = iconRealId + 1
					sNum = sNum + 1
                    addUIconToChess(disInfos, boardIndex, oldId, uIcon)
                else
                    table.remove(emptyPoses, boardIndex)
                end
            end
        end
    end
    return sNum
end
--进行倍数图标处理,棋盘还原
function mulIconFunctionAndReChess(disInfos, disId, isFree)
    local sNum = 0
    --按照消除棋盘位置留空
	local emptyPoses = {}
	for index, disInfo in ipairs(disInfos) do
		local lastIdMap = {}
		local chessdata = disInfo.chessdata
		local emptyPos = {}
		sNum = 0
		for col = 1, #chessdata do
			for row = 1, #chessdata[col] do
				local Id = chessdata[col][row].Id
				local val = chessdata[col][row].val
				if disId[Id] == nil and lastIdMap[Id] == nil and val ~= 70 then
					table.insert(emptyPos, { col, row })
					disId[Id] = 1
				end
				if    val == 70 then
					sNum = sNum + 1
				end
			end
		end
		table.insert(emptyPoses, emptyPos)
		lastIdMap = disInfo.iDMap
	end
    return sNum
end

--对各个棋盘进行赋值
function addUIconToChess(disInfos, boardIndex, oldId, uIcon)
    for i = boardIndex, #disInfos do
        local chessdata = disInfos[i].chessdata
        for col = 1, #chessdata do
            for row = 1, #chessdata[col] do
                if chessdata[col][row].Id == oldId then
                    chessdata[col][row] = uIcon
                    break
                end
            end
        end
    end
end

--对棋盘进行消除处理(一次)
function chessdataHandle(chessdata, lastColRow, disId, isFree)
    local disInfo = { dis = {}, chessdata = table.clone(chessdata), mul = 0,winfo= {} }
    --进行是否可消除判断
    getDisMul(disInfo)
    --记录Id将消除位置变为0
    if #disInfo.dis > 0 then
        for _, value in ipairs(disInfo.dis) do
			for _, coordinate in ipairs(value.data ) do
					local   col = coordinate[1]
					local  row =  coordinate[2]
                    if chessdata[col][row] ~= 0 then
                        local val = chessdata[col][row].val
                        if value.ele == val or  val == 90  then
                            local Id = chessdata[col][row].Id
                            disId[Id] = 1
                            chessdata[col][row] = 0
						else
							print("!!!!!!!!!!!!!!!")
                        end
                    end
                
            end
            disInfo.mul = disInfo.mul + value.mul
        end
		
		--先填充
		reChessHandle_W(chessdata,disInfo.winfo,isFree)
        --zero下落处理
        for col = 1, #chessdata do
            dropFillZero(chessdata[col])
        end
		
        local spin = table_162_normalspin_1
        if isFree then
            spin = table_162_free_1
        end
        --棋盘重新填充处理
        reChessHandle(lastColRow, spin, chessdata,isFree)
		
        --对棋盘进行在处理
        fillCellToId(chessdata)
    end
    return disInfo, chessdata
end
--先填充W
function reChessHandle_W(chessdata,winfo,isFree)
	local Freecol = 0 
	local coltable = {}
	local randcol = {}
	for col = 1, #chessdata do
		for row = 1, #chessdata[col] do
			if chessdata[col][row] == 0 then
				if not coltable[col] then 
					coltable[col] = true
					table.insert(randcol,col)
				end 
				
			end
		end
	end 
	Freecol = randcol[math.random(#randcol)]
	for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            if Freecol ~= 0 and Freecol == col and   chessdata[col][row] == 0 then	
				if isFree then 
					local robj = table_162_mul_1[gamecommon.CommRandInt(table_162_mul_1, 'gailvfree')]
					local uIcon = { Id = iconRealId, val = robj.iconid, mul = robj.mul }
					chessdata[col][row] = uIcon 
					iconRealId = iconRealId + 1
					table.insert(winfo,{ Id = iconRealId, val = robj.iconid, mul = robj.mul,coordinate={col,row}})
					break
				else 
					if table_162_mul_3[gamecommon.CommRandInt(table_162_mul_3, 'gailvfree')].mul ~=0 then 
						local robj = table_162_mul_2[gamecommon.CommRandInt(table_162_mul_2, 'gailvfree')]
						local uIcon = { Id = iconRealId, val = robj.iconid, mul = robj.mul }
						chessdata[col][row] = uIcon 
						iconRealId = iconRealId + 1
						table.insert(winfo,{ Id = iconRealId, val = robj.iconid, mul = robj.mul,coordinate={col,row}})
						break
					end 
				end 
            end
        end
	end 
   
end 
function reChessHandle(lastColRow, spin, chessdata,isFree)
	
    for col = 1, #chessdata do
        local lastRow = lastColRow[col]
        for row = 1, #chessdata[col] do
            if chessdata[col][row] == 0 then
				lastRow = lastRow - 1
				if lastRow <= 0 then
					lastRow = #spin + lastRow
				end
				chessdata[col][row] = spin[lastRow]['c' .. col]
            end
        end
        lastColRow[col] = lastRow
    end
end

function dropFillZero(data,winfo)
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

-- 检查是否越界
local function isValid(row, col,board)
    return   row >= 1 and row <= ROWS and col >= 1 and col <= COLS and (not board[row][col].isadjacent) 
end

-- 检查指定位置是否相同
local function isEqual(row1, col1, row2, col2,board,constv)
    return not board[row2][col2].use and ((board[row1][col1].val == board[row2][col2].val) or  (board[row1][col1].val == 90 and board[row2][col2].val ==constv  ) or  (board[row2][col2].val == 90))
end
local function mergetable(t, s)
	for _,v in pairs(s) do
		table.insert(t,v)
	end
	return t
end 
local function mergeelements(t)
	if #t <= 1 then
		return t
	end 
	local ct = {}
	for _,v in ipairs(t) do
		local id = ROWS * v[1] +v[2]
		if not ct[id] then 
			 ct[id] = v
		end 	
	end
	local c = {}
	mergetable(c ,ct)
	
	return c
end 
-- 检查相邻的元素是否相同
local function checkAdjacent(row, col,board,constv)
	local curval = board[row][col].val 
	if curval ~= 90 and curval ~= constv then 
		return {}
	end 
    local positions = {{row, col}}
    -- 检查上方相邻元素
    local r, c = row - 1, col
    if  isValid(r, c,board) and isEqual(row, col, r, c,board,constv) then 
		board[row][col].isadjacent = true
        table.insert(positions, {r, c})
		positions = mergetable(positions,checkAdjacent(r, c,board,constv))
		board[row][col].isadjacent = nil 
    end

    -- 检查下方相邻元素
    r, c = row + 1, col
    if  isValid(r, c,board) and isEqual(row, col, r, c,board,constv) then 
		board[row][col].isadjacent = true
        table.insert(positions, {r, c})
		positions = mergetable(positions,checkAdjacent(r, c,board,constv))
		board[row][col].isadjacent = nil 
    end

    -- 检查左侧相邻元素
    r, c = row, col - 1
    if isValid(r, c,board) and isEqual(row, col, r, c,board,constv) then
		board[row][col].isadjacent = true
        table.insert(positions, {r, c})
		positions = mergetable(positions,checkAdjacent(r, c,board,constv))
		board[row][col].isadjacent = nil 
    end

    -- 检查右侧相邻元素
    r, c = row, col + 1
    if isValid(r, c,board) and isEqual(row, col, r, c,board,constv) then 
		board[row][col].isadjacent = true
        table.insert(positions, {r, c})
		positions = mergetable(positions,checkAdjacent(r, c,board,constv))
		board[row][col].isadjacent = nil 
    end
	positions = mergeelements(positions)
    -- 如果相邻相同元素数量达到5个或以上，返回相同元素的位置
	return positions
end

-- 遍历棋盘，检查相邻的相同元素
local function findMatches(board)
    local matches = {}
    for i = 1, ROWS do
        for j = 1, COLS do
			if not board[i][j].use and board[i][j].val ~= 90  then 
				if i == 3 then
				local a= 1
				end 
				local  positions = checkAdjacent(i, j,board,board[i][j].val)
				if #positions >= 5  then
					for _,v in ipairs(positions) do
						board[v[1]][v[2]].use = true
					end
					matches[#matches + 1] = positions
				end
			end 
        end
    end
    return matches
end

--判断是否可消除倍数  返回val
function getDisMul(disInfo)
    local disNums = { 5, 6, 7, 8, 9, 10, 11, 12,13,14,15 }
	local chessdata = disInfo.chessdata
	local matchese = findMatches(chessdata)
	--data 可以消除的坐标
    for _, data in pairs(matchese) do
		local key = 1
		for _,v in ipairs(data) do
			local chessman = chessdata[v[1]][v[2]]
			if chessman.val ~= 90 then 
				key =  chessman.val
				break
			end 
		end
		local num = #data 
        for i = #disNums, 1, -1 do
            if num >= disNums[i] then
                local mulIndex = disNums[i]
                if table_162_paytable[key] ~= nil and table_162_paytable[key]['c' .. mulIndex] > 0 then
                    --可以消除
					--遍历看看有没有90的
					local Wmul = 0
					for _,v in ipairs(data) do
						local chessman = chessdata[v[1]][v[2]]
						if chessman.val == 90 then 
							Wmul= Wmul + chessman.mul
						end 
					end
					if Wmul ==0 then 
						Wmul = 1
					end 
                    table.insert(disInfo.dis, {ele = key,num=num,mul = table_162_paytable[key]['c' .. mulIndex]*Wmul,data=data})
                    break
                end
            end
        end
    end
end

--给棋盘编号

function fillCellToId(chessdata)
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            local iconObj = chessdata[col][row]
            if type(iconObj) ~= 'table' then
				 chessdata[col][row] = {
                    Id = iconRealId,
                    val = iconObj,
                }
                iconRealId = iconRealId + 1
            end
        end
    end
end

--打印棋盘
function printchessdata(chessdata)
    print('==========================================')
    for row = 1, 7 do
        local rowstr = ''
        for col = 1, 7 do
            if type(chessdata[row][col]) == 'table' then
                rowstr = rowstr .. chessdata[row][col].val .. ','
            else
                rowstr = rowstr .. chessdata[row][col] .. ','
            end
        end
        print(rowstr)
    end
end
