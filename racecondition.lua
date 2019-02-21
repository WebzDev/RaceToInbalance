MinigameStartpoints = { wpMG1, wpMG2, wpMG3, wpMG4, wpMG5, wpMG6, wpMG7, wpMG8 }
RandomStartpoints = Utils.Shuffle(MinigameStartpoints)
PitBarrels = Utils.Shuffle({ Actor72, Actor73, Actor74, Actor75, Actor76, Actor77, Actor78, Actor79, Actor80, Actor81, Actor82, Actor83, Actor84, Actor85, Actor86, Actor87 })
PitArtillary = { Actor65, Actor64, Actor66, Actor67, Actor68, Actor69, Actor70, Actor71 }

PrimeBaseLocations = Utils.Shuffle({ wpBase1a, wpBase1b })
SecondBaseLocations = Utils.Shuffle({ wpBase2a, wpBase2b })
ThirdBaseLocations = Utils.Shuffle({ wpBase3a, wpBase3b })
LosersBaseLocations = Utils.Shuffle({ wpBase4a, wpBase4b })

Players = {}
Ranking = {}
MinigameTag = "minigame"
Minigame = true
MinigameActors = {}
MinigameCameras = {}

EndMinigame = function()
    Utils.Do(MinigameActors, function(actor)
        if not actor.IsDead then actor.Health = 0 end
    end)
    Utils.Do(MinigameCameras, function(camera)
        camera.Destroy()
    end)
    Minigame = false
end

RankPlayer = function(player)
    table.insert(Ranking, player)
    return #Ranking
end

CheckMinigameState = function()
    if #Ranking == #Players - 1 then EndMinigame() end
end

BindMCVToJeep = function(jeep)
    Trigger.OnKilled(jeep, function(self, killer)
        local rank = RankPlayer(self.Owner)
        PlaceRankedPlayer(self.Owner, rank)
        CheckMinigameState()
    end)
end

NormalizeRanking = function(rank)
    local count = #Players
    return 9 - math.floor(rank / count * 8)
end

PlaceRankedPlayer = function(player, rank)
    rank = NormalizeRanking(rank)
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
    if player.IsBot then mcv.Deploy() end
    player.GetActorsByType("v08")[1].Destroy()

    if player.IsLocalPlayer then Camera.Position = mcv.CenterPosition end
end

TargetBarrel = function()
    if #PitBarrels > 0 then
        local brl = table.remove(PitBarrels)
        if brl.IsDead then
            return TargetBarrel()
        else
            return brl
        end
    else
        return nil
    end
end

SendInHeli = function(heli)
    if not Minigame then return false end
    if heli and heli.AmmoCount() < 2 then
        heli.Health = 0
    end

    if not heli or heli.IsDead then
        heli = Actor.Create("heli", true, { Owner = bombers, Location = CPos.New(64, 0) })
        table.insert(MinigameActors, heli)
    end

    local brl = TargetBarrel()
    if brl == nil then heli.Health = 0 end

    if not heli.IsDead then
        Trigger.OnKilled(brl, function()
            SendInHeli(heli)
        end)
        heli.Attack(brl, true, true)
    end
end

WorldLoaded = function()
    neutral = Player.GetPlayer("Neutral")
    creeps = Player.GetPlayer("Creeps")
    bombers = Player.GetPlayer("Bombers")

    Players = Player.GetPlayers(function(player)
        return not player.IsNonCombatant
    end)

    Utils.Do(Players, function(player)
        local wp = table.remove(RandomStartpoints)
        local jeep = Actor.Create("jeep", true, { Location = wp.Location, Owner = player })
        table.insert(MinigameActors, jeep)
        BindMCVToJeep(jeep)
        if player.IsBot then jeep.Hunt() end

        local camera = Actor.Create("camera", true, { Location = PitCenter.Location, Owner = player })
        table.insert(MinigameCameras, camera)
    end)

    Camera.Position = PitCenter.CenterPosition

    Utils.Do(PitArtillary, function(art)
        table.insert(MinigameActors, art)
    end)

    Actor64.Move(CPos.New(51, 14))
    Actor65.Move(CPos.New(51, 23))
    Actor66.Move(CPos.New(77, 24))
    Actor67.Move(CPos.New(77, 15))
    Actor68.Move(CPos.New(60, 32))
    Actor69.Move(CPos.New(69, 32))
    Actor70.Move(CPos.New(69, 6))
    Actor71.Move(CPos.New(60, 6))

    Media.Debug(#MinigameActors .. " minigame actors")

    Trigger.AfterDelay(DateTime.Seconds(5), SendInHeli)
end
