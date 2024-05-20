module('dragon', package.seeall)

local logic = {}
--执行输出一个非wild代码
function findNoWildVal(eliminateHandle)
    local noWildVal = 90
    for _, value in ipairs(eliminateHandle) do
        if value.iconId ~= 90 then
            noWildVal = value.iconId
            break
        end
    end
    return noWildVal
end

--获取消除倍数
function getEleMul(iconId, mNum)
    local eObj = table_136_paytable[iconId]
    if eObj ~= nil then
        local mulNum = { 4, 5, 6, 7, 8, 9, 10, 13, 15, 18, 21,25 }
        for i = #mulNum, 1, -1 do
            if mNum >= mulNum[i] then
                return eObj['c' .. mulNum[i]]*10
            end
        end
    end
    return 0
end

--下落置0处理(单列)
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
--重新填充棋盘
function reChessHandle(chessdata, eliminateInfo,lastColRow)
    local getLastColRow=function (col)
        local lastRow =  lastColRow[col]
        lastRow = lastRow-1
        if lastRow<=0 then
            lastRow = #table_136_normalspin_1
        end
        lastColRow[col] = lastRow
        return table_136_normalspin_1[lastRow]['c'..col]
    end


    for _, value in ipairs(eliminateInfo) do
        for _, val in ipairs(value.eliminateHandle) do
            chessdata[val.c][val.r] = 0
        end
    end
    for col = 1, #chessdata do
        dropFillZero(chessdata[col])
    end
    --重新填充棋牌
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            if chessdata[col][row] == 0 then
                local iconId = getLastColRow(col)
                chessdata[col][row] = iconId
            end
        end
    end
end

--执行相邻消除,第一次
function nearEliminate(chessdata)
    --消除信息
    local eliminateInfo = {}
    --简历遍历记录表
    local tmpRecord = {}
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            tmpRecord[col] = tmpRecord[col] or {}
            tmpRecord[col][row] = 0
        end
    end
    --开始遍历
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            local tmpWild = {}
            if tmpRecord[col][row] == 0 then
                --执行遍历消除
                --消除处理数据  {{c,r,iconId}}
                local eliminateHandle = {}
                eliminateDFS(col, row, chessdata, tmpWild, tmpRecord, eliminateHandle)
                local eleId = findNoWildVal(eliminateHandle)
                local mNum  = #eliminateHandle
                local mul   = getEleMul(eleId, mNum)
                if mul > 0 then
                    table.insert(eliminateInfo, { eleId = eleId, mul = mul, eliminateHandle = eliminateHandle })
                end
            end
        end
    end
    return eliminateInfo
    -- return {}
end

--消除遍历代码
function eliminateDFS(c, r, chessdata, tmpWild, tmpRecord, eliminateHandle)
    if c < 1 or c > 5 or r < 1 or r > 5 or tmpWild[c .. '_' .. r] ~= nil or tmpRecord[c][r] ~= 0 then
        return
    end
    local iconId = chessdata[c][r]
    if eliminateHandle == {} then
        table.insert(eliminateHandle, { c = c, r = r, iconId = iconId })
    else
        --寻找一个不是90的数值
        local noWildVal = findNoWildVal(eliminateHandle)
        if noWildVal == 90 or noWildVal == iconId or iconId == 90 then
            if iconId == 90 then
                tmpWild[c .. '_' .. r] = 1
            else
                tmpRecord[c][r] = 1
            end
            table.insert(eliminateHandle, { c = c, r = r, iconId = iconId })
        else
            return
        end
    end
    eliminateDFS(c - 1, r, chessdata, tmpWild, tmpRecord, eliminateHandle)
    eliminateDFS(c + 1, r, chessdata, tmpWild, tmpRecord, eliminateHandle)
    eliminateDFS(c, r - 1, chessdata, tmpWild, tmpRecord, eliminateHandle)
    eliminateDFS(c, r + 1, chessdata, tmpWild, tmpRecord, eliminateHandle)
