--分析函数
Const_status = {
    Normal = 1,
    UIcon = 2,
}
local chip = gamecommon.GetBetConfig(1, cash.LineNum)[1]
local tChip = chip * cash.LineNum
local status = Const_status.Normal
local lastStatus = Const_status.Normal
local iconmaps = {} --中奖图标倍数统计
local tWinScore = 0 --本次中奖倍数
local winMul = {} --赢取倍数统计
local sessionMap = {} --各个场景统计{triggerNum,winScore}
sessionMap[Const_status.Normal] = { triggerNum = 0, winScore = 0 }
sessionMap[Const_status.UIcon] = { triggerNum = 0, winScore = 0,lockNum=0 }
local startJMap={}
local isInLock=false
local uIconLockC=0
local uIconLockNumMap={}
local unLockNumMap={}       --不中的次数
local tmpunlock= 0 
function BackFunction(data)
    local unum = 0
    --分析棋盘
    local chessdata = data.boards[1]
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            if chessdata[col][row]==100 then
                unum = unum + 1
            end
        end
    end
    StatisticswinMul(data) --统计爆奖倍数
    --普通
    status = Const_status.Normal
    local zmul = data.extraData.zmul
    
    StatisticsIcons(data)
    sessionMap[Const_status.Normal].triggerNum = sessionMap[Const_status.Normal].triggerNum + 1
    sessionMap[Const_status.Normal].winScore = sessionMap[Const_status.Normal].winScore + data.winScore-zmul*tChip
    if zmul>0 then
        sessionMap[Const_status.UIcon].winScore = sessionMap[Const_status.UIcon].winScore + zmul*tChip
        sessionMap[Const_status.UIcon].lockNum = sessionMap[Const_status.UIcon].lockNum + 1
        isInLock = false
        uIconLockC = uIconLockC + 1
        uIconLockNumMap[uIconLockC] = uIconLockNumMap[uIconLockC] or 0
        uIconLockNumMap[uIconLockC] = uIconLockNumMap[uIconLockC] + 1
        uIconLockC = 0
    elseif isInLock then
        uIconLockC = uIconLockC + 1
        uIconLockNumMap[uIconLockC] = uIconLockNumMap[uIconLockC] or 0
        uIconLockNumMap[uIconLockC] = uIconLockNumMap[uIconLockC] + 1
    end
    if unum>=3 then
        if isInLock==false and zmul>0 then
            --计算那次
            -- startJMap[unum] = startJMap[unum] or 0
            -- startJMap[unum] = startJMap[unum] + 1
        elseif isInLock==false and zmul==0 then
            --触发的时候
            startJMap[unum] = startJMap[unum] or 0
            startJMap[unum] = startJMap[unum] + 1
            isInLock=true
            sessionMap[Const_status.UIcon].triggerNum = sessionMap[Const_status.UIcon].triggerNum + 1
        elseif zmul==0 and isInLock then
            --连续锁定的情况
            sessionMap[Const_status.UIcon].lockNum = sessionMap[Const_status.UIcon].lockNum + 1
        end
    end
    if zmul==0 and isInLock==false then
        tmpunlock=tmpunlock+1
        unLockNumMap[unum] = unLockNumMap[unum] or 0
        unLockNumMap[unum] = unLockNumMap[unum] + 1
    end
end

function IsNormal()
    return status == Const_status.Normal
end

--统计中奖倍数
function StatisticswinMul(data)
    winMul[data.winScore/tChip] =winMul[data.winScore/tChip] or 0
    winMul[data.winScore/tChip] = winMul[data.winScore/tChip] +1
end

--统计图标中奖率
function StatisticsIcons(data)
    for _, value in ipairs(data.winLines[1]) do
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
        print(key .. '=' .. value)
        tMul = tMul + key * value
        tval = tval + value
    end
    local keyArrays = {}
    for key, value in pairs(startJMap) do
        table.insert(keyArrays,key)
    end
    table.sort(keyArrays,function (a,b)
        return a<b
    end)
    local ustr=''
    for i, v in ipairs(keyArrays) do
        ustr=ustr..string.format('%d=%d',keyArrays[i],startJMap[keyArrays[i]])..','
    end
    keyArrays={}
    for key, value in pairs(uIconLockNumMap) do
        table.insert(keyArrays,key)
    end
    table.sort(keyArrays,function (a,b)
        return a<b
    end)
    local lockstr=''
    for i, v in ipairs(keyArrays) do
        lockstr=lockstr..string.format('%d=%d',keyArrays[i],uIconLockNumMap[keyArrays[i]])..','
    end
    local unlockstr=''
    keyArrays = {}
    for key, value in pairs(unLockNumMap) do
        table.insert(keyArrays,key)
    end
    table.sort(keyArrays,function (a,b)
        return a<b
    end)
    for index, value in ipairs(keyArrays) do
        unlockstr=unlockstr..string.format('%d=%d',keyArrays[index],unLockNumMap[keyArrays[index]])..','
    end
    -- local rtpstr=''
    -- for key, value in pairs(cash.RtpMap) do
    --     rtpstr = rtpstr..string.format('key=%d,num=%d,winscore=%d,',key,value.num,value.winScore)
    -- end
    -- print(rtpstr)
    print('-------------------------------------------------')
    print('unlockstr='..unlockstr)
    print('unumInfo:'..ustr)
    print('lockstr='..lockstr)
    print('-------------------------------------------------')
    print('Normal:trigger='..sessionMap[Const_status.Normal].triggerNum .. ',winScore=' .. sessionMap[Const_status.Normal].winScore)
    print('UIcon:trigger='..sessionMap[Const_status.UIcon].triggerNum .. ',winScore=' .. sessionMap[Const_status.UIcon].winScore..',lockNum='..sessionMap[Const_status.UIcon].lockNum)
    print('-------------------------------------------------')
    for key, value in pairs(iconmaps) do
        local str = 'iconid:' .. key .. ','
        for i = 3, 5 do
            local val = 0
            if value[i] ~= nil then
                val = value[i]
            end
            str = str .. 'mul=' .. i .. ',val=' .. val .. ','
        end
        print(str)
    end
    print('tval=' .. tval .. ',tmulscore=' .. tMul * tChip..',tmpunlock='..tmpunlock)
end
