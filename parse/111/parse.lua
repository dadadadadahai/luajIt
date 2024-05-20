--分析函数
Const_status ={
    Normal = 1,
    Free = 2,
    Bonus = 3,
}
local chip = 2
local tChip = chip * 30
local status = Const_status.Normal
local lastStatus=Const_status.Normal
local iconmaps={}       --中奖图标倍数统计
local tWinScore = 0     --本次中奖倍数
local winMul = {}       --赢取倍数统计
local sessionMap={}     --各个场景统计{triggerNum,winScore}
local freeNum = 0       --免费游戏游玩次数
sessionMap[Const_status.Normal]={triggerNum=0,winScore =0}
sessionMap[Const_status.Free]={triggerNum=0,winScore =0}
sessionMap[Const_status.Bonus]={triggerNum=0,winScore =0}
function BackFunction(data)
    -- print(table2json(data))
    StatisticswinMul(data)          --统计爆奖倍数
    local features = data.features
    if table.empty(features.bonus)==false then
        if status~=Const_status.Bonus then
            --必然是首次触发
            StatisticsIcons(data)
            sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
            sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
            lastStatus=status
            status = Const_status.Bonus
            sessionMap[Const_status.Bonus] = sessionMap[Const_status.Bonus] or {triggerNum = 0,winScore=0}
            sessionMap[Const_status.Bonus].triggerNum = sessionMap[Const_status.Bonus].triggerNum + 1
        end
        local bonus = features.bonus
        if bonus.lackTimes<=0 then
            --free结束
            status =lastStatus
            sessionMap[Const_status.Bonus].winScore = sessionMap[Const_status.Bonus].winScore + bonus.tWinScore
        end
    elseif table.empty(features.free)==false then
        if features.free.lackTimes < features.free.totalTimes then
            freeNum = freeNum + 1
        end
        --免费
        if status~=Const_status.Free then
            StatisticsIcons(data)
            sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
            sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
            --必然是首次触发
            status = Const_status.Free
            sessionMap[Const_status.Free] = sessionMap[Const_status.Free] or {triggerNum = 0,winScore=0}
            sessionMap[Const_status.Free].triggerNum = sessionMap[Const_status.Free].triggerNum + 1
        end
        local free = features.free
        if free.lackTimes<=0 then
            --free结束
            status = Const_status.Normal
            sessionMap[Const_status.Free].winScore = sessionMap[Const_status.Free].winScore + free.tWinScore
        end
    else
        --普通
        status = Const_status.Normal
        StatisticsIcons(data)
        sessionMap[Const_status.Normal] = sessionMap[Const_status.Normal] or {triggerNum = 0,winScore=0}
        sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
        sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
    end
end
function IsNormal()
    return status==Const_status.Normal
end
--统计中奖倍数
function StatisticswinMul(data)
    local features = data.features
    if status==Const_status.Normal and(table.empty(features.free)==false or table.empty(features.bonus)==false) then
        tWinScore = data.winScore
    elseif table.empty(features.bonus)==false and features.bonus.lackTimes<=0 then
        if table.empty(features.free)==false and features.free.lackTimes<=0 then
            tWinScore = tWinScore + features.free.tWinScore
        else
            tWinScore = tWinScore + features.bonus.tWinScore
        end
        if table.empty(features.free) or (table.empty(features.free)==false and features.free.lackTimes<=0) then
            --计算倍数
            winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
            winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
            tWinScore = 0
        end
    elseif table.empty(features.free)==false and features.free.lackTimes<=0 then
        tWinScore = tWinScore + features.free.tWinScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        tWinScore = 0
    elseif table.empty(features.bonus) and table.empty(features.free) then
        tWinScore = data.winScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        tWinScore = 0
    end
end
--统计图标中奖率
function StatisticsIcons(data)
    for _, value in ipairs(data.winlines[1]) do
        iconmaps[value[4]] = iconmaps[value[4]] or {}
        iconmaps[value[4]][value[2]] = iconmaps[value[4]][value[2]] or 0
        iconmaps[value[4]][value[2]] = iconmaps[value[4]][value[2]] + 1
    end
end



----------------------------------------
function OverShow()
    --结束显示
    local tMul = 0
    local tval = 0
    for key, value in pairs(winMul) do
        print(key..'='..value)
        tMul = tMul + key*value
        tval = tval + value
    end
    print('-------------------------------------------------')
    print('Normal:trigger='..sessionMap[Const_status.Normal].triggerNum..',winScore='..sessionMap[Const_status.Normal].winScore)
    print('Free:trigger='..sessionMap[Const_status.Free].triggerNum..',winScore='..sessionMap[Const_status.Free].winScore)
    print('Bonus:trigger='..sessionMap[Const_status.Bonus].triggerNum..',winScore='..sessionMap[Const_status.Bonus].winScore)
    print('AllFreeNum:'..freeNum)

    local tWinScore = sessionMap[Const_status.Normal].winScore + sessionMap[Const_status.Free].winScore + sessionMap[Const_status.Bonus].winScore

    print(' rtp = '..tWinScore / (sessionMap[Const_status.Normal].triggerNum * 0.6))

    print('-------------------------------------------------')
    for key, value in pairs(iconmaps) do
        local str='iconid:'..key..','
        for i=3,5 do
            local val = 0
            if value[i]~=nil then
                val = value[i]
            end
            str=str..'mul='..i..',val='..val..','
        end
        print(str)
    end
	print('tval='..tval..',tmulscore='..tMul*tChip)
end
