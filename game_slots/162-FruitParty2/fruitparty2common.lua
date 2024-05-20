module('fruitparty2', package.seeall)
Table = 'game162fruitparty2'
LineNum = 1
GameId = 162
J = 100
S = 70
-- fruitparty2
function Get(gameType, uid)
    local datainfos = unilight.getdata(Table, uid)
    if table.empty(datainfos) then
        datainfos = {
            _id = uid,
            roomInfo = {}
        }
        unilight.savedata(Table, datainfos)
    end
    if table.empty(datainfos.roomInfo[gameType]) then
        local rInfo = {
            betindex = 1,
            betMoney = 0,
            free={},            --免费模式
            isInHight=0,        --是否处于高下注模式 0:不是 1:是
        }
        datainfos.roomInfo[gameType] = rInfo
        unilight.update(Table, datainfos._id, datainfos)
    end
    local datainfo = datainfos.roomInfo[gameType]
    return datainfo, datainfos
end
--购买高中奖率
function BuyHighBet(highLevel,datainfo,datainfos)
    datainfo.isInHight = highLevel
    unilight.update(Table, datainfos._id, datainfos)
    return {
        errno = 0,
        isInHight=highLevel,
    }
end
--购买免费
function BuyFree(gameType,betindex,datainfo,datainfos)
    if table.empty(datainfo.free)==false then
        return{
            errno = ErrorDefine.ERROR_INFREEING,
        }
    end
    local betconfig = gamecommon.GetBetConfig(gameType, LineNum)
    local betMoney = betconfig[betindex]
    local chip = table_162_buyfree[1].price * betMoney
        -- 执行扣费
    local remainder, ok = chessuserinfodb.WChipsChange(datainfos._id, Const.PACK_OP_TYPE.SUB,chip ,"埃及艳后新购买免费")
    if ok==false then
        return {
            errno =ErrorDefine.CHIPS_NOT_ENOUGH,
        }
    end
    --入库存
    local addscore =  chip*(10000-gamecontrol.GetTaxXs(GameId,gameType))/10000
    gamecommon.IncSelfStockNumByType(GameId, gameType, addscore)
    datainfo.betMoney = betMoney
    datainfo.free={
        totalTimes=10,
        lackTimes=10,
        tWinScore = 0,
        tMul = 0,
        mulInfoList={},
    }
    local res = {
        errno = 0,
        betIndex = datainfo.betindex,
        bAllLine = LineNum,
        payScore = datainfo.betMoney * LineNum,
        winScore = 0,
        winLines = {},
        boards = {},
        iconsAttachData = {},
        features={
            free = datainfo.free,

        },
        extraData = {
            disInfo = {},
        }
    }
    unilight.update(Table, datainfos._id, datainfos)
    return res
