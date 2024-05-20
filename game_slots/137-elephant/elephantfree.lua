--大象模块
module('Elephant',package.seeall)

--大象免费游戏
function PlayFreeGame(elephantInfo,uid,gameType)
    -- 游戏后台记录所需初始信息
    local sTime = os.time()
    local reschip = chessuserinfodb.RUserChipsGet(uid)
    -- 清理棋盘信息
    elephantInfo.boards = {}
    -- 增加免费游戏次数
    elephantInfo.free.lackTimes = elephantInfo.free.lackTimes - 1
    -- jackpot发送客户端的数据表
    local jackpot = {}
    -- 生成免费棋盘和结果
    local resultGame,elephantInfo = gamecontrol.RealCommonRotate(uid,GameId,gameType,true,elephantInfo,elephantInfo.betMoney,GetBoards)
    elephantInfo.free.tWinScore = elephantInfo.free.tWinScore + resultGame.winScore
    -- 返回数据
    local res = GetResInfo(uid, elephantInfo, gameType, resultGame.tringerPoints, resultGame.freeEndFlag)
    -- 判断是否结算
    if elephantInfo.free.lackTimes <= 0 then
        if elephantInfo.free.tWinScore > 0 then
            -- 获取奖励
            BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD_BASE, elephantInfo.free.tWinScore, Const.GOODS_SOURCE_TYPE.RABBIT)
        end
    end
    res.winScore = resultGame.winScore
    res.winPoints = resultGame.winPoints
    res.boards = {resultGame.boards}
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
        {type='free',chessdata = resultGame.boards,totalTimes=elephantInfo.free.totalTimes,lackTimes=elephantInfo.free.lackTimes,tWinScore=elephantInfo.free.tWinScore},
        jackpot
    )
    if elephantInfo.free.lackTimes <= 0 then
        elephantInfo.free = {}
    end
    -- 保存数据库信息
    SaveGameInfo(uid,gameType,elephantInfo)
    return res
end
