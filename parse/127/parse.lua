--分析函数
Const_status ={
    Normal = 1,
    Free = 2,
    Respin = 3,
    Collect = 4,
    TenMul = 5,
}
local chip = gamecommon.GetBetConfig(1,10)[1]
local tChip = chip * 10
local status = Const_status.Normal
local lastStatus=Const_status.Normal
local iconmaps={}       --中奖图标倍数统计
local tWinScore = 0     --本次中奖倍数
local winMul = {}       --赢取倍数统计
local freeWinScores = {}     --免费游戏次数
local sessionMap={}     --各个场景统计{triggerNum,winScore}
local normalNum = 0
local respinNum = 0
local bigWinIcon = 0
sessionMap[Const_status.Normal]={triggerNum=0,winScore =0,winScoreB = 0}
sessionMap[Const_status.Free]={triggerNum=0,winScore =0,winScoreB = 0,wildNum = 0}
sessionMap[Const_status.Respin]={triggerNum=0,winScore =0}
sessionMap[Const_status.TenMul]={triggerNum=0,winScore =0}
sessionMap[Const_status.Collect]={triggerNum=0,winScore =0}
function BackFunction(data)
    StatisticswinMul(data)          --统计爆奖倍数
    local features = data.features
    if table.empty(features.respin)==false then
        if status~=Const_status.Respin then
            --必然是首次触发
            -- StatisticsIcons(data)
            -- sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
            -- sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
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
    else
        --普通
        status = Const_status.Normal
        StatisticsIcons(data)
        if data.bigWinIcon > 0 then
            sessionMap[Const_status.TenMul] = sessionMap[Const_status.TenMul] or {triggerNum=0,winScore =0}
            sessionMap[Const_status.TenMul].triggerNum = sessionMap[Const_status.TenMul].triggerNum + 1
            sessionMap[Const_status.TenMul].winScore = sessionMap[Const_status.TenMul].winScore + data.winScore
        else
            sessionMap[Const_status.Normal] = sessionMap[Const_status.Normal] or {triggerNum=0,winScore =0,winScoreB = 0}
            sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
            sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
        end
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
    if table.empty(features.respin) then
        tWinScore = data.winScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        tWinScore = 0
        normalNum = normalNum + 1
    end
    if table.empty(features.respin) == false and features.respin.lackTimes <= 0 then
        tWinScore = tWinScore + data.features.respin.tWinScore
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
        winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
        tWinScore = 0
        respinNum = respinNum + 1
    end
    -- 统计十倍图标个数
    if data.bigWinIcon ~= nil and data.bigWinIcon >= 0 then
        bigWinIcon = bigWinIcon + 1
        -- if bigWinIcons[data.bigWinIcon] == nil then
        --     bigWinIcons[data.bigWinIcon] = 0
        -- end
        -- bigWinIcons[data.bigWinIcon] = bigWinIcons[data.bigWinIcon] + 1
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
    print('Respin:trigger='..sessionMap[Const_status.Respin].triggerNum..',winScore='..sessionMap[Const_status.Respin].winScore)
    print('TenMul:trigger='..sessionMap[Const_status.TenMul].triggerNum..',winScore='..sessionMap[Const_status.TenMul].winScore)
    -- print('Free:trigger='..sessionMap[Const_status.Free].triggerNum..',winScore='..sessionMap[Const_status.Free].winScore)
    print('NormalNum: '..normalNum)
    print('RespinNum: '..respinNum)
    print('bigWinIcon = '..bigWinIcon)
    print('-------------------------------------------------')
    for key, value in pairs(freeWinScores) do
        print(key..'='..value)
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
