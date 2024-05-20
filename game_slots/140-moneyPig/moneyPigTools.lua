module('moneyPig',package.seeall)
function StartToImagePool(imageType)
    if imageType==1 then
        return TypeOne()
    else
        return TypeTwo()
    end
end

function TypeTwo()
    local iconId= table_140_respin[gamecommon.CommRandInt(table_140_respin,'gailv')].iconId
    local chessdata={{iconId},{0},{iconId}}
    local index = math.random(#table_140_free)
    chessdata[2][1] = table_140_free[index].c1
    if chessdata[2][1] == 90 then
        chessdata[2][1] = table_140_col2[gamecommon.CommRandInt(table_140_col2,'gailv')].iconId
    end
    local mul,addMul,firstIconId = calc(chessdata)
    local disInfo={addMul=addMul,firstIconId=firstIconId,chessdata=chessdata}
    return disInfo,mul,2
end

--普通图库
function TypeOne()
    --产生棋盘 
    local cols={1,1,1}
    local chessdata=gamecommon.CreateSpecialChessData(cols,table_140_normalspin)
    if chessdata[2][1] == 90 then
        chessdata[2][1] = table_140_col2[gamecommon.CommRandInt(table_140_col2,'gailv')].iconId
    end
    --执行结算
    wild90To91(chessdata)
    local mul,addMul,firstIconId = calc(chessdata)
    local disInfo={addMul=addMul,firstIconId=firstIconId,chessdata=chessdata}
    return disInfo,mul,1
end
function wild90To91(chessdata)
    if chessdata[1][1]==90 then
        chessdata[1][1]=91
    end
    if chessdata[3][1]==90 then
        chessdata[3][1]=91
    end
end


--执行结算
function calc(chessdata)
    local wildMap={
        [91] = 1,
        [92] = 1,
        [93] = 1,
        [94] = 1,
    }
    local firstIconId = -1
    local wildNum = 0
    local tmpIconMap={
        [1]=1,
        [2]=1,
        [3]=1,
    }
    local isblend = true
    for col=1,3 do
        local iconId = chessdata[col][1]
        if firstIconId==-1 and wildMap[iconId]==nil then
            firstIconId = iconId
        elseif wildMap[iconId]==nil then
            if firstIconId~=iconId then
                firstIconId=-2
            end
        elseif wildMap[iconId]~=nil then
            wildNum=wildNum+1
        end
        if tmpIconMap[iconId]==nil and wildMap[iconId]==nil then
            isblend=false
        end
    end
    local  mul = 0
    local  addMul = 1
    if wildNum>=3 then
        --启用wild 倍数
        firstIconId = 90
        mul = table_140_paytable[firstIconId].c3
    elseif firstIconId>0 then
        mul = table_140_paytable[firstIconId].c3
    elseif isblend then
        firstIconId=0
        mul = table_140_paytable[firstIconId].c3
    end
    if mul>0 and firstIconId~=90 and wildMap[chessdata[2][1]]~=nil then
        --判断棋盘是否有wild 需要翻倍
        local twoIconId = chessdata[2][1]
        for _, value in ipairs(table_140_col2) do
            if value.iconId==twoIconId then
                addMul = value.mul
                break
            end
        end
    end
    mul = mul * addMul
    return mul,addMul,firstIconId
end