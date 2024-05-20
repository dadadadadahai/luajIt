module('corpse',package.seeall)
local table_stock_tax = import 'table/table_stock_tax'
--进入游戏场景消息
function CmdEnterGame(uid,msg)
    local gameId = msg.gameId
    local gameType = msg.gameType
    local datainfo,datainfos = Get(gameType,uid)
    local betconfig = gamecommon.GetBetConfig(gameType,LineNum)
    local res={
        errno = 0,
        betConfig = betconfig,
        betIndex = datainfo.betindex,
        bAllLine=LineNum,
        normalScore = datainfo.normalScore,
        features={
            bonus=PackBonus(datainfo),
        },
    }
    gamecommon.SendNet(uid,'EnterSceneGame_S',res)
end
function CmdGameOprate(uid,msg)
    local gameId = msg.gameId
    local gameType = msg.gameType
    local datainfo,datainfos = Get(gameType,uid)
    local res={}
    if datainfo.normalScore>0 and table.empty(datainfo.bonus) then
        -- BackpackMgr.GetRewardGood(datainfos._id, Const.GOODS_ID.GOLD, datainfo.normalScore,Const.GOODS_SOURCE_TYPE.CORPSE)
        -- datainfo.normalScore = 0
        -- datainfo.normalChip = 0
        -- datainfo.addMulNum = 0
        -- unilight.update(Table, datainfos._id, datainfos)
        -- local r = {
        --     errno = 0,
        --     normalScore = datainfo.normalScore,
        -- }
        -- gamecommon.SendNet(uid,'RecvNormalScoreGame_S',r)
    end
    if table.empty(datainfo.bonus)==false then
        if msg.extraData==nil then
            res=Bonus(nil,gameType,datainfo,datainfos)
        else
            res=Bonus(msg.extraData.pos,gameType,datainfo,datainfos)
        end
        WithdrawCash.GetBetInfo(uid,Table,gameType,res,false)
    else
        res = Normal(gameId,gameType,msg.betIndex,datainfo,datainfos)
        WithdrawCash.GetBetInfo(uid,Table,gameType,res,true)
    end
    gamecommon.SendNet(uid, 'GameOprateGame_S', res)
end
--[[
    是否翻倍普通中奖
]]
function CmdCorpseDouble(uid,msg)
    local gameId = msg.gameId
    local gameType = msg.gameType
    local res={
        errno = 0,
        normalScore = 0
    }
    local datainfo,datainfos = Get(gameType,uid)
    if datainfo.normalScore<=0 then
        gamecommon.SendNet(uid,'RecvNormalScoreGame_S',{errno=ErrorDefine.ERROR_RECVNORMAL})
        return
    end
    local userinfo = unilight.getdata('userinfo', uid)
    local stock =  gamecommon.GetSelfStockNumByType(gameId, gameType)
    userinfo.point.chargeMax = userinfo.point.chargeMax or 0
    if 50<=math.random(100) and datainfo.addMulNum<3 and stock>=datainfo.normalScore and datainfo.normalScore*2<=userinfo.point.chargeMax then
        -- stock = stock - datainfo.normalScore
        local normal = datainfo.normalScore
        datainfo.normalScore = datainfo.normalScore*2
        res.normalScore = datainfo.normalScore
        datainfo.addMulNum = datainfo.addMulNum + 1
        gamecommon.IncSelfStockNumByType(gameId, gameType, -normal)
    else
        --5 3
        -- 3 5   +2
        --不中
        local addscore = datainfo.normalChip*(10000-gamecontrol.GetTaxXs(gameId,gameType))/10000
        local rstock = addscore - datainfo.normalScore
        
        -- local addscore = datainfo.normalScore-(datainfo.normalChip*(10000-gamecontrol.GetTaxXs(gameId,gameType))/10000)
        -- stock = stock + addscore
        --[[
            库存恢复
        ]]
        gamecommon.IncSelfStockNumByType(gameId, gameType, -rstock +addscore)
        datainfo.normalScore = 0
        datainfo.normalChip = 0
        datainfo.addMulNum = 0
        res.normalScore = 0
    end
    unilight.update(Table, datainfos._id, datainfos)
    gamecommon.SendNet(uid,'CorpseDoubleCmd_S',res)
end
--[[
    领取普通中奖
]]
function CmdCorpseRecvNormalScore(uid,msg)
    local gameId = msg.gameId
    local gameType = msg.gameType
    local datainfo,datainfos = Get(gameType,uid)
    if datainfo.normalScore>0 then
        local res = {
            errno = 0,
            normalScore = datainfo.normalScore,
        }
        BackpackMgr.GetRewardGood(datainfos._id, Const.GOODS_ID.GOLD, datainfo.normalScore,Const.GOODS_SOURCE_TYPE.CORPSE)
        datainfo.normalScore = 0
        datainfo.normalChip = 0
        datainfo.addMulNum = 0
        unilight.update(Table, datainfos._id, datainfos)
        gamecommon.SendNet(uid,'CorpseRecvNormalScoreGame_S',res)
    else
        gamecommon.SendNet(uid,'CorpseRecvNormalScoreGame_S',{errno=ErrorDefine.ERROR_RECVNORMAL})
    end
end
function Drop(gameType,uid)
    local datainfo,datainfos = Get(gameType,uid)
    if datainfo.normalScore>0 then
        BackpackMgr.GetRewardGood(datainfos._id, Const.GOODS_ID.GOLD, datainfo.normalScore,Const.GOODS_SOURCE_TYPE.CORPSE)
        datainfo.normalScore = 0
        datainfo.normalChip = 0
        datainfo.addMulNum = 0
        unilight.update(Table, datainfos._id, datainfos)
    end
end
--注册消息解析
function RegisterProto()
    gamecommon.RegGame(GameId, corpse)
    gamecommon.GetModuleCfg(GameId,corpse)
    gamecommon.JackNameInit(GameId,corpse)
end