module('gamecommon',package.seeall)
table_autoControl_nc1 = import 'table/table_autoControl_nc1'
table_autoControl_nc2 = import 'table/table_autoControl_nc2'
table_autoControl_nc3 = import 'table/table_autoControl_nc3'
table_autoControl_nc4 = import 'table/table_autoControl_nc4'
table_autoControl_nc5 = import 'table/table_autoControl_nc5'
table_autoControl_cz = import 'table/table_autoControl_cz'
table_autoControl_dc = import 'table/table_autoControl_dc'
table_autoControl_pp=  import 'table/table_autoControl_pp'
table_autoControl_chargeLow = import 'table/table_autoControl_chargeLow'
table_autoControl_zero = import 'table/table_autoControl_zero'
table_autoControl_chargeLow1 = import 'table/table_autoControl_chargeLow1'
table_autoControl_chargeLow2 = import 'table/table_autoControl_chargeLow2'
table_autoControl_chargeLow3 = import 'table/table_autoControl_chargeLow3'
table_autoControl_chargeLow4 = import 'table/table_autoControl_chargeLow4'
table_autoControl_chargeLow5 = import 'table/table_autoControl_chargeLow5'
table_autoControl_chargeLow6 = import 'table/table_autoControl_chargeLow6'
table_autoControl_chargeLow7 = import 'table/table_autoControl_chargeLow7'
table_autoControl_chargeLow8 = import 'table/table_autoControl_chargeLow8'
table_autoControl_chargeLow9 = import 'table/table_autoControl_chargeLow9'
table_autoControl_chargeLow10 = import 'table/table_autoControl_chargeLow10'
table_autoControl_chargeLow11 = import 'table/table_autoControl_chargeLow11'
table_autoControl_chargeLow12 = import 'table/table_autoControl_chargeLow12'
table_autoControl_chargeLow13 = import 'table/table_autoControl_chargeLow13'
table_autoControl_chargeLow14 = import 'table/table_autoControl_chargeLow14'
table_autoControl_lowCha = import 'table/table_autoControl_lowCha'
table_parameter_parameter = import 'table/table_parameter_parameter'
table_stock_recharge_lv = import 'table/table_stock_recharge_lv'
table_stock_xs_1 = import 'table/table_stock_xs_1'
table_stock_xs_2 = import 'table/table_stock_xs_2'
table_stock_xs_3 = import 'table/table_stock_xs_3'
table_stock_play_limit = import 'table/table_stock_play_limit'
--[[
    获取控制系数
]]
function GetControlPoint(uid)
    return 10000
end
--充值玩家RTP其实影响
function SelectRechargeControlCfg(userinfo,chips,totalRechargeChips,chipsWithdraw)
    local rtp = 10000
    local condition = 0
    for key, value in pairs(table_autoControl_dc) do
        if totalRechargeChips >= value.chargeLimit and totalRechargeChips <= value.chargeMax then
            condition = key
            break
        end
    end
    if condition <= 0 then
        condition = #table_autoControl_dc
    end
    if totalRechargeChips <= 2000 then
        userinfo.point.chargeMax = 4400
        userinfo.point.isMiddleKill = 1
        local rtable =  gamecommon['table_autoControl_chargeLow'..condition]
        for _, value in ipairs(rtable) do
            if chips>=value.conditionMin and chips<=value.conditionMax then
                rtp = value.control
                break
            end
        end
        -- print("realrtp:"..rtp)
        unilight.update('userinfo',userinfo._id,userinfo)

    elseif totalRechargeChips<=4000 and userinfo.point.isMiddleKill~=2 then
        userinfo.point.isMiddleKill = userinfo.point.isMiddleKill or 0
        if userinfo.point.isMiddleKill<2 and chessuserinfodb.GetAHeadTolScore(userinfo._id)>3500 then
            userinfo.point.isMiddleKill = 1
            userinfo.point.chargeMax = 3500
            unilight.update('userinfo',userinfo._id,userinfo)
        end
        if chessuserinfodb.GetAHeadTolScore(userinfo._id)<=3500 and userinfo.point.isMiddleKill~=2 then
            userinfo.point.isMiddleKill = 2
            userinfo.point.chargeMax = 0
            unilight.update('userinfo',userinfo._id,userinfo)
        end
    else
        --计算最高上限
        --userinfo.point.chargeMax = 0
        userinfo.point.chargeMax = totalRechargeChips * table_autoControl_cz[1]['condition' .. condition]
        if userinfo.base.regFlag == 2 then
            userinfo.point.chargeMax = totalRechargeChips * table_autoControl_cz[2]['condition' .. condition]
        end
        userinfo.point.chargeMax = userinfo.point.chargeMax - chipsWithdraw
        if userinfo.point.chargeMax<0 then
            --零流水玩家
            userinfo.point.chargeMax = 0
        end
        local xs = (chips+chipsWithdraw)/totalRechargeChips
        for i=1,#table_stock_play_limit-1 do
            local filed = 'condition'..condition
            if xs>=table_stock_play_limit[i][filed] and xs<=table_stock_play_limit[i+1][filed] then
                rtp = table_stock_play_limit[i].control
                break
            end
        end
        unilight.update('userinfo',userinfo._id,userinfo)
    end
    return rtp
