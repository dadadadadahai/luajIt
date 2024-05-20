--分析函数
Const_status ={
    Normal = 1,
    Free = 2,
}
local chip = gamecommon.GetBetConfig(1,20)[1]
local status = Const_status.Normal
local lastStatus=Const_status.Normal
local iconmaps={}       --中奖图标倍数统计
local tWinScore = 0     --本次中奖倍数
local tBet = 0
local winMul = {}       --赢取倍数统计
local sessionMap={}     --各个场景统计{triggerNum,winScore}
local freeNum = 0
local TriggerNormalScore=  0        --触发收集时普通棋盘的中奖值
sessionMap[Const_status.Normal]={triggerNum=0,winScore =0}
sessionMap[Const_status.Free]={triggerNum=0,winScore =0}
function BackFunction(data)
    local winScore =0
    local tchip = data.payScore
    if table.empty(data.features.free)==false then
        --免费
        if status~=Const_status.Free then
            sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
            sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
            --必然是首次触发
            status = Const_status.Free
            sessionMap[Const_status.Free] = sessionMap[Const_status.Free] or {triggerNum=0,winScore =0}
            sessionMap[Const_status.Free].triggerNum = sessionMap[Const_status.Free].triggerNum + 1
        end
        local free = data.features.free
        if free.lackTimes<=0 then
            --free结束
            status = Const_status.Normal
            sessionMap[Const_status.Free].winScore = sessionMap[Const_status.Free].winScore + free.tWinScore
            -- 免费结算
            tWinScore = tWinScore + data.features.free.tWinScore
            winMul[tWinScore/tchip] = winMul[tWinScore/tchip] or 0
            winMul[tWinScore/tchip] = winMul[tWinScore/tchip] + 1
            tWinScore = 0
        end
        disInfoAna(data)
    else
        winScore = data.winScore        
        sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
        sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + winScore
        status = Const_status.Normal
        disInfoAna(data)
        winMul[winScore/tchip] = winMul[winScore/tchip] or 0
        winMul[winScore/tchip] = winMul[winScore/tchip] + 1
    end
end
function disInfoAna(data)
    --统计图标
    local disInfo = data.extraData.disInfo
    for index, value in ipairs(disInfo) do
        local info = value.infos
        for _, infoItem in ipairs(info) do
            -- print('info info info info info info info info',infoItem.iconid,infoItem.val,infoItem.mul,infoItem.valMul)
            iconmaps[infoItem.iconId] = iconmaps[infoItem.iconId] or {}
            iconmaps[infoItem.iconId][infoItem.val] = iconmaps[infoItem.iconId][infoItem.val] or 0
            iconmaps[infoItem.iconId][infoItem.val] = iconmaps[infoItem.iconId][infoItem.val] + 1
        end
    end
end
function IsNormal()
    return status==Const_status.Normal
end
----------------------------------------
function OverShow()
    local winscore = 0
    local tvalue = 0
    for key, value in pairs(winMul) do
        print(key..'='..value)
        tvalue = tvalue + value
        winscore = winscore+key*value*30
    end
    print('-------------------------------------------------')
    print('Normal:trigger='..sessionMap[Const_status.Normal].triggerNum..',winScore='..sessionMap[Const_status.Normal].winScore)
    print('Free:trigger='..sessionMap[Const_status.Free].triggerNum..',winScore='..sessionMap[Const_status.Free].winScore)
    -- print('Bonus1:trigger='..sessionMap[2].triggerNum..',winScore='..sessionMap[2].winScore)
    -- print('Bonus2:trigger='..sessionMap[3].triggerNum..',winScore='..sessionMap[3].winScore)
    -- print('Bonus3:trigger='..sessionMap[4].triggerNum..',winScore='..sessionMap[4].winScore)
    -- print('Bonus4:trigger='..sessionMap[5].triggerNum..',winScore='..sessionMap[5].winScore)
    -- print('Bonus5:trigger='..sessionMap[6].triggerNum..',winScore='..sessionMap[6].winScore)
    print('-------------------------------------------------')
    local iconNum = {5,6,7,8,9,12,15,20,25}
    local val = 0
    for i=1,7 do
        local str='iconid:'..i..','
        local obj = iconmaps[i]
        for j=1,#iconNum do
            if obj==nil then
                str=str..'mul='..iconNum[j]..',val=0'..'|'
            else
                if obj[iconNum[j]]==nil then
                    str=str..'mul='..iconNum[j]..',val=0'..'|'
                else
                    val = val + obj[iconNum[j]]
                    str=str..'mul='..iconNum[j]..',val='..obj[iconNum[j]]..'|'
                end
            end
        end
        print(str)
    end
    -- local awinScore = 0
    -- for _, value in pairs(sessionMap) do
    --     awinScore = awinScore + value.winScore
    -- end
    print('tvalue=',tvalue)
end

