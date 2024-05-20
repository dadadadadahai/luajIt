module('animal',package.seeall)

function NormalFree()
    local imageType=1
    local dis={b={},f={}}
    local cols={3,3,3,3,3}
    local chessdata = gamecommon.CreateSpecialChessData(cols,table_145_normalspin)
    local wildMap={[90]=1}
    local noWildMap ={[70]=1}
    local tMul = 0
    local result =  gamecommon.LinesHandle(wildMap,noWildMap,table_145_paytable,table_145_payline,chessdata,nil,nil)
    for _,value in ipairs(result) do
        tMul=sys.addToFloat(tMul,value[3])
    end
    local sFree=0
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            if chessdata[col][row]==70 then
                sFree=sFree+1
            end
        end
    end
    dis.b={chessdata=chessdata,dis=result,mul = tMul}
    if table_145_uFree[sFree]~=nil then
        --开始触发免费
        local totalTimes = table_145_uFree[sFree].freeNum
        local lackTimes = totalTimes
        imageType=2
        --锁定框
        local sameLockRange={}
        local sameLockMap={}
        local sameIconHandle=function (sameIconId)
            for col=1,#chessdata do
                for row=1,#chessdata[col] do
                    if sameIconId == chessdata[col][row] then
                        if sameLockMap[col..'_'..row]==nil then
                            table.insert(sameLockRange,{col,row})
                            sameLockMap[col..'_'..row]=1
                        end

                    end
                end
            end
        end
        local iconIdToSameId = function (sameIconId,chessdata)
            for _,value in ipairs(sameLockRange) do
                chessdata[value[1]][value[2]] = sameIconId
            end
        end
        for i=1,lackTimes do
            chessdata = gamecommon.CreateSpecialChessData(cols,table_145_free)            
            local mul = 0
            --新图标
            chessdata[3][2]=table_145_fGailv[gamecommon.CommRandInt(table_145_fGailv,'gailv')].iconId
            local sameIconId = chessdata[3][2]
            local rchessdata = table.clone(chessdata)
            sameIconHandle(sameIconId)
            iconIdToSameId(sameIconId,rchessdata)
            --计算倍数
            result =  gamecommon.LinesHandle(wildMap,noWildMap,table_145_paytable,table_145_payline,rchessdata,nil,nil)
            for _,value in ipairs(result) do
                tMul=sys.addToFloat(tMul,value[3])
                mul = sys.addToFloat(mul,value[3])
            end
            table.insert(dis.f,{totalTimes=totalTimes,lackTimes =totalTimes-i,chessdata=chessdata,sameLockRange=table.clone(sameLockRange),mul=mul,dis=result})
        end
    end
    return dis,tMul/20,imageType
end