module('CandyTouch',package.seeall)
--逻辑处理函数
function LogicProcess(chessdata,lastColRow,spin,doubleMaps)
    local disInfo={}
    local gteFiveIconIdAndPos = {}
    --统计五个以上的连接
    gteFiveIconIdAndPos = SameIconProcess(chessdata)
    local resultChessdata=chessdata
    while #gteFiveIconIdAndPos>0 do
        --计算要当前要消除的倍数
        local infos =  CalcPayMul(gteFiveIconIdAndPos,doubleMaps)
        --产生新棋盘
        local newchessdata,clearPos = DropChessAndFill(resultChessdata,gteFiveIconIdAndPos,lastColRow,spin)
        resultChessdata = newchessdata
        -- table.insert(disInfo,{chessdata = newchessdata,infos=infos,clearPos=clearPos})
        table.insert(disInfo,{chessdata = newchessdata,infos=infos})
        gteFiveIconIdAndPos = SameIconProcess(newchessdata)
    end
    return disInfo,resultChessdata
end
--处理棋盘下落,生成新棋盘
function DropChessAndFill(chessdata,gteFiveIconIdAndPos,lastColRow,spin)
    --消除的坐标点
    local clearPos = {}
    local newChessData = table.clone(chessdata)
    for _, value in ipairs(gteFiveIconIdAndPos) do
        for _,pos in ipairs(value.pos) do
            local col,row = pos[1],pos[2]
            newChessData[col][row] = 0
            table.insert(clearPos,{col,row})
        end
    end
    --执行下落
    for col=1,#newChessData do
        local dropNum = 0
        local row= 1
        local tNum = #newChessData[col]
        while row<=tNum do
            local iconId = newChessData[col][row]
            if iconId==0 then
                dropNum = dropNum + 1
                for r=row,tNum-1 do
                    newChessData[col][r] = newChessData[col][r+1]
                end
                newChessData[col][tNum] = 0
                tNum = tNum-1
            else
                row = row + 1
            end
        end
        --填充该列数据
        local zeroRow = 0
        tNum = #newChessData[col]
        for r=1,tNum do
            if newChessData[col][r]==0 then
                zeroRow = r
                break
            end
        end
        if zeroRow>0 then
            local startIndex =  lastColRow[col]
            local index = 1
            for r=zeroRow,tNum do
                startIndex = startIndex - 1
                if startIndex<1 then
                    startIndex = #spin
                end
                newChessData[col][r] = spin[startIndex]['c'..col]
                -- -----------------------Test----------------------------
                -- if math.random(100) <= 90 then
                --     newChessData[col][r] = 3
                -- end
                -- -----------------------Test----------------------------
            end
            lastColRow[col] = startIndex
        end
    end
    return newChessData,clearPos
end

