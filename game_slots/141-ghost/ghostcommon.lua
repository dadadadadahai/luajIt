module('ghost', package.seeall)
--不识别type
function StartToImagePool()
    local imageType = 1
    local result,lastchessdata = commonRotate(false)
    local sFreeNum = 0
    local free={}
    --判断是否触发free
    for col=1,#lastchessdata do
        for row=1,#lastchessdata[col] do
            if getIconIdFunc(lastchessdata[col][row])==70 then
                sFreeNum = sFreeNum + 1
            end
        end
    end
    local tMul = result.mul
    if sFreeNum>=3 then
        imageType=2
        free={totalTimes=12+(sFreeNum-3)*2,lackTimes=12+(sFreeNum-3)*2,res={}}
        local addMul = 0
        --触发了免费模式
        for i=1,free.lackTimes do
            local freeresult,_,AddMul = commonRotate(true,addMul)
            freeresult.AddMul = AddMul
            addMul=freeresult.AddMul
            tMul = tMul + freeresult.mul
            table.insert(free.res,freeresult)
        end
    end
    --构建返回最终体
    local finRes={n=result,f=free}
    return finRes,tMul,imageType
end

--通用处理,一次过程
function commonRotate(isFree,AddMul)
    --获取总倍数,放大100倍
    local getTMul100=function(eliminateInfo,AddMul)
        local tMul = 0
        for _,val in ipairs(eliminateInfo) do
            tMul = tMul + val.mul*100
        end
        return tMul*AddMul
    end


    local spin = table_141_normalspin
    if isFree then
        spin = table_141_free
    end
    local cols = { 4, 4, 4, 4, 4 }
    local mul = 0
    if AddMul==nil then
        AddMul=0
    end
    local chessdata, lastCols = gamecommon.CreateSpecialChessData(cols, spin)
    local free={}
    local dis = {}
    --棋盘金框处理
    local rchessdata = chessToGold(chessdata, isFree)
    local wildMap = {
        [90] = 1
    }
    local noWildMap = {
        [70] = 1
    }
    --进行消除处理
    local eliminateInfo = gamecommon.AllLineDisEle(wildMap, noWildMap, table_141_paytable, rchessdata, getIconIdFunc)
    if #eliminateInfo>0 then
        AddMul=AddMul+1
    end
    local curMul = getTMul100(eliminateInfo,AddMul)
    mul=mul + curMul
    table.insert(dis, { chessdata = table.clone(rchessdata), eliminateInfo = eliminateInfo,AddMul=AddMul,curMul=curMul/100 })
    local lastchessdata = rchessdata
    --执行消除过程
    while #eliminateInfo > 0 do
        rchessdata = rechessdata(eliminateInfo,isFree,lastCols,spin,rchessdata)
        eliminateInfo = gamecommon.AllLineDisEle(wildMap, noWildMap, table_141_paytable, rchessdata, getIconIdFunc)
        if #eliminateInfo>0 then
            AddMul=AddMul+1
        end
        local curMul = getTMul100(eliminateInfo,AddMul)
        mul=mul + curMul
        lastchessdata=rchessdata
        table.insert(dis, { chessdata = table.clone(rchessdata), eliminateInfo = eliminateInfo,AddMul=AddMul,curMul=curMul/100 })
    end
    --返回倍数除以100
    return{
        AddMul=AddMul,
        mul = mul/100,
        dis=dis
    },lastchessdata,AddMul
end



--重构棋盘
function rechessdata(eliminateInfo,isFree,lastCols,spin,chessdata)
    local emliPosMap={}
    for _, val in ipairs(eliminateInfo) do
        local eliminateHandle = val.eliminateHandle
        for _, eliPos in ipairs(eliminateHandle) do
            local col, row = eliPos.c, eliPos.r
            local celloj = chessdata[col][row]
            if emliPosMap[col..'_'..row]==nil then
                if celloj.isgold == 1 and celloj.val ~= 90 then
                    celloj.val = 90
                    chessdata[col][row] = celloj
                else
                    chessdata[col][row] = 0
                end 
                emliPosMap[col..'_'..row]=1
            end
        end
    end
    --处理棋盘下落
    for col = 1, #chessdata do
        dropFillZero(chessdata[col])
    end
    local getLastColId = function (col)
        local row = lastCols[col]
        row=row-1
        if row<=0 then
            row = #spin
        end
        lastCols[col]=row
        return spin[row]['c'..col]
    end
    --填充0号元素
    for col = 1, #chessdata do
        for row=1,#chessdata[col] do
            if chessdata[col][row]==0 then
                chessdata[col][row] = getLastColId(col)
            end
        end
    end
    --构建棋盘
    return chessToGold(chessdata, isFree)
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

function getIconIdFunc(celloj)
    return celloj.val
end

function chessToGold(chessdata, isFree)
    local rchessdata = {}
    for col = 1, #chessdata do
        rchessdata[col] = rchessdata[col] or {}
        for row = 1, #chessdata[col] do
            if type(chessdata[col][row]) ~= 'table' then
                --是否为金框
                local isgold = 0
                if col >= 2 and col <= 4 then
                    local gailv = table_141_234gold[1].gailv
                    if math.random(10000) <= gailv then
                        isgold = 1
                    end
                end
                if isFree and col == 3 and chessdata[col][row]~=70 then
                    isgold = 1
                end
                rchessdata[col][row] = { val = chessdata[col][row], isgold = isgold }
            else
                rchessdata[col][row] = chessdata[col][row]
            end
        end
    end
    return rchessdata
end
