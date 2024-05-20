module('luckstar',package.seeall)
LineNum = 20
--142幸运星
function StartToImagePool()
    local cols={4,4,4,4,4}
    local chessdata = gamecommon.CreateSpecialChessData(cols,table_142_normalspin)
    --判断中奖
    local wild={
        [90] = 1
    }
    local nowild={
        [70] = 1
    }
    local resdata = gamecommon.WiningLineFinalCalc(chessdata, table_142_payline, table_142_paytable, wild, nowild)
    local mul = 0
    local serverMul = 0
    local winLines ={}
    for _, value in ipairs(resdata) do
        mul = mul+value.mul
        table.insert(winLines, { value.line, value.num, value.mul, value.ele })
    end
    --计算7号元素倍数
    local serverNum = 0
    for col=1,#chessdata do
        for row=1,#chessdata[col] do
            if chessdata[col][row]==7 then
                serverNum=serverNum+1
            end
        end
    end
    if table_142_severPayMul[7]['c'..serverNum]~=nil and table_142_severPayMul[7]['c'..serverNum]>0 then
        serverMul= table_142_severPayMul[7]['c'..serverNum]
        mul = mul + serverMul
    end
    local resdata={
        chessdata=chessdata,
        winLines=winLines,
        serverMul=serverMul,
    }
    return resdata,mul/LineNum,1
end