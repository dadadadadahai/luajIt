--分析函数
Const_status ={
    Normal = 1,
    Free = 2,
    Respin = 3,
    Collect = 4,
}
local chip = gamecommon.GetBetConfig(1,10)[1]
local tChip = chip * 10
local status = Const_status.Normal
local lastStatus=Const_status.Normal
local iconmaps={}       --中奖图标倍数统计
local tWinScore = 0     --本次中奖倍数
local winMul = {}       --赢取倍数统计
local sessionMap={}     --各个场景统计{triggerNum,winScore}
local freeNum = 0
sessionMap[Const_status.Normal]={triggerNum=0,winScore =0}
sessionMap[Const_status.Free]={triggerNum=0,winScore =0,collect = {}}
sessionMap[Const_status.Respin]={triggerNum=0,winScore =0}
sessionMap[Const_status.Collect]={triggerNum=0,winScore =0}
function BackFunction(data)
    StatisticswinMul(data)          --统计爆奖倍数
    local features = data.features
    if table.empty(features.respin)==false then
        if status~=Const_status.Respin then
            --必然是首次触发
            StatisticsIcons(data)
            sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
            sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
            lastStatus=status
            status = Const_status.Respin
            sessionMap[Const_status.Respin] = sessionMap[Const_status.Respin] or {triggerNum = 0,winScore=0}
            sessionMap[Const_status.Respin].triggerNum = sessionMap[Const_status.Respin].triggerNum + 1
        end
        local respin = features.respin
        if respin.lackTimes<=0 then
            --free结束
            status =lastStatus
            sessionMap[Const_status.Respin].winScore = sessionMap[Const_status.Respin].winScore + respin.tWinScore
        end
    elseif table.empty(features.free)==false then
        --免费
        if status~=Const_status.Free then
            StatisticsIcons(data)
            sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
            sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
            --必然是首次触发
            status = Const_status.Free
            sessionMap[Const_status.Free] = sessionMap[Const_status.Free] or {triggerNum=0,winScore =0,collect = {}}
            sessionMap[Const_status.Free].triggerNum = sessionMap[Const_status.Free].triggerNum + 1
        end
        local free = features.free
        for iconId, collectInfo in pairs(data.collect) do
            sessionMap[Const_status.Free].collect[iconId] = sessionMap[Const_status.Free].collect[iconId] or {}
            sessionMap[Const_status.Free].collect[iconId].collectNum = sessionMap[Const_status.Free].collect[iconId].collectNum or 0
            sessionMap[Const_status.Free].collect[iconId].score = sessionMap[Const_status.Free].collect[iconId].score or 0
            sessionMap[Const_status.Free].collect[iconId].collectNum = sessionMap[Const_status.Free].collect[iconId].collectNum + collectInfo.collectNum
            sessionMap[Const_status.Free].collect[iconId].score = sessionMap[Const_status.Free].collect[iconId].score + collectInfo.score
        end
        if free.freeEndFlag == true then
            --free结束
            status = Const_status.Normal
            sessionMap[Const_status.Free].winScore = sessionMap[Const_status.Free].winScore + free.tWinScore
        end
        -- -- 如果中Bow
        -- if table.empty(features.collect)==false then
        --     -- sessionMap[Const_status.Collect] = sessionMap[Const_status.Collect] or {triggerNum = 0,winScore=0}
        --     sessionMap[Const_status.Collect].winScore = sessionMap[Const_status.Collect].winScore + features.collect.tWinScore
        --     sessionMap[Const_status.Collect].triggerNum = sessionMap[Const_status.Collect].triggerNum + 1
        -- end
    else
        --普通
        status = Const_status.Normal
        StatisticsIcons(data)
        sessionMap[Const_status.Normal] = sessionMap[Const_status.Normal] or {triggerNum=0,winScore =0}
        sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
        sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
        -- 如果中Bow
        if table.empty(features.collect)==false then
            -- sessionMap[Const_status.Collect] = sessionMap[Const_status.Collect] or {triggerNum = 0,winScore=0}
            sessionMap[Const_status.Collect].winScore = sessionMap[Const_status.Collect].winScore + features.collect.tWinScore
            sessionMap[Const_status.Collect].triggerNum = sessionMap[Const_status.Collect].triggerNum + 1
        end
    end
end
function IsNormal()
    return status==Const_status.Normal
end
--统计中奖倍数
function StatisticswinMul(data)
    local features = data.features
    if status==Const_status.Normal and(table.empty(features.free)==false or table.empty(features.respin)==false) then
        tWinScore = data.winScore
    elseif table.empty(features.free)==false and features.free.freeEndFlag == true then
        -- 免费结算
        tWinScore = tWinScore + features.free.tWinScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        tWinScore = 0
    elseif table.empty(features.respin) and table.empty(features.free) and table.empty(features.collect) then
        tWinScore = data.winScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        tWinScore = 0
    end
    if table.empty(features.free) and table.empty(features.respin) == false then
        tWinScore = tWinScore + data.features.respin.tWinScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        tWinScore = 0
    end
    if table.empty(features.free) == false and features.free.lackTimes < features.free.totalTimes then
        freeNum = freeNum + 1
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
    print('FreeNum: '..freeNum)
    -- print('freeRealNum:'..chilli.FreeWinScore)
    print('-------------------------------------------------')
    if sessionMap[Const_status.Free].collect ~= nil then
        for iconId = 6, 9 do
            if sessionMap[Const_status.Free].collect[iconId] ~= nil then
                local collectInfo = sessionMap[Const_status.Free].collect[iconId]
                print('iconId = '..iconId..','..'collectNum = '..collectInfo.collectNum..','..'score = '..collectInfo.score)
            end
        end
    end
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

