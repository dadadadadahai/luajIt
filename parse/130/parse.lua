--分析函数
Const_status ={
    Normal = 1,
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
sessionMap[Const_status.Normal]={triggerNum=0,winScore =0,winScoreB = 0}
function BackFunction(data)
    StatisticswinMul(data)          --统计爆奖倍数
    local features = data.features
    --普通
    status = Const_status.Normal
    StatisticsIcons(data)
    sessionMap[Const_status.Normal] = sessionMap[Const_status.Normal] or {triggerNum=0,winScore =0,winScoreB = 0}
    sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
    sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
end
function IsNormal()
    return status==Const_status.Normal
end
--统计中奖倍数
function StatisticswinMul(data)
    tWinScore = data.winScore
    winMul[tWinScore/tChip] = winMul[tWinScore/tChip] or 0
    winMul[tWinScore/tChip] = winMul[tWinScore/tChip] + 1
    tWinScore = 0
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
