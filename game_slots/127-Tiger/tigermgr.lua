-- 老虎游戏模块
module('Tiger', package.seeall)

-- 获取老虎模块信息
function CmdEnterGame(uid, msg)
    -- 获取玩家信息
    local userInfo = unilight.getdata("userinfo",uid)
    -- 获取游戏类型
    local gameType = msg.gameType
    -- 获取数据库信息
    local tigerInfo = Get(gameType, uid)
    local res = GetResInfo(uid, tigerInfo, gameType)


    ------------------------------------- 特殊游戏特殊处理 -------------------------------------
    res.features = nil
    -------------------------------------------------------------------------------------------


    -- 发送消息
    gamecommon.SendNet(uid,'EnterSceneGame_S',res)
end

--拉动游戏过程
function CmdGameOprate(uid, msg)
    local res={}
    -- 获取数据库信息
    local tigerInfo = Get(msg.gameType, uid)
    if not table.empty(tigerInfo.respin) then
        --进入respin游戏逻辑
        local res = PlayRespinGame(tigerInfo,uid,msg.gameType)
        WithdrawCash.GetBetInfo(uid,DB_Name,msg.gameType,res,false,GameId)
        ------------------------------------- 特殊游戏特殊处理 -------------------------------------
        -------------------------------------------------------------------------------------------
        gamecommon.SendNet(uid,'GameOprateGame_S',res)
    else
        --进入普通游戏逻辑
        local res = PlayNormalGame(tigerInfo,uid,msg.betIndex,msg.gameType)
        WithdrawCash.GetBetInfo(uid,DB_Name,msg.gameType,res,true,GameId)
        ------------------------------------- 特殊游戏特殊处理 -------------------------------------
        -------------------------------------------------------------------------------------------
        gamecommon.SendNet(uid,'GameOprateGame_S',res)
    end

end

-- 老虎购买免费次数
function CmdBuyFree(uid,msg)
    -- 获取数据库信息
    local tigerInfo = Get(msg.gameType, uid)
    local buyRes = BuyFree(tigerInfo,uid,msg.betIndex,msg.gameType)
    gamecommon.SendNet(uid,'TigerBuyFreeCmd_S',buyRes)
end

-- 注册消息解析
function RegisterProto()
    gamecommon.RegGame(GameId, Tiger)
    gamecommon.GetModuleCfg(GameId,Tiger)
end