GameId = 117
local goldfiles = getDir('../game_slots/118-chilli')
for index, value in ipairs(goldfiles) do
    dofile(value)
end
--初始化
FireCombo.RegisterProto()
local tNum = 100000
local sTime = os.clock()
local msg = {}
msg.gameId = GameId
msg.gameType = 1
msg.betIndex = 1
while tNum > 0 do
    FireCombo.CmdGameOprate(1, msg)
    if IsNormal() then
        tNum = tNum - 1
    end
end
OverShow()
local eTime = os.clock()
print('pTime='..eTime - sTime)
