#!mainFile "main.opy"
settings {
    "main": {
        "modeName": "Gun Game no CDs",
        "description": "Orignally by Vassy and improved by Pukima.\nThis includes consistant Ultimate Charge, a Next Hero Display as well as bug fixes and minor code improvements.\n\nCode: 9QVNB"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "enableMatchVoiceChat": true,
        "spectatorSlots": 0,
        "returnToLobby": "never"
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "workshopIsland",
                "workshopIslandNight"
            ]
        },
        "general": {
            "enableHeroSwitching": false,
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "respawnTime%": 0,
            "scoreToWin": 50,
            "enableSelfInitiatedRespawn": false,
            "spawnHealthPacks": "enabled"
        }
    },
    "heroes": {
        "allTeams": {
            "ana": {
                "damageDealt%": 250
            },
            "baptiste": {
                "damageDealt%": 300
            },
            "brigitte": {
                "secondaryFireRechargeRate%": 500,
                "shieldBashCooldown%": 20,
                "shieldBashKb%": 300,
                "ability1Kb%": 300
            },
            "mccree": {
                "ability2Cooldown%": 20
            },
            "mei": {
                "damageDealt%": 500,
                "enableSpawningWithUlt": true
            },
            "mercy": {
                "damageDealt%": 500
            },
            "moira": {
                "ability2MaxDamage%": 500,
                "damageDealt%": 300,
                "movementSpeed%": 200
            },
            "orisa": {
                "damageDealt%": 300
            },
            "sigma": {
                "damageDealt%": 300
            },
            "sombra": {
                "damageDealt%": 500
            },
            "symmetra": {
                "damageDealt%": 300
            },
            "hammond": {
                "damageDealt%": 400
            },
            "zarya": {
                "damageDealt%": 200,
                "ability1Cooldown%": 50
            },
            "zenyatta": {
                "damageDealt%": 300
            },
            "general": {
                "abilityCooldown%": 0,
                "enableInfiniteAmmo": true,
                "enableSpawningWithUlt": true,
                "combatUltGen%": 0,
                "passiveUltGen%": 0
            }
        }
    }
}

#Global variables

globalvar RandomizedHeroes 0


#Player variables

playervar RandomizedHeroes 0
playervar CurrentHero 1
playervar CanSkipHero 2
playervar UltimateCharge 3
playervar NextHeroHUD 4
playervar is_afk 16
playervar ThirdAfkBoxID 22
playervar FirstAfkBoxID 23
playervar SecondAfkBoxID 24
playervar Timer 25


rule "Every game list randomizer":
    @Event eachPlayer
    
    RandomizedHeroes = random.shuffle(getAllHeroes())


rule "Longer game time":
    @Condition isGameInProgress() == true
    
    setMatchTime(4500)


rule "Disabler":
    disableScoring()
    disableGamemodeCompletion()


rule "No assemble heroes":
    @Condition isAssemblingHeroes() == true
    
    setMatchTime(0)


rule "Player non-game initalizer":
    @Event eachPlayer
    
    eventPlayer.RandomizedHeroes = RandomizedHeroes
    eventPlayer.CurrentHero = eventPlayer.RandomizedHeroes[0]
    eventPlayer.RandomizedHeroes = eventPlayer.RandomizedHeroes.exclude(eventPlayer.CurrentHero)
    eventPlayer.preloadHero(eventPlayer.CurrentHero)
    eventPlayer.CanSkipHero = true
    eventPlayer.setAllowedHeroes(eventPlayer.CurrentHero)
    eventPlayer.startForcingHero(eventPlayer.CurrentHero)
    eventPlayer.preloadHero(eventPlayer.RandomizedHeroes[0])
    eventPlayer.J = 0
    eventPlayer.K = len(getAllHeroes()) - eventPlayer.getScore()
    eventPlayer.F = 0


