-- 老虎游戏模块
module('Tiger', package.seeall)

function PlayNormalGame(tigerInfo,uid,betIndex,gameType)
    -- 游戏后台记录所需初始信息
    local sTime = os.time()
    local reschip = chessuserinfodb.RUserChipsGet(uid)
    -- 清理棋盘附加信息
    tigerInfo.iconsAttachData = {}
    -- 保存下注档次
    tigerInfo.betIndex = betIndex
    local betConfig = gamecommon.GetBetConfig(gameType,table_127_hanglie[1].linenum)
    local betgold = betConfig[tigerInfo.betIndex]                                                      -- 单注下注金额
    local payScore = betgold * table_127_hanglie[1].linenum                                   -- 全部下注金额
    local jackpot = {}
    -- 扣除金额
    local _, ok = chessuserinfodb.WChipsChange(uid, Const.PACK_OP_TYPE.SUB, payScore, "老虎下注扣费")
    if ok == false then
        local res = {
            errno = 1,
            desc = "当前余额不足"
        }
        return res
    end
    tigerInfo.betMoney = payScore
    -- 生成普通棋盘和结果
    local resultGame,tigerInfo = gamecontrol.RealCommonRotate(uid,GameId,gameType,false,tigerInfo,tigerInfo.betMoney,GetBoards)

    -- 普通游戏扣除respin中奖金额
    resultGame.winScore = resultGame.winScore - resultGame.respinWinScore

    -- 保存棋盘数据
    tigerInfo.boards = resultGame.boards
    if resultGame.respinFlag == false and resultGame.winScore > 0 then
        -- 增加奖励
        BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD, resultGame.winScore, Const.GOODS_SOURCE_TYPE.TIGER)
    end

    -- 返回数据
    local res = GetResInfo(uid, tigerInfo, gameType)
    res.boards = {resultGame.boards}
    res.winScore = resultGame.winScore
    res.winlines = resultGame.winlines
    res.bigWinIcon = resultGame.bigWinIcon
    -- 增加后台历史记录
    if resultGame.respinFlag then
        -- 判断是否结算
        if tigerInfo.respin.lackTimes <= 0 then
            res.features.respin.tWinScore = tigerInfo.respin.tWinScore or 0
            if tigerInfo.respin.tWinScore > 0 then
                -- 获取奖励
                BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD_BASE, tigerInfo.respin.tWinScore, Const.GOODS_SOURCE_TYPE.TIGER)
            end
        end
        gameDetaillog.SaveDetailGameLog(
            uid,
            sTime,
            GameId,
            gameType,
            tigerInfo.betMoney,
            reschip,
            chessuserinfodb.RUserChipsGet(uid),
            0,
            {type='normalRespin',chessdata = tigerInfo.respin.boards,totalTimes=tigerInfo.respin.totalTimes,lackTimes=tigerInfo.respin.lackTimes,tWinScore=tigerInfo.respin.tWinScore},
            jackpot
        )
        if tigerInfo.respin.lackTimes <= 0 then
            tigerInfo.respin = {}
            tigerInfo.bres = {}
        end
    else
        gameDetaillog.SaveDetailGameLog(
            uid,
            sTime,
            GameId,
            gameType,
            tigerInfo.betMoney,
            reschip,
            chessuserinfodb.RUserChipsGet(uid),
            0,
            {type='normal',chessdata = resultGame.boards},
            jackpot
        )
    end
    -- 保存数据库信息
    SaveGameInfo(uid,gameType,tigerInfo)
    return res
end