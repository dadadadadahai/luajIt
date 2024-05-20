GameId = 113
local goldfiles = getDir('../game_slots/113-fivedragons')
for index, value in ipairs(goldfiles) do
    dofile(value)
end
--初始化
FiveDragons.RegisterProto()
local tNum = 100000
local sTime = os.clock()
local msg = {}
msg.gameId = GameId
msg.gameType = 1
msg.betIndex = 1
msg.extraData = {}
msg.extraData.choose = 3        -- 五种选择
while tNum > 0 do
    FiveDragons.CmdGameOprate(1, msg)
    if IsNormal() then
        tNum = tNum - 1
    end
end
OverShow()
local eTime = os.clock()
print('pTime='..eTime - sTime)
