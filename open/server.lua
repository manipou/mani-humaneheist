local Open = {}

function Open.Log(Source, Message)
    exports['onl_logsender']:SendLog(Source, Message, {
        labels = {
            job = 'logs',
            discordId = true,
            steamId = true,
            license = true,
            playerJob = true,
            jobGrade = true,
            playerName = true,
            screenshot = false,
            money = true,
            black_money = true,
            bank = true,
            coords = true,
            radio = true
        },
        discordTitle = Message,
        discordWebhook = nil
    })
end

return Open