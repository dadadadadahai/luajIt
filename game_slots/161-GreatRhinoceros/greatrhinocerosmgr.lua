-- 大象游戏模块
module('GreatRhinoceros', package.seeall)

-- 获取大象模块信息
function CmdEnterGame(uid, msg)
    -- 获取玩家信息
    local userInfo = unilight.getdata("userinfo",uid)
    -- 获取游戏类型
    local gameType = msg.gameType
    -- 获取数据库信息
    local dataInfo = Get(gameType, uid)
    local res = GetResInfo(uid, dataInfo, gameType)
    -- 发送消息
    gamecommon.SendNet(uid,'EnterSceneGame_S',res)
end

--拉动游戏过程
function CmdGameOprate(uid, msg)
    local res={}
    -- 获取数据库信息
    local dataInfo = Get(msg.gameType, uid)

    if not table.empty(dataInfo.free) then
        --进入免费游戏逻辑
        local res = PlayFreeGame(dataInfo,uid,msg.gameType)
        WithdrawCash.GetBetInfo(uid,DB_Name,msg.gameType,res,false,GameId)
        gamecommon.SendNet(uid,'GameOprateGame_S',res)
    else
        --进入普通游戏逻辑
        local res = PlayNormalGame(dataInfo,uid,msg.betIndex,msg.gameType,msg.isAdditional)
        WithdrawCash.GetBetInfo(uid,DB_Name,msg.gameType,res,true,GameId)
        gamecommon.SendNet(uid,'GameOprateGame_S',res)
    end
end

-- 注册消息解析
function RegisterProto()
    gamecommon.RegGame(GameId, GreatRhinoceros)
    gamecommon.GetModuleCfg(GameId,GreatRhinoceros)
end