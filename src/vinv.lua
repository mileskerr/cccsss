vinv = {}


function vinv.moveItems(src, dst, src_slot)
    local src_item = src.getItemDetail(src_slot)
    if src_item == nil then return 0, {} end
    local si, ss = src.getRealLoc(src_slot)
    local total_moved = 0
    local slots_changed = {}

    local dst_list = dst.list()

    for i=1, dst.size() do
        if (dst_list[i] == nil) or (dst_list[i].name == src_item.name) then
            local di, ds = dst.getRealLoc(i)
            local moved = src.invs[si].pushItems(peripheral.getName(dst.invs[di]), ss, 64, ds)
            if moved > 0 then
                table.insert(slots_changed, i)
                total_moved = total_moved + moved
                if total_moved >= src_item.count then return total_moved, slots_changed end
            end
        else
        end
    end
    return total_moved, slots_changed
end

vinv.new = function(...)
    local self = {}

    self.invs = {}
    self.is_virtual = true

    for _, a in pairs(arg) do
        if type(a) == "table" then
            self.invs.insert(a)
        elseif type(a) == "string" then
            table.insert(self.invs, peripheral.wrap(a))
        end
    end

    function self.size()
        local res = 0
        for _, inv in ipairs(self.invs) do
            res = res + inv.size()
        end
        return res
    end
    
    function self.getRealLoc(vloc)
        local offs = 0
        for i, inv in ipairs(self.invs) do
            local size = inv.size()
            if (offs + size) > vloc then
                return i, vloc - offs
            end
            offs = offs + size
        end
    end
    
    local function getVloc(i, s)
        local res = s
        for j=1, i-1 do
            res = res + self.invs[j].size()
        end
        return res
    end

    function self.list()
        local res = {}
        local offs = 0
        for _, inv in pairs(self.invs) do
            local list = inv.list()
            local size = inv.size()
            for i=0, size do
                res[i + offs] = list[i]
            end
            offs = offs + size
        end
        return res
    end

    function self.getItemDetail(vloc)
        local i, s = self.getRealLoc(vloc)
        return self.invs[i].getItemDetail(s)
    end

    function self.listDetailSlow()
        local res = {}
        for vloc, item in pairs(self.list()) do
            table.insert(res, self.getItemDetail(vloc))
        end
        return res
    end


    function self.listDetail()
        local fns = {}
        local res = {}

        for i, inv in ipairs(self.invs) do
            for s, _ in pairs(inv.list()) do
                table.insert(fns, function ()
                    res[getVloc(i,s)] = inv.getItemDetail(s)
                end)
            end
        end
        parallel.waitForAll(unpack(fns))
        return res
    end

    return self
end
