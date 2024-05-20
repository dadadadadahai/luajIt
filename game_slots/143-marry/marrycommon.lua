module('marry',package.seeall)
LineNum = 30
function StartToImagePool()
    local res,tMul,sFree,chessdata = oneCommonRotate(table_143_normalspin)
    local imageType=1
    local dis={b={
        winLines=res,chessdata=chessdata,mul=tMul
    },f={}}
    if sFree>=3 then
        imageType=2
        local totalTimes=8
        local lackTimes = 8
        while lackTimes>0 do
            local res1,tMul1,sFree1,chessdata1 = oneCommonRotate(table_143_freespin)
            local res2,tMul2,sFree2,chessdata2 = oneCommonRotate(table_143_freespin)
            local fMul = tMul1+tMul2
            if tMul1>0 and tMul2>0 then
                fMul = fMul * 8 
            end
            totalTimes=totalTimes+sFree1+sFree2
            lackTimes=lackTimes+sFree1+sFree2
            lackTimes=lackTimes-1
            table.insert(dis.f,{fMul=fMul,totalTimes=totalTimes,lackTimes=lackTimes,data={[1]={winLines=res1,chessdata=chessdata1,mul=tMul1},[2]={winLines=res2,chessdata=chessdata2,mul=tMul2}}})
            tMul=tMul+fMul
        end
    end
    return dis,tMul/LineNum,imageType
end
--一个棋盘旋转处理
function oneCommonRotate(spin)
    local cols={3,3,3,3,3}
    local chessdata = gamecommon.CreateSpecialChessData(cols,spin)
    local wildMap={[90]=1}
    local noWildMap={[70]=1}
    --进行中线判断
    local res = gamecommon.LinesHandle(wildMap,noWildMap,table_143_paytable,table_143_payline,chessdata,getIconIdFunc,doubleFunc)
    local tMul = 0
    --计算总倍数
    for _,value in ipairs(res) do
        tMul = tMul + value[3]
    end
    --计算sFree个数
    local sFree=0
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            if chessdata[col][row]==70 then
                sFree = sFree + 1
            end
        end
    end
    return res,tMul,sFree,chessdata
end



function getIconIdFunc(celloj)
    if celloj>=9 and celloj<=16 then
        return celloj-8
    end
    return celloj
end

function doubleFunc(celloj)
    if celloj>=9 and celloj<=16 then
        return 2
    end
    return 1
end