end

--执行全消除,入口函数
function chessHandle(chessdata, lastColRow,isdrago,chageToArray)
    local disEIe = {}
    local eliminateInfo = nearEliminate(chessdata)
    table.insert(disEIe, { eliminateInfo = eliminateInfo, chessdata = table.clone(chessdata) })
    -- if not isdrago then
    --     table.insert(disEIe, { eliminateInfo = eliminateInfo, chessdata = table.clone(chessdata) })
    -- else
    --     table.insert(disEIe, { eliminateInfo = eliminateInfo, chessdata = table.clone(chessdata),chageToArray=chageToArray })
    -- end
    while next(eliminateInfo) do
        --执行棋盘,重置重新下落
        reChessHandle(chessdata, eliminateInfo, lastColRow)
        if isdrago then
            chessdata,chageToArray = eleDragonLowToHigh(chessdata)
        end
        eliminateInfo = nearEliminate(chessdata)
        table.insert(disEIe, { eliminateInfo = eliminateInfo, chessdata = table.clone(chessdata) })
        -- if not isdrago then
        --     table.insert(disEIe, { eliminateInfo = eliminateInfo, chessdata = table.clone(chessdata) })
        -- else
        --     table.insert(disEIe, { eliminateInfo = eliminateInfo, chessdata = table.clone(chessdata),chageToArray=chageToArray })
        -- end
    end
    return disEIe
end

--消除棋盘上的低级图标
function eleLowIcon(chessdata,lastColRow)
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            if chessdata[col][row] >= 1 and chessdata[col][row] <= 4 then
                chessdata[col][row] = 0
            end
        end
    end
    reChessHandle(chessdata, {},lastColRow)
    return chessdata
