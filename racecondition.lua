MinigameStartpoints = { wpMG1, wpMG2, wpMG3, wpMG4, wpMG5, wpMG6, wpMG7, wpMG8 }
RandomStartpoints = Utils.Shuffle(MinigameStartpoints)

PrimeBaseLocations = Utils.Shuffle({ wpBase1a, wpBase1b })
SecondBaseLocations = Utils.Shuffle({ wpBase2a, wpBase2b })
ThirdBaseLocations = Utils.Shuffle({ wpBase3a, wpBase3b })
LosersBaseLocations = Utils.Shuffle({ wpBase4a, wpBase4b })

Players = {}
Ranking = {}

RankPlayer = function(player)
    table.insert(Ranking, player)
    return #Ranking
end

BindMCVToJeep = function(jeep)
    Trigger.OnKilled(jeep, function(self, killer)
        Media.Debug('Jeep killed.')
        local rank = RankPlayer(self.Owner)
        Media.Debug('Rank: ' .. rank)
        PlaceRankedPlayer(self.Owner, rank)
    end)
end

NormalizeRanking = function(rank)
    local count = #Players
    return 9 - math.floor(rank / count * 8)
end

PlaceRankedPlayer = function(player, rank)
    rank = NormalizeRanking(rank)
    Media.Debug("Normalize" .. rank)
    if rank == 1 or rank == 2 then
        wp = table.remove(PrimeBaseLocations)
    elseif rank == 3 or rank == 4 then
        wp = table.remove(SecondBaseLocations)
    elseif rank == 5 or rank == 6 then
        wp = table.remove(ThirdBaseLocations)
    else
        wp = table.remove(LosersBaseLocations)
    end

    local mcv = Actor.Create('mcv', true, { Location = wp.Location, Owner = player })
    local homes = player.GetActorsByType("v08")
    Utils.Do(homes, function(home)
        home.Destroy()
    end)

    -- https://forum.openra.net/viewtopic.php?f=85&t=20354&p=305715&hilit=camera#p305715
    -- Camera.Position = mcv.CenterPosition
    Beacon.New(player, mcv.CenterPosition, 1)
    -- Actor.Create("camera", true, { Owner = player, Location = wp.Location })
end

WorldLoaded = function()
    m0 = Player.GetPlayer("Multi0")
    local t = Actor.Create("4tnk", true, { Location = CPos.New(55, 10), Owner = m0 })
    Media.FloatingText("Survive the longest.", t.CenterPosition, 90)

    Players = Player.GetPlayers(function(player)
        return player.IsLocalPlayer or player.IsBot
    end)

    Utils.Do(Players, function(player)
        local wp = table.remove(RandomStartpoints)
        local jeep = Actor.Create("jeep", true, { Location = wp.Location, Owner = player })
        BindMCVToJeep(jeep)
    end)

end