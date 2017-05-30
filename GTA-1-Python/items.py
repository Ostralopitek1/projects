import math
import characters
import vehicles
import hitboxes
import chunk
import pygame

FIST = 0
GUN = 1
RIFLE = 2
SYRINGE = 3

lsItems = []
lsAmmo = []

ammo = pygame.image.load("resources/ammo.png")


class Item:
    def __init__(self, type, posX, posY):
        self.id = -1
        self.playerId = -1
        self.playerSlot = -1
        self.posX = posX
        self.posY = posY
        if posX != -1:
            self.id = len(lsItems)
            lsItems.append(self)
        self.type = type
        self.fireRateCount = 0
        self.fireRate = -1
        self.damage = -1
        self.shootingRange = -1
        self.isWeapon = False
        if type <= 2:
            self.isWeapon = True
            # Poing
            if type == 0:
                self.damage = 2.5
                self.fireRate = 30
                self.shootingRange = 70
            # Pistolet
            elif type == 1:
                self.damage = 10
                self.fireRate = 20
                self.shootingRange = 800
            # Rifle
            elif type == 2:
                self.damage = 100
                self.fireRate = 5
                self.shootingRange = 800

    def shoot(self):
        player = characters.lsCharacters[self.playerId]
        # lsHits = [[], []]
        stepX, stepY = self.getPath(player.direction - 1, player.hitSpace)
        for line in range(int(self.shootingRange / player.hitSpace)):
            point = int(player.getCenter()[0] + stepX * line), int(player.getCenter()[1] + stepY * line)
            # Vérifier si il y a une hitBox sur ce point
            if chunk.getPixelForHitboxe(point[0], point[1]) != (255, 255, 255, 255):
                Ammo(player.getCenter(), point, (stepX, stepY), 0, 0, player.direction)
                return
            # Si le point est à côté d'un véhicule ou d'un personnage
            resHit = hitboxes.hitSomething(point)
            if resHit[0] != 0:
                if self.type == 0:
                    resHit[1].damage(self.damage)
                else:
                    Ammo(player.getCenter(), point, (stepX, stepY), resHit[1], self.damage, player.direction)
                return

        line = int(self.shootingRange / player.hitSpace)
        point = int(player.getCenter()[0] + stepX * line), int(player.getCenter()[1] + stepY * line)
        if self.type != 0:
            Ammo(player.getCenter(), point, (stepX, stepY), 0, 0, player.direction)

    def use(self):
        player = characters.lsCharacters[self.playerId]
        player.health = 10
        player.slots[player.curSlot] = Item(0, -1, -1)
        del self

    def drop(self, player):
        self.playerId = -1
        self.posX = player.posX
        self.posY = player.posY
        self.id = len(lsItems)
        player.slots[player.curSlot] = Item(0, -1, -1)

    def getPath(self, angle, hypo):
        stepX = abs(math.cos(math.radians(angle)) * hypo)
        stepY = abs(math.sin(math.radians(angle)) * hypo)
        if 90 >= angle >= 0:
            stepX = stepX if hypo >= 0 else -stepX
            stepY = -stepY if hypo >= 0 else stepY
        elif 180 >= angle > 90:
            stepX = -stepX if hypo >= 0 else stepX
            stepY = -stepY if hypo >= 0 else stepY
        elif 270 >= angle > 180:
            stepX = -stepX if hypo >= 0 else stepX
            stepY = stepY if hypo >= 0 else -stepY
        elif 360 >= angle > 270:
            stepX = stepX if hypo >= 0 else -stepX
            stepY = stepY if hypo >= 0 else -stepY
        return stepX, stepY


class Ammo:
    def __init__(self, startPos, endPos, step, obj, damage, direction):
        self.posX = startPos[0]
        self.posY = startPos[1]
        self.direction = direction
        self.obj = list(endPos)
        self.damageObj = obj
        self.damage = damage
        self.stepX = step[0] * 2
        self.stepY = step[1] * 2
        lsAmmo.append(self)

    def remove(self):
        if self.damageObj in vehicles.getVehicles():
                self.damageObj.damage(self.damage)
        elif self.damageObj in characters.lsCharacters:
                self.damageObj.damage(self.damage)
        lsAmmo.remove(self)

    def distance(self, pos):
        dist = math.sqrt((pos[0] - self.posX)**2 + (pos[1] - self.posY)**2)
        return dist


item = [Item(1, 2500, 2900),
        Item(2, 10500, 2500),
        Item(1, 8000, 4500),
        Item(2, 7000, 600),
        Item(1, 4030, 14000),
        Item(2, 8780, 10700),
        Item(1, 10500, 9000),
        Item(3, 3293, 4112),
        Item(3, 10650, 1328)]

for i in range(len(item)):
    lsItems.append(item[i])
