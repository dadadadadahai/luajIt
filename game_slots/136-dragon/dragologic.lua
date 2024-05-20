module('dragon', package.seeall)
--逻辑旋转模块
function StartToImagePool()
    local cols = { 5, 5, 5, 5, 5 }
    --产生一个棋盘
    local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols,table_136_normalspin_1)
    local dis = chessHandle(chessdata, lastColRow)

    --总消除数量
    local eliinateNum = 0
    local mul = 0
    local lastChessdata = {}

    for index, value in ipairs(dis) do
        lastChessdata = value.chessdata
        local disEliinateNum = calcWildNum(value.eliminateInfo)
        eliinateNum = eliinateNum + disEliinateNum
        for _, val in ipairs(value.eliminateInfo) do
            mul = mul + val.mul
        end
        dis[index].disEliinateNum = disEliinateNum
    end
    --进入判断是否触发特殊
    local saveResult = {
        before = {
            mul = mul,
            dis = dis,
            eliinateNum = eliinateNum
        },
        after = {

        }
    }
    --最后一次的棋盘
    lastChessdata = table.clone(lastChessdata)
    local imageType = 1
    if eliinateNum >= 10 then
        local tmpmul, tmplastChessdata, tmpeliinateNum = sGameHandleCommon(2, lastChessdata,mul,
            saveResult,lastColRow)
        imageType = 2
        eliinateNum = eliinateNum + tmpeliinateNum
        mul = mul + tmpmul
        lastChessdata = tmplastChessdata
    end
    if eliinateNum >= 30 then
        local tmpmul, tmplastChessdata, tmpeliinateNum = sGameHandleCommon(3, lastChessdata,mul, saveResult,lastColRow)
        imageType = 3
        eliinateNum = eliinateNum + tmpeliinateNum
        mul = mul + tmpmul
        lastChessdata = tmplastChessdata
    end
    if eliinateNum >= 50 then
        local tmpmul, tmplastChessdata, tmpeliinateNum = sGameHandleCommon(4, lastChessdata,mul, saveResult,lastColRow)
        imageType = 4
        eliinateNum = eliinateNum + tmpeliinateNum
        mul = mul + tmpmul
        lastChessdata = tmplastChessdata
    end
    if eliinateNum >= 70 then
        local tmpmul, tmplastChessdata, tmpeliinateNum = sGameHandleCommon(5, lastChessdata,mul, saveResult,lastColRow)
        imageType = 5
        eliinateNum = eliinateNum + tmpeliinateNum
        mul = mul + tmpmul
        lastChessdata = tmplastChessdata
    end
    return  saveResult,mul/10,imageType
end



--小游戏组装结构体通用处理
function sGameHandleCommon(imageType, lastChessdata, mul, saveResult,lastColRow)
    local tmpBoards, disAdd, tmpMul, tmpLastChessdata, eliinateNum = {}, {}, 0, {}, 0
    if imageType == 2 then
        --绿龙
        tmpBoards, disAdd, tmpMul, tmpLastChessdata, eliinateNum = green(lastChessdata,lastColRow)
    elseif imageType == 3 then
        --蓝龙处理
        --mul, lastChessdata = dragon2.sGameHandleCommon(2, lastChessdata, boards, mul, saveResult)
        tmpBoards, disAdd, tmpMul, tmpLastChessdata, eliinateNum = blue(lastChessdata,lastColRow)
    elseif imageType == 4 then
        --红龙处理
        --mul, lastChessdata = dragon2.sGameHandleCommon(2, lastChessdata, boards, mul, saveResult)
        --mul, lastChessdata = dragon2.sGameHandleCommon(3, lastChessdata, boards, mul, saveResult)
        tmpBoards, disAdd, tmpMul, tmpLastChessdata, eliinateNum = red(lastChessdata,lastColRow)
    elseif imageType == 5 then
        --mul, lastChessdata = dragon2.sGameHandleCommon(2, lastChessdata, boards, mul, saveResult)
        --mul, lastChessdata = dragon2.sGameHandleCommon(3, lastChessdata, boards, mul, saveResult)
        --mul, lastChessdata = dragon2.sGameHandleCommon(4, lastChessdata, boards, mul, saveResult)
        tmpBoards, disAdd, tmpMul, tmpLastChessdata, eliinateNum = mother(lastChessdata,lastColRow)
    end
    table.insert(saveResult.after, { mul = tmpMul, dis = disAdd,eliinateNum=eliinateNum })
    lastChessdata = tmpLastChessdata
    return tmpMul, lastChessdata, eliinateNum
end