GameId = 101
local goldfiles = getDir('../game_slots/105-beautydisco')
for index, value in ipairs(goldfiles) do
    dofile(value)
end
--初始化
beautydisco.RegisterProto()
local tNum = 1000
local sTime = os.clock()
local msg = {}
msg.gameId = GameId
msg.gameType = 1
msg.betIndex = 1
while tNum > 0 do
    beautydisco.CmdGameOprate(1, msg)
    if IsNormal() then
        tNum = tNum - 1
    end
end
OverShow()
local eTime = os.clock()
print('pTime='..eTime - sTime)
