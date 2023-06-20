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
        for pos, child in pairs(self.children) do
            child.propagate(fn_name, unpack(arg))
        end
    end
    
    function self.addChild(child, pos)
        if child == nil then error("child can't be nil",2) end
        if pos == nil then
            table.insert(self.children, child)
        else
            table.insert(self.children, pos, child)
        end
        child.parent = self
    end
    
    function self.start()
        while true do
            self.propagate("recieveEvent", os.pullEvent())
        end
    end

    function self.realPos(x, y)
        local offs_x, offs_y = 0, 0
        if self.parent.term == term then --parent's term is same as current
            local x0, y0 = self.parent.realPos()
            offs_x, offs_y = offs_x+x0, offs_y+y0
        elseif self.parent.term.getPosition then --parent's term is a window
            local x0, y0 = self.parent.realPos()
            local x1, y1 = self.parent.term.getPosition()
            offs_x, offs_y = offs_x+x0+x1-1, offs_y+y0+y1-1
        else --parent's term is the root
            return 0, 0
        end
        if x == nil then
            return offs_x, offs_y
        else
            return x+offs_x, y+offs_y
        end
    end
    
    self.x, self.y = 1, 1
    self.width, self.height = 0, 0
    --self.term = window.create(term.current(),1,1,1,1,true)
    self.term = term.current()
    
    children = children or {}
    self.children = {}
    for pos, child in pairs(children) do
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

    function self.write(str, line, text_color, bg_color)
        line = 1 or line
        text_color = text_color or colors.white
        bg_color = bg_color or self.clear_color
        self.term.setTextColor(text_color)
        self.term.setBackgroundColor(bg_color)
        self.term.setCursorPos(1, line)
        self.term.write(str)
    end
    

    function self.draw()

        self.term = window.create(self.parent.term, self.x, self.y, self.width, self.height)

        for _, child in pairs(self.children) do
            child.term = self.term
        end
        self.term.setBackgroundColor(self.clear_color)
        self.term.clear()
    end

    local addChild = self.addChild
    function self.addChild(child, pos)
        addChild(child, pos)
        child.term = self.term
    end
    return self
end

ui.list = function(argt)
    local self = ui.win(argt)

    local function space()
        local list_height = 1
        for pos, child in ipairs(self.children) do
            child.x = 1
            child.y = list_height
            list_height = list_height + child.height
        end
    end

    local draw = self.draw
    function self.draw()
        space()
        draw()
    end

    return self
end

ui.button = function(argt)
    local self = ui.new()
    
    self.x, self.y = argt.x or 1, argt.y or 1
    self.width = argt.width or 1
    self.height = argt.height or 1
    self.text_color = argt.text_color or colors.white
    self.bg_color = argt.bg_color or colors.gray
    self.label = argt.label or ""
    self.action1 = argt.action1 or function() end
    self.action2 = argt.action2 or function() end

    function self.recieveEvent(event, button, x, y)
        local real_x, real_y = self.realPos(self.x, self.y)
        if (event == "mouse_click") and (x >= real_x and x < real_x + self.width) and (y >= real_y and y < real_y + self.height) then
            if button == 1 then
                --mprint(self.label)
                self.action1()
            elseif button == 2 then
                self.action2()
            end
        end
    end

    function self.draw()
        self.term.setTextColor(self.text_color)
        self.term.setBackgroundColor(self.bg_color)
        self.term.setCursorPos(self.x, self.y)
        self.term.write(ccs.ensure_width(self.label, self.width))
    end
    
    return self
end

ui.text_box = function(argt) 
    local self = ui.new()

    self.x, self.y = argt.x or 1, argt.y or 1
    self.width = argt.width or 1
    self.height = argt.height or 1
    self.text_color = argt.text_color or colors.white
    self.bg_color = argt.bg_color or colors.gray
    self.onEnter = function() end
    self.onChange = function() end

    local read_str = ""

    function self.draw()
        self.term.setTextColor(self.text_color)
        self.term.setBackgroundColor(self.bg_color)
        self.term.setCursorPos(self.x, self.y)
        self.term.write(ccs.ensure_width(read_str .. "_", self.width))
    end

    local function newChar(char)
        self.term.setTextColor(self.text_color)
        self.term.setBackgroundColor(self.bg_color)
        self.term.setCursorPos(self.x + #read_str, self.y)
        read_str = read_str..char
        self.term.write(char.."_")
    end
    
    local function newKey(key, is_held)
        if key == keys.backspace then
            read_str = string.sub(read_str, 1, -2)
            self.term.setTextColor(self.text_color)
            self.term.setBackgroundColor(self.bg_color)
            self.term.setCursorPos(self.x + #read_str, self.y)
            self.term.write("_ ")
        elseif key == keys.enter then
            self.onEnter(read_str)
        end
    end

    function self.recieveEvent(event, ...)
        if event == "char" then
            newChar(unpack(arg))
        elseif event == "key" then
            newKey(unpack(arg))
        end
    end

    return self
end
