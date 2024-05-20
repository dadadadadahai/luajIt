local lfs = require 'lfs_ffi'
local TestGameId = 0
function attrdir (path,tableName)
	if tableName==nil then
		tableName = {}	
	end
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                attrdir (f,tableName)
            else
				if string.sub(file,#file-3)=='.lua' then
					table.insert(tableName,f)
				end
            end
        end
    end
	return tableName
end
function getDir(path,tableName)
	if tableName==nil then
		tableName = {}	
	end
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                attrdir (f,tableName)
            else
				if string.sub(file,#file-3)=='.lua' then
					table.insert(tableName,f)
				end
            end
        end
    end
	return tableName
end
function getDirs(path,dirnames)
	if dirnames==nil then
		dirnames={}
	end
	for dir in lfs.dir(path) do
		if dir ~= "." and dir ~= ".." then
			local f = path..'/'..dir
			local attr = lfs.attributes (f)
			if attr.mode == "directory" then
				table.insert(dirnames,dir)
			end
		end
	end
	return dirnames
end
--初始化游戏列表
function initGameCode()
	local dirs = getDirs('game_slots')
	for _, value in ipairs(dirs) do
		if tonumber(string.sub(value,1,3))==TestGameId then
			local files = attrdir('game_slots/'..value)
			for _, f in ipairs(files) do
				-- print(f)
				dofile(f)
				-- dofile(string.format('game_slots/%s/%s',value,f))
			end
		end
	end
end
--初始化一些系统设置
function initSys()
	local files = attrdir('sys')
	for _, value in ipairs(files) do
		-- dofile('sys/'..value)
		dofile(value)
	end
	local gamecommon = attrdir('gamecommon')
	for _, value in ipairs(gamecommon) do
		-- dofile('sys/'..value)
		dofile(value)
	end
end
--初始化分析模块
function initParse()
	local files = attrdir('parse/'..TestGameId)
	for _, value in ipairs(files) do
		-- dofile('sys/'..value)
		-- print(value)
		if string.find(value,'start')==nil then
			dofile(value)
		end
	end
end
local function init()
	initSys()
	initGameCode()
	initParse()
	math.randomseed(os.time())
	local ModuleMap={
		[101] = goldenunicorn,
		[102] = CrazyTruck,
		[103] = happypumpkin,
		[104] = MayanMiracle,
		[105] = beautydisco,
		[106] =mariachi,
		[107] = Football,
		[108] = FruitParadise,
		[109] = cash,
		[110]  =cleopatra,
		[111] = OrchardCarnival,
		[112]  =NineLinesLegend,
		[113] = FiveDragons,
		[114] = FruitMachine,
		[115] = Avatares,
		[116] = LuckyWheel,
		[117] = FireCombo,
		[118] = chilli,
		[119] = LuckySeven,
		[121] = cleopatraNew,
		[122] = Apollo,
		[123] = corpse,
		[124] = AdventurousSpirit,
		[125] = rockgame,
		[126] = Fisherman,
		[127] = Tiger,
		[129] = CandyTouch,
		[130] = FortuneGem,
		[131] = GoldCow,
		[132] = Rabbit,
		[133] = Mouse,
		[134] = Dragon,
		[135] = Seven,
		[137] = Elephant,
		[160] = sweetBonanza,
		[161] = GreatRhinoceros,
	}
	local msg={
		gameId=TestGameId,
		gameType = 1,
		betIndex = 1,
		extraData = {choose = 1},
	}
	local sclock = os.clock()
	local obj = ModuleMap[TestGameId]
	obj.RegisterProto()
	while MaxNum > 0 do	
		obj.CmdGameOprate(1,msg)
		if IsNormal() then
			MaxNum = MaxNum - 1
		end
	end
	local eclock  = os.clock()
	-- print('over',eclock-sclock)
	OverShow()
end
tolXs=10000
MaxNum = 1000000
isBuyFree = false
TestGameId = 132
init()