import objects
import math
import random
import pygame

MAX_SPEED = 15
MAX_BACK_SPEED = -7
lsVehicles = []


def getVehicles():
    return lsVehicles


def getVehicle(vehicleid):
    return lsVehicles[vehicleid]


def getTypeSprite(type):
    spritePath = "resources/vehicles/" + str(type) + ".png"
    return pygame.image.load(spritePath)


def accelerate(vehicle, c):
    c += 1
    if c == 10 and vehicle.canMove():
        if vehicle.speed < MAX_SPEED:
            vehicle.speed += 1
        c = 0
    return c


def back(vehicle, backCount):
    backCount += 1
    speed = vehicle.speed - 1
    if backCount >= 5 and speed > MAX_BACK_SPEED and vehicle.canMove():
        vehicle.speed = speed
        backCount = 0
    return backCount


def decelerate(vehicle, deceleration):
    if vehicle.speed > 0:
        vehicle.speed -= deceleration
    elif vehicle.speed < 0:
        vehicle.speed += deceleration


def autoBrake(c):
    c += 1
    if c == 30:
        for vehicle in getVehicles():
            decelerate(vehicle, 1)
        c = 0
    return c


def forward():
    for vehicle in getVehicles():
        if not vehicle.canMove():
            vehicle.speed = 0
            continue
        vehicle.speed = vehicle.getMaxSpeed()
        stepX, stepY = getPath(vehicle, vehicle.speed)
        vehicle.posX += stepX
        vehicle.posY += stepY
        vehicle.stepX = stepX
        vehicle.stepY = stepY


def turnRight(vehicle):
    if abs(vehicle.speed) >= 2:
        angle = vehicle.direction
        vehicle.prevDirection = angle
        if angle <= 0:
            vehicle.direction = 360
        vehicle.direction -= 2


def turnLeft(vehicle):
    if abs(vehicle.speed) >= 2:
        angle = vehicle.direction
        vehicle.prevDirection = angle
        if angle >= 360:
            vehicle.direction = 0
        vehicle.direction += 2


def getPath(vehicle, speed):
    angle = vehicle.direction
    stepX = abs(math.cos(math.radians(angle)) * speed)
    stepY = abs(math.sin(math.radians(angle)) * speed)
    if 90 >= angle >= 0:
        stepX = stepX if vehicle.speed >= 0 else -stepX
        stepY = -stepY if vehicle.speed >= 0 else stepY
    elif 180 >= angle > 90:
        stepX = -stepX if vehicle.speed >= 0 else stepX
        stepY = -stepY if vehicle.speed >= 0 else stepY
    elif 270 >= angle > 180:
        stepX = -stepX if vehicle.speed >= 0 else stepX
        stepY = stepY if vehicle.speed >= 0 else -stepY
    elif 360 >= angle > 270:
        stepX = stepX if vehicle.speed >= 0 else -stepX
        stepY = stepY if vehicle.speed >= 0 else -stepY
    return stepX, stepY

vehiculeSpawn = [[1650,2380,90],
                 [2190,2585,270],
                 [2080,3050,90],
                 [1760,3920,270],
                 [2405,4585,270],
                 [10150,2840,120],
                 [10495,3625,297],
                 [11275,2680,180],
                 [11050,900,270],
                 [9450,11800,270],
                 [11100,9150,270],
                 [14850,4850,180],
                 [4000,13800,180],
                 [2800,13400,0],
                 [2800,13600,0],
                 [6500,12000,180]]

def spawnAll(surface):
    for i in range(len(vehiculeSpawn)):
        objects.Vehicle(surface, False, random.randint(0, 7), vehiculeSpawn[i][0], vehiculeSpawn[i][1], vehiculeSpawn[i][2])