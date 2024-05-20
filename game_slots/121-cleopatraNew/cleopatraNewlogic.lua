module('cleopatraNew', package.seeall)
local iconRealId = 1
--执行雷神2图库
function StartToImagePool(imageType)
    if imageType==2 then
        --跑免费图库
        return Free()
    else
        return Normal()
    end
end

function Free()
    --默认15次
    local tFreeNum = 15
    local cFreeNum = 0
    local isFree=false
    --全部u图标累计
    local allUMul = 0
    --普通倍数
    local normalMul = 0
    local cols = { 5, 5, 5, 5, 5, 5 }
    local allDisInfos = {}
    while true do
        local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols, table_121_free_1)
        iconRealId = 1
        fillCellToId(chessdata)
        --总消除数据，after触发免费后的数据
        --一次棋盘消除数据
        local disInfos = { before = {} ,curMul=0}
        local disId = {}
        local disInfo, tchessdata = chessdataHandle(chessdata, lastColRow, disId, true)
        table.insert(disInfos.before, disInfo)
        while table.empty(disInfo.dis) == false do
            disInfo, tchessdata = chessdataHandle(tchessdata, lastColRow, disId, true)
            table.insert(disInfos.before, disInfo)
        end
        local imageType = 1
        local mul = 0
        --进行倍数图标处理,统计s个数,倍数图标返回倍数
        local sNum, uMul = mulIconFunctionAndReChess(disInfos, disId, true)
        --对棋盘数据进行最终整理,计算棋盘mul
        local FinMul = arrangeToSave(disInfos)
        local curMul = FinMul
        if FinMul>0 then
            allUMul = allUMul + uMul
            if allUMul>0 and uMul>0 then
                normalMul = normalMul + FinMul*allUMul
                curMul = curMul*allUMul
            else
                normalMul = normalMul + FinMul
            end
        end
        cFreeNum = cFreeNum + 1
        disInfos.curMul = curMul
        table.insert(allDisInfos, disInfos)
        if sNum >= 3 then
            tFreeNum = tFreeNum + 5
            isFree=true
        end
        local sMul =  calcSMul(sNum)
        normalMul = normalMul + sMul
        if cFreeNum >= tFreeNum or normalMul>300 then
            break
        end
    end
    --进行最终倍数计算
    local mul = normalMul
    return allDisInfos, mul, 2
end

function calcSMul(sNum)
    if sNum==4 then
        return 3
    elseif sNum==5 then
        return 5
    elseif sNum==6 then
        return 100
    end
    return 0
end


function Normal()
    local getDisMul=function(disInfo)
        local mul = 0
        for _,value in ipairs(disInfo) do
            mul = mul + value.mul
        end
        return mul
    end
    local cols = { 5, 5, 5, 5, 5, 5 }
    --table_121_normalspin_1
    local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols, table_121_normalspin_1)
    iconRealId = 1
    --棋盘进行id预处理
    fillCellToId(chessdata)
    --总消除数据，after触发免费后的数据
    local disInfos = { before = {},f={}}
    local disId = {}
    local disInfo, tchessdata = chessdataHandle(chessdata, lastColRow, disId)
    table.insert(disInfos.before, disInfo)
    local mul = getDisMul(disInfo)
    while table.empty(disInfo.dis) == false and mul<=300 do
        disInfo, tchessdata = chessdataHandle(tchessdata, lastColRow, disId)
        mul = mul + getDisMul(disInfo)
        table.insert(disInfos.before, disInfo)
    end
    local imageType = 1
    --进行倍数图标处理,统计s个数,倍数图标返回倍数
    local sNum, uMul = mulIconFunctionAndReChess(disInfos, disId)
    --对棋盘数据进行最终整理,计算最终mul
    local FinMul = arrangeToSave(disInfos)
    if uMul > 0 then
        FinMul = FinMul * uMul
    end
    if sNum>=4 then
        --出发免费
       local f,freeMul =  Free()
       FinMul = FinMul + freeMul
       disInfos.f = f
    --    print('normal sNum>3')
       imageType=3
    end
    local sMul =  calcSMul(sNum)
    FinMul = FinMul + sMul



    return disInfos, FinMul, imageType
end

--对数据进行整理保存
function arrangeToSave(disInfos)
    local FinMul = 0
    for _, disInfo in ipairs(disInfos.before) do
        disInfo.iDMap = nil
        for _, dis in ipairs(disInfo.dis) do
            FinMul = FinMul + dis.mul
        end
    end
    return FinMul
