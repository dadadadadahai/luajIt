--分析函数
Const_status = {
    Normal = 1,
    Free = 2,
    Bonus = 3,
}
local chip = gamecommon.GetBetConfig(1, cleopatraNew.LineNum)[1]
local winMul = {} --赢取倍数统计
local tBet = 0
local curNoWin = 0
local tWinScore = 0     --本次中奖倍数
local tChip = chip * cleopatraNew.LineNum
local maxNoWin = 0
local iconmaps = {} --中奖图标倍数统计
local sessionMap = {} --各个场景统计{triggerNum,winScore}
local status = Const_status.Normal
sessionMap[Const_status.Normal] = { triggerNum = 0, winScore = 0 }
sessionMap[Const_status.Free] = { triggerNum = 0, winScore = 0 }
sessionMap[Const_status.Bonus] = { triggerNum = 0, winScore = 0 }
function BackFunction(data)
    StatisticswinMul(data)          --统计爆奖倍数
    local features = data.features
    if table.empty(features.free) == false then
        --免费
        if status ~= Const_status.Free then
            -- StatisticsIcons(data)
            sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
            sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore
            --必然是首次触发
            status = Const_status.Free
            sessionMap[Const_status.Free] = sessionMap[Const_status.Free] or { triggerNum = 0, winScore = 0 }
            sessionMap[Const_status.Free].triggerNum = sessionMap[Const_status.Free].triggerNum + 1
        end
        local free = features.free
        if free.lackTimes <= 0 then
            --free结束
            status = Const_status.Normal
            sessionMap[Const_status.Free].winScore = sessionMap[Const_status.Free].winScore + free.tWinScore
        end
    else
        status = Const_status.Normal
        local winScore = data.winScore
        local tchip = data.payScore
        -- winMul[winScore / tchip] = winMul[winScore / tchip] or 0
        -- winMul[winScore / tchip] = winMul[winScore / tchip] + 1
        if winScore == 0 then
            curNoWin = curNoWin + 1
        else
            if maxNoWin < curNoWin then
                maxNoWin = curNoWin
            end
            curNoWin = 0
        end
        sessionMap[1].triggerNum = sessionMap[1].triggerNum + 1
        sessionMap[1].winScore = sessionMap[1].winScore + winScore
        tBet  =tBet + tchip
    end
    --统计图标
    local disInfo = data.extraData.disInfo
    for index, value in ipairs(disInfo) do
        local info = value.info
        for _, infoItem in ipairs(info) do
            -- print('info info info info info info info info',infoItem.iconid,infoItem.val,infoItem.mul,infoItem.valMul)
            iconmaps[infoItem.iconid] = iconmaps[infoItem.iconid] or {}
            iconmaps[infoItem.iconid][infoItem.val] = iconmaps[infoItem.iconid][infoItem.val] or 0
            iconmaps[infoItem.iconid][infoItem.val] = iconmaps[infoItem.iconid][infoItem.val] + 1
        end
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
--------------------------------------------------------------------
function OverShow()
    --结束显示
    local tMul = 0
    local tval = 0
    -- local num = 0
    -- local tableList = ""
    for key, value in pairs(winMul) do
        -- num = num + 1
        -- tableList = tableList..key..'='..value..'         '
        -- if num == 5 then
        --     print(tableList)
        --     tableList = ""
        --     num = 0
        -- end
        print(key .. '=' .. value)
        tMul = tMul + key * value
        tval = tval + value
    end
    print('-------------------------------------------------')
    print('Normal:trigger=' ..
    sessionMap[1].triggerNum ..
    ',winScore=' .. sessionMap[1].winScore ..
    ',tBet=' .. tBet .. ',rtp=' .. sessionMap[1].winScore / tBet .. ',maxNoWin=' .. maxNoWin)
    print('Free:trigger='..sessionMap[Const_status.Free].triggerNum..',winScore='..sessionMap[Const_status.Free].winScore)
    print('-------------------------------------------------')
    local iconNum = { 5, 6, 7, 8, 11, 14, 17, 21 }
    local val = 0
    for i = 1, 10 do
        local str = 'iconid:' .. i .. ','
        local obj = iconmaps[i]
        for j = 1, #iconNum do
            if obj == nil then
                str = str .. 'mul=' .. iconNum[j] .. ',val=0' .. '|'
            else
                if obj[iconNum[j]] == nil then
                    str = str .. 'mul=' .. iconNum[j] .. ',val=0' .. '|'
                else
                    val = val + obj[iconNum[j]]
                    str = str .. 'mul=' .. iconNum[j] .. ',val=' .. obj[iconNum[j]] .. '|'
                end
            end
        end
        print(str)
    end
    -- for key, value in pairs(iconmaps) do
    --     local str='iconid:'..key..','
    --     for k, v in pairs(value) do
    --         str =str..'mul='..k..',val='..v..'|'
    --     end
    --     print(str)
    -- end
    local mulWinScore = tMul * chip
    print('tval=' .. tval .. ',tmul=' .. tMul .. ',mulWinScore=' .. mulWinScore .. ',val=' .. val)
    -- print('FreeTwinScore',cleopatraNew.FreeTwinScore)
end
