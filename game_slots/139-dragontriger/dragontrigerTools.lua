module('dragontriger',package.seeall)

function StartToImagePool(imageType)
    if imageType==1 then
        --第一种类型
        local chessdata1,mul1,rIconId1 = calcSingleChessdata(table_139_normalspin)
        local chessdata2,mul2,rIconId2 = calcSingleChessdata(table_139_normalspin_2)
        local mul = (mul1/2*10+mul2/2*10)/10
        if mul1>0 and mul2>0 then
            mul = mul * 2
        end
        local disInfo={board1={chessdata=chessdata1,mul=mul1,rIconId=rIconId1},board2={chessdata=chessdata2,mul=mul2,rIconId=rIconId2} }
        return disInfo,mul,1
    elseif imageType==2 then
        --第二种类型
        local chessdata1,mul1,rIconId1 = calcSingleChessdata(table_139_normalspin)
        local disInfo={board1={chessdata=chessdata1,mul=mul1,rIconId=rIconId1},board2={} }
        return disInfo,mul1,2
    else
        --第三种类型
        local chessdata2,mul2,rIconId2 = calcSingleChessdata(table_139_normalspin_2)
        local disInfo={board1={},board2={chessdata=chessdata2,mul=mul2,rIconId=rIconId2} }
        return disInfo,mul2,3
    end
end


--[[
    返回棋盘,中奖原始倍数
]]
function calcSingleChessdata(spin)
    local cols={1,1,1}
    local chessdata =  gamecommon.CreateSpecialChessData(cols,spin)
    local mul = 0
    local rIconId = 0
    local isSame = true
    local isZero = false
    --判断图标是否相同
    for col=1,3 do
        local iconId = chessdata[col][1]
        if iconId==1000 then
            mul = 0
            rIconId=0
            isSame=false
            isZero=true
            break
        end
        if rIconId==0 then
            rIconId = iconId
        elseif rIconId~=iconId then
            isSame = false
        end
    end
    if isSame then
        mul = table_139_paytable[rIconId].c3
    elseif isZero==false then
        rIconId=0
        mul = table_139_paytable[0].c3
    end
    return chessdata,mul,rIconId
end