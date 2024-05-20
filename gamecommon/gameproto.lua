--游戏通用变量定义
module('gamecommon', package.seeall)

--服务器启动完后注册网络消息
function RegGameNetCommand()
    --辣椒游戏
  --  GameChili.RegisterProto()
  goldenunicorn.RegisterProto()
  happypumpkin.RegisterProto()
  beautydisco.RegisterProto()
  mariachi.RegisterProto()
  -- 102 疯狂大卡车
  CrazyTruck.RegisterProto()
  -- 104 玛雅神迹
  MayanMiracle.RegisterProto()
  -- 107 足球
  Football.RegisterProto()
  -- 108 水果天堂
  FruitParadise.RegisterProto()
  cash.RegisterProto()
  cleopatra.RegisterProto()
  cacaNiQuEls.RegisterProto()
  PenaltyKick.RegisterProto()
  OrchardCarnival.RegisterProto()
  NineLinesLegend.RegisterProto()
  FiveDragons.RegisterProto()
  FruitMachine.RegisterProto()
  Avatares.RegisterProto()
  LuckyWheel.RegisterProto()
  miner.RegisterProto()
  FireCombo.RegisterProto()
  LuckySeven.RegisterProto()
  chilli.RegisterProto()
  -- cleopatraNew.RegisterProto()
  Apollo.RegisterProto()
end

