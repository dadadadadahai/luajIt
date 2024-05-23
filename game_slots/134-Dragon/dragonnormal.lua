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

    -- 只有普通扣费 买免费触发的普通不扣费

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
    -- 每一句初始化倍数
   -- local mulList = {}
   -- local sumMul = 1
   -- -- 随机额外倍数
    --local mul = table_134_normalMul[gamecommon.CommRandInt(table_134_normalMul, 'pro')].mul
    --table.insert(mulList,mul)
    --sumMul = mul
    --winMul = winMul * sumMul
    --extraData = {
     --   mulList = dragonInfo.mulList,
     --   sumMul = dragonInfo.sumMul,
    --}
    if resultGame.isFree == false and resultGame.winScore > 0 then
        -- 增加奖励
        BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD, resultGame.winScore, Const.GOODS_SOURCE_TYPE.DRAGON)
    elseif resultGame.isFree == true and resultGame.winScore > 0 then
        dragonInfo.free.tWinScore = dragonInfo.free.tWinScore + resultGame.winScore       
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
    gameDetaillog.SaveDetailGameLog(
        uid,
        sTime,
        GameId,
        gameType,
        dragonInfo.betMoney,
        reschip,
        chessuserinfodb.RUserChipsGet(uid),
        0,
        {type='normal',chessdata = resultGame.boards},
        jackpot
    )
    return res
end