
module('MasterJoker', package.seeall)
DB_Name = "game164masterjoker"

GameId = 164
S = 70
W = 90
DataFormat = {1,1,1,1,1}    -- 棋盘规格
Table_Base = import "table/game/164/table_164_hanglie"                        -- 基础行列
--执行金牛图库
function StartToImagePool(imageType)
    return Normal()
end
--判断是否可消除倍数  返回val
function getDisMul(boards)
	local numMap = {}
    for col = 1, #boards do
        for row = 1, #boards[col] do
            local val = boards[col][row]
            numMap[val] = numMap[val] or 0
            numMap[val] = numMap[val] + 1
        end
    end
    local disNums = {  3, 4,5 }
	local dis = { }
	local Wnums = numMap[W] or 0 
    for key, num in pairs(numMap) do
        for i = #disNums, 1, -1 do
			local mulIndex = disNums[i]
            if num+Wnums >= mulIndex then
                if table_164_paytable[key] ~= nil and table_164_paytable[key]['c' .. mulIndex] > 0 then
                    --可以消除
                    table.insert(dis, {ele = key,num=num,mul = table_164_paytable[key]['c' .. mulIndex]})
                    break
                end
            end
        end
    end
	return dis
end
function Normal()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}
    -- 生成返回数据
    local res = {}
    -- 获取中奖线
    res.winlines = {}
    local winMul = 0
    local imageType = 1
    -- respin中奖金额
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_164_normalspin)
	-- 计算中奖倍数
	local winlines = getDisMul(boards)

	-- 计算中奖线金额
	for k, v in ipairs(winlines) do
		table.insert(res.winlines, {0, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
    -- 棋盘数据
    res.boards = boards
	res.winMul = winMul
	res.specialmul = 0
	if winMul >0 and check_S(boards) then
		res.specialmul =  table_164_mulPro[gamecommon.CommRandInt(table_164_mulPro, 'pro')].mul
		winMul = winMul * res.specialmul
		imageType = 2
	end 
    return res, winMul, imageType
end
function check_S(boards)
	return boards[3][1] == W
end 