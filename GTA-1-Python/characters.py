import pygame

lsCharacters = []

def getStatus(datPlayer):
    #Le joueur est à pied
    if datPlayer[3] == -1:
        return False
    #Le joueur est en véhicule
    else:
        return True

def getPlayer():
    for char in lsCharacters:
        if char.isPlayer:
            return char

def getVehicleID(datPlayer):
    return datPlayer[3]

def rot_center(image, angle):
    orig_rect = image.get_rect()
    rot_image = pygame.transform.rotate(image, angle)
    rot_rect = orig_rect.copy()
    rot_rect.center = rot_image.get_rect().center
    rot_image = rot_image.subsurface(rot_rect).copy()
    return rot_image