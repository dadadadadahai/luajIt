--时间管理模块
module('pockergameframe',package.seeall)
--启动时间脉冲函数  最小100ms
-- unilight.addtimermsec("pockergameframe.Pluse", 100)


PockRoomList={}
--进入时间
function RegPluseObj(PockerRoomMgr)
    table.insert(PockRoomList,PockerRoomMgr)
end
function Pluse()
    local timeNow = os.msectime()
    for _,obj in ipairs(PockRoomList) do
        obj:Pluse(timeNow)
    end
end