end
--棋盘上2 4列随机变成高级图标的其中之二
function eleToHighIconTwo(chessdata)
    local cols = { 2, 4 }
    local randIconId = { 1, 2, 3, 4 }
    for i = 1, 2 do
        local randIndex = math.random(#randIconId)
        local iconId = randIconId[randIndex]
        table.remove(randIconId, randIndex)
        for r = 1, 5 do
            chessdata[cols[i]][r] = iconId
        end
    end
    return chessdata
end
--4个位置变wild
function fourToWild(chessdata)
    chessdata[2][2] = 90
    chessdata[2][4] = 90
    chessdata[4][2] = 90
    chessdata[4][4] = 90
    return chessdata
end
--固定位置变换图标
function fixPosToIconId(chessdata)
    local iconId = table_136_lv3[gamecommon.CommRandInt(table_136_lv3,'gailv')].iconId
    local rows={{1,3,5},{2,4},{1,3,5},{2,4},{1,3,5}}
    for col=1,#chessdata do
        local rowRand = rows[col]
        for _,row in ipairs(rowRand) do
            chessdata[col][row] = iconId
        end
    end
    return chessdata
end

--随机生成4个wild不占用中间
function eleRandToFourWild(chessdata)
    local pos = {}
    for col = 1, 5 do
        for row = 1, 5 do
            if not (col == 3 and row == 3) then
                table.insert(pos, { col, row })
            end
        end
    end
    for i = 1, 4 do
        local posIndex = math.random(#pos)
        local p = pos[posIndex]
        table.remove(pos, posIndex)
        chessdata[p[1]][p[2]] = 90
    end
    return chessdata
end

--龙母过程 低级图标变随机高级图标
function eleDragonLowToHigh(chessdata)
    local chageToArray={}
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            local iconId = chessdata[col][row]
            if iconId >= 1 and iconId <= 4 then
                local iconId = table_136_lv4[gamecommon.CommRandInt(table_136_lv4,'gailv')].iconId
                chessdata[col][row] = iconId
                table.insert(chageToArray,iconId)
            end
        end
    end
    return chessdata,chageToArray
end

--wild 记录
function calcWildNum(eliminateHandle)
    local WildRecord = {}
    local disEliinateNum = 0
    for _, value in ipairs(eliminateHandle) do
        for _, iconInfo in ipairs(value.eliminateHandle) do
            if iconInfo.iconId == 90 and WildRecord[iconInfo.c .. '_' .. iconInfo.r] == nil then
                disEliinateNum = disEliinateNum + 1
                WildRecord[iconInfo.c .. '_' .. iconInfo.r] = 1
            elseif iconInfo.iconId ~= 90 then
                disEliinateNum = disEliinateNum + 1
            end
        end
    end
    return disEliinateNum
end



--绿龙处理 消除1-4
function green(lastChessdata,lastColRow)
    local boards = {}
    local mul = 0
    local chessdata = eleLowIcon(lastChessdata,lastColRow)
    --这里处理的子项消除
    local disAdd = chessHandle(chessdata,lastColRow)
    local tchessdata = {}
    local eliinateNum = 0
    for index, value in ipairs(disAdd) do
        table.insert(boards, value.chessdata)
        tchessdata = value.chessdata
        local disEliinateNum = calcWildNum(value.eliminateInfo)
        eliinateNum = eliinateNum + disEliinateNum
        for _, val in ipairs(value.eliminateInfo) do
            mul = mul + val.mul
        end
        disAdd[index].disEliinateNum = disEliinateNum
    end
    return boards, disAdd, mul, table.clone(tchessdata), eliinateNum
end


--蓝龙处理 4个位置变wild
function blue(lastChessdata,lastColRow)
    local boards = {}
    local mul = 0
    local chessdata = fourToWild(lastChessdata)
    local disAdd = chessHandle(chessdata,lastColRow)
    local tchessdata = {}
    local eliinateNum = 0
    for index, value in ipairs(disAdd) do
        table.insert(boards, value.chessdata)
        tchessdata = value.chessdata
        local disEliinateNum = calcWildNum(value.eliminateInfo)
        eliinateNum = eliinateNum + disEliinateNum
        for _, val in ipairs(value.eliminateInfo) do
            mul = mul + val.mul
        end
        disAdd[index].disEliinateNum = disEliinateNum
    end
    return boards, disAdd, mul, table.clone(tchessdata), eliinateNum
end
--固定位置变换,固定图标
function red(lastChessdata,lastColRow)
    local boards = {}
    local mul = 0
    local chessdata = fixPosToIconId(lastChessdata)
    local disAdd = chessHandle(chessdata,lastColRow)
    local tchessdata = {}
    local eliinateNum = 0
    for index, value in ipairs(disAdd) do
        table.insert(boards, value.chessdata)
        tchessdata = value.chessdata
        local disEliinateNum = calcWildNum(value.eliminateInfo)
        eliinateNum = eliinateNum + disEliinateNum
        for _, val in ipairs(value.eliminateInfo) do
            mul = mul + val.mul
        end
        disAdd[index].disEliinateNum = disEliinateNum
    end
    return boards, disAdd, mul, table.clone(tchessdata), eliinateNum
end

function mother(lastChessdata,lastColRow)
    local mul = 0
    local chessdata,chageToArray = eleDragonLowToHigh(lastChessdata)
    local disAdd = chessHandle(chessdata,lastColRow,true,chageToArray)
    local tchessdata = {}
    local eliinateNum = 0
    for index, value in ipairs(disAdd) do
        tchessdata = value.chessdata
        local disEliinateNum = calcWildNum(value.eliminateInfo)
        eliinateNum = eliinateNum + disEliinateNum
        for _, val in ipairs(value.eliminateInfo) do
            mul = mul + val.mul
        end
        disAdd[index].disEliinateNum = disEliinateNum
    end
    return boards, disAdd, mul, table.clone(tchessdata), eliinateNum
end
