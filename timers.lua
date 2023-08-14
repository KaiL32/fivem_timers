timer = {
    __list = {},
    __bindings = {}
}

local listShortcut = timer.__list
local bindShortcut = timer.__bindings
local TIMER_FIELD_NAME = 1
local TIMER_FIELD_INTERVAL = 2
local TIMER_FIELD_REPS = 3
local TIMER_FIELD_CALLBACK = 4
local TIMER_FIELD_NEXT = 5
local SysTime = GetGameTimer

function timer.Exists(name)
    return bindShortcut[name]
end

function timer.Remove(name)
    local timer_id = bindShortcut[name]

    if timer_id then
        bindShortcut[name] = nil
        table.remove(listShortcut, timer_id)
    end

    for k, v in pairs(listShortcut) do
        bindShortcut[v[TIMER_FIELD_NAME]] = k
    end
end

function timer.Create(name, delay, num, callback)
    timer.Remove(name)
    local ms = delay * 1000

    bindShortcut[name] = table.insert(listShortcut, {
        [TIMER_FIELD_NAME] = name,
        [TIMER_FIELD_INTERVAL] = ms,
        [TIMER_FIELD_REPS] = num or 0,
        [TIMER_FIELD_CALLBACK] = callback,
        [TIMER_FIELD_NEXT] = SysTime() + ms,
    })
end

function timer.Simple(seks, callback)
    return Citizen.SetTimeout(seks * 1000, callback)
end

function timer.Think()
    local time = SysTime()
    local reps, timerData, timerNext

    for timerId = 1, #listShortcut do
        timerData = listShortcut[timerId]

        if timerData then
            timerNext = timerData[TIMER_FIELD_NEXT]

            if time >= timerNext then
                reps = timerData[TIMER_FIELD_REPS]

                if reps ~= 0 then
                    reps = reps - 1

                    if reps <= 0 then
                        timer.Remove(timerData[TIMER_FIELD_NAME])
                        goto _continue
                    else
                        timerData[TIMER_FIELD_REPS] = reps
                    end
                end

                timerData[TIMER_FIELD_NEXT] = time + timerData[TIMER_FIELD_INTERVAL]
                ::_continue::
                timerData[TIMER_FIELD_CALLBACK](reps)
            end
        end
    end
end

local timerThink = timer.Think

Citizen.CreateThread(function()
    while true do
        timerThink()
        Citizen.Wait(1)
    end
end)