-- 大象游戏模块
module('Elephant', package.seeall)

function PlayNormalGame(elephantInfo,uid,betIndex,gameType)
    -- 游戏后台记录所需初始信息
    local sTime = os.time()
    local reschip = chessuserinfodb.RUserChipsGet(uid)
    -- 清理棋盘附加信息
    elephantInfo.iconsAttachData = {}
    -- 保存下注档次
    elephantInfo.betIndex = betIndex
    local betConfig = gamecommon.GetBetConfig(gameType,table_137_hanglie[1].linenum)
    local betgold = betConfig[elephantInfo.betIndex]                                                      -- 单注下注金额
    local payScore = betgold * table_137_hanglie[1].linenum                                   -- 全部下注金额
    local jackpot = {}

    -- 只有普通扣费 买免费触发的普通不扣费
    if elephantInfo.BuyFreeNumS == 0 then
        -- 扣除金额
        local _, ok = chessuserinfodb.WChipsChange(uid, Const.PACK_OP_TYPE.SUB, payScore, "大象下注扣费")
        if ok == false then
            local res = {
                errno = 1,
                desc = "当前余额不足"
            }
            return res
        end
    end
    elephantInfo.betMoney = payScore
    -- 生成普通棋盘和结果
    local resultGame,elephantInfo = gamecontrol.RealCommonRotate(uid,GameId,gameType,false,elephantInfo,elephantInfo.betMoney,GetBoards)
    -- 保存棋盘数据
    elephantInfo.boards = resultGame.boards
    if resultGame.isFree == false and resultGame.winScore > 0 then
        -- 增加奖励
        BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD, resultGame.winScore, Const.GOODS_SOURCE_TYPE.RABBIT)
    elseif resultGame.isFree == true and resultGame.winScore > 0 then
        elephantInfo.free.tWinScore = elephantInfo.free.tWinScore + resultGame.winScore
    end
    -- 保存数据库信息
    SaveGameInfo(uid,gameType,elephantInfo)
    -- 返回数据
    local res = GetResInfo(uid, elephantInfo, gameType, resultGame.tringerPoints)
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
        elephantInfo.betMoney,
        reschip,
        chessuserinfodb.RUserChipsGet(uid),
        0,
        {type='normal',chessdata = resultGame.boards},
        jackpot
    )
    return res
end