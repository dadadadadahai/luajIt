-- 兔子游戏模块
module('Rabbit', package.seeall)
-- 兔子所需数据库表名称
DB_Name = "game132rabbit"
-- 兔子通用配置
GameId = 132
S = 70
W = 90
U = 80
DataFormat = {3,4,3}    -- 棋盘规格
Table_Base = import "table/game/132/table_132_hanglie"                        -- 基础行列
Table_mulPro = import "table/game/132/table_132_mulPro"  
spuriousPro  =  Table_mulPro and  (Table_mulPro[1].spuriousPro or 100  ) or 100
MaxNormalIconId = 6
LineNum = Table_Base[1].linenum

function StartToImagePool(imageType)
	if imageType == 2 then 
		return  Free()
	elseif imageType == 3 then 
		return   FullIcon()
	end
    return Normal()
end
function Free()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}
    local isFree = false
    local iconsAttachData = {}
    local imageType = 2
    -- 判断是否进入免费
	local freeInfo = {}
	local tWinMul = 0
	for i = 1, table_132_respinPro[1].num do
		boards = {}
		iconsAttachData = {}
		local uNum = table_132_respinIcon[gamecommon.CommRandInt(table_132_respinIcon, 'pro')].uNum
		local uList = chessutil.NotRepeatRandomNumbers(1, 10, uNum)
		--进行排序
		table.sort(uList, function(a, b)
			return a < b
		end)
		local insertPoint = 0
		local listPoint = 1
		-- 遍历棋盘对应位置插入U图标
		for col = 1, #DataFormat do
			for row = 1, DataFormat[col] do
				if boards[col] == nil then
					boards[col] = {}
				end
				insertPoint = insertPoint + 1
				if insertPoint == uList[listPoint] then
					boards[col][row] = U
					listPoint = listPoint + 1
				else
					boards[col][row] = 88
				end
			end
		end
		
		-- 根据棋盘中U图标生成对应数据
		GetIconInfoU(boards,iconsAttachData)
	
		-- 计算中奖倍数
		local winlines = gamecommon.WiningLineFinalCalc(boards,table_132_payline,table_132_paytable,wilds,nowild)
	
		-- 中奖金额
		local winMul = 0
		-- -- 获取中奖线
	
		local winMulU = GetWinScoreU(iconsAttachData)
		winMul = sys.addToFloat(winMul,winMulU)
		-- 生成返回数据
		table.insert(freeInfo,{
			-- winlines = winlines,
			boards = boards,
			winMul = winMul,
			iconsAttachData = iconsAttachData,
		})
		tWinMul = tWinMul + winMul
	end
	local res = {
		freeInfo = freeInfo,
		isfake = 0 ,
	}
	
	return res, tWinMul, imageType

end
function FullIcon()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}
    local isFree = false
    local iconsAttachData = {}
    local imageType = 1
    -- 判断是否进入免费
   
	-- 生成异形棋盘
	boards = gamecommon.CreateSpecialChessData(DataFormat,table_132_normalspin)
	-- 根据棋盘中U图标生成对应数据
	GetIconInfoU(boards,iconsAttachData)
	-- 计算中奖倍数
	local resultWinlines = gamecommon.WiningLineFinalCalc(boards,table_132_payline,table_132_paytable,wilds,nowild)
	-- 中奖金额
	local winMul = 0
	-- 获取中奖线
	local winlines = {}
	winlines[1] = {}
	-- 计算中奖线金额
	for k, v in ipairs(resultWinlines) do
		table.insert(winlines[1], {v.line, v.num, v.mul,v.ele})
		winMul = sys.addToFloat(winMul,v.mul)
	end
	-- 倍数除以线数
	winMul = winMul 
	-- 判断U图标中奖金额
	local winMulU = GetWinScoreU(iconsAttachData)
	if winMulU > 0 then
		imageType = 3
	end
	winMul = sys.addToFloat(winMul,winMulU)
	-- 生成返回数据
	local res = {
		winlines = winlines,
		boards = boards,
		iconsAttachData = iconsAttachData,
		isfake =  0
	}
	return res, winMul, imageType
   

