import pygame, characters, objects, status, vehicles
from math import *


def distance(pointA, pointB):
    dist = sqrt((pointB[0] - pointA[0])**2 + (pointB[1] - pointA[1])**2)
    return dist

def checkCharacters(obj, hitPos):
    
    nearestCharacters = []
    for hitChar in characters.lsCharacters:
        if obj.distance(hitChar.getCenter()) < objects.vLONG + objects.cLONG + 40:
            if hitChar != obj and hitChar.status != status.DRIVING:
                nearestCharacters.append(hitChar)
    
    # Vérifier si hitPos point est dans un personnage
    for char in nearestCharacters:
        # Décalage entre chaque triangle
        cornerChar = list(char.getCorners()[3]) if char.speed >= 0 else list(char.getCorners()[2])
        stepXchar, stepYchar = vehicles.getPath(char, obj.hitSpace)

        # Récupérer tous les points à l'intérieur du véhicule
        for line in range(0, int((objects.cLONG / 1.5 / obj.hitSpace + 1))):
            cornerChar[0] += stepXchar
            cornerChar[1] += stepYchar
            for columnChar in range(0, int(objects.cLARGE / obj.hitSpace) + 1):
                hitPosChar = [int(cornerChar[0] - stepYchar * columnChar), int(cornerChar[1] + stepXchar * columnChar)]
                dist = distance(hitPosChar, hitPos)
                if dist <= 10:
                    return False
    return True
                
def checkVehicles(obj, hitPos):
    # Récupérer tous les véhicules proches
    nearestVehicles = []
    for hitVeh in vehicles.getVehicles():
        if obj.distance(hitVeh.getCenter()) < objects.vLONG + 10:
            if hitVeh != obj:
                nearestVehicles.append(hitVeh)

    # Vérifier si hitPos est dans une voiture
    for veh in nearestVehicles:
        # Décalage entre chaque triangle
        cornerVeh = list(veh.getCorners()[3]) if veh.speed >= 0 else list(veh.getCorners()[0])
        stepXveh, stepYveh = vehicles.getPath(veh, obj.hitSpace)

        #Récupérer tous les points à l'intérieur du véhicule
        for line in range(0, int((objects.vLONG / obj.hitSpace))):
            cornerVeh[0] += stepXveh
            cornerVeh[1] += stepYveh
            for columnVeh in range(0, int(objects.vLARGE / obj.hitSpace) + 1):
                hitPosVeh = [int(cornerVeh[0] - stepYveh * columnVeh), int(cornerVeh[1] + stepXveh * columnVeh)]
                dist = distance(hitPosVeh, hitPos)
                if dist <= 10:
                    return False
    return True

def hitSomething(point):
    for vehicle in vehicles.getVehicles():
        if vehicle.distance(point) <= objects.vLARGE:
            return 1, vehicle
    for char in characters.lsCharacters:
        if not char.isPlayer and char.distance(point) <= 50:
            return 2, char
    return 0, 0

def getNearestVehicle(point):
    shortest = 18000
    veh = 0
    for vehicle in vehicles.getVehicles():
        dist = vehicle.distance(point)
        if dist < shortest:
            veh = vehicle
    return veh

def getNearestCharacter(point):
    shortest = 18000
    char = 0
    for character in characters.lsCharacters:
        dist = character.distance(point)
        if dist < shortest:
            char = character
    return char
