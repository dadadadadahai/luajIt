module('penguin',package.seeall)
LineNum = 1

local blueMap={
    [1]=1,
    [3]=1,
    [5]=1,
    [7]=1,
    [9]=1
}
function StartToImagePool()
    local imageType = 1
    local allMul = 0
    --  f blueNum blueMul purpleNum purpleMul
    local dis={b={},f={},c={}}
    --其他冰块
    local otherIce = {{1,2},{1,4},{2,1},{2,5},{4,1},{4,5},{5,2},{5,4}}
    local edgeIce = {{1,1},{1,5},{5,1},{5,5}}
    local chessdata=createChessdataAndIce(otherIce,edgeIce)
    --进行中奖判断
    local disAfter = gamecommon.AllLineDisEle({},{},table_144_paytable,chessdata,nil)
    local disNum,mul,posMap = calcMulAndDisNum(disAfter)
    --进行冰块消除处理
    local collectIconIds,disPoint = iceDis(disNum,otherIce,edgeIce,disAfter,posMap)
    table.insert(dis.b,{dis=disAfter,mul=mul,chessdata=table.clone(chessdata),disPoint=disPoint,collectIconIds=collectIconIds})
    -- allMul=allMul+mul
    allMul = sys.addToFloat(allMul,mul)
    while isContinueDis(disNum,otherIce,edgeIce) do
        chessdata=createChessdataAndIce(otherIce,edgeIce)
        disAfter = gamecommon.AllLineDisEle({},{},table_144_paytable,chessdata,nil)
        disNum,mul,posMap = calcMulAndDisNum(disAfter)
        -- allMul=allMul+mul
        allMul = sys.addToFloat(allMul,mul)
        collectIconIds,disPoint = iceDis(disNum,otherIce,edgeIce,disAfter,posMap)
        table.insert(dis.b,{dis=disAfter,mul=mul,chessdata=table.clone(chessdata),disPoint=disPoint,collectIconIds=collectIconIds})
    end
    --进入特殊模式
    if table.empty(edgeIce) then
        imageType=2
        local blueNum = 0
        local blueMul=2
        local purpleNum = 0
        local purpleMul = 1
        --初始化触发局
        local blueNum,blueMul,purpleNum,purpleMul = handleCollection(blueNum,blueMul,purpleNum,purpleMul,collectIconIds)
        dis.c={blueNum=blueNum,blueMul=blueMul,purpleNum=purpleNum,purpleMul=purpleMul}
        freeDis={}
        local tMul = 0
        while purpleMul>=0 do
            freeDis,tMul,blueNum,blueMul,purpleNum,purpleMul = oneFreeHandle(blueNum,blueMul,purpleNum,purpleMul)
            -- allMul=allMul+tMul
            allMul = sys.addToFloat(allMul,mul)
            table.insert(dis.f,{res=freeDis,purpleMul=purpleMul,tMul=tMul})
            purpleMul=purpleMul-1
        end
    end
    return dis,allMul,imageType
end

