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
    for _, names in pairs(slot_idx[i][s].name) do
    for _, name in ipairs(names) do
    for j, loc in ipairs(name_idx[name]) do
        if i == loc[1] and s == loc[2] then
            table.remove(name_idx[name],j)
            table.insert(open_slots,loc)
            return
        end
        print("it shouldn't have come to this")
    end
    end
    end
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
    for i, inv in ipairs(invs) do
        for s, _ in ipairs(inv.list()) do
            index(i,s)
        end
    end
end

function find_by_name(query)
    query = process_name(query)
    local results = {}
    for name, locs in pairs(name_idx) do
        local m,me = string.find(name, query)

        if (m ~= nil) then
            match = {
                name = name,
                locs = locs
            }
            table.insert(results, match)
        end
    end
    return results
end

function extract_item(loc)
    local i,s = loc[1], loc[2]
    interface.pull_items(invs[i],s)
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
                print("item potentially stored in slot " .. s)
                return
            end
        end
    end
end

function storage.store_all()
    for slot, _ in pairs(interface.list()) do
        store(slot)
    end
end
