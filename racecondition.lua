MinigameStartpoints = { wpMG1, wpMG2, wpMG3, wpMG4, wpMG5, wpMG6, wpMG7, wpMG8 }
RandomStartpoints = Utils.Shuffle(MinigameStartpoints)

PrimeBaseLocations = { wpBase1a, wpBase1b }
SecondBaseLocations = wpBase2a, wpBase2b }
ThirdBaseLocations = { wpBase3a, wpBase3b }
LosersBaseLocations = { wpBase4a, wpBase4b }
Ranking = 0

BindMCVToJeep = function(player)
    local jeeps = player.GetActorsByType('jeep')
    Utils.Do(jeeps, function(jeep)
        Trigger.OnKilled(jeep, function(self, killer)
            Media.Debug('Jeep killed.')

            Actor.Create('mcv', true, { Location = Actor105.Location, Owner = player })
        end)
    end)
end

WorldLoaded = function()
    m0 = Player.GetPlayer("Multi0")
    Media.Debug("Start your engines!")
    Actor.Create("4tnk", true, { Location = CPos.New(55, 10), Owner = m0 })

    Players = Player.GetPlayers(function(player)
        return player.IsLocalPlayer or player.IsBot
    end)

    Utils.Do(Players, function(player)
        local wp = table.remove(RandomStartpoints)
        Actor.Create("jeep", true, { Location = wp.Location, Owner = player })
    end)

end