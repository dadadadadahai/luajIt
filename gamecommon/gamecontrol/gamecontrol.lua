module('gamecontrol',package.seeall)
local table_parameter_parameter= import "table/table_parameter_parameter"
local table_stock_tax = import 'table/table_stock_tax'
local table_auto_betUp = import 'table/table_auto_betUp'
local table_auto_pointN = import 'table/table_auto_pointN'
local table_auto_bxs = import 'table/table_auto_bxs'
local table_autoControl_dc = import 'table/table_autoControl_dc'
local sgameFuncMap = {}
--[[
    游戏特殊玩法注册
]]
function RegisterSgameFunc(gameId,playingType,sgameFunc)
    sgameFuncMap[gameId] = sgameFuncMap[gameId] or {}
    sgameFuncMap[gameId][playingType] = sgameFunc
end
function RealCommonRotate(_id,gameId, gameType, isfree, datainfo,chip,func,sgameFunc)
    local userinfo = unilight.getdata('userinfo',_id)
    --获取累计充值
    local totalRechargeChips = userinfo.property.totalRechargeChips
    --充值玩家,非充值玩家
    return nocharge_user(_id,gameId,gameType,isfree,datainfo,chip,totalRechargeChips,func,sgameFunc)
end
--非充值玩家
function nocharge_user(_id,gameId,gameType,isfree,datainfo,chip,totalRechargeChips,func,sgameFunc)
    local tmpdatainfo = table.clone(datainfo)
    local controlvalue = gamecommon.GetControlPoint(_id)
    --获取当前金币
    local result = {}
     --数据记录
    local dataRecord = {}
    result = func(_id, gameId, gameType, isfree, tmpdatainfo)
    local userinfo = unilight.getdata('userinfo',_id)
    PlayMaxMul(_id,chip,totalRechargeChips,gameType,datainfo)
    --预先计算不中奖金额
    local aHeadWinscore = AheadBonusPickWinScore(_id,gameId,gameType,tmpdatainfo,datainfo,sgameFunc)
    --当次中奖金额
    local curWinscore,jackpotChips, freeWinScore= CurResultTwinScore(result,tmpdatainfo,datainfo)
    --控制玩家不触发
    local firstControlLow = ControlLow(controlvalue,tmpdatainfo,datainfo)
    --控制玩家当前中奖额度不超过多少倍
    local maxmulAllow = IsAllowMaxMul(gameId,aHeadWinscore,curWinscore,jackpotChips,freeWinScore,chip,gameType,userinfo)
    table.insert(dataRecord,{result,tmpdatainfo,datainfo,curWinscore,aHeadWinscore,firstControlLow,jackpotChips,freeWinScore})
    
    local whileNum = 0
    local maxWhileNum = 10
    local maxchipfunc
    if totalRechargeChips<=0 then
        maxchipfunc = FreeUserMaxChips
    else
        maxchipfunc = ChargeUserMaxChip
    end
    local isWhile = false
    --非充值玩家不允许超过的最大金币
    while true do
        if (GameSingleMaxMul(curWinscore,chip) or firstControlLow or maxmulAllow or maxchipfunc(_id,chip,aHeadWinscore + curWinscore,tmpdatainfo,datainfo,totalRechargeChips) or (result.isReRotate~=nil and result.isReRotate)) or isWhile then
            --执行循环
            local param=nil
            if table.empty(tmpdatainfo.Param)==false then
                param = tmpdatainfo.Param
            end
            tmpdatainfo = table.clone(datainfo)
            tmpdatainfo.Param = param
            result = func(_id, gameId, gameType, isfree, tmpdatainfo)
            PlayMaxMul(_id,chip,totalRechargeChips,gameType,datainfo)
            aHeadWinscore = AheadBonusPickWinScore(_id,gameId,gameType,tmpdatainfo,datainfo,sgameFunc)
            --当次中奖金额
            curWinscore,jackpotChips,freeWinScore = CurResultTwinScore(result,tmpdatainfo,datainfo)
            --判断是否触发特殊
            firstControlLow = ControlLow(controlvalue,tmpdatainfo,datainfo)
            maxmulAllow = IsAllowMaxMul(gameId,aHeadWinscore,curWinscore,jackpotChips,freeWinScore,chip,gameType,userinfo)
            whileNum=whileNum+1
            table.insert(dataRecord,{result,tmpdatainfo,datainfo,curWinscore,aHeadWinscore,firstControlLow,jackpotChips,freeWinScore})
            if isWhile==false then
                isWhile=true
            end
            -- print('while while',whileNum,curWinscore + aHeadWinscore)
            if whileNum>=maxWhileNum then
                break
            end
        else
            break
        end
    end
    table.sort(dataRecord,function (a, b)
        return a[4]+a[5]>b[4]+a[5]
    end)
    local isOk = false
    local dataRecordIndex = 1
    for index, value in ipairs(dataRecord) do
        isOk =  IsAllowMaxMul(gameId,value[4],value[5],value[7],value[8],chip,gameType,userinfo) or maxchipfunc(_id,chip,value[4]+value[5],value[2],value[3],totalRechargeChips)
        if controlvalue<10000 then
            isOk = isOk or value[6]
        end
        -- print('1',value[1].isSucces~=nil and value[1].isSucces)
        -- print('2',value[1].isReRotate==nil or value[1].isReRotate==false)
        -- print('3',isOk)
        if (isOk==false and ((value[1].isReRotate==nil or value[1].isReRotate==false) or (value[1].isSucces~=nil and value[1].isSucces))) then
            result = value[1]
            tmpdatainfo = value[2]
            dataRecordIndex=index
            break
        end
    end
    if isOk then
        table.sort(dataRecord,function (a, b)
            return a[4]+a[5]<b[4]+a[5]
        end)
        --不满足结果求解
        for index,value in ipairs(dataRecord) do
            local specialScene = {'free','bonus','pick','respin'}
            local isSpecial = false
            for _,v in ipairs(specialScene) do
                if IsCreateNewPlayingGame(v,value[2],value[3]) then
                    isSpecial = true
                    break
                end
            end
            if isSpecial==false then
                result = value[1]
                tmpdatainfo = value[2]
                dataRecordIndex=index
                break
            end
        end
    end
    local d = dataRecord[dataRecordIndex]
    local specialWin=0
    if result.specialWin~=nil then
        specialWin = result.specialWin
    end
    local twinscore = result.winScore+d[5] + specialWin+d[7]
    local nochangeStock = {}
    nochangeStock[109] = 1
    -- local bstock = unilight.getdata("slotsStock", gameType).stockNum
    -- print('bstock',bstock)
    if (userinfo.point.isMiddleKill==nil or userinfo.point.isMiddleKill~=1) and (userinfo.property.totalRechargeChips>0 and nochangeStock[gameId]==nil) then
        local addscore = 0
        local specialScene = {'bonus','pick','free','respin'}
        local isnew = false 
        for _, value in ipairs(specialScene) do
            isnew = isnew or IsCreateNewPlayingGame(value,tmpdatainfo,d[3])
        end
        if IsGameInPlayingGame(tmpdatainfo)==false or isnew then
            --判断押注
            -- addscore =  chip*(10000-table_stock_tax[gameType].taxPercent)/10000
            -- addscore =  chip*(10000-GetTaxXs(gameId,gameType))/10000
            -- local curdaytimestamp = chessutil.ZeroTodayTimestampGet()
            -- --gameBetPumpInfo
            -- local keyval = gameId*1000000+ unilight.getzoneid() * 100 + gameType
            -- local sdata = unilight.getByFilter('gameBetPumpInfo',unilight.a(unilight.eq('daytimestamp',curdaytimestamp),unilight.eq('keyval',keyval),unilight.eq('taxPercent',table_stock_tax[gameType].taxPercent)),1)
            -- if table.empty(sdata) then
            --     local idata={
            --         _id = go.newObjectId(),
            --         keyval = keyval,
            --         daytimestamp=curdaytimestamp,
            --         gameType = gameType,
            --         gameId = gameId,
            --         taxPercent = table_stock_tax[gameType].taxPercent,--抽水比例
            --         betNum = 1,         --下注次数
            --         tbet = chip,        --累计下注
            --         betDump = chip - addscore  --累计抽水
            --     }
            --     unilight.savedata('gameBetPumpInfo',idata)
            -- else
            --     local idata = sdata[1]
            --     idata.betNum = idata.betNum + 1
            --     idata.tbet = idata.tbet + chip
            --     idata.betDump = idata.betDump + (chip - addscore)
            --     unilight.savedata('gameBetPumpInfo',idata)
            -- end
        end
        local stock = addscore - twinscore
        -- print(stock)
            --减库存
        -- gamecommon.IncSelfStockNumByType(gameId, gameType, stock)
        -- print(string.format('stock=%.4f,chip=%d,twinscore=%d',stock,chip,twinscore))
    end
    -- print('curstock',unilight.getdata("slotsStock", gameType).stockNum)
    return result,tmpdatainfo
