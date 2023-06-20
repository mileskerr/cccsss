require("vinv")

storage = {}

storage.new = function(io, archive) 
    local self = {}
    self.io = io
    self.archive = archive

    function self.extract(filter) 
        fns = {}
        for slot, item in pairs(self.archive.list()) do
            table.insert(fns, function()
                if filter(item) then vinv.moveItems(self.archive, self.io, slot) end
            end)
        end
        for slot, item in pairs(self.io.list()) do
            table.insert(fns, function()
                if not filter(item) then vinv.moveItems(self.io, self.archive, slot) end
            end)
        end
        parallel.waitForAll(unpack(fns))
    end

    return self
end

storage.newCategory = function(items, subcategories)
    local self = {}
    self.items = items
    self.subcategories = subcategories
    return self
end
