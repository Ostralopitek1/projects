from math import *

import characters
import chunk
import hitboxes
import pygame
import status
import vehicles
import items
import sounds

vLONG = 150
vLARGE = 65
vDIAG = sqrt((vLONG * vLONG) + (vLARGE * vLARGE)) / 2  # Diagonale / 2
vCENTER = int(vLONG / 2)
vANGLE = 23.5

cLONG = 50
cLARGE = 50
cDIAG = sqrt((cLONG * cLONG) + (cLARGE * cLARGE)) / 2  # Diagonale / 2
cCENTER = int(cLONG / 2)
cANGLE = 45

SPRINT_SPEED = 0.45
WALK_SPEED = 0.25
BACK_SPEED = -0.20

HIT_SPACE = 5

playerSprites = []
for pType in range(1):
    playerSprites.append([])
    for indexImg in range(12):
        imgPath = "resources/characters/" + str(pType) + "/" + str(indexImg) + ".png"
        playerSprites[pType].append(pygame.image.load(imgPath))

lsExplosion = []

class Vehicle:
    def __init__(self, surface, hasNPC, type, posX, posY, direction=0, journeyId=0, speed=0):
        self.id = len(vehicles.getVehicles())
        vehicles.getVehicles().append(self)
        self.surface = surface
        self.type = type
        self.sprite = vehicles.getTypeSprite(type)
        self.speed = speed
        self.hasPlayer = False
        self.hasNPC = hasNPC
        self.posX = float(posX)
        self.posY = float(posY)
        self.prevDirection = direction + 1
        self.direction = direction
        self.stepX = 0.0
        self.stepY = 0.0
        self.journeyId = journeyId
        self.journeyObj = 0
        self.accCount = 0
        self.hitSpace = 10
        self.health = 100


    def remove(self):
        lsVeh = vehicles.getVehicles()
        for char in characters.lsCharacters:
            if char.vehicleId > self.id:
                char.vehicleId -= 1
        for veh in lsVeh[:self.id]:
            if veh.id > self.id:
                veh.id -= 1
        lsVeh.remove(self)
        del self

    def getCenter(self):
        return int(self.posX) + vCENTER, int(self.posY) + vCENTER

    def getCorners(self):
        corners = []
        cornerX = cos(radians(self.direction + vANGLE)) * vDIAG  # Avant-Gauche
        cornerY = sin(radians(self.direction + vANGLE)) * vDIAG  # Arrière-Droit
        corners.append((self.posX + cornerX + vCENTER, self.posY - cornerY + vCENTER, 5, 5))
        corners.append((self.posX - cornerX + vCENTER, self.posY + cornerY + vCENTER, 5, 5))

        cornerX = cos(radians(self.direction - vANGLE)) * vDIAG  # Avant-Droit
        cornerY = sin(radians(self.direction - vANGLE)) * vDIAG  # Arrière-Gauche
        corners.append((self.posX + cornerX + vCENTER, self.posY - cornerY + vCENTER, 5, 5))
        corners.append((self.posX - cornerX + vCENTER, self.posY + cornerY + vCENTER, 5, 5))

        return corners

    def canMove(self):
        if self.speed == 0:
            return True

        forward = True if self.speed > 0 else False
        corner = list(self.getCorners()[0]) if forward else list(self.getCorners()[1])
        stepX, stepY = vehicles.getPath(self, self.hitSpace)

        # Récupérer tous les véhicules proches
        nearestVehicles = []
        for hitVeh in vehicles.getVehicles():
            if self.distance(hitVeh.getCenter()) < vLONG + 10:
                if hitVeh != self:
                    nearestVehicles.append(hitVeh)


        # Vérifier qu'il n'y a pas de mur fixe en face
        for column in range(0, int(vLARGE / self.hitSpace) + 1):
            hitPos = [int(corner[0] - (stepY * column)), int(corner[1] + stepX * column)]
            if column == 0 or column == 6:
                cornerStepX, cornerStepY = vehicles.getPath(self, -17)
            elif column == 1 or column == 5:
                cornerStepX, cornerStepY = vehicles.getPath(self, -7)
            else:
                cornerStepX, cornerStepY = 0, 0

            hitPos[0] -= int(cornerStepX)
            hitPos[1] -= int(cornerStepY)
            # Hitboxs fixes
            if chunk.getPixelForHitboxe(hitPos[0],hitPos[1]) != (255, 255, 255, 255): # and self.hasNPC == False:
                self.damage(10)
                return False

            # Hitboxs mobiles
            if not hitboxes.checkVehicles(self, hitPos):
                return False
            if not hitboxes.checkCharacters(self, hitPos):
                char = hitboxes.getNearestCharacter(hitPos)
                if not char.isPlayer:
                    self.speed /= 3
                    char.damage(10)
                return False
        return True

    def getMaxSpeed(self):  # Retourne le nombre de pixels sans chocs
        speed = self.speed
        #return speed
        # Décalage entre chaque triangle
        corner = list(self.getCorners()[0]) if speed >= 0 else list(self.getCorners()[1])  # Marche avant ou arrière
        stepX, stepY = vehicles.getPath(self, self.hitSpace)


        # Récupérer tous les véhicules proches
        nearestVehicles = []
        for hitVeh in vehicles.getVehicles():
            if self.distance(hitVeh.getCenter()) < vLONG + 10:
                if hitVeh != self:
                    nearestVehicles.append(hitVeh)

        for line in range(1, int((speed / self.hitSpace + 1))):
            corner[0] += stepX
            corner[1] += stepY
            for column in range(0, int(vLARGE / self.hitSpace) + 1):
                hitPos = [int(corner[0] - (stepY * column)), int(corner[1] + stepX * column)]
                if column == 0 or column == 6:
                    cornerStepX, cornerStepY = vehicles.getPath(self, -17)
                elif column == 1 or column == 5:
                    cornerStepX, cornerStepY = vehicles.getPath(self, -7)
                else:
                    cornerStepX, cornerStepY = 0, 0
                hitPos[0] -= int(cornerStepX)
                hitPos[1] -= int(cornerStepY)
                if chunk.getPixelForHitboxe(hitPos[0],hitPos[1])!= (255, 255, 255, 255) and self.hasNPC == False:
                #if hitMap.get_at(hitPos) != (255, 255, 255, 255):
                    forwardSpeed = speed % self.hitSpace
                    return forwardSpeed if speed > 0 else -forwardSpeed

        # Vérifier la dernière ligne qui est infèrieure à hitSpace
        stepLineX, stepLineY = vehicles.getPath(self, speed % self.hitSpace - 1)
        corner[0] += stepLineX
        corner[1] += stepLineY
        for column in range(0, int(vLARGE / self.hitSpace) + 1):
            hitPos = (int(corner[0] - stepY * column), int(corner[1] + stepX * column))
            #if hitMap.get_at(hitPos) != (255, 255, 255, 255):
            if chunk.getPixelForHitboxe(hitPos[0],hitPos[1])!= (255, 255, 255, 255) and self.hasNPC == False:
                forwardSpeed = speed % self.hitSpace
                return forwardSpeed if speed > 0 else -forwardSpeed
                # pygame.draw.rect(self.surface, (0, 0, 255), (565 - self.posX + hitPos[0], 285 - self.posY + hitPos[1], 2, 2))

        return speed

    def distance(self, pos):
        dist = sqrt((pos[0] - self.getCenter()[0])**2 + (pos[1] - self.getCenter()[1])**2)
        return dist

    def damage(self, damage):
        self.health -= damage
        if self.health <= 0:
            if self.hasPlayer:
                self.speed = 0
                player = characters.getPlayer()
                player.quitVehicle()
                player.damage(3)
            sounds.play("explosion")
            lsExplosion.append((self.posX, self.posY))
            self.remove()


