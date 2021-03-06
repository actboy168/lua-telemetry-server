local timer = require 'timer'
local log   = require 'log'
local fs    = require 'bee.filesystem'
local util  = require 'utility'

log.init(fs.path '', fs.path 'log/clients.log')

local userPulses  = {}
local userClients = {}

timer.loop(10, function ()
    local clients = {}
    for token, lastPulse in pairs(userPulses) do
        if timer.clock() - lastPulse > 120 then
            userPulses[token]  = nil
            userClients[token] = nil
        else
            local client = userClients[token]
            clients[client] = (clients[client] or 0) + 1
        end
    end

    local list = {}
    for client in pairs(clients) do
        list[#list+1] = client
    end
    table.sort(list, function (a, b)
        return clients[a] > clients[b]
    end)

    local buf = {}
    for _, client in ipairs(list) do
        buf[#buf+1] = ('% 8d : %s'):format(clients[client], client)
    end
    log.info('Clients:\n' .. table.concat(buf, '\n'))
end)

return function (token, stream)
    local client = string.unpack('z', stream)
    userPulses[token]  = timer.clock()
    userClients[token] = client
end
