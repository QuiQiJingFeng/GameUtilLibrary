local Coroutine = {}
local co_list = {}

function Coroutine:run(func,...)
    --创建一个携程并执行
    local co = coroutine.create(func)
    local state = coroutine.resume(co,...)
    assert(state,"coroutine resume failed")
end

function Coroutine:waiteActive(key)
    local co = coroutine.running()
    co_list[key] = co
    return coroutine.yield()
end

function Coroutine:active(key,...)
    local co = co_list[key]
    if not co then return end
    local state = coroutine.resume(co,...)
    --当state的false的时候,说明该协程已经执行完毕
    if not state then
        co_list[key] = nil
    end
end

return Coroutine

--[[
    --利用协程解决 将原来异步回调解决的问题 变成同步调用的问题
    Coroutine:run(function() 
        print("run a coroutine")
        local userId = Coroutine:waiteActive("WAITE_LOGIN")
        print("userId =>",userId)
    end)

    print("change main coroutine")
    --等待用户登录完成之后调用active
    Coroutine:active("WAITE_LOGIN",10086)

    --OUTPUT:
        run a coroutine
        change main coroutine
        userId =>10086

--]]