module('cashwheel', package.seeall)

local betconfig = {
    [1] = 100,
    [3] = 500,
    [6] = 1000,
    [9] = 5000,
    [12] = 10000
}
local betMoney = 0
local imageType = 3


function StartToImagePool()
    betMoney = betconfig[imageType]
    local resImageType = imageType
    local dis={}
    local mul = 0
    local winScore,chessdata,specialIconId = rotateOnce(resImageType, false)
    table.insert(dis,{chessdata=chessdata,winScore=winScore,specialIconId=specialIconId,type=1})
    local tWinScore = winScore
    --免费转一次
    if specialIconId==80 then
        local winScore,chessdata,specialIconId = rotateOnce(imageType, true)
        resImageType=imageType+1
        table.insert(dis,{chessdata=chessdata,winScore=winScore,specialIconId=specialIconId,type=2})
        tWinScore = tWinScore+winScore
    elseif specialIconId==70 or specialIconId==71 then
        --触发特殊玩法
        local indexVal = getIndex(imageType)
        local winScore = table_151_trunctable[gamecommon.CommRandInt(table_151_trunctable,'t'..indexVal..'gailv')]['t'..indexVal..'money']
        resImageType = imageType+2
        table.insert(dis,{winScore=winScore,type=3})
        tWinScore=tWinScore+winScore
    end
    mul = tWinScore/betMoney
    return dis,mul,resImageType
end

function rotateOnce(imageType, isfree)
    --生成棋盘
    local spin = getSpin(imageType, isfree)
    local cols = { 1, 1, 1 }
    local chessdata = gamecommon.CreateSpecialChessData(cols, spin)
    --取特殊
    local indexVal = getIndex(imageType)
    local specialIconId = 0
    if isfree==false then
        specialIconId = table_151_special[gamecommon.CommRandInt(table_151_special, 'gailv' .. indexVal)].iconId
    end
    --计算普通中奖
    local winScore = calcNormalScore(chessdata, imageType)
    local sMul = specialMul(specialIconId)
    winScore = winScore * sMul
    return winScore,chessdata,specialIconId
end

--倍数判定
function specialMul(specialIconId)
    local mul = 1
    if specialIconId == 100 then
        mul = 2
    elseif specialIconId == 101 then
        mul = 5
    elseif specialIconId == 102 then
        mul = 10
    end
    return mul
end

function calcNormalScore(chessdata, imageType)
    local chessstr = ''
    local maxNum = 3
    if imageType == 1 then
        maxNum = 2
    end
    for col = 1, maxNum do
        local iconId = chessdata[col][1]
        local str = ''
        if iconId == 1 then
            str = '0'
        elseif iconId == 2 then
            str = '00'
        elseif iconId == 3 then
            str = '1'
        elseif iconId == 4 then
            str = '5'
        elseif iconId == 5 then
            str = '10'
        end
        chessstr = chessstr .. str
    end
    local winScore = tonumber(chessstr)
    if chessstr==''then
        winScore = 0
    end
    return winScore*100
end

function getIndex(imageType)
    local index = 1
    if imageType == 1 then
        index = 1
    elseif imageType == 3 then
        index = 2
    elseif imageType == 6 then
        index = 3
    elseif imageType == 9 then
        index = 4
    elseif imageType == 12 then
        index = 5
    end
    return index
end

--返回spin表
function getSpin(imageType, isfree)
    local index = getIndex(imageType)
    if isfree then
        return cashwheel['table_151_free_' .. index]
    else
        return cashwheel['table_151_normalspin_' .. index]
    end
end
