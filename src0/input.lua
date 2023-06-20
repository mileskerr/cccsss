
term.setCursorBlink(true)
local tx, ty = term.getCursorPos(x,y)
local written_str = ""

while true do
    local event, a, b = os.pullEvent()
    local redraw = true

    if event == "key" then
        if a == keys.backspace then
            written_str = string.sub(written_str, 1, -2)
        end
    elseif event == "char" then
        write(a)
        written_str = written_str .. a
    else
        redraw = false
    end

    if redraw then
        term.setCursorPos(tx,ty)
        io.write(written_str, "  ")
        io.flush()
        term.setCursorPos(#written_str+1,ty)
    end
end

