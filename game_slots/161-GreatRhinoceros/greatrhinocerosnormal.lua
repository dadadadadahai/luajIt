-- 大象游戏模块
module('GreatRhinoceros', package.seeall)

function PlayNormalGame(dataInfo,uid,betIndex,gameType)
    -- 游戏后台记录所需初始信息
    local sTime = os.time()
    local reschip = chessuserinfodb.RUserChipsGet(uid)
    -- 清理棋盘附加信息
    dataInfo.iconsAttachData = {}
    -- 保存下注档次
    dataInfo.betIndex = betIndex
    local betConfig = gamecommon.GetBetConfig(gameType,table_161_hanglie[1].linenum)
    local betgold = betConfig[dataInfo.betIndex]                                                      -- 单注下注金额
    local payScore = betgold * table_161_hanglie[1].linenum                                   -- 全部下注金额
    local jackpot = {}

    -- 只有普通扣费 买免费触发的普通不扣费
    if dataInfo.BuyFreeNumS == 0 then
        -- 扣除金额
        local _, ok = chessuserinfodb.WChipsChange(uid, Const.PACK_OP_TYPE.SUB, payScore, "大犀牛下注扣费")
        if ok == false then
            local res = {
                errno = 1,
                desc = "当前余额不足"
            }
            return res
        end
    end
    dataInfo.betMoney = payScore
    -- 生成普通棋盘和结果
    local resultGame,dataInfo = gamecontrol.RealCommonRotate(uid,GameId,gameType,false,dataInfo,dataInfo.betMoney,GetBoards)
    -- 保存棋盘数据
    dataInfo.boards = resultGame.boards
    if resultGame.isFree == false and resultGame.winScore > 0 then
        -- 增加奖励
        BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD, resultGame.winScore, Const.GOODS_SOURCE_TYPE.ELEPHANT)
    elseif resultGame.isFree == true and resultGame.winScore > 0 then
        dataInfo.free.tWinScore = dataInfo.free.tWinScore + resultGame.winScore
    end
    -- 保存数据库信息
    SaveGameInfo(uid,gameType,dataInfo)
    -- 返回数据
    local res = GetResInfo(uid, dataInfo, gameType, resultGame.tringerPoints)
    res.boards = {resultGame.boards}
    res.winScore = resultGame.winScore
    res.winPoints = resultGame.winPoints
    res.extraData = resultGame.extraData
    -- 增加后台历史记录
    gameDetaillog.SaveDetailGameLog(
        uid,
        sTime,
        GameId,
        gameType,
        dataInfo.betMoney,
        reschip,
        chessuserinfodb.RUserChipsGet(uid),
        0,
        {type='normal',chessdata = resultGame.boards},
        jackpot
    )
    return res
end