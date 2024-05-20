GameId = 103
local goldfiles = getDir('../game_slots/103-happypumpkin')
for index, value in ipairs(goldfiles) do
    dofile(value)
end
--初始化
happypumpkin.RegisterProto()
local tNum = 1000
local sTime = os.clock()
local msg = {}
msg.gameId = GameId
msg.gameType = 1
msg.betIndex = 1
while tNum > 0 do
    happypumpkin.CmdGameOprate(1, msg)
    if IsNormal() then
        tNum = tNum - 1
    end
end
OverShow()
local eTime = os.clock()
print('pTime='..eTime - sTime)
