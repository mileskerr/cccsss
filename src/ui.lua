require("storage")




while true do

    local ip = io.read()
    
    local first_char = string.sub(ip,1,1)
    
    if first_char == "/" then
        local cmd = string.sub(ip,2)
        fn = storage[ip]
        if type(fn) == "function" then
            local start_time = os.clock()
            fn()
            print("done after " .. os.clock()-start_time .. "s")
        else
            print("not a function")
        end
    end
end


