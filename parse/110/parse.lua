local chip = 50
local winMul = {}       --赢取倍数统计
local sessionMap = {}
local tBet = 0
local curNoWin = 0
local maxNoWin =  0
sessionMap[1] = {triggerNum=0,winScore =0}
local iconmaps={}       --中奖图标倍数统计
function BackFunction(data)
    local winScore = data.winScore
    local tchip = data.payScore
    winMul[winScore/tchip] = winMul[winScore/tchip] or 0
    winMul[winScore/tchip] = winMul[winScore/tchip] + 1
    if winScore==0 then
        curNoWin = curNoWin + 1
    else
        if maxNoWin<curNoWin then
            maxNoWin = curNoWin
        end
        curNoWin = 0
    end
    sessionMap[1].triggerNum = sessionMap[1].triggerNum + 1
    sessionMap[1].winScore = sessionMap[1].winScore + winScore
    tBet  =tBet + tchip
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
    return true
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
        print(key..'='..value)
        tMul = tMul + key*value
        tval = tval + value
    end
    print('-------------------------------------------------')
    print('Normal:trigger='..sessionMap[1].triggerNum..',winScore='..sessionMap[1].winScore..',tBet='..tBet..',rtp='..sessionMap[1].winScore/tBet..',maxNoWin='..maxNoWin)
    print('-------------------------------------------------')
    local iconNum = {5,6,7,8,11,14,17,21}
    local val = 0
    for i=1,10 do
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
    -- for key, value in pairs(iconmaps) do
    --     local str='iconid:'..key..','
    --     for k, v in pairs(value) do
    --         str =str..'mul='..k..',val='..v..'|'
    --     end
    --     print(str)
    -- end
    local mulWinScore = tMul*chip
	print('tval='..tval..',tmul='..tMul..',mulWinScore='..mulWinScore..',val='..val)
end