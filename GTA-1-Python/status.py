import random

DRIVING = 1
WALKING = 0

TICKS = 0

import items
import characters
import chunk
import hitboxes
import interaction
import pygame
import vehicles
import hud

cJourneys = [
    [[2790, 2250, 0], [2790, 3245, 270], [3500, 3245, 0], [3500, 3270, 270], [2730, 3270, 180], [2730, 2250, 90]],
    [[4700, 13750, 270], [4700, 13450, 90]],
    [[8000, 2200, 90], [8000, 5000, 270]],
    [[8500, 2200, 90], [8500, 5000, 270]]]

vJourneys = [[[1090, 1995, 90, 1], [5125, 1825, 0, 1], [5291, 5010, 270, 1], [1260, 5180, 180, 1]],
             [[2400, 2300, 0, 1], [2570, 2600, 270, 1], [1240, 2770, 180, 1], [1070, 2020, 90, 1], [9500, 1850, 0, 1],
              [2500, 2850, 270, 1]]]
itemsSprites = []
for itemType in range(4):
    strImg = "resources/items/" + str(itemType) + ".png"
    itemsSprites.append(pygame.image.load(strImg))


def updateScreen(surface, player):
    surface.fill((69, 174, 248))

    pVeh = vehicles.getVehicle(player.vehicleId)

    # Couche 1 : sol
    if player.status == DRIVING:
        pVeh = vehicles.getVehicle(player.vehicleId)
        chunk.prepareChunkLoadTexture(pVeh.posX, pVeh.posY)
        chunk.prepareTexture(pVeh.posX, pVeh.posY)
        chunk.updateScreenChunk(surface, pVeh.posX, pVeh.posY, 0)
    else:
        chunk.prepareChunkLoadTexture(player.posX, player.posY)
        chunk.prepareTexture(player.posX, player.posY)
        chunk.updateScreenChunk(surface, player.posX + 55, player.posY + 55, 0)

    if player.status == DRIVING:
        interaction.showMission(surface, pVeh.posX - 55, pVeh.posY - 55)
    else:
        interaction.showMission(surface, player.posX, player.posY)

    # Couche 2 : Items
    for item in items.lsItems:
        if player.status == WALKING:
            surface.blit(itemsSprites[item.type], (640 + item.posX - player.getCenter()[0],
                                                   360 + item.posY - player.getCenter()[1]))
        else:
            surface.blit(itemsSprites[item.type], (670 + item.posX - pVeh.posX,
                                                   390 + item.posY - pVeh.posY))

    # Couche 3 : joueurs
    for char in characters.lsCharacters:
        # Mettre à jour l'endroit que vise le joueur
        if char.isPlayer:
            char.prevDirection = char.direction
            char.direction = char.getDirection()
        if char.speed == 0:
            char.curSprite = 0
            char.rotSprite = rotCenter(char.sprites[0], char.direction)
        if char.prevDirection != char.direction:
            # Changer l'orientation du sprite
            char.rotSprite = rotCenter(char.sprites[char.curSprite], char.direction)

        # Afficher l'image
        if char.isPlayer:
            if player.status == WALKING:
                surface.blit(char.rotSprite, (640, 360))
        else:
            if player.status == WALKING:
                surface.blit(char.rotSprite, (
                640 - player.getCenter()[0] + char.getCenter()[0], 360 - player.getCenter()[1] + char.getCenter()[1]))
            else:
                surface.blit(char.rotSprite, (640 + 110 - pVeh.getCenter()[0] + char.getCenter()[0],
                                              360 + 105 - pVeh.getCenter()[1] + char.getCenter()[1]))

    # Couche 4 : véhicules
    for vehicle in vehicles.getVehicles():
        # Afficher tous les véhicules
        if vehicle.health == 0 and vehicle.hasPlayer:
            player.posX = pVeh.posX
            player.posY = pVeh.posY
            player.status = WALKING
            vehicle.remove()
        if vehicle.prevDirection != vehicle.direction:
            img = vehicle.sprite
            img = rotCenter(img, vehicle.direction)
        else:
            img = vehicle.sprite
        if vehicle.hasPlayer:
            surface.blit(img, (640, 360))
        else:
            if player.status == WALKING:
                surface.blit(img, (535 - player.getCenter()[0] + vehicle.getCenter()[0],
                                   255 - player.getCenter()[1] + vehicle.getCenter()[1]))
            else:
                surface.blit(img, (
                640 - pVeh.getCenter()[0] + vehicle.getCenter()[0], 360 - pVeh.getCenter()[1] + vehicle.getCenter()[1]))

    # Couche 5 : Eclat des munitions
    for ammo in items.lsAmmo:
        ammo.posX += ammo.stepX
        ammo.posY += ammo.stepY
        imgAmmo = pygame.transform.rotate(items.ammo, ammo.direction)
        surface.blit(imgAmmo, (640 + ammo.posX - player.getCenter()[0], 360 + ammo.posY - player.getCenter()[1]))
        if ammo.distance(ammo.obj) <= 10:
            ammo.remove()

    # Couche 6 : Elements de décor
    if player.status == DRIVING:
        chunk.updateScreenChunk(surface, pVeh.posX, pVeh.posY, 1)
    else:
        chunk.updateScreenChunk(surface, player.posX + 55, player.posY + 55, 1)

    moveNPCs(player)

    # interaction.showMap(surface)

    if player.status == DRIVING:
        interaction.showMap(surface, pVeh.posX, pVeh.posY)
    else:
        interaction.showMap(surface, player.posX + 55, player.posY + 55)

    interaction.showDialogMission(surface)
    # pygame.draw.line(surface, (255, 0, 0), (640, 380), (640, 380), 2)

    if interaction.missionFinal:
        interaction.showMissionFinal(surface)

    hud.showLife(surface, player.health)
    hud.showItems(surface, player.curSlot, player.slots)


