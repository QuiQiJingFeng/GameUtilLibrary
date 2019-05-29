local Closure = {}

local executeList = {}

function Closure:handler(callback)
    local times = 1
    local newfunc = function()
        times = times - 1
        if times < 0 then
            return
        end
        return callback()
    end
    table.insert(executeList,newfunc)
    return newfunc
end

function Closure:execute()
    local k,call
    while true do
        k,call = next(executeList,k)
        if not call then
            break
        end
        call()
    end
    executeList = {}
end

return Closure

--[[
    说明:
    当使用handler包装一个方法的时候,那么意味着如果发生游戏状态切换(比如断线重连，退出房间等),你的方法将在状态退出的时候提前执行,
    假如说你的方法在状态退出之前被执行了(比如动作的回调啊，调度啊什么的)，那么状态退出的时候是不会执行的。
    但是假如你的方法在状态退出前还没有执行,那么将随着状态的退出被执行,你自定义的方法回调(动作回调、调度等)将会失效
    
]]