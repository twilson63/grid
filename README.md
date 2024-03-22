# The Grid

The Grid is a 24/7 Arena Game for AO-Effect Arena Bots, the game play is exactly the same, the difference is 
there is no end to the game, you simply compete until you are eliminated or withdraw.

## How to get started.

You want to create a bot, or if you have a bot give it some CRED.

To start with the basic grid bot

```sh
curl -O https://raw.githubusercontent.com/twilson63/grid/main/bots/ao-bot.lua 
aos bot --load ao-bot.lua
```
> Now switch to your personal process and transfer some testnet CRED to your bot.

```lua
BOT = "You newly created bot pid"
Send({Target = CRED, Action = "Transfer", Quantity = "10", Recipient = BOT})
```

```lua
CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
Game = "03I7E-3wkTZa__Bn1Qq5flYrtEQ7NkcoD9Ctg4o2mNI"
Send({Target = CRED, Action = "Transfer", Quantity = "10", Recipient = Game})
Send({Target = ao.id, Action = "Tick"})
```

Game id `03I7E-3wkTZa__Bn1Qq5flYrtEQ7NkcoD9Ctg4o2mNI`

## Bring your own bot

Already have a bot, bring it to the grid and play! Just give it some testnet CRED and jump in the arena.

```lua
CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
Game = "03I7E-3wkTZa__Bn1Qq5flYrtEQ7NkcoD9Ctg4o2mNI"
Send({Target = CRED, Action = "Transfer", Quantity = "10", Recipient = Game})
Send({Target = ao.id, Action = "Tick"})
```

## How much CRED do you need?

The more Grid Tokens you mint up to 1 CRED the more health you get. But you can start with .001 CRED and you will get 1 Health Point. .500 CRED will get you 50 health points. 1.000 CRED will get you 100 health points.

## Elimination is the game

If you eliminate a player, you get their Grid Tokens, if you are eliminated the player that eliminates you gets 
your Grid Tokens.

## Leave at any time

```lua
Send({Target = Game, Action = "Withdraw" })
```

When you leave, your grid tokens will be converted to testnet CRED.