rule "HUD creator":
    @Event eachPlayer
    
    hudSubheader([i for i in [i for i in eventPlayer if i.CanSkipHero == true] if i.CurrentHero != 0], "CROUCH + INTERACT TO SKIP THE CURRENT HERO (ONE TIME USE)", HudPosition.TOP, 1, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, l"{0}: {1}".format("KILLS LEFT", 1 + len(eventPlayer.RandomizedHeroes)), HudPosition.TOP, 2, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(eventPlayer, heroIcon(eventPlayer.RandomizedHeroes[0]), "Next Hero:", eventPlayer.RandomizedHeroes[0], HudPosition.LEFT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    eventPlayer.NextHeroHUD = getLastCreatedText()
    hudSubheader(eventPlayer, "ORIGINAL MODE BY Vassy", HudPosition.RIGHT, 0, Color.YELLOW, HudReeval.NONE, SpecVisibility.DEFAULT)
    hudSubheader(hostPlayer, "Serverload: {0}/255".format(getServerLoad()), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Skip 1 hero":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition isGameInProgress() == true
    @Condition eventPlayer.CanSkipHero == true
    @Condition eventPlayer.CurrentHero != 0
    
    eventPlayer.startForcingHero(eventPlayer.RandomizedHeroes[0])
    eventPlayer.CanSkipHero = false
    wait(0.1)
    eventPlayer.addToScore(1)
    eventPlayer.K = len(getAllHeroes()) - eventPlayer.getScore()
    eventPlayer.stopForcingCurrentHero()
    eventPlayer.CurrentHero = eventPlayer.RandomizedHeroes[0]
    eventPlayer.RandomizedHeroes = eventPlayer.RandomizedHeroes.exclude(eventPlayer.CurrentHero)
    eventPlayer.preloadHero(eventPlayer.CurrentHero)


rule "Kill -=> Next hero":
    @Event playerDealtFinalBlow
    @Condition isGameInProgress() == true
    @Condition eventPlayer.CurrentHero != 0
    
    wait(0.5)
    eventPlayer.UltimateCharge = eventPlayer.getUltCharge()
    eventPlayer.startForcingHero(eventPlayer.CurrentHero)
    wait(0.1)
    eventPlayer.addToScore(1)
    eventPlayer.K = len(getAllHeroes()) - eventPlayer.getScore()
    eventPlayer.stopForcingCurrentHero()
    eventPlayer.setUltCharge(eventPlayer.UltimateCharge)
    eventPlayer.CurrentHero = eventPlayer.RandomizedHeroes[0]
    eventPlayer.RandomizedHeroes = eventPlayer.RandomizedHeroes.exclude(eventPlayer.CurrentHero)
    eventPlayer.preloadHero(eventPlayer.CurrentHero)


rule "Destroy Next Hero HUD":
    @Event eachPlayer
    @Condition eventPlayer.RandomizedHeroes[0] == 0
    
    destroyHudText(eventPlayer.NextHeroHUD)


rule "Healing over time":
    @Event eachPlayer
    
    eventPlayer.stopAllHoT()
    wait()
    eventPlayer.startHoT(eventPlayer, 20, 20)
    wait(5)
    goto RULE_START


rule "Game ender":
    @Event playerDealtFinalBlow
    @Condition isGameInProgress() == true
    @Condition eventPlayer.CurrentHero == 0
    
    H = true
    setSlowMotion(20)
    eventPlayer.addToScore(1)
    eventPlayer.K = len(getAllHeroes()) - eventPlayer.getScore()
    wait(0.5)
    declarePlayerVictory(sorted(getAllPlayers(), lambda player: player.K).slice(0, ceil(0.5 * getNumberOfPlayers(Team.ALL))))


rule "AFK Enable":
    @Event eachPlayer
    @Condition eventPlayer.is_afk != true
    @Condition eventPlayer.getThrottle() == vect(0, 0, 0)
    @Condition eventPlayer.isHoldingButton(Button.JUMP) != true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) != true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) != true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) != true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) != true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) != true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) != true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) != true
    @Condition eventPlayer.isHoldingButton(Button.MELEE) != true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) != true
    @Condition eventPlayer.isCommunicatingAnything() != true
    
    wait(10, Wait.ABORT_WHEN_FALSE)
    eventPlayer.is_afk = true
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.startForcingThrottle(0, 0.008, 0, 0.008, 0, 0.008)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.ULTIMATE)
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.disallowButton(Button.CROUCH)
    hudHeader(eventPlayer, "YOU ARE MARKED AS AFK", HudPosition.TOP, 2, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    eventPlayer.FirstAfkBoxID = getLastCreatedText()
    hudHeader(eventPlayer, l"{0} {1}".format("YOU WILL BE KICKED IN", l"{0} sec".format(eventPlayer.Timer)), HudPosition.TOP, 2, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    eventPlayer.SecondAfkBoxID = getLastCreatedText()
    eventPlayer.Timer = 31


rule "AFK Disable":
    @Event eachPlayer
    @Condition eventPlayer.is_afk == true
    @Condition (eventPlayer.getThrottle() != vect(0, 0, 0) or eventPlayer.isCommunicatingAnything()) == true
    
    eventPlayer.is_afk = false
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.stopForcingThrottle()
    wait(0.112)
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.allowButton(Button.ABILITY_2)
    eventPlayer.allowButton(Button.ULTIMATE)
    eventPlayer.allowButton(Button.MELEE)
    eventPlayer.allowButton(Button.JUMP)
    eventPlayer.allowButton(Button.CROUCH)
    destroyHudText(eventPlayer.FirstAfkBoxID)
    destroyHudText(eventPlayer.SecondAfkBoxID)
    destroyHudText(eventPlayer.ThirdAfkBoxID)


rule "AFK Timer":
    @Event eachPlayer
    @Condition eventPlayer.is_afk == true
    
    eventPlayer.Timer = eventPlayer.Timer - 1
    wait(1, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


rule "AFK Kick":
    @Event eachPlayer
    @Condition eventPlayer.is_afk == true
    
    wait(30, Wait.ABORT_WHEN_FALSE)
    removeFromGame(eventPlayer)


rule "Ultmeter Update":
    @Event eachPlayer
    @Condition eventPlayer.isUsingUltimate() != true
    
    eventPlayer.UltimateCharge = eventPlayer.UltimateCharge + 1
    eventPlayer.setUltCharge(eventPlayer.UltimateCharge)
    wait(0.05)
    if eventPlayer.UltimateCharge < 100:
        goto RULE_START


rule "Ultimeter Reset":
    @Event eachPlayer
    @Condition eventPlayer.isUsingUltimate() == true
    @Condition eventPlayer.UltimateCharge >= 100
    
    eventPlayer.UltimateCharge = 0
