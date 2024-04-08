Game = "wudLa8_VIjHZ6VA5ZG1ZHZs5CYkaIUw4Je_ePYEqmGQ"

Handlers.add("registered", Handlers.utils.hasMatchingTag("Action", "Registered"), function ()
  Send({Target = Game, Action = "Transfer", Recipient = Game, Quantity = "1"})
end)

Handlers.add("playing", Handlers.utils.hasMatchingTag("Action", "Payment-Received"), function ()
    Send({Target = Game, Action = "GetGameState"})
end)

-- Request Tokens
Send({Target = Game, Action = "RequestTokens"})
-- Register
Send({Target = Game, Action = "Register"})


