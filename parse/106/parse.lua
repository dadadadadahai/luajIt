--分析函数
Const_status ={
    Normal = 1,
    Free = 2,
    Bonus = 3,
    Pick = 4,
}
local chip = gamecommon.GetBetConfig(GameType,mariachi.LineNum)[1]
local tChip = chip * mariachi.LineNum
local status = Const_status.Normal
local lastStatus=Const_status.Normal
local iconmaps={}       --中奖图标倍数统计
local tWinScore = 0     --本次中奖倍数
local winMul = {}       --赢取倍数统计
local sessionMap={}     --各个场景统计{triggerNum,winScore}
sessionMap[Const_status.Normal]={triggerNum=0,winScore =0}
sessionMap[Const_status.Free]={triggerNum=0,winScore =0}
sessionMap[Const_status.Bonus]={triggerNum=0,winScore =0}
sessionMap[Const_status.Pick] = {triggerNum=0,winScore =0}
function BackFunction(data)
    StatisticswinMul(data)          --统计爆奖倍数
    local features = data.features
    if table.empty(features.bonus)==false then
        if status~=Const_status.Bonus then
            --必然是首次触发
            if status==Const_status.Normal then
                StatisticsIcons(data)
                sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
                sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
            end
            lastStatus=status
            status = Const_status.Bonus
            sessionMap[Const_status.Bonus] = sessionMap[Const_status.Bonus] or {triggerNum = 0,winScore=0}
            sessionMap[Const_status.Bonus].triggerNum = sessionMap[Const_status.Bonus].triggerNum + 1
        end
        local bonus = features.bonus
        if bonus.lackTimes<=0 then
            --free结束
            if table.empty(features.free)==false and features.free.lackTimes<=0 then
                status = Const_status.Normal
            else
                status =lastStatus
            end
            sessionMap[Const_status.Bonus].winScore = sessionMap[Const_status.Bonus].winScore + bonus.tWinScore
        end
    elseif table.empty(features.free)==false then
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
    if status==Const_status.Normal and (table.empty(features.free)==false or table.empty(features.bonus)==false or table.empty(features.pick)==false ) then
        tWinScore = data.winScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        if tWinScore/tChip>30 then
            print('Normal Pass')
        end
        tWinScore = 0
    elseif table.empty(features.bonus)==false and features.bonus.lackTimes<=0 then
        tWinScore = features.bonus.tWinScore
        if table.empty(features.free) then
            winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
            winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
            -- print('tChip',tChip)
            if tWinScore/tChip>30 then
                print('bonus Pass')
            end
            tWinScore = 0
        elseif table.empty(features.free)==false and features.free.lackTimes<=0 then
            tWinScore = features.free.tWinScore
            winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
            winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
            if tWinScore/tChip>30 then
                print('free Pass')
            end
            tWinScore = 0
        end
    elseif table.empty(features.free)==false and features.free.lackTimes<=0 and table.empty(features.bonus) then
        tWinScore = features.free.tWinScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        if tWinScore/tChip>30 then
            print('free1 Pass',tWinScore,tChip)
            -- IsBreak=true
        end
        tWinScore = 0
    elseif table.empty(features.free) and table.empty(features.bonus) then
        --普通模式
        winMul[data.winScore/tChip] = winMul[data.winScore/tChip] or 0
        winMul[data.winScore/tChip] = winMul[data.winScore/tChip] + 1
        if data.winScore/tChip>30 then
            print('Normal1 Pass',data.winScore)
            -- IsBreak=true
        end
        tWinScore = 0
    end
end
--统计图标中奖率
function StatisticsIcons(data)
    for _, value in ipairs(data.winLines[1]) do
        local iconid = value[4]
        if iconid>=90 and iconid<=99 then
            iconid = 90
        end
        iconmaps[iconid] = iconmaps[iconid] or {}
        iconmaps[iconid][value[2]] = iconmaps[iconid][value[2]] or 0
        iconmaps[iconid][value[2]] = iconmaps[iconid][value[2]] + 1
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
	print('tval='..tval..',tmulwinscore='..tMul*chip*mariachi.LineNum)
end