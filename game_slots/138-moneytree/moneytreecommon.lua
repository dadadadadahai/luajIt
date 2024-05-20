module('moneytree',package.seeall)
function StartToImagePool(imageType)
    if imageType==1 then
        return normal()
    elseif imageType==2 then
        return respin()
    end
end
local getLastColsIcon=function (lastCols,col)
    local row = lastCols[col]
    local iconId = table_138_normalspin[row]['c'..col]
    row = row - 1
    if row<=0 then
        row = #table_138_normalspin
    end
    lastCols[col]=row
    return iconId
end
--组合顶部半边图标
local function packTopRow(lastCols)
    local topRow = {}
    for col=1,6 do
        topRow[col] = getLastColsIcon(lastCols,col)
    end
    return topRow
end
local getTMul100=function(eliminateInfo,AddMul)
    local tMul = 0
    for _,val in ipairs(eliminateInfo) do
        tMul = tMul + val.mul*100
    end
    return tMul*AddMul
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

local function rechessdata(eliminateInfo,topRow,lastCols,spin,chessdata)
    local emliPosMap={}
    for _, val in ipairs(eliminateInfo) do
        local eliminateHandle = val.eliminateHandle
        for _, eliPos in ipairs(eliminateHandle) do
            local col, row = eliPos.c, eliPos.r
            if emliPosMap[col..'_'..row]==nil then
                chessdata[col][row] = 0
                emliPosMap[col..'_'..row]=1
            end
        end
    end
    for col = 1, #chessdata do
        dropFillZero(chessdata[col])
    end
    --优先处理topRow问题
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            if chessdata[col][row]==0 then
                chessdata[col][row]=topRow[col]
                topRow[col] = getLastColsIcon(lastCols,col)
                break
            end
        end
    end
    --填充全部id
    for col = 1, #chessdata do
        for row=1,#chessdata[col] do
            if chessdata[col][row]==0 then
                chessdata[col][row] = getLastColsIcon(lastCols,col)
            end
        end
    end
    return chessdata
end

function normal()
    local cols={4,4,4,4,4,4}
    local chessdata,lastCols = gamecommon.CreateSpecialChessData(cols,table_138_normalspin)
    local topRow = packTopRow(lastCols)
    local dis = {}
    local wildMap = {
        [90] = 1
    }
    local noWildMap = {
        [80] = 1
    }
    local mul = 0
    local AddMul=0
    local eliminateInfo = gamecommon.AllLineDisEle(wildMap, noWildMap, table_138_paytable, chessdata, nil)
    if #eliminateInfo>0 then
        AddMul=AddMul+1
    end
    local curMul = getTMul100(eliminateInfo,AddMul)
    mul=mul + curMul
    table.insert(dis, { chessdata = table.clone(chessdata),topRow=table.clone(topRow), eliminateInfo = eliminateInfo,AddMul=AddMul,curMul=curMul/100 })
    local lastchessdata = chessdata
    --执行消除过程
    while #eliminateInfo > 0 do
        chessdata = rechessdata(eliminateInfo,topRow,lastCols,spin,chessdata)
        eliminateInfo = gamecommon.AllLineDisEle(wildMap, noWildMap, table_138_paytable, chessdata, nil)
        if #eliminateInfo>0 then
            AddMul=AddMul+1
            if AddMul>=4 then
                AddMul = 5
            end
        end
        local curMul = getTMul100(eliminateInfo,AddMul)
        mul=mul + curMul
        lastchessdata=chessdata
        table.insert(dis, { chessdata = table.clone(chessdata),topRow=table.clone(topRow), eliminateInfo = eliminateInfo,AddMul=AddMul,curMul=curMul/100 })
    end
    local imageType = 1
    local uNum = 0
    for col=1,#lastchessdata do
        for row=1,#lastchessdata[col] do
            if lastchessdata[col][row]==80 then
                uNum=uNum+1
            end
        end
    end
    if uNum>=3 then
        imageType=3
    end
    return dis,mul/100,imageType
end