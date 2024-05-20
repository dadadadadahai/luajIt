cjson =require 'cjson'
function attrdir(dirs)
	local files = sys.getDirFiles(dirs, '.lua')
	return files
end

--初始化一些系统设置
function initSys()
	local files = sys.getDirFiles('sys', '.lua')
	for _, value in ipairs(files) do
		-- dofile('sys/'..value)
		dofile(value)
	end
	local gamecommon = sys.getDirFiles('gamecommon', '.lua')
	for _, value in ipairs(gamecommon) do
		-- dofile('sys/'..value)
		dofile(value)
	end
end

--初始化游戏
function initGameCode()
	local dirs = sys.getDirs('game_slots')
	for _, value in ipairs(dirs) do
		if tonumber(string.sub(value, 1, 3)) == TestGameId then
			local files = sys.getDirFiles('game_slots/' .. value, '.lua')
			for _, f in ipairs(files) do
				-- print(f)
				dofile(f)
				-- print('f end')
			end
		end
	end
end

--判断是否需要启用倍数控制
function isCheckMul(gameOj, imageType, FinMul)
	if ischecked then
		--构建查询表明
		local key = string.format("%d%s", imageType, FinMul)
		if roleMulMap[key] ~= nil then
			local maxNum = roleMulMap[key]
			if mulMap[FinMul] < maxNum then
				return true
			end
		end
		return false
	end
	return true
end

function initMulConfig(gameOj)
	local tablename = string.format('table_%d_imageS', TestGameId)
	local tableoj = gameOj[tablename]
	for _, value in ipairs(tableoj) do
		local i = 1
		local fieldType = 'type' .. i
		local fieldLimit = 'limit' .. i
		while value[fieldType] ~= nil do
			--构建key
			local key = string.format("%d%s", i, tostring(value[fieldType]))
			if value[fieldLimit] >= 0 then
				roleMulMap[key] = value[fieldLimit]
			end
			i = i + 1
			fieldType = 'type' .. i
			fieldLimit = 'limit' .. i
		end
	end
end

--获取数据库已保存图库倍数数量
function getExistMul()
	local muls = sys.getMulMap(TestGameId,imageType)
	for index, value in ipairs(muls) do
		mulMap[tostring(value._id)] = value.mulNum
	end
end
function GetRealMul(Mul,gameOj)
	local hangliename = string.format('table_%d_hanglie',TestGameId)
	local hanglie = gameOj[hangliename]
	local line = hanglie[1].linenum
	return  Mul/line

end
--主入口函数
function main()
	-- print('init')
	initSys()
	-- print('init 75')
	initGameCode()
	getExistMul()
	-- print('exist')
	local gameModuleMap = {
		[121] = cleopatraNew,
		[127] = Tiger,
		[131] = GoldCow,
		[132] = Rabbit,
		[133] = Mouse,
		[134] = Dragon,
		[136] = dragon,
		[137] = Elephant,
		[138] = moneytree,
		[139] = dragontriger,
		[140] = moneyPig,
		[141] = ghost,
		[142] = luckstar,
		[143] = marry,
		[144] = penguin,
		[145] = animal,
		[151] = cashwheel,
		[160] = sweetBonanza,
		[161] = GreatRhinoceros,
		[162] = fruitparty2,
	}
	math.randomseed(os.time())
	local gameOj = gameModuleMap[TestGameId]
	gamecommon.GetModuleCfg(TestGameId, gameOj)
	--初始化跑图个数配置
	initMulConfig(gameOj)
	local rTimes = 0
	while true do
		-- print('loop start')
		local disInfos, FinMul, tmpimageType = gameOj.StartToImagePool(imageType)
		if tmpimageType == imageType or imageType == 0 then
			FinMul = tostring(GetRealMul(FinMul,gameOj))
			mulMap[FinMul] = mulMap[FinMul] or 0
			if isCheckMul(gameOj, tmpimageType, FinMul) then
				-- print('tmpimageType',tmpimageType,FinMul,cjson.encode(disInfos))
				mulMap[FinMul] = mulMap[FinMul] + 1
				sys.saveToPool(TestGameId, tmpimageType, isGzip, tonumber(FinMul), disInfos)
				rTimes = rTimes + 1
				if rTimes >= RunTimes then
					break
				end
			end
		end

		-- print('loop end')
	end
end

mulMap = {}
roleMulMap = {}
isGzip = 0
--循环次数
RunTimes = 10200
--图库产生逻辑
imageType =  1
TestGameId = 160
ischecked = false
print('run start')
main()
print('run end')
-- readByLines()