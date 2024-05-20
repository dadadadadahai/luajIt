module('moneytree',package.seeall)

--获取图标随机位置,并维护empytPos
local function getRandomPos(emptyPos)
    local randIndex = math.random(#emptyPos)
    local pos = emptyPos[randIndex]
    table.remove(emptyPos,randIndex)
    return pos[1],pos[2]
end
--所有图标倍数+1
local function mulAddOne(chessdata,exceptMap)
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            local celloj = chessdata[col][row]
            if type(celloj)=='table' and exceptMap[col..'_'..row]==nil and not(celloj.val==81 and celloj.mul==0)then
                celloj.mul = celloj.mul +1
                chessdata[col][row]=celloj
            end
        end
    end
end

--获取一个格子的图标id值和倍数
local function getRespinVal()
    local respinoj= table_138_respin[gamecommon.CommRandInt(table_138_respin,'gailv')]
    return respinoj.iconId,respinoj.mul
end
--获取初始101图标倍数
local function getInitUNumMul()
    return table_138_respinInit[gamecommon.CommRandInt(table_138_respinInit,'gailv')].mul
end


--跑respin过程 imageType 2
function respin()
    --返回提
    local dis={}
    --初始化棋盘
    local chessdata ={}
    --随机空位
    local emptyPos = {}
    for col=1,6 do
        chessdata[col]={}
        for row=1,4 do
            chessdata[col][row] = 0
            table.insert(emptyPos,{col,row})
        end
    end
    --获取初始respin个数
    local uNum = table_138_buyfree[gamecommon.CommRandInt(table_138_buyfree,'gailv')].uNum
    for i=1,uNum do
        local col,row = getRandomPos(emptyPos)
        local mul = getInitUNumMul()
        --构建组合体
        chessdata[col][row]={val=101,mul=mul}
    end
    local lackTimes=3
    local lastchessdata = chessdata
    table.insert(dis,{lackTimes=3,chessdata=table.clone(chessdata),u2=0})
    --u2图标数量
    local u2=0
    local u2Compound={}
    while lackTimes>0 and #emptyPos>0 do
        local tolU2Compound={}
        local isNew = false
        local newU1Pos={}
        local newU1Map={}
        for i=#emptyPos,1,-1 do
            local iconId,mul =  getRespinVal()
            if iconId~=100 then
                isNew=true
                local pos= emptyPos[i]
                table.remove(emptyPos,i)
                --直接赋值为table
                if iconId==81 or iconId==82 then
                    chessdata[pos[1]][pos[2]]={val=iconId,mul = 0} 
                    if iconId==81 then
                        table.insert(newU1Pos,{pos[1],pos[2]})
                        newU1Map[pos[1]..'_'..pos[2]]=1
                    end
                else
                    chessdata[pos[1]][pos[2]]={val=iconId,mul = mul} 
                end
            end
        end
        local disItem={lackTimes=lackTimes,chessdata=table.clone(chessdata),u2=u2,u2Compound={},newU1Pos=newU1Pos}
        if isNew then
            lackTimes=3
            --棋盘处理
            chessdata,u2,disItem.u2Compound = handlechessdata(chessdata,newU1Map,u2)
            emptyPos = {}
            chessdataErgodic(chessdata,function (celloj,col,row)
                if celloj==0 then
                    table.insert(emptyPos,{col,row})
                end
            end)
        else
            lackTimes = lackTimes-1
        end
        disItem.lackTimes = lackTimes
        table.insert(dis,disItem)
        lastchessdata = chessdata
    end
    local tmul= 0
    --计算总倍数
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            local celloj = chessdata[col][row]
            if type(celloj)=='table'then
                tmul = tmul+celloj.mul
            end
        end
    end
    return dis,tmul,2
end

--棋盘遍历处理
function chessdataErgodic(chessdata,cellojFunc)
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            local celloj = chessdata[col][row]
            if cellojFunc~=nil then
                cellojFunc(celloj,col,row)
            end
        end
    end
end

--棋盘整体处理
function handlechessdata(chessdata,newU1Map,u2)
    --u2合并表
    local u2Compound = {}
    local findU1=function (ecol,erow)
        local otherU1={}
        chessdataErgodic(chessdata,function (celloj,col,row)
            if celloj~=0 and  not (col==ecol and row==erow) and celloj.val==81 and celloj.mul>0 then
                table.insert(otherU1,{col,row,celloj.mul})
            end
        end)
        return otherU1
    end
    local u1Handle=function (celloj,col,row)
        if celloj~=0 and celloj.val==81 and newU1Map[col..'_'..row]~=nil then
            --新u1,执行除自己以外的所有图标+1
            local exceptMap={}
            exceptMap[col..'_'..row]=1
            local otherU1 = findU1(col,row)
            if #otherU1>=2 then
                --需要执行合并
                local tmul = 0
                local item = {compoundPos={col,row},compoundArrs={}}
                for i=1,2 do
                    local value = otherU1[i]
                    tmul = tmul + value[3]
                    chessdata[value[1]][value[2]] = 0
                    table.insert(item.compoundArrs,{value[1],value[2]})
                end
                table.insert(u2Compound,item)
                chessdata[col][row]={val=101,mul=tmul}
                u2=u2+1
            else
                mulAddOne(chessdata,{})
                chessdata[col][row]={val=81,mul=1}
            end
        elseif celloj~=0 and celloj.val==82 then
            --u2处理
            chessdata[col][row]={val=101,mul=celloj.mul}
            u2=u2+1
        end
    end
    --执行u1合并处理
    chessdataErgodic(chessdata,u1Handle)
    --对u2加倍进行处理
    for i=1,u2 do
        mulAddOne(chessdata,{})
    end
    return chessdata,u2,u2Compound
end