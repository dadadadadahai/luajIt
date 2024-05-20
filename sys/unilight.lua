unilight = {}
local otherdata={}
local userdata={
    property={
                chips=1000000,
                totalRechargeChips=1000000,
            },
            point={
                chargeMax=100000000,
            },
            gameData={
                slotsCount = 0,
            },
            status={
                chipsWithdraw = 0,
            },
            base={
                regFlag=1,
            },
}
function unilight.savedata(table,data)
    if table~='userinfo' then
        otherdata = data
    else
        userdata = data
    end
end 
function unilight.update(table,id,data)
    if table~='userinfo' then
        otherdata = data
    else
        userdata = data
    end
end
function unilight.getdata(table,id)
    if table~='userinfo' then
        return otherdata
    else
        return userdata
    end
end
function unilight.info()
    
end
function unilight.error()
end