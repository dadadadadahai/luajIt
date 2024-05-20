--大象模块
module('GreatRhinoceros',package.seeall)

--大象免费游戏
function PlayFreeGame(dataInfo,uid,gameType)
    -- 游戏后台记录所需初始信息
    local sTime = os.time()
    local reschip = chessuserinfodb.RUserChipsGet(uid)
    -- 清理棋盘信息
    dataInfo.boards = {}
    -- 增加免费游戏次数
    dataInfo.free.lackTimes = dataInfo.free.lackTimes - 1
    -- jackpot发送客户端的数据表
    local jackpot = {}
    -- 生成免费棋盘和结果
    local resultGame,dataInfo = gamecontrol.RealCommonRotate(uid,GameId,gameType,true,dataInfo,dataInfo.betMoney,GetBoards)
    dataInfo.free.tWinScore = dataInfo.free.tWinScore + resultGame.winScore
    -- 返回数据
    local res = GetResInfo(uid, dataInfo, gameType, resultGame.tringerPoints, resultGame.freeEndFlag)
    -- 判断是否结算
    if dataInfo.free.lackTimes <= 0 then
        if dataInfo.free.tWinScore > 0 then
            -- 获取奖励
            BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD_BASE, dataInfo.free.tWinScore, Const.GOODS_SOURCE_TYPE.RABBIT)
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
        dataInfo.betMoney,
        reschip,
        chessuserinfodb.RUserChipsGet(uid),
        0,
        {type='free',chessdata = resultGame.boards,totalTimes=dataInfo.free.totalTimes,lackTimes=dataInfo.free.lackTimes,tWinScore=dataInfo.free.tWinScore},
        jackpot
    )
    if dataInfo.free.lackTimes <= 0 then
        dataInfo.free = {}
    end
    -- 保存数据库信息
    SaveGameInfo(uid,gameType,dataInfo)
    return res
end
