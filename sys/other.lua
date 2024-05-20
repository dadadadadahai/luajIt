chessuserinfodb={}
BackpackMgr={}
gameDetaillog={}
WithdrawCash={}
chessutil={}
function import(sModule)
    return require(sModule)
end
chessuserinfodb.WChipsChange =function ()
    return 0,true
end
chessuserinfodb.GetAHeadTolScore=function (uid)
    return 1000
end
chessuserinfodb.RUserChipsGet=function (uid)
    return 1000
end
BackpackMgr.GetRewardGood=function (id, gType,winScore,reson)
    
end
gameDetaillog.SaveDetailGameLog=function ()
    
end
WithdrawCash.GetBetInfo=function ()
    
end
chessuserinfodb.RUserGameControl=function ()
    return 0
end

function chessutil.NotRepeatRandomNumbers(min, max, n)
	-- --必须写这个，或者有其他的写法，这个是设置时间的，没有这个每次随即出来的数都会一样
	-- math.randomseed(tostring(os.time()):reverse():sub(1, 7)) --设置时间种子
	local tb = {}
	while #tb < n do 
		local istrue = false
		local num = math.random( min,max )
		if #tb ~= nil then
			for i = 1 ,#tb do
				if tb[i] == num then
					istrue = true
				end
			end
		end
		if istrue == false then
			table.insert( tb, num )
		end
	end
	return tb
end