end
-- 普通拉动
function Normal(gameId,gameType, betindex, datainfo, datainfos, uid)
    local betconfig = gamecommon.GetBetConfig(gameType, LineNum)
    local betMoney = betconfig[betindex]
    --print('betconfig='..json.encode(betconfig))
    local chip = betMoney * LineNum
    if betMoney == nil or betMoney <= 0 then
        return {
            errno = ErrorDefine.ERROR_PARAM,
        }
    end
    local sTime = os.time()
    if datainfo.isInHight==1 then
        chip = math.floor(chip/table_162_buygailv[1].betChange)
    end
    -- 执行扣费
    local remainder, ok = chessuserinfodb.WChipsChange(datainfos._id, Const.PACK_OP_TYPE.SUB, chip,
        "埃及艳后新玩法投注")
    if ok == false then
        return {
            errno =ErrorDefine.CHIPS_NOT_ENOUGH,
        }
    end
    datainfo.betMoney = betMoney
    datainfo.betindex = betindex
    -- gamecommon.ReqGamePoolBet(gameId, gameType, chip)
    local result,newdatainfo= gamecontrol.RealCommonRotate(datainfos._id, GameId, gameType, false, datainfo, chip, CommonRotate,nil)
    datainfos.roomInfo[gameType] = newdatainfo
    datainfo = newdatainfo
    if table.empty(result.jackpot)==false then
        gamecommon.AddJackpotHisoryTypeOne(datainfos._id,GameId,gameType,result.jackpot.iconNum,result.jackpotChips)
    end
    local winScore =  result.winScore
    -- 执行加入
    gameDetaillog.SaveDetailGameLog(
        datainfos._id,
        sTime,
        gameId,
        gameType,
        chip,
        remainder+chip,
        remainder+winScore+result.jackpotChips,
        0,
        {type='normal',chessdata = result.chessdata,disInfo=result.disInfo,zmul =result.mulcfg.mul },
        result.jackpot
    )
    BackpackMgr.GetRewardGood(datainfos._id, Const.GOODS_ID.GOLD,winScore+result.jackpotChips, Const.GOODS_SOURCE_TYPE.fruitparty2)
    unilight.update(Table, datainfos._id, datainfos)
    local boards={}
    table.insert(boards,result.chessdata)
    local res = {
        errno = 0,
        betIndex = datainfo.betindex,
        bAllLine = LineNum,
        payScore = datainfo.betMoney * LineNum,
        winScore = winScore,
        winLines = {},
        boards = boards,
        iconsAttachData = result.iconsAttachData,
        features={
            jackpot=result.jackpot,
            free = datainfo.free,

        },
        extraData = {
            disInfo = result.disInfo,
        }
    }
    return res
end
function Free(gameId, gameType, datainfo,datainfos)
    local chip = datainfo.betMoney * LineNum
    local result,newdatainfo = gamecontrol.RealCommonRotate(datainfos._id, gameId, gameType, true, datainfo, chip, CommonRotate,nil)
    datainfos.roomInfo[gameType] = newdatainfo
    datainfo = newdatainfo
    local winScore =  result.winScore
    datainfo.free.lackTimes = datainfo.free.lackTimes  -1
    datainfo.free.tWinScore = datainfo.free.tWinScore + winScore
    if datainfo.free.lackTimes<=0 then
        BackpackMgr.GetRewardGood(datainfos._id, Const.GOODS_ID.GOLD,datainfo.free.tWinScore, Const.GOODS_SOURCE_TYPE.fruitparty2)
        print('tfreeWinScore',datainfo.free.tWinScore)
    end
    gameDetaillog.SaveDetailGameLog(
        datainfos._id,
        os.time(),
        gameId,
        gameType,
        chip,
        chip,
        chessuserinfodb.RUserChipsGet(datainfos._id),
        0,
        {type='free',chessdata = result.chessdata,disInfo=result.disInfo,zmul =result.mulcfg.mul,totalTimes=datainfo.free.totalTimes,
        lackTimes=datainfo.free.lackTimes,tWinScore = datainfo.free.tWinScore },
        {}
    )
    local boards={}
    table.insert(boards,result.chessdata)
    local res = {
        errno = 0,
        betIndex = datainfo.betindex,
        bAllLine = LineNum,
        payScore = datainfo.betMoney * LineNum,
        winScore = winScore,
        winLines = {},
        boards = boards,
        iconsAttachData = result.iconsAttachData,
        features={
            free=datainfo.free,
        },
        extraData = {
            disInfo = result.disInfo,
        }
    }
    if datainfo.free.lackTimes<=0 then
        datainfo.free={}
    end
    unilight.update(Table, datainfos._id, datainfos)
    return res
