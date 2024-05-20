module('cleopatraNew',package.seeall)
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
        features={
            free = datainfo.free,
        },
        extraData={
            isInHight = datainfo.isInHight,
            freePrice = table_121_buyfree[1].price,
            betChange = table_121_buygailv[1].betChange,
        }
    }
    gamecommon.SendNet(uid,'EnterSceneGame_S',res)
end
function CmdGameOprate(uid,msg)
    local gameId = msg.gameId
    local gameType = msg.gameType
    local datainfo,datainfos = Get(gameType,uid)
    local res={}
    if table.empty(datainfo.free)==false then
        res = Free(gameId,gameType,datainfo,datainfos)
        WithdrawCash.GetBetInfo(uid,Table,gameType,res,false)
    else
        res = Normal(gameId,gameType,msg.betIndex,datainfo,datainfos,uid)
        WithdrawCash.GetBetInfo(uid,Table,gameType,res,true)
    end
    gamecommon.SendNet(uid, 'GameOprateGame_S', res)
end
function CmdBuyFree(uid,msg)
    local gameType = msg.gameType
    local datainfo,datainfos = Get(gameType,uid)
    local res = BuyFree(gameType,msg.betindex,datainfo,datainfos)
    gamecommon.SendNet(uid, 'GameOprateGame_S', res)
end
function CmdBuyHighBet(uid,msg)
    local gameType = msg.gameType
    local datainfo,datainfos = Get(gameType,uid)
    local res = BuyHighBet(msg.highLevel,datainfo,datainfos)
    gamecommon.SendNet(uid, 'CleopatraNewBuyHighBetCmd_S', res)
end
--注册消息解析
function RegisterProto()
    gamecommon.RegGame(GameId, cleopatraNew)
    -- local poolConfigs = {
    --     chipsConfigs     = table_110_jackpot_chips,   --标准金额
    --     addPerConfigs    = table_110_jackpot_add_per, --奖池增加
    --     bombConfigs      = table_110_jackpot_bomb,    --奖池暴池概率
    --     scaleConfigs     = table_110_jackpot_scale,   --奖池爆池比例
    --     betConfigs       = table_110_jackpot_bet,     --奖池触发下注
    -- }
    -- gamecommon.GamePoolInit(GameId,poolConfigs)
    -- gamecommon.GamePoolInit(GameId)
    gamecommon.GetModuleCfg(GameId,cleopatraNew)
end