end
--非充值用户
function SelectControlCfg(val,slotsCount)
    local index = 0
    for key, value in pairs(table_autoControl_pp) do
        if slotsCount>=value.gameLow and slotsCount<=value.gameUp then
            index=key
            break
        end
    end
    if index==0 then
        index=5
    end
    -- print('index=',index)
    local control = 0
    local maxval = 0
    local maxkey = 0
    local tablecfg = gamecommon['table_autoControl_nc'..index]
    for key, value in pairs(tablecfg) do
        if value.conditionMax>maxval then
            maxval =value.conditionMax
            maxkey = key
        end
        if val>=value.conditionMin and val<=value.conditionMax then
            control = value.control
            break
        end
    end
    if val>maxval then
        control = tablecfg[maxkey].control
    end
    return control
end
--根据库存查看房间RTP
function GetRoomRtpByStock(gameType)
    local tablecfg = gamecommon['table_stock_xs_'..gameType]
    local data =  unilight.getdata("slotsStock", gameType)
    local stock =  data.stockNum
    local rtp = tablecfg[1].rtpXS
    for _, value in ipairs(tablecfg) do
        if stock>=value.stockMin and stock<=value.stockMax then
            rtp = value.rtpXS
            break
        end
    end
    return rtp
end


--RTP选择
--[[
    200 50 100          三种控制模型
]]
function GetModelRtp(uid,gameId, gameType, controlvalue)
    --获取房间库存RTP
    -- local tolXs = GetRoomRtpByStock(gameType)/10000
    local tolXs1 = tolXs/10000
    if tolXs1>=1.5 then
        local gte1Model = {
            { rtp = 200, gailv = (tolXs1 - 1.5)*2 },
            { rtp = 150, gailv = 1- ((tolXs1 - 1.5)*2)},
        }
        local rtpmodel = gte1Model[CommRandFloat(gte1Model, 'gailv')]
        return rtpmodel.rtp
    elseif tolXs1>=1 and tolXs1<1.5 then
        local gte1Model = {
            { rtp = 150, gailv = (tolXs1 - 1)*2 },
            { rtp = 100, gailv = 1- ((tolXs1 - 1)*2)},
        }
        local rtpmodel = gte1Model[CommRandFloat(gte1Model, 'gailv')]
        return rtpmodel.rtp
    elseif tolXs1>=0.75 and tolXs1<1 then
        local gte1Model = {
            { rtp = 100, gailv = (tolXs1 - 0.75)*4 },
            { rtp = 75, gailv = 1- ((tolXs1 - 0.75)*4)},
        }
        local rtpmodel = gte1Model[CommRandFloat(gte1Model, 'gailv')]
        return rtpmodel.rtp
    elseif tolXs1<0.75 then
        local gte1Model = {
            { rtp = 75, gailv = (tolXs1 - 0.5)*4 },
            { rtp = 50, gailv = 1- ((tolXs1 - 0.5)*4)},
        }
        local rtpmodel = gte1Model[CommRandFloat(gte1Model, 'gailv')]
        return rtpmodel.rtp
    end
end
function GetSpin(uid,gameId, gameType)
    -- print('GetSpinGetSpinGetSpinGetSpinGetSpinGetSpinGetSpin')
    local controlvalue ,totalRechargeChips,userinfo= GetControlPoint(uid)
    local rtp  = 0
    rtp = GetModelRtp(uid,gameId, gameType, controlvalue)
    -- print('rtp='..rtp..'controlvalue='..controlvalue)
    local spin=''
    if rtp==100 then
        spin=string.format('table_%d_normalspin_%d',gameId,gameType)
    else
        spin = string.format('table_%d_normalspin_%d_%d',gameId,rtp,gameType)
    end
    --返回
    local importstr=string.format('table/game/%d/%s',gameId,spin)
    -- print('Rtp',rtp) 
    return import(importstr),rtp
end