end

--进行倍数图标处理,棋盘还原
function mulIconFunctionAndReChess(disInfos, disId, isFree)
    --随机获取需要产生的倍数图标的个数
    local field = 'gailv100'
    if isFree then
        field = 'gailvfree'
    end

    local mulNum = table_mul_gamety1[gamecommon.CommRandInt(table_mul_gamety1, field)].num
    local changeToMul = {} --Id To iconsAttachData
    local sNum, uMul = 0, 0
    --统计s图标
    local lastBefore = disInfos.before[#disInfos.before]
    local chessdata = lastBefore.chessdata
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            local Id = chessdata[col][row].Id
            local val = chessdata[col][row].val
            if val==70 then
                sNum = sNum +1
            end
        end
    end
    --按照消除棋盘位置留空
    if mulNum > 0 then
        local emptyPoses = {}
        for index, disInfo in ipairs(disInfos.before) do
            local lastIdMap = {}
            local chessdata = disInfo.chessdata
            local emptyPos = {}
            for col = 1, #chessdata do
                for row = 1, #chessdata[col] do
                    local Id = chessdata[col][row].Id
                    local val = chessdata[col][row].val
                    if disId[Id] == nil and lastIdMap[Id] == nil and val ~= 70 then
                        table.insert(emptyPos, { col, row })
                        disId[Id] = 1
                    end
                end
            end
            table.insert(emptyPoses, emptyPos)
            lastIdMap = disInfo.iDMap
        end
        for i = 1, mulNum do
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
                    local oldId = disInfos.before[boardIndex].chessdata[col][row].Id
                    local robj = table_121_mul_1[gamecommon.CommRandInt(table_121_mul_1, field)]
                    uMul = uMul + robj.mul
                    local uIcon = { Id = iconRealId, val = robj.iconid, mul = robj.mul }
                    iconRealId = iconRealId + 1
                    addUIconToChess(disInfos.before, boardIndex, oldId, uIcon)
                else
                    table.remove(emptyPoses, boardIndex)
                end
            end
        end
    end
    return sNum, uMul
end

--对各个棋盘进行赋值
function addUIconToChess(before, boardIndex, oldId, uIcon)
    for i = boardIndex, #before do
        local chessdata = before[i].chessdata
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
    --iDMap 当前棋盘拥有的Id map
    local disInfo = { dis = {}, chessdata = table.clone(chessdata), mul = 0, iDMap = {} }
    local numMap = {}
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            local val = chessdata[col][row].val
            local Id = chessdata[col][row].Id
            numMap[val] = numMap[val] or 0
            numMap[val] = numMap[val] + 1
            disInfo.iDMap[Id] = 1
        end
    end
    --进行是否可消除判断
    getDisMul(numMap, disInfo.dis)
    --记录Id将消除位置变为0
    if #disInfo.dis > 0 then
        for _, value in ipairs(disInfo.dis) do
            for col = 1, #chessdata do
                for row = 1, #chessdata[col] do
                    if chessdata[col][row] ~= 0 then
                        local val = chessdata[col][row].val
                        if value.ele == val then
                            local Id = chessdata[col][row].Id
                            disId[Id] = 1
                            chessdata[col][row] = 0
                        end
                    end
                end
            end
            disInfo.mul = disInfo.mul + value.mul
        end
        --zero下落处理
        for col = 1, #chessdata do
            dropFillZero(chessdata[col])
        end
        local spin = table_121_normalspin_1
        if isFree then
            spin = table_121_free_1
        end
        --棋盘重新填充处理
        reChessHandle(lastColRow, spin, chessdata)
        --对棋盘进行在处理
        fillCellToId(chessdata)
    end
    return disInfo, chessdata
end

function reChessHandle(lastColRow, spin, chessdata)
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

--判断是否可消除倍数  返回val
function getDisMul(numMap, dis)
    local disNums = { 5, 6, 7, 8, 11, 14, 17, 21 }
    for key, num in pairs(numMap) do
        for i = #disNums, 1, -1 do
            if num >= disNums[i] then
                local mulIndex = disNums[i]
                if table_121_paytable[key] ~= nil and table_121_paytable[key]['c' .. mulIndex] > 0 then
                    --可以消除
                    table.insert(dis, {ele = key,num=num,mul = table_121_paytable[key]['c' .. mulIndex]})
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
