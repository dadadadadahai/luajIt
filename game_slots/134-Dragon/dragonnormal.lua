-- 生肖龙游戏模块
module('Dragon', package.seeall)

function PlayNormalGame(dragonInfo,uid,betIndex,gameType)
    -- 游戏后台记录所需初始信息
    local sTime = os.time()
    local reschip = chessuserinfodb.RUserChipsGet(uid)
    -- 清理棋盘附加信息
    dragonInfo.iconsAttachData = {}
    -- 保存下注档次
    dragonInfo.betIndex = betIndex
    local betConfig = gamecommon.GetBetConfig(gameType,table_134_hanglie[1].linenum)
    local betgold = betConfig[dragonInfo.betIndex]                                                      -- 单注下注金额
    local payScore = betgold * table_134_hanglie[1].linenum                                   -- 全部下注金额
    local jackpot = {}
    -- 扣除金额
    local _, ok = chessuserinfodb.WChipsChange(uid, Const.PACK_OP_TYPE.SUB, payScore, "生肖龙下注扣费")
    if ok == false then
        local res = {
            errno = 1,
            desc = "当前余额不足"
        }
        return res
    end
    dragonInfo.betMoney = payScore
    -- 生成普通棋盘和结果
    local resultGame,dragonInfo = gamecontrol.RealCommonRotate(uid,GameId,gameType,false,dragonInfo,dragonInfo.betMoney,GetBoards)
    -- 保存棋盘数据
    dragonInfo.boards = resultGame.boards
    if resultGame.winScore > 0 then
        -- 增加奖励
        BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD, resultGame.winScore, Const.GOODS_SOURCE_TYPE.DRAGON)
    end
    -- 返回数据
    local res = GetResInfo(uid, dragonInfo, gameType, resultGame.tringerPoints)
    res.boards = {resultGame.boards}
    res.winScore = resultGame.winScore
    res.winlines = resultGame.winlines
    res.extraData = resultGame.extraData
    -- 保存数据库信息
    SaveGameInfo(uid,gameType,dragonInfo)
    -- 增加后台历史记录
    local type = 'normal'
    -- 如果中了免费模式
    if not table.empty(dragonInfo.free) then
        type = 'freeNormal'
    end
    gameDetaillog.SaveDetailGameLog(
        uid,
        sTime,
        GameId,
        gameType,
        dragonInfo.betMoney,
        reschip,
        chessuserinfodb.RUserChipsGet(uid),
        0,
        {type=type,chessdata = resultGame.boards},
        jackpot
    )
    return res
end