
reader = coroutine.create(function()
    while true do
        local ip = io.read()
        coroutine.yield(ip)
    end
end)

local _, ip = coroutine.resume(reader)
print("input recieved: " .. ip)
