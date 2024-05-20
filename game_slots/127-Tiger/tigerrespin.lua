-- 老虎游戏模块
module('Tiger', package.seeall)
--老虎Respin游戏
function PlayRespinGame(tigerInfo,uid,gameType)
    -- 游戏后台记录所需初始信息
    local sTime = os.time()
    local reschip = chessuserinfodb.RUserChipsGet(uid)
    -- 获取本次Respin的结果
    tigerInfo.respin = table.clone(tigerInfo.bres[1])
    table.remove(tigerInfo.bres,1)
    tigerInfo.boards = tigerInfo.respin.boards

    -- 生成中奖线
    local winlines = {}
    winlines[1] = {}
    tigerInfo.winlines = tigerInfo.respin.winlines or winlines

    -- 返回数据
    local res = GetResInfo(uid, tigerInfo, gameType, nil, {})
    -- 判断是否结算
    if tigerInfo.respin.lackTimes <= 0 then
        res.features.respin.tWinScore = tigerInfo.respin.tWinScore or 0
        if tigerInfo.respin.tWinScore > 0 then
            -- 获取奖励
            BackpackMgr.GetRewardGood(uid, Const.GOODS_ID.GOLD_BASE, tigerInfo.respin.tWinScore, Const.GOODS_SOURCE_TYPE.TIGER)
        end
    end

    -- 游戏未结算金额为0
    res.winScore = 0
    res.winlines = tigerInfo.winlines
    -- respin模式固定发false
    -- res.bigWinIcon = bigWinIcon
    -- 增加后台历史记录
    gameDetaillog.SaveDetailGameLog(
        uid,
        sTime,
        GameId,
        gameType,
        tigerInfo.betMoney,
        reschip,
        chessuserinfodb.RUserChipsGet(uid),
        0,
        {type='respin',chessdata = tigerInfo.respin.boards,totalTimes=tigerInfo.respin.totalTimes,lackTimes=tigerInfo.respin.lackTimes,tWinScore=tigerInfo.respin.tWinScore},
        {}
    )
    if tigerInfo.respin.lackTimes <= 0 then
        tigerInfo.respin = {}
        tigerInfo.bres = {}
    end
    res.boards = {tigerInfo.boards}
    -- 保存数据库信息
    SaveGameInfo(uid,gameType,tigerInfo)
    return res
end

-- 计算respin最终棋盘
function RespinFinalBoards()
    -- 获取W元素
    local wilds = {}
    wilds[W] = 1
    local nowild = {}
    local boards = {}
    local respinIconId = table_127_respinicon[gamecommon.CommRandInt(table_127_respinicon, 'pro')].iconId
    -- 空白图标判断
    local blankIconFlag = false
    local respinMul = 1
    local bigWinIcon = -1
    
    for col = 1,#DataFormat do
        if boards[col] == nil then
            boards[col] = {}
        end
        for row = 1,DataFormat[col] do
            local iconId = table_127_respin[gamecommon.CommRandInt(table_127_respin, 'pro')].result
            if iconId == 1 then
                boards[col][row] = 0
                blankIconFlag = true
            elseif iconId == 2 then
                boards[col][row] = respinIconId
            elseif iconId == 3 then
                boards[col][row] = W
            end
          
        end
    end
    -- 获取中奖线
    local reswinlines = {}
    reswinlines[1] = {}


    if respinIconId <= 4 then
        local wildNum = math.random(0,3)
        local wildPoint = chessutil.NotRepeatRandomNumbers(1, 6, wildNum)
        table.sort(wildPoint)
        local insertPoint = 1
        for col = 2, 3 do
            for row = 1,DataFormat[col] do
                if insertPoint == wildPoint then
                    boards[col][row] = W
                end
                insertPoint = insertPoint + 1
            end
        end
    end


    -- 中奖金额
    local winMul = 0
    -- 计算中奖倍数
    local winlines = gamecommon.WiningLineFinalCalc(boards,table_127_payline,table_127_paytable,wilds,nowild)
    -- 计算中奖线金额
    for k, v in ipairs(winlines) do
        table.insert(reswinlines[1], {v.line, v.num, v.mul,v.ele})
        winMul = sys.addToFloat(winMul,v.mul)
    end
    -- 如果填满则奖励*10
    if IsAllWinPoints(boards,{}) then
        respinMul = 10
        winMul = winMul * respinMul
		bigWinIcon =  respinIconId
    end

    local res = {
        respinIconId = respinIconId,
		respinMul = respinMul,
        boards = boards,
        winMul = winMul ,
        winlines = reswinlines,
        bigWinIcon = bigWinIcon,
		respinFlag = true,
    }
    return res
end

-- 预计算respin
function AheadRespin(res)
    local finalBoards = table.clone(res.boards)
	-- 保存本次随机的结果
    local bres = {}
	table.insert(bres,{boards = table.clone(res.boards),winlines =table.clone(res.winlines) })
	--一共修改几次
	local canchanglist = {}
	for col = 1,#DataFormat do
		for row = 1,DataFormat[col] do
			if finalBoards[col][row] ~= 0 then
				table.insert(canchanglist,{col,row})
			end
		end
	end
	local totalTimes = math.random(3)+1
	if totalTimes > #canchanglist then
		totalTimes = #canchanglist
	end 
	for i=1,totalTimes do
	    local wilds = {}
		wilds[W] = 1
		local nowild = {}
		local curres = { }
		curres.boards = table.clone(finalBoards)
		curres.winlines={}
		curres.winlines[1]={}
        -- 本轮是否有修改
		if math.random(10000) < 7000 then 
			local ckey =   table.choice(canchanglist)
			local cval = table.remove(canchanglist,ckey)
			curres.boards[cval[1]][cval[2]] = 0 
		end 
		-- 计算中奖倍数
		local winlines = gamecommon.WiningLineFinalCalc(curres.boards,table_127_payline,table_127_paytable,wilds,nowild)

		-- 计算中奖线金额
		for k, v in ipairs(winlines) do
			table.insert(curres.winlines[1], {v.line, v.num, v.mul,v.ele})
			winMul = sys.addToFloat(winMul,v.mul)
		end
        table.insert(bres,curres)
		finalBoards = table.clone(curres.boards)
	end
	--倒序
	local curbres = {}
	for j=#bres,1,-1 do
		table.insert(curbres,bres[j])
	end
	local  resultRespin =  table.remove(curbres,1)
	for i, respinInfo in ipairs(curbres) do
		-- 修改总次数
		--respinInfo.totalTimes = totalTimes
		--respinInfo.lackTimes = totalTimes-i 
	end
    return {
        bres = curbres,
        resultRespin = resultRespin,
    }
end