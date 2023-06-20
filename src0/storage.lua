storage = {}

interface_name = "minecraft:barrel_15"
interface = peripheral.wrap(interface_name)

invs = { peripheral.find(
    "inventory", function(name, _)
        return (name ~= interface_name)
    end
) }


name_idx = {} --slots containing each item indexed by name and display name
slot_idx = {} --searchable keys for each item indexed by slots holding those items. essentially a copy of the storage contents.

for i=1,#invs do
    slot_idx[i] = {}
end

function process_name(name)
    name = string.gsub(name.lower(name)," ","_")
    return name
end

function insert_create(t,v) 
    if (t == nil) then
        t = {v}
    else
        table.insert(t,v)
    end
    return t
end

function deindex(i,s) --must be called after extracting item
    if slot_idx[i][s] == nil or slot_idx[i][s].names == nil then return end
    for k, name in ipairs(slot_idx[i][s].names) do
        for l, loc in ipairs(name_idx[name]) do
            if i == loc[1] and s == loc[2] then
                table.remove(name_idx[name],l)
            end
        end
        if #name_idx[name] == 0 then
            name_idx[name] = nil
        end
    end
    slot_idx[i][s] = nil
end

function index(i,s)
    local inv = invs[i]
    local detail = inv.getItemDetail(s)
    
    if detail ~= nil then
        local name = process_name(
            detail.name:gsub(".*:","")
        )
        local dsp_name = process_name(detail.displayName)
    
        name_idx[name] =
            insert_create(name_idx[name],{i,s})
        slot_idx[i][s] = { names = {name}}
    
        if dsp_name ~= name then
            name_idx[dsp_name] =
                insert_create(name_idx[dsp_name],{i,s})
            table.insert(slot_idx[i][s].names, dsp_name)
        end
    end
end

function storage.index_all()
    for i, inv in pairs(invs) do
        for s, _ in pairs(inv.list()) do
            index(i,s)
        end
    end
end

function storage.find_by_name(query)
    if query == "" or query == nil then return {}, {} end
    query = process_name(query)
    local match_locs, match_names = {}, {}
    for name, locs in pairs(name_idx) do
        local m, _ = string.find(name, query)

        if m then
            table.insert(match_locs, locs)
            table.insert(match_names, name)
        end
    end
    return match_locs, match_names
end

function extract_item(loc)
    local i,s = loc[1], loc[2]
    interface.pullItems(peripheral.getName(invs[i]),s)
    deindex(i,s)
end    

function available(inv) --space left in inventory
    local res = inv.size()
    for _, item in pairs(inv.list()) do
        res = res - 1
    end
    return res
end

function store(slot)
    for i, inv in pairs(invs) do        
        for s=1, inv.size() do
            if slot_idx[i][s] == nil then
                interface.pushItems(peripheral.getName(inv), slot)
                index(i,s)
                return
            end
        end
    end
end

function store_all()
    for slot, _ in pairs(interface.list()) do
        store(slot)
    end
end

function storage.filter_items()
    while true do
        _, items = os.pullEvent("filter_changed")
        store_all()
        for _, locs in ipairs(items) do
            for _, loc in ipairs(locs) do
                extract_item(loc)
            end
        end
    end
end

storage.index_all()