--function 一次free 处理
function oneFreeHandle(blueNum,blueMul,purpleNum,purpleMul)
    local dis={}
    local tMul = 0
    --产生棋盘
    local cols={5,5,5,5,5}
    local chessdata = gamecommon.CreateSpecialChessData(cols,table_144_free)
    local disAfter = gamecommon.AllLineDisEle({},{},table_144_paytable,chessdata,nil)
    local disNum,mul,posMap = calcMulAndDisNum(disAfter)
    mul = mul * blueMul
    local collectIconIds,disPoint = iceDis(disNum,{},{},disAfter,posMap)
    tMul=sys.addToFloat(tMul,mul)
    blueNum,blueMul,purpleNum,purpleMul = handleCollection(blueNum,blueMul,purpleNum,purpleMul,collectIconIds)
    table.insert(dis,{dis=disAfter,mul=mul,chessdata=table.clone(chessdata),collectIconIds=collectIconIds,blueNum=blueNum,blueMul=blueMul,purpleNum=purpleNum,purpleMul=purpleMul})
    while disNum>0 do
        chessdata=gamecommon.CreateSpecialChessData(cols,table_144_free)
        if tMul>=300 then
            for col=1,2 do
                for row=1,#chessdata[col] do
                    if col==1 then
                        chessdata[col][row] = math.random(5)
                    elseif col==2 then
                        chessdata[col][row] = math.random(6,10)
                    end
                end
            end
        end
        disAfter = gamecommon.AllLineDisEle({},{},table_144_paytable,chessdata,nil)
        disNum,mul,posMap = calcMulAndDisNum(disAfter)
        mul = mul * blueMul
        -- tMul=tMul+mul
        tMul=sys.addToFloat(tMul,mul)
        collectIconIds,disPoint = iceDis(disNum,{},{},disAfter,posMap)
        blueNum,blueMul,purpleNum,purpleMul = handleCollection(blueNum,blueMul,purpleNum,purpleMul,collectIconIds)
        table.insert(dis,{dis=disAfter,mul=mul,chessdata=table.clone(chessdata),collectIconIds=collectIconIds,blueNum=blueNum,blueMul=blueMul,purpleNum=purpleNum,purpleMul=purpleMul})
    end
    return dis,tMul,blueNum,blueMul,purpleNum,purpleMul
end
--处理收集
function handleCollection(blueNum,blueMul,purpleNum,purpleMul,collectIconIds)
    for _, value in ipairs(collectIconIds) do
        local iconId = value[3]
        if blueMap[iconId]~=nil then
            --收集蓝色
            blueNum=blueNum+1
            if blueNum>=10 then
                blueNum = 0
                blueMul=blueMul+1
            end
        else
            purpleNum=purpleNum+1
            if purpleNum>=10 then
                purpleNum=0
                purpleMul=purpleMul+1
            end
        end
    end
    return blueNum,blueMul,purpleNum,purpleMul
end



--判断是否可以继续消除函数  两个条件  disNum>0 collectIconIds 为空
function isContinueDis(disNum,otherIce,edgeIce)
    if disNum>0 and table.empty(edgeIce)==false then
        return true
    end
    return false
end


--冰块消除 
function iceDis(disNum,otherIce,edgeIce,dis,posMap)
    local randPosfunc=function (array)
        local arrayIndex = math.random(#array)
        local pos = array[arrayIndex]
        table.remove(array,arrayIndex)
        return pos
    end
    local realDis=  0
    local disPoint = {}
    for i=1,disNum do
        if #otherIce>0 then
            realDis=realDis+1
            local pos =randPosfunc(otherIce)
            table.insert(disPoint,pos)
        elseif #edgeIce>0 then
            realDis=realDis+1
            local pos =randPosfunc(edgeIce)
            table.insert(disPoint,pos)
        else
            --进入收集
            --触发新游戏
            break
        end
    end
    
    --收集的图标id
    local collectIconIds={}
    for col=1,5 do
        for row=1,5 do
            local collectIconId = posMap[col..'_'..row]
            if collectIconId~=nil then
                realDis=realDis-1
                if realDis<0 then
                    table.insert(collectIconIds,{col,row,collectIconId})
                end
            end
        end
    end
    return collectIconIds,disPoint
end

--计算中奖倍数和消除图标个数
function calcMulAndDisNum(dis)
    local posMap={}
    local disNum = 0
    local mul = 0
    for _,value in ipairs(dis) do
        mul = value.mul + mul
        for _,val in ipairs(value.eliminateHandle) do
            if posMap[val.c..'_'..val.r]==nil then
                posMap[val.c..'_'..val.r]=val.iconId
                disNum = disNum + 1
            end
        end
    end
    return disNum,mul,posMap
end
--生成棋盘并进行冰块处理
function createChessdataAndIce(otherIce,edgeIce)
    local cols={5,5,5,5,5}
    local chessdata = gamecommon.CreateSpecialChessData(cols,table_144_normalspin)
    --填充冰块
    for _,value in ipairs(otherIce) do
        local col,row = value[1],value[2]
        chessdata[col][row] = 0
    end
    for _,value in ipairs(edgeIce) do
        local col,row = value[1],value[2]
        chessdata[col][row] = 0
    end
    return chessdata
end