end
function Normal()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    -- 初始棋盘
    local boards = {}
    local isFree = false
    local iconsAttachData = {}
    local imageType = 1
    -- 判断是否进入免费
    if math.random(10000) <= table_132_respinPro[1].pro then
        isFree = true
    end
    if isFree then
        imageType = 2
        local freeInfo = {}
        local tWinMul = 0
        for i = 1, table_132_respinPro[1].num do
            boards = {}
            iconsAttachData = {}
            local uNum = table_132_respinIcon[gamecommon.CommRandInt(table_132_respinIcon, 'pro')].uNum
            local uList = chessutil.NotRepeatRandomNumbers(1, 10, uNum)
            --进行排序
            table.sort(uList, function(a, b)
                return a < b
            end)
            local insertPoint = 0
            local listPoint = 1
            -- 遍历棋盘对应位置插入U图标
            for col = 1, #DataFormat do
                for row = 1, DataFormat[col] do
                    if boards[col] == nil then
                        boards[col] = {}
                    end
                    insertPoint = insertPoint + 1
                    if insertPoint == uList[listPoint] then
                        boards[col][row] = U
                        listPoint = listPoint + 1
                    else
                        boards[col][row] = 88
                    end
                end
            end
            
            -- 根据棋盘中U图标生成对应数据
            GetIconInfoU(boards,iconsAttachData)
        
            -- 计算中奖倍数
            local winlines = gamecommon.WiningLineFinalCalc(boards,table_132_payline,table_132_paytable,wilds,nowild)
        
            -- 中奖金额
            local winMul = 0
            -- -- 获取中奖线
            -- local winlines = {}
            -- winlines[1] = {}
            -- -- 计算中奖线金额
            -- for k, v in ipairs(winlines) do
            --     table.insert(winlines[1], {v.line, v.num, v.mul,v.ele})
            --     winMul = sys.addToFloat(winMul,v.mul)
            -- end
            -- -- 倍数除以线数
            -- winMul = winMul / table_132_hanglie[1].linenum
            -- 判断U图标中奖金额
            local winMulU = GetWinScoreU(iconsAttachData)
            winMul = sys.addToFloat(winMul,winMulU)
            -- 生成返回数据
            table.insert(freeInfo,{
                -- winlines = winlines,
                boards = boards,
                winMul = winMul,
                iconsAttachData = iconsAttachData,
            })
            tWinMul = tWinMul + winMul
        end
        local res = {
            freeInfo = freeInfo,
        }
      
        
        return res, tWinMul, imageType

    else
        -- 生成异形棋盘
        boards = gamecommon.CreateSpecialChessData(DataFormat,table_132_normalspin)
        -- 根据棋盘中U图标生成对应数据
        GetIconInfoU(boards,iconsAttachData)
        -- 计算中奖倍数
        local resultWinlines = gamecommon.WiningLineFinalCalc(boards,table_132_payline,table_132_paytable,wilds,nowild)
        -- 中奖金额
        local winMul = 0
        -- 获取中奖线
        local winlines = {}
        winlines[1] = {}
        -- 计算中奖线金额
        for k, v in ipairs(resultWinlines) do
            table.insert(winlines[1], {v.line, v.num, v.mul,v.ele})
            winMul = sys.addToFloat(winMul,v.mul)
        end
        -- 判断U图标中奖金额
        local winMulU = GetWinScoreU(iconsAttachData)
        if winMulU > 0 then
            imageType = 3
        end
        winMul = sys.addToFloat(winMul,winMulU)
        -- 生成返回数据
        local res = {
            winlines = winlines,
            boards = boards,
            iconsAttachData = iconsAttachData,
			isfake =  (imageType == 1 and  (math.random(10000) > spuriousPro   and 0 or  math.random(2)  )  or 0)
        }
        return res, winMul, imageType
    end

end