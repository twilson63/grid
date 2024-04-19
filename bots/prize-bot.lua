-- Initializing global variables to store the latest game state and game host process.
LatestGameState = LatestGameState or nil
Game = Game or "ltH8ToDf7hmFKc6NIefy5646NVFfBz8KHQqf-nkcD-s"
CRED = CRED or "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
Counter = Counter or 0
ONE_CRED = 1000
DailyPrize = 2500
Period = 24 * 60 * 60 * 1000
EliminatedCount = EliminatedCount or 0
Now = Now or 0
PeriodStart = PeriodStart or 0

colors = {
  red = "\27[31m",
  green = "\27[32m",
  blue = "\27[34m",
  reset = "\27[0m",
  gray = "\27[90m"
}

-- Respawn - restart prize cycle
function Respawn()
  EliminatedCount = 0
  Send({Target = CRED, Action = "Transfer", Quantity = tostring(DailyPrize * ONE_CRED), Recipient = Game})
end

-- Checks if two points are within a given range.
-- @param x1, y1: Coordinates of the first point.
-- @param x2, y2: Coordinates of the second point.
-- @param range: The maximum allowed distance between the points.
-- @return: Boolean indicating if the points are within the specified range.
function inRange(x1, y1, x2, y2, range)
    return math.abs(x1 - x2) <= range and math.abs(y1 - y2) <= range
end

-- Decides the next action based on player proximity and energy.
-- If any player is within range, it initiates an attack; otherwise, moves randomly.
function decideNextAction()
  local player = LatestGameState.Players[ao.id]
  local targetInRange = false

  for target, state in pairs(LatestGameState.Players) do
      if target ~= ao.id and inRange(player.x, player.y, state.x, state.y, 1) then
          targetInRange = true
          break
      end
  end

  if player.energy > 10 and targetInRange then
    print(colors.red .. "Player in range. Attacking..." .. colors.reset)
    ao.send({Target = Game, Action = "PlayerAttack", AttackEnergy = tostring(player.energy)})
  else
    -- print(colors.red .. "No player in range or insufficient energy. Moving randomly." .. colors.reset)
    local directionMap = {"Up", "Down", "Left", "Right", "UpRight", "UpLeft", "DownRight", "DownLeft"}
    local randomIndex = math.random(#directionMap)
    ao.send({Target = Game, Action = "PlayerMove", Direction = directionMap[randomIndex]})
  end
end

-- Handler to print game announcements and trigger game state updates.
Handlers.add(
  "PrintAnnouncements",
  Handlers.utils.hasMatchingTag("Action", "Announcement"),
  function (msg)
    ao.send({Target = Game, Action = "GetGameState"})
    print(colors.green .. msg.Event .. ": " .. msg.Data .. colors.reset)
    print("Location: " .. "row: " .. LatestGameState.Players[ao.id].x .. ' col: ' .. LatestGameState.Players[ao.id].y)

  end
)

-- Handler to trigger game state updates.
Handlers.add(
  "GetGameStateOnTick",
  Handlers.utils.hasMatchingTag("Action", "Tick"),
  function ()
      --print(colors.gray .. "Getting game state..." .. colors.reset)
      ao.send({Target = Game, Action = "GetGameState"})
  end
)

-- Handler to update the game state upon receiving game state information.
Handlers.add(
  "UpdateGameState",
  function (msg) 
    return msg.Action == "GameState" and msg.From == Game
  end,
  function (msg)
    local json = require("json")
    LatestGameState = json.decode(msg.Data)
    -- ao.send({Target = ao.id, Action = "UpdatedGameState"})
    --print("Game state updated. Print \'LatestGameState\' for detailed view.")
    print("Location: " .. "row: " .. LatestGameState.Players[ao.id].x .. ' col: ' .. LatestGameState.Players[ao.id].y)
    decideNextAction()
    ao.send({Target = ao.id, Action = "Tick"})
  end
)

-- Handler to automatically attack when hit by another player.
Handlers.add(
  "ReturnAttack",
  function (msg) 
    return msg.Action == "Hit" and msg.From == Game
  end,
  function (msg)
    local playerEnergy = LatestGameState.Players[ao.id].energy
    if playerEnergy == undefined then
      print(colors.red .. "Unable to read energy." .. colors.reset)
      decideNextAction()
    elseif playerEnergy > 10 then
      print(colors.red .. "Player has insufficient energy." .. colors.reset)
      decideNextAction()
    else
      print(colors.red .. "Returning attack..." .. colors.reset)
      ao.send({Target = Game, Action = "PlayerAttack", AttackEnergy = tostring(playerEnergy)})
    end
    ao.send({Target = ao.id, Action = "Tick"})
  end
)

Handlers.add(
  "ReSpawn",
  function (msg) 
    return msg.Action == "Eliminated" and msg.From == Game
  end,
  function (msg)
    local quantity = DailyPrize 
    Now = msg.Timestamp
    
    if PeriodStart == 0 then
      PeriodStart = msg.Timestamp
      EliminatedCount = 1
    elseif PeriodStart < (msg.Timestamp - Period) then
      PeriodStart = msg.Timestamp
      EliminatedCount = 1
    else 
      EliminatedCount = EliminatedCount + 1
    end
    
    
    -- calculate prize amount
    if EliminatedCount > 8 then 
      quantity = 1 * ONE_CRED
    elseif EliminatedCount >= 4 and EliminatedCount <= 8 then
      quantity = 18 * ONE_CRED
    else
      -- half prize for each eliminated round
      for i=1,EliminatedCount,1 do
        quantity = quantity / 2
      end
      quantity = quantity * ONE_CRED
    end
    print("Elminated! " .. "Playing again! Prize: " .. tostring(math.floor(quantity)))
    Send({Target = CRED, Action = "Transfer", Quantity = tostring(math.floor(quantity)), Recipient = Game})
  end
)

Handlers.add(
  "StartTick",
  function (msg) 
    return msg.Action == "Payment-Received" and msg.From == Game
  end,
  function (msg)
    Send({Target = Game, Action = "GetGameState", Name = Name, Owner = Owner })
    print('Start Moooooving!')
  end
)

Prompt = function () return Name .. "> " end

