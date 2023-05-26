IGS.SUB_GROUPS = IGS.SUB_GROUPS or {}
local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetSubGroup(sGroupName, iGroupWeight)
    self:SetInstaller(function(pl)
        if SERVER then
            if pl.SetSubscribe then
                pl:SetSubscribe(sGroupName)
            end
        end
    end):SetMeta("ultima_subs", sGroupName)

    self.sub_group = self:Insert(IGS.SUB_GROUPS, sGroupName)
    self.sub_group_weight = iGroupWeight or 0

    return self
end

if CLIENT then return end

local function fl_filter(t, func)
    local res = {}

    for i, v in ipairs(t) do
        if func(v) then
            res[#res + 1] = v
        end
    end

    return res
end

hook.Add("IGS.PlayerPurchasesLoaded", "IGS_ULTIMA_SUBS", function(pl, purchases)
    local purchased_subs = {}

    if purchases then
        local purchases_list = table.GetKeys(purchases)
        purchased_subs = fl_filter(purchases_list, function(uid) return IGS.GetItemByUID(uid):GetMeta("ultima_subs") end)
        if #purchased_subs == 0 then return end
        local priority_item = IGS.GetItemByUID(purchased_subs[1])

        for _, v in ipairs(purchased_subs) do
            local ITEM = IGS.GetItemByUID(v)

            if ITEM.sub_group_weight > priority_item.sub_group_weight then
                priority_item = ITEM
            end
        end

        priority_item:Setup(pl)
    end
end)