end
--[[
    根据下注档次，充值系统等确定玩家最大可中倍数
]]
function PlayMaxMul(uid,betchip,totalRechargeChips,gameType,datainfo)
    local getBetIndex = function ()
        if datainfo.betindex==nil then
            return datainfo.betIndex
        end
        return datainfo.betindex
    end
    local chips =chessuserinfodb.GetAHeadTolScore(uid)
    local userinfo = unilight.getdata('userinfo',uid)
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
    local mul = 0
    for index, value in ipairs(table_auto_betUp) do
        if value.stageId==gameType and getBetIndex()==value.betIndex then
            mul = value.mul
            break
        end
    end
    local mul1 = 0
    -- if betchip<9000 and totalRechargeChips>=10000 then
    --     local xs = (betchip*table_auto_bxs[1]['x'..condition])/(totalRechargeChips*table_auto_bxs[2]['x'..condition]+chips*table_auto_bxs[3]['x'..condition])
    --     for _, value in ipairs(table_auto_pointN) do
    --         if xs>=value.low and xs<value.up then
    --             mul1 = value.mul
    --             break
    --         end
    --     end
    -- end
    local selfMul = userinfo.point.maxMul or 0
    if mul>mul1 and mul1>0 then
        mul = mul1
    end
    if mul>selfMul and selfMul>0 then
        mul = selfMul
    end
    userinfo.point.maxMul = mul
