ui = {}

function ui.setColors(win, fg, bg)
    if fg then win.setTextColor(fg) end
    if bg then win.setBackgroundColor(bg) end
end

function ui.split(parent, pos, dir)
    parent.clear()
    parent.setCursorPos(1,1)
    local pw, ph = parent.getSize()
    local x1, y1, w1, h1, x2, y2, w2, h2
    if dir == "h" then
        if pos < 0 then pos = pw + pos end
        x1, y1, w1, h1 = 1, 1, pos, ph
        x2, y2, w2, h2 = pos+1, 1, pw-pos, ph
    else
        if pos < 0 then pos = ph + pos end
        x1, y1, w1, h1 = 1, 1, pw, pos
        x2, y2, w2, h2 = 1, pos+1, pw, ph-pos
    end
    return window.create(parent,x1,y1,w1,h1), window.create(parent,x2,y2,w2,h2)
end

function ui.list(win, items, reverse)
    win.clear()
    _, h = win.getSize()
    for i, item in pairs(items) do
        if i > h then break end
        if reverse then y = h - i else y = i end
        win.setCursorPos(1,y)
        win.write(item)
    end
end

function ui.text_input(win, on_change)
    win.clear()
    local read_str = ""

    win.setCursorPos(1,1)
    win.write("_")

    while true do
        local event, a, b = os.pullEvent()
        local redraw = true

        if event == "key" then
            if a == keys.backspace then
                read_str = string.sub(read_str, 1, -2)
            elseif a == keys.enter then
                win.setCursorPos(#read_str+1, 1)
                win.write(" ")
                return read_str
            end
        elseif event == "char" then
            read_str = read_str .. a
        else
            redraw = false
        end

        if redraw then
            win.setCursorPos(1, 1)
            win.write(read_str .. "_ ")
            os.queueEvent(on_change, read_str)
        end
    end
end

