module('animal',package.seeall)

function StartToImagePool(imageType)
    if imageType==3 then
        --跑特殊的
        return uRespin()
    else
        return NormalFree()
    end
end


function uRespin()
    local cols={3,3,3,3,3}
    local emptyPos={}
    for col=1,5 do
        for row=1,3 do
            table.insert(emptyPos,{col,row})
        end
    end
    local uPosRange={}
    local chessdata = gamecommon.CreateSpecialChessData(cols,table_145_free)
    local uNum = table_145_U[gamecommon.CommRandInt(table_145_U,'gailv')].uNum
    local rchessdata = table.clone(chessdata)
    local getURand =function ()
        local index = math.random(#emptyPos)
        local c,r = emptyPos[index][1],emptyPos[index][2]
        table.remove(emptyPos,index)
        return c,r
    end
    local uToIconId = table_145_UTo[gamecommon.CommRandInt(table_145_UTo,'gailv')].iconId
    for i=1,uNum do
        local c,r = getURand()
        rchessdata[c][r] = uToIconId
        table.insert(uPosRange,{c,r})
    end
    local wildMap={[90]=1}
    local noWildMap ={[70]=1}
    local tMul = 0
    local result =  gamecommon.LinesHandle(wildMap,noWildMap,table_145_paytable,table_145_payline,rchessdata,nil,nil)
    for _,value in ipairs(result) do
        tMul=sys.addToFloat(tMul,value[3])
    end
    local dis={chessdata=chessdata,uPosRange=uPosRange,dis=result,uToIconId=uToIconId}
    return dis,tMul/20,3
end