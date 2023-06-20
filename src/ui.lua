ccs = require("cc.strings")
require("utils")
ui = {}


--local term = window.create(term.current(),5,5,5,5, false)
ui.new = function(children)
    local self = {}


    function self.recieveEvent() end
    function self.draw() end
    function self.delete()
        for _, child in pairs(self.children) do
            child.delete()
        end
        local my_index = nil
        for i, sibling in pairs(self.parent.children) do
            if sibling == self then
                my_index = i
                break
            end
        end
        if my_index == nil then error("ah",2) end
        table.remove(self.parent.children, my_index)
    end

    function self.propagate(fn_name, ...)
        local fn = self[fn_name]
        fn(unpack(arg))
        for name, child in pairs(self.children) do
            child.propagate(fn_name, unpack(arg))
        end
    end
    
    function self.addChild(child)
        if child == nil then error("child can't be nil",2) end
        table.insert(self.children, child)
        child.parent = self
    end
    
    function self.start()
        while true do
            self.propagate("recieveEvent", os.pullEvent())
        end
    end
    
    self.x, self.y = 1, 1
    self.width, self.height = 0, 0
    --self.term = window.create(term.current(),1,1,1,1,true)
    self.term = term.current()
    
    children = children or {}
    self.children = {}
    for name, child in pairs(children) do
        self.addChild(child)
    end

    return self
end

ui.win = function(argt)
    local self = ui.new(argt.children)
    self.x = argt.x or 1
    self.y = argt.y or 1
    self.width = argt.width or 1
    self.height = argt.height or 1
    self.clear_color = argt.clear_color or colors.black
    

    function self.draw()
        self.term = window.create(self.parent.term, self.x, self.y, self.width, self.height)
        for _, child in pairs(self.children) do
            child.term = self.term
        end
        self.term.setBackgroundColor(self.clear_color)
        self.term.clear()
    end

    local addChild = self.addChild
    function self.addChild(child)
        if child == nil then error("child can't be nil",2) end
        addChild(child)
        child.term = self.term
    end
    return self
end

ui.list = function(argt)
    local self = ui.win(argt)

    local list_height = 0
    for name, child in pairs(self.children) do
        child.x = child.x + self.x - 1
        child.y = child.y + list_height + self.y - 1
        list_height = list_height + child.height
    end

    return self
end

ui.button = function(argt)
    local self = ui.new(argt.children)
    
    self.x, self.y = argt.x or 1, argt.y or 1
    self.width = argt.width or 1
    self.height = argt.height or 1
    self.text_color = argt.text_color or colors.white
    self.bg_color = argt.bg_color or colors.gray
    self.label = argt.label or ""
    self.action1 = argt.action1 or function() end
    self.action2 = argt.action2 or function() end

    function self.recieveEvent(event, button, x, y)
        if (event == "mouse_click") and (x >= self.x and x < self.x + self.width) and (y >= self.y and y < self.y + self.height) then
            if button == 1 then
                mprint(self.term.getPosition())
                self.action1()
            elseif button == 2 then
                self.action2()
            end
        end
    end

    function self.draw()
        local offs_x, offs_y = 0,0
        if self.term.getPosition() then offs_x, offs_y = self.term.getPosition() end
        self.term.setTextColor(self.text_color)
        self.term.setBackgroundColor(self.bg_color)
        self.term.setCursorPos(self.x-offs_x+1, self.y-offs_y+1)
        self.term.write(ccs.ensure_width(self.label, self.width))
    end
    
    return self
end

ui.text_box = function(parent) 
    local self = ui.new(parent)
    return self
end