end
function CommonRotate(uid,gameId, gameType,isfree,datainfo)
    local chip = datainfo.betMoney * LineNum
    local res={
        chessdata = {}, --初始棋盘
        winScore = 0,
        tringerPoints = {},
        jackpotChips = 0,
        jackpot = {},
        disInfo={},
        mulcfg={},
        iconsAttachData={},
        tmul = 0,
    }
    local cols = {5, 5, 5, 5, 5, 5}
    -- local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols, table_162_normalspin)

    local cfg,rtp = gamecommon.GetSpin(uid,GameId,gameType)
    if table.empty(datainfo.free)==false then
        cfg = fruitparty2['table_162_free_'..gameType]
    elseif datainfo.isInHight==1 and rtp==100 then
        cfg = table_162_high
    end
    local chessdata, lastColRow = gamecommon.CreateSpecialChessData(cols,cfg)
    
    if gmInfo.free==1 then
        for col=1,6 do
            local row = math.random(5)
            chessdata[col][row] = S
        end
    end
    -- 判断出不出倍数图标
    local mulcfg={}
    local table_num = fruitparty2['table_mul_gamety'..gameType]
    local table_mul = fruitparty2['table_162_mul_'..gameType]
    local num = 0
    local fieldName=''
    local tmptable_mul = table.clone(table_mul)
    if isfree then
        fieldName = 'gailvfree'
    else
        fieldName = 'gailv'..rtp
    end
    if gmInfo.sfree==1 then
        -- mulcfg = table_mul[math.random(2,#table_mul)]
        num = 5
    else
        num = table_num[gamecommon.CommRandInt(table_num,fieldName)].num
        -- num = 4
    end
    for i=1,num do
        local sIndex = gamecommon.CommRandInt(tmptable_mul,fieldName)
        local mcc = tmptable_mul[sIndex]
        -- table.remove(tmptable_mul,sIndex)
        table.insert(mulcfg,mcc)
        -- res.tmul = res.tmul + mcc.ID
    end
    local iconsAttachData = {}
    local jackpot  = {}
    local jackNum = 0
    -- 统计各个图标数量
    local disInfo = {} -- 每步消除的id信息和倍数信息{chessdata=,info={iconid,mul,winScore},{},{}}
    local jnum = 0
    local fbl = IsExistEliminate(chessdata)
    if fbl then
        jnum = math.floor(jackNum*0.7)
    else
        jnum = jackNum
    end
    if jackNum>0 then
        for i=1,jnum do
             local opos =  gamecommon.ReturnArrayRand(emptyPos)
             chessdata[opos[1]][opos[2]] = J
        end
    end
    if table.empty(mulcfg)==false then
        local mulnum = math.random(0,#mulcfg)
        -- mulnum = 0
        for i=1,mulnum do
            local opos =  gamecommon.ReturnArrayRand(emptyPos)
            chessdata[opos[1]][opos[2]] = mulcfg[1].iconid
            table.insert(iconsAttachData,{line = opos[1],
            row = opos[2],
            data = {
                mul = mulcfg[1].mul
            }})
            table.remove(mulcfg,1)
        end
    end
    local EliminateInfo={
        jackNum = jackNum-jnum,
        mulcfg=mulcfg,
    }
    local dchessdata = table.clone(chessdata)
    -- 总中奖倍数
    local bl = EliminateProcess(chessdata, lastColRow, disInfo, chip, uid, gameType,cfg,EliminateInfo)
    while bl do
        bl = EliminateProcess(chessdata, lastColRow, disInfo, chip, uid, gameType,cfg,EliminateInfo)
    end
    local winScore = 0
    for _, value in ipairs(disInfo) do
        for _, v in ipairs(value.info) do
            winScore = winScore + v.winScore
        end
    end
    local tmpMulInfoList={}
    for _, v in ipairs(iconsAttachData) do
        res.tmul = res.tmul + v.data.mul
        table.insert(tmpMulInfoList,v.data.mul)
    end 
    for _, value in ipairs(disInfo) do
        for _,v in ipairs(value.iconsAttachData) do
            res.tmul = res.tmul + v.data.mul
            table.insert(tmpMulInfoList,v.data.mul)
        end
    end
    local snum = 0
    local lastChessdata = dchessdata
    if #disInfo>0 then
        lastChessdata = disInfo[#disInfo].chessdata
    end
    for col=1,#lastChessdata do
        for row=1,#lastChessdata[col] do
            if lastChessdata[col][row]==S then
                snum = snum + 1
            end
        end
    end
    if table.empty(datainfo.free)==false then
        if snum>=3 then
            datainfo.free.totalTimes = datainfo.free.totalTimes + 5
            datainfo.free.lackTimes = datainfo.free.lackTimes + 5
        end
        if res.tmul>0 and winScore>0 then
            for _, value in ipairs(tmpMulInfoList) do
                table.insert(datainfo.free.mulInfoList,value)
            end
            res.tmul = datainfo.free.tMul + res.tmul
            datainfo.free.tMul = res.tmul
        end
    else
        if snum>=4 then
            datainfo.free = {
                totalTimes = 10,
                lackTimes = 10,
                tWinScore = 0,
                tMul = 0,
                mulInfoList={},
            }
        end
    end
    if res.tmul>0 then
        winScore = winScore*res.tmul
    end
    res.chessdata=dchessdata
    res.winScore = winScore
    res.jackpotChips = jackpot.tWinScore or 0
    res.jackpot = jackpot
    res.disInfo=disInfo
    -- res.mulcfg = mulcfg
    res.iconsAttachData = iconsAttachData
    return res
end
-- 消除执行过程
function EliminateProcess(chessdata, lastColRow, disInfo, chip, uid, gameType,cfg,EliminateInfo)
    local statMap = {}
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            statMap[chessdata[col][row]] = statMap[chessdata[col][row]] or 0
            statMap[chessdata[col][row]] = statMap[chessdata[col][row]] + 1
        end
    end 
    local bl = false
    local zidMap = {}
    local info = {}
    for key, val in pairs(statMap) do
        if table_162_paytable[key] ~= nil then
            local paytablekey = table_162_paytable[key]
            local paymul,rval = GetMul(paytablekey,val)
            if paymul ~= nil and paymul > 0 then
                -- 需要消除
                bl = true
                zidMap[key] = 1
                table.insert(info, {
                    iconid = key,
                    mul = paymul,
                    winScore = math.floor(paymul * chip),
					val=rval,
                })
            end
        end
    end
    if bl==false then
        if statMap[J]~=nil and statMap[J]>=8 then
            zidMap[J] = 1
            table.insert(info, {
                iconid = J,
                mul = 0,
                winScore = 0,
                val = J,
            })
            bl=true
        end
    end
    if bl then
        -- 执行消除 输出棋盘
        gamecommon.Eliminate(chessdata, zidMap)
        -- gamecommon.FillZeroChess(chessdata, lastColRow, table_162_normalspin)
        local iconsAttachData = gamecommon.FillZeroChess(chessdata, lastColRow,cfg,EliminateInfo)
        table.insert(disInfo, {
            chessdata = table.clone(chessdata),
            info = info,
            iconsAttachData = iconsAttachData,
        })
    end
    return bl
end
function GetMul(paytablekey,valnum)
    local colobj = {5,6,7,8,11,14,17,21}
    if valnum<colobj[1] then
        return 0,0
    elseif valnum>=colobj[8] then
        return paytablekey['c'..colobj[8]],colobj[8]
    end
    for i=1,7 do
        local colvalmin = colobj[i]
        local colvalmax = colobj[i+1]
        if valnum>=colvalmin and valnum<colvalmax then
            return paytablekey['c'..colvalmin],colvalmin
        end
    end
end

--判断是否有消除
function IsExistEliminate(chessdata)
    local statMap = {}
    for col = 1, #chessdata do
        for row = 1, #chessdata[col] do
            statMap[chessdata[col][row]] = statMap[chessdata[col][row]] or 0
            statMap[chessdata[col][row]] = statMap[chessdata[col][row]] + 1
        end
    end 
    local bl = false
    local zidMap = {}
    local info = {}
    for key, val in pairs(statMap) do
        if table_162_paytable[key] ~= nil then
            local paytablekey = table_162_paytable[key]
            local paymul,rval = GetMul(paytablekey,val)
            if paymul ~= nil and paymul > 0 then
                -- 需要消除
                bl = true
                zidMap[key] = 1
            end
        end
    end
    return bl
end