end

--[[
    aHeadWinscore 预计算的中奖金额
    curWinscore 当前中中奖金额  
    判断是否超过库存值
]]
function IsAllowMaxMul(gameid,aHeadWinscore,curWinscore,jackpotChips,freeWinScore,chip,gameType,userinfo)
    local freeExtMapGame ={}
    freeExtMapGame[121] = 1
    freeExtMapGame[126] = 1
    freeExtMapGame[129] = 1
    local maxmul = table_parameter_parameter[19+(gameType-1)].Parameter
    if userinfo.point.maxMul==nil or userinfo.point.maxMul<=0 then
        if aHeadWinscore>maxmul*chip then
            return true
        end
        if freeExtMapGame[gameid]~=nil and freeWinScore>0 then
            if freeWinScore>=chip*200 then
                -- print('freeWinScore true')
                return true
            end
        elseif curWinscore-jackpotChips>maxmul*chip then
            return true
        end
    else
        if aHeadWinscore>userinfo.point.maxMul*chip then
            return true
        end
        if freeExtMapGame[gameid]~=nil and freeWinScore>0 then
            if freeWinScore>=chip*200 then
                -- print('freeWinScore true')
                return true
            end
        elseif curWinscore>userinfo.point.maxMul*chip then
           return true
        end
    end
    -- local stock = unilight.getdata("slotsStock", gameType).stockNum
    -- print('curstock=',stock)
    -- if stock-(aHeadWinscore+curWinscore)<0 then
    --     print('stock true')
    --     return true
    -- end
    return false
end 
--[[
    判断是否触发了新玩法
]]
function IsCreateNewPlayingGame(playingType,tmpdatainfo,datainfo)
    if (table.empty(tmpdatainfo[playingType])==false and table.empty(datainfo[playingType])) or ((table.empty(datainfo[playingType]) == false and datainfo[playingType].totalTimes == -1) and (table.empty(tmpdatainfo[playingType]) == false and tmpdatainfo[playingType].totalTimes ~= -1)) then
        return true
    end
    return false
end
--[[
    判断当前游戏是否在特殊玩法中
]]
function IsGameInPlayingGame(datainfo)
    local specialScene = {'bonus','pick','free','respin'}
    for _, value in ipairs(specialScene) do
        if table.empty(datainfo[value])==false and datainfo[value].totalTimes~=nil and  datainfo[value].totalTimes>0 then
            return true,datainfo[value].tWinScore,value
        end
    end
    return false,0,''
end
--[[
    预先计算首次产生bonus,pick到结束产生的总奖励
]]
function AheadBonusPickWinScore(uid,gameId,gameType,tmpdatainfo,datainfo,sgameFunc)
    local realSgameFunc = nil
    local specialScene = {'free','bonus','pick','respin'}
    for _, value in ipairs(specialScene) do
        -- if table.empty(tmpdatainfo[value])==false and table.empty(datainfo[value]) then
        if (IsCreateNewPlayingGame(value,tmpdatainfo,datainfo)) then
            local gameIdMap =  sgameFuncMap[gameId]
            if gameIdMap~=nil then
                local tmpfunc = gameIdMap[value]
                if tmpfunc~=nil then
                    realSgameFunc = tmpfunc
                end
            end
            if realSgameFunc~=nil then
               --首次触发,执行预计算
                local val = table.clone(tmpdatainfo[value])
                while true do
                    local tWinScore,lackTimes = realSgameFunc(uid,gameType,tmpdatainfo)
                    if lackTimes<=0 then
                        tmpdatainfo[value] = val
                        -- print('AheadBonusPickWinScore',tWinScore)
                        return tWinScore
                    end
                end
            end
        end
    end
    -- print('AheadBonusPickWinScore',0)
    return 0
