GameId = 116
local goldfiles = getDir('../game_slots/116-luckywheel')
for index, value in ipairs(goldfiles) do
    dofile(value)
end
--初始化
LuckyWheel.RegisterProto()
local tNum = 100000
local sTime = os.clock()
local msg = {}
msg.gameId = GameId
msg.gameType = 1
msg.betIndex = 1
while tNum > 0 do
    LuckyWheel.CmdGameOprate(1, msg)
    if IsNormal() then
        tNum = tNum - 1
    end
end
OverShow()
local eTime = os.clock()
print('pTime='..eTime - sTime)
