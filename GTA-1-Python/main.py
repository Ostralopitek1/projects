#Import Valentin
import datetime

import pygame
import characters, status, vehicles, listener, chunk, menu, random, interaction, sounds
from pygame import *
from objects import *

pygame.init()

surface = pygame.display.set_mode((1280, 720), FULLSCREEN)
pygame.display.set_caption('Vigilante')
fpsClock = pygame.time.Clock()

#Curseur
status.newCursor()
init = True

#Menu
menuT = -1

#Heure de début
time = datetime.datetime.now()

#Variables
deccCount = 0
accCount = 0
spriteCount = 0
backCount = 0

#Touches
key_W = False
key_S = False
key_A = False
key_D = False
click = True

datPlayer = [100, 100, 0, 0, -1, 100, 0, 0]

vehTexture = []
for type in range(2):
    vehTexture.append(vehicles.getTypeSprite(type))

player = Character(True, 2500, 2500, 0, surface)

Character(False,8000, 2200,0,surface,journey=2,direction=270)
Character(False,8500, 2500,0,surface,journey=3,direction=270)

Vehicle(surface, True, random.randint(0, 7), 1090, 1995, direction=90, journeyId=0)
Vehicle(surface, True, random.randint(0, 7), 2400, 2300, journeyId=1)
Vehicle(surface, True, random.randint(0, 7), 2570, 2600, direction=270, journeyId=1).journeyObj = 1
Vehicle(surface, True, random.randint(0, 7), 8500, 9000, journeyId=0)
vehicles.spawnAll(surface)

level = menu.creation(surface)

sounds.init()
if menu.health_music == 1:
    sounds.play("musique")

inProgress = True
while inProgress:

    if menuT == -1:
        menuT = menu.affichageMenu(surface)

    if menuT == 1:
        inProgress = False

    if init:
        chunk.prepareChunkLoadTexture(2500, 2500)
        chunk.prepareTexture(2500, 2500)
        init = False

    if interaction.spawn == 1:
        Vehicle(surface, True, 8, 2400, 2300,direction=270,journeyId=1)
        interaction.spawn = 0
    elif interaction.spawn == 2:
        Character(False, 4700, 13750, 0, surface, direction=90,journey=1,newId=1)
        interaction.spawn = 0

    playerMove = player.canMove()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            #Sauvegarder les données du joueur
            inProgress = False

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_t:
                Vehicle(surface, False, random.randint(0, 7), player.getCenter()[0] - 200, player.getCenter()[1])
                Character(False, player.posX + 200, player.posY, random.randint(0, 0), surface)
            if event.key == pygame.K_e:
                if player.status == status.WALKING:
                    player.enterVehicle()
                else:
                    player.quitVehicle()
            if event.key == pygame.K_ESCAPE:
                menuT = -1
                menu.screen = 0
                menu.continuer_partie = False
                menuT = menu.affichageMenu(surface)
            if event.key == pygame.K_1:
                player.curSlot = 0
            if event.key == pygame.K_2:
                player.curSlot = 1
            if event.key == pygame.K_3:
                player.curSlot = 2
            if event.key == pygame.K_4:
                player.curSlot = 3

            if player.status == status.WALKING:
                if event.key == pygame.K_e:
                    interaction.changeMapShow(player.getCenter()[0],player.getCenter()[1])

                if event.key == pygame.K_r:
                    if interaction.detectMission:
                        interaction.getMission(player.posX, player.posY)

                if event.key == pygame.K_n:
                    if interaction.missionFinal == False:
                        if interaction.currSpeech != -1:
                            interaction.execMission()
                    else:
                        interaction.missionFinal = False
                        interaction.currSpeech = -1
                        interaction.curMission = 0
                        interaction.detectMission = True

                if event.key == pygame.K_y:
                    if player.slots[player.curSlot].id == -1:
                        player.pickItem()
                    else:
                        player.drop()
            if not interaction.mapShow:
                if event.key == pygame.K_w:
                    key_W = True
                    if player.status == status.WALKING and playerMove:
                        player.speed = 1
                    elif player.status == status.DRIVING:
                        if vehicle.speed < 0:
                            sounds.play("brake")
                        else:
                            sounds.play("forward")
                if event.key == pygame.K_s:
                    key_S = True
                    if player.status == status.WALKING and playerMove:
                        player.speed = -1
                    else:
                        if vehicle.speed > 0:
                            sounds.play("brake")
                        else:
                            sounds.play("forward")
                if event.key == pygame.K_a:
                    key_A = True
                if event.key == pygame.K_d:
                    key_D = True

            if event.key == pygame.K_LSHIFT and player.status != status.DRIVING:
                player.sprint = True
                player.speed = 2
        if event.type == pygame.KEYUP:
            if event.key == pygame.K_LSHIFT and player.status != status.DRIVING:
                player.sprint = False
                player.speed = 1
            if event.key == pygame.K_w:
                key_W = False
                if player.status == status.WALKING:
                    player.speed = 0
                else:
                    sounds.stop("forward")
            if event.key == pygame.K_s:
                key_S = False
                if player.status == status.WALKING:
                    player.speed = 0
                else:
                    sounds.stop("brake")
                    if vehicle.speed < 0:
                        sounds.stop("forward")
            if event.key == pygame.K_a:
                key_A = False
            if event.key == pygame.K_d:
                key_D = False

        if event.type == pygame.MOUSEBUTTONDOWN:
            click = True
        if event.type == pygame.MOUSEBUTTONUP:
            weapon = player.slots[player.curSlot]
            weapon.fireRateCount = weapon.fireRate - 2
            click = False

    vehicles.forward()
    deccCount = vehicles.autoBrake(deccCount)
    status.displayFPS(surface, fpsClock.get_fps(), fpsClock.tick())
    if menuT == 0:
        status.updateScreen(surface, player)
        pygame.display.update()


    if not interaction.mapShow and interaction.currSpeech == -1:
        #Touches répétées
        if player.status == status.DRIVING:
            vehicle = vehicles.getVehicle(player.vehicleId)
            vehMove = vehicle.canMove()
        if key_W:
            if player.status == status.DRIVING and vehMove:
                accCount = vehicles.accelerate(vehicle, accCount)
            elif playerMove:
                accCount, spriteCount = player.forward(accCount, spriteCount)
        if key_S:
            if player.status == status.DRIVING and vehMove:
                backCount = vehicles.back(vehicle, backCount)
            elif playerMove:
                backCount, spriteCount = player.back(backCount, spriteCount)
        if key_A:
            if player.status == status.DRIVING:
                if vehicle.speed >= 0:
                     vehicles.turnLeft(vehicle)
                else:
                     vehicles.turnRight(vehicle)
        if key_D:
            if player.status == status.DRIVING:
                if vehicle.speed >= 0:
                     vehicles.turnRight(vehicle)
                else:
                     vehicles.turnLeft(vehicle)
        if click:
            if player.status == status.WALKING:
                player.shoot()

listener.onQuit(time)
pygame.quit()