end
--[[
    计算当次结果的总奖励金币
]]
function CurResultTwinScore(result,tmpdatainfo,datainfo)
    local specialScene = {'bonus','pick','free','collect'}
    local isSpecil =false
    local winScore=  0
    local freeWinScore = 0
    for _, value in ipairs(specialScene) do
        -- if table.empty(tmpdatainfo[value])==false then
        if table.empty(tmpdatainfo[value])==false and  tmpdatainfo[value].tWinScore ~= nil and tmpdatainfo[value].totalTimes > 0 then
            local tmpTWinScore = tmpdatainfo[value].tWinScore+result.winScore
            if value=='free'then
                freeWinScore = tmpTWinScore
            end
            if table.empty(datainfo[value])==false and datainfo[value].tWinScore==tmpTWinScore then
                isSpecil=true
                tmpTWinScore = 0
            end
            winScore = winScore + tmpTWinScore
        end
    end
    local jackpotChips = 0
    if winScore<=0 and isSpecil==false then
        winScore = result.winScore
        if result.aHeadWin~=nil then
            winScore = winScore + result.aHeadWin
        end
    end
    --判断本次是否中jackpot
    if result.jackpotChips~=nil and result.jackpotChips>0 then
        winScore = winScore + result.jackpotChips
        jackpotChips=result.jackpotChips
    end
    -- print('CurResultTwinScore',winScore)
    -- print('freeWinScore',freeWinScore)
    return winScore,jackpotChips,freeWinScore
end
--[[
    是否超过游戏允许的最大倍数
]]
function GameSingleMaxMul(winScore,betChip)
    -- if winScore>betChip*MaxMul then
    --     print('GameSingleMaxMul')
    --     return true
    -- end
    return false
end
--[[
    控制玩家不触发
]]
function ControlLow(control,tmpdatainfo,datainfo)
    -- local specialScene = {'bonus','pick','free'}
    -- for _, value in ipairs(specialScene) do
    --     -- if table.empty(tmpdatainfo[value])==false and table.empty(datainfo[value]) then
    --     if (table.empty(tmpdatainfo[value])==false and table.empty(datainfo[value])) or ((table.empty(datainfo[value]) == false and datainfo[value].totalTimes == -1) and (table.empty(tmpdatainfo[value]) == false and tmpdatainfo[value].totalTimes ~= -1)) then
    --         if control<10000 then
    --             return true
    --         end
    --     end
    -- end
    return false
end
--[[
    免费玩家不允许超过最大的金币上限
]]
function FreeUserMaxChips(_id,chip,winScore,tmpdatainfo,datainfo,totalRechargeChips)
    local chips =chessuserinfodb.GetAHeadTolScore(_id)
    local noChargeMax = table_parameter_parameter[15].Parameter
    if chips+winScore>noChargeMax and winScore>0 then
        -- print('FreeUserMaxChips')
        return true
    end
    return false
end
--[[
    计算充值玩家累计付费
]]
function ChargeUserMaxChip(_id, chip,winScore,tmpdatainfo,datainfo,totalRechargeChips)
    local chips =chessuserinfodb.GetAHeadTolScore(_id)
    local userinfo = unilight.getdata('userinfo',_id)
    if userinfo.point.chargeMax~=nil and userinfo.point.chargeMax>0 then
        if chips + winScore>userinfo.point.chargeMax then
            if winScore>chip then
                return true
            end
            if IsCreateNewPlayingGame('free',tmpdatainfo,datainfo) then
                        -- print('no pass chargeMax free')
                return true
            end
        end
    end
    -- -- print('chargeMax',userinfo.point.chargeMax)
    -- if userinfo.point.chargeMax<=0 and chips<table_parameter_parameter[18].Parameter then
    --     if chips + winScore>table_parameter_parameter[18].Parameter  then
    --         --[[
    --             零流水或负流水玩家判定
    --         ]]
    --         -- print('ChargeUserMaxChip chargeMax')
    --         return true
    --     end
    -- end
    -- if chips>=userinfo.point.chargeMax then
    --     if  winScore>chip then
    --         -- print('no pass chargeMax')
    --         return true
    --     end
    --     if IsCreateNewPlayingGame('free',tmpdatainfo,datainfo) then
    --         -- print('no pass chargeMax free')
    --         return true
    --     end
    -- end
    -- if chips<userinfo.point.chargeMax and chips + winScore>userinfo.point.chargeMax  then
    --     -- print('ChargeUserMaxChip chargeMax')
    --     -- print('winScore',winScore,chips,userinfo.point.chargeMax)
    --     return true
    -- end
    return false
end