class Character:
    def __init__(self, player, posX, posY, type, surface, direction=0, journey=0,newId=0):
        self.id = len(characters.lsCharacters)
        characters.lsCharacters.append(self)
        self.surface = surface
        self.isPlayer = player
        self.objX = posX
        self.objY = posY
        self.sprites = playerSprites[type]
        self.curSprite = 2
        self.rotSprite = self.sprites[0]
        self.spriteCount = 0
        self.accCount = 0
        self.posX = posX
        self.posY = posY
        self.stepX = 0
        self.stepY = 0
        self.curSlot = 0
        self.slots = [items.Item(0, -1, -1), items.Item(0, -1, -1), items.Item(0, -1, -1), items.Item(0, -1, -1)]
        self.journeyId = journey if not player else -1
        self.journeyObj = -1
        self.prevDirection = self.getDirection() if player else direction
        self.direction = self.prevDirection
        self.speed = 0 if player else 1
        self.sprint = False
        self.status = 0  # 0:Marche 1:Conduit
        self.vehicleId = -1
        self.hitSpace = 10
        self.health = 10
        self.newId = newId

    def remove(self):
        characters.lsCharacters.remove(self)
        del self

    def getDirection(self):
        cursorPos = pygame.mouse.get_pos()
        x = cursorPos[0] - 640
        y = cursorPos[1] - 360
        angle = 0
        if x != 0 and y != 0:
            angle = atan(y / x)
            angle = angle / (2 * pi) * 360
            if x < 0 < y:
                angle = (90 + angle) + 90
            elif x < 0 and y < 0:
                angle += 180
            elif x > 0 > y:
                angle += 360
        else:
            if x == 0 and y > 0:
                angle = 90
            elif y == 0 and x < 0:
                angle = 180
            elif x == 0 and y < 0:
                angle = 270
            elif y == 0 and y > 0:
                angle = 0
        return 360 - int(angle)

    def getCenter(self):
        return int(self.posX+ cCENTER), int(self.posY + cCENTER)

    def nextSprite(self):
        self.curSprite += 1
        wType = self.slots[self.curSlot].type
        if wType > 2:
            wType = 0
        if self.curSprite >= 4 * (wType + 1):
            self.curSprite = 4 * wType
        self.rotSprite = status.rotCenter(self.sprites[self.curSprite], self.direction)

    def getPath(self):
        angle = self.direction
        speed = 0
        if self.speed == 2:
            speed = SPRINT_SPEED
        elif self.speed == 1:
            speed = WALK_SPEED
        elif self.speed == 0:
            speed = 0
        elif self.speed == -1:
            speed = BACK_SPEED
        speed *= status.TICKS

        stepX = abs(cos(radians(angle)) * speed)
        stepY = abs(sin(radians(angle)) * speed)
        if 90 >= angle >= 0:
            stepX = stepX if speed >= 0 else -stepX
            stepY = -stepY if speed >= 0 else stepY
        elif 180 >= angle > 90:
            stepX = -stepX if speed >= 0 else stepX
            stepY = -stepY if speed >= 0 else stepY
        elif 270 >= angle > 180:
            stepX = -stepX if speed >= 0 else stepX
            stepY = stepY if speed >= 0 else -stepY
        elif 360 >= angle > 270:
            stepX = stepX if speed >= 0 else -stepX
            stepY = stepY if speed >= 0 else -stepY
        return stepX, stepY

    def forward(self, accCount, spriteCount):
        accCount += 1
        spriteCount += 1
        self.speed = 2 if self.sprint else 1
        if accCount >= 2:
            stepX, stepY = self.getPath()
            self.posX += stepX
            self.posY += stepY
            self.stepX = stepX
            self.stepY = stepY
            accCount = 0
        if spriteCount == 5 and self.sprint:
            self.nextSprite()
            spriteCount = 0
        elif spriteCount >= 8:
            self.nextSprite()
            spriteCount = 0
        return accCount, spriteCount

    def back(self, deccCount, spriteCount):
        self.speed = -1
        deccCount += 1
        if deccCount == 5:
            stepX, stepY = self.getPath()
            self.posX += stepX
            self.posY += stepY
            self.stepX = stepX
            self.stepY = stepY
            deccCount = 0
        if spriteCount == 10 and self.sprint:
            self.nextSprite()
            spriteCount = 0
        elif spriteCount >= 17:
            self.nextSprite()
            spriteCount = 0
        return deccCount, spriteCount

    def enterVehicle(self):
        for vehId, vehicle in enumerate(vehicles.getVehicles()):
            dist = self.distance((vehicle.getCenter()[0]-50, vehicle.getCenter()[1]-50))
            if dist < 80:
                self.status = status.DRIVING
                self.vehicleId = vehId
                sounds.play("enterVehicle")
                vehicle.hasPlayer = True
                vehicle.hasNPC = False
                return vehId

    def quitVehicle(self):
        vehicle = vehicles.getVehicles()[self.vehicleId]
        if vehicle.speed == 0:
            vehicle.hasPlayer = False
            self.status = status.WALKING
            self.vehicleId = -1
            self.speed = 0
            sounds.play("enterVehicle")
            self.sprint = False
            r = vehicle.direction
            self.posX = vehicle.getCenter()[0] + 20 - 175 + int(((180*(((r+270)%360)//180))+((((r+270)%360)%180)*(((((r+270)%360)//180)*2)-1)*-1))/180 * 150)
            self.posY = vehicle.getCenter()[1] + 20 - 175 + int(((180*(r//180))+((r%180)*(((r//180)*2)-1)*-1))/180 * 150)
            self.direction = vehicle.direction
            sounds.stop("forward")

    def getCorners(self):
        corners = []
        cornerX = cos(radians(self.direction + cANGLE)) * cDIAG  # Avant-Gauche
        cornerY = sin(radians(self.direction + cANGLE)) * cDIAG  # Arrière-Droit
        corners.append((self.posX + cornerX, self.posY - cornerY, 5, 5))
        corners.append((self.posX - cornerX, self.posY + cornerY, 5, 5))

        cornerX = cos(radians(self.direction - cANGLE)) * cDIAG  # Avant-Droit
        cornerY = sin(radians(self.direction - cANGLE)) * cDIAG  # Arrière-Gauche
        corners.append((self.posX + cornerX + cCENTER, self.posY - cornerY + cCENTER, 5, 5))
        corners.append((self.posX - cornerX + cCENTER, self.posY + cornerY + cCENTER, 5, 5))

        return corners

    def canMove(self):
        if self.speed == 0:
            return True
        forward = True if self.speed > 0 else False
        corner = list(self.getCorners()[0]) if forward else list(self.getCorners()[1])
        stepX, stepY = vehicles.getPath(self, HIT_SPACE)

        for column in range(0, int(cLARGE / HIT_SPACE) + 1):
            hitPos = [int(corner[0] + cCENTER + 55 - (stepY * column)), int(corner[1] + cCENTER + 55 + stepX * column)]
            if chunk.getPixelForHitboxe(hitPos[0],hitPos[1])!= (255, 255, 255, 255):
                self.curSprite = 2
                return False

            if not hitboxes.checkVehicles(self, hitPos) or not hitboxes.checkCharacters(self, hitPos):
                self.curSprite = 2
                return False
        return True

    def damage(self, damage):
        self.health -= damage
        if self.health <= 0:
            sounds.play("hitHuman")
            if self.isPlayer:
                self.health = 10
                self.posX = 2500
                self.posY = 2500
                chunk.init = 1
            else:
                self.remove()

    def distance(self, pos):
        dist = sqrt((pos[0] - self.getCenter()[0])**2 + (pos[1] - self.getCenter()[1])**2)
        return dist

    def shoot(self):
        weapon = self.slots[self.curSlot]
        if weapon.type <= 2:
            weapon.fireRateCount += 1
            if weapon.fireRateCount == weapon.fireRate:
                weapon.fireRateCount = 0
                weapon.shoot()
                if weapon.type != 0:
                    sounds.play("shoot")
        elif weapon.type == 3:
            weapon.use()

    def pickItem(self):
        for item in items.lsItems:
            if self.distance((item.posX, item.posY)) < 50:
                self.slots[self.curSlot].drop(self)
                item.posX = -1
                item.posY = -1
                item.playerId = self.id
                item.playerSlot = self.curSlot
                self.slots[self.curSlot] = item

    def drop(self):
        self.slots[self.curSlot].drop(self)