--计算赔付倍数
function CalcPayMul(gteFiveIconIdAndPos,doubleMaps)
    local result={}
    local mulcfgNum={5,6,7,8,9,12,15,20,25}
    local getCNum = function (num)
        if num>=mulcfgNum[#mulcfgNum] then
            return mulcfgNum[#mulcfgNum]
        end
        for i=1,#mulcfgNum-1 do
            if num>=mulcfgNum[i] and num<mulcfgNum[i+1] then
                return mulcfgNum[i]
            end
        end
    end

    for _,value in ipairs(gteFiveIconIdAndPos) do
        local iconId = value.iconId
        local num= value.num
        local cnum = getCNum(num)
        -- 获取缓存倍数
        local sumDoubleMul = 1
        for _, pos in ipairs(value.pos) do
            local doubleMul = GetDoubleMul(doubleMaps[pos[1]][pos[2]])
            if doubleMul > 1 then
                if sumDoubleMul == 1 then
                    sumDoubleMul = doubleMul
                else
                    sumDoubleMul = sumDoubleMul + doubleMul
                end
            end
            -- 执行标记翻倍缓存
            doubleMaps[pos[1]][pos[2]] = doubleMaps[pos[1]][pos[2]] + 1 or 0
        end

        print("iconId = "..iconId)
        print("cnum = "..cnum)
        if table_129_paytable[iconId]['c'..cnum] then
            -- table.insert(result,{iconId=iconId,num=num,mul=table_129_paytable[iconId]['c'..cnum],sumDoubleMul = sumDoubleMul,clearPos=value.pos,doubleMaps = table.clone(doubleMaps)})
            table.insert(result,{iconId=iconId,num=num,mul=table_129_paytable[iconId]['c'..cnum],sumDoubleMul = sumDoubleMul,clearPos=value.pos,val=cnum})
        end

        -- for _, pos in ipairs(value.pos) do
        -- end

    end
    return result
end
--一个棋盘同样的icon处理
function SameIconProcess(chessdata)
    local tmpIconRecord = {}    --未处理位置记录
    for col=1,#chessdata do
        tmpIconRecord[col] = {}
        for row=1,#chessdata[col] do
            tmpIconRecord[col][row] = 0
        end
    end
    --大于5个的图标和坐标
    local gteFiveIconIdAndPos={}
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            if tmpIconRecord[col][row]==0 then
                --开始处理
                
                local iconId = chessdata[col][row]
                local IconPosArrays={}
                if iconId~=90 then
                    tmpIconRecord[col][row] = 1
                end
                if iconId~=90 then
                    StartSame(iconId,{col,row},IconPosArrays,tmpIconRecord,chessdata)
                    for c=1,#chessdata do
                        for r=1,#chessdata[c] do
                            if chessdata[c][r]==90 then
                                tmpIconRecord[c][r] = 0
                            end
                        end
                    end
                end
                if #IconPosArrays>=5 then
                    table.insert(gteFiveIconIdAndPos,{iconId=iconId,pos=IconPosArrays,num=#IconPosArrays})
                end
            end
        end
    end
    return gteFiveIconIdAndPos
end
--查找连续性区域
function StartSame(iconId,pos,IconPosArrays, tmpIconRecord,chessdata)
    local col,row = pos[1],pos[2]
    --向左寻找
    local leftFind=function ()
        local tmpcol = col - 1
        if tmpcol>=1 then
            if (chessdata[tmpcol][row]==iconId or chessdata[tmpcol][row]==90) and tmpIconRecord[tmpcol][row]==0 then
                tmpIconRecord[tmpcol][row] = 1
                --执行递归
                StartSame(iconId,{tmpcol,row},IconPosArrays,tmpIconRecord,chessdata)
            end
        end
    end
    --向右寻找
    local rightFind = function ()
        local tmpcol = col + 1
        if tmpcol<=#chessdata then
            if (chessdata[tmpcol][row]==iconId or chessdata[tmpcol][row]==90) and tmpIconRecord[tmpcol][row]==0 then
                tmpIconRecord[tmpcol][row] = 1
                --执行递归
                StartSame(iconId,{tmpcol,row},IconPosArrays,tmpIconRecord,chessdata)
            end
        end
    end
    --向上寻找
    local topFind=function ()
        local tmprow = row + 1
        if tmprow<=8 then
            if (chessdata[col][tmprow]==iconId or chessdata[col][tmprow]==90) and tmpIconRecord[col][tmprow]==0 then
                tmpIconRecord[col][tmprow] = 1
                --执行递归
                StartSame(iconId,{col,tmprow},IconPosArrays,tmpIconRecord,chessdata)
            end
        end
    end
    --向下寻找
    local downFind=function ()
        local tmprow = row - 1
        if tmprow>=1 then
            if (chessdata[col][tmprow]==iconId or chessdata[col][tmprow]==90)and tmpIconRecord[col][tmprow]==0 then
                tmpIconRecord[col][tmprow] = 1
                --执行递归
                StartSame(iconId,{col,tmprow},IconPosArrays,tmpIconRecord,chessdata)
            end
        end
    end
    leftFind()
    rightFind()
    topFind()
    downFind()
    table.insert(IconPosArrays,{col,row})
end

function GetDoubleMul(doubleNum)
    local doubleMul = 1
    for _, value in ipairs(table_129_mul) do
        if doubleNum == value.num then
            doubleMul = value.mul
        end
    end
    return doubleMul
end