def rotCenter(image, angle):
    orig_rect = image.get_rect()
    rot_image = pygame.transform.rotate(image, angle)
    rot_rect = orig_rect.copy()
    rot_rect.center = rot_image.get_rect().center
    rot_image = rot_image.subsurface(rot_rect).copy()
    return rot_image


def displayFPS(surface, fps, ticks):
    myfont = pygame.font.SysFont("monospace", 15)
    label = myfont.render(str(fps)[:2], 1, (255, 0, 0))
    surface.blit(label, (5, 5))
    global TICKS
    TICKS = ticks


def newCursor():
    r = ("           ...          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           ...          ",
         "                        ",
         ".........      .........",
         ".+++++++.      .+++++++.",
         ".........      .........",
         "                        ",
         "                        ",
         "           ...          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           .+.          ",
         "           ...          ")

    datable, masktuple = pygame.cursors.compile(r, black='.', white='+', xor='o')
    pygame.mouse.set_cursor((24, 24), (0, 0), datable, masktuple)


def moveNPCs(player):
    if player.status == DRIVING:
        pVeh = vehicles.getVehicle(player.vehicleId)
    # Bouger les personnages
    pPos = player.getCenter() if player.status == WALKING else pVeh.getCenter()

    for char in characters.lsCharacters:
        if not char.isPlayer:
            if char.distance(pPos) > 30000:
                char.remove()
                continue
            journey = cJourneys[char.journeyId]
            objPos = journey[char.journeyObj][:2]
            if hitboxes.distance(objPos, (char.posX, char.posY)) <= 11:
                char.journeyObj += 1
                if char.journeyObj == len(journey):
                    char.journeyObj = 0
                char.prevDirection = char.direction
                char.direction = journey[char.journeyObj][2]
            elif char.canMove():
                char.accCount, char.spriteCount = char.forward(char.accCount, char.spriteCount)

    # Bouger les véhicules
    for veh in vehicles.getVehicles():
        if veh.hasNPC:
            pPos = player.getCenter() if player.status == WALKING else pVeh.getCenter()
            if veh.distance(pPos) > 30000:
                veh.remove()
                # print(veh.posX, veh.posY, veh.direction, veh.journeyId, veh.journeyObj)
                continue
            journey = vJourneys[veh.journeyId]
            journeyObj = journey[veh.journeyObj]
            objPos = journeyObj[:2]
            if hitboxes.distance(objPos, (veh.posX, veh.posY)) <= 11:
                veh.journeyObj += 1
                if veh.journeyObj == len(journey):
                    veh.journeyObj = 0
                veh.prevDirection = veh.direction
                veh.direction = journeyObj[2]
            elif veh.canMove():
                if veh.direction != journeyObj[2]:
                    if journeyObj[3] == 1:
                        vehicles.turnRight(veh)
                    elif journeyObj[3] == -1:
                        vehicles.turnLeft(veh)
                veh.speed = vehicles.MAX_SPEED / 2.5


def getNewID(i):
    for char in characters.lsCharacters:
        if char.newId == i:
            return True
    return False
