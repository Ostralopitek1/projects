import pygame
import fonctionDialogue
import status

missionTexture = pygame.image.load("resources/mission.png")
position = [[2750, 3245, 60, 0],
            [9663, 2031, 60, 1],
            [3834, 14615, 60, 2],
            [4798, 13918, 60, 3],
            [4798, 13846, 60, 4],
            [14456, 4618, 60, 5]]

curMission = 0
detectMission = True

mapShow = False
map = pygame.image.load("resources/panneauCarte.png")
positionMap = [[5830, 5056, 71],
               [9351, 2191, 71],
               [11598, 4019, 71],
               [3374, 9950, 71],
               [8048, 12048, 71],
               [2940, 12941, 71],
               [13419, 13853, 71],
               [8063, 8663, 71],
               [1392, 9185, 71],
               [9930, 9217, 71]]

currScene = 0
currSpeech = -1
spawn = 0
missionFinal = False


def getMission(posX, posY):
    if not (curMission == 4 and status.getNewID(1) == True):
        global detectMission
        distance = int(
            (posX - position[curMission][0]) * (posX - position[curMission][0]) + (posY - position[curMission][1]) * (
                posY - position[curMission][1]))
        if distance < position[curMission][2] * position[curMission][2]:
            execMission()
            detectMission = False


def execMission():
    global curMission
    global currSpeech
    global detectMission
    global missionFinal
    global spawn

    if curMission == 0:
        if currSpeech < 8:
            currSpeech += 1
        else:
            curMission += 1
            currSpeech = -1
            spawn = 1
            detectMission = True

    elif curMission == 1:
        if currSpeech < 0:
            currSpeech += 1
        else:
            curMission += 1
            currSpeech = -1
            detectMission = True

    elif curMission == 2:
        if currSpeech < 2:
            currSpeech += 1
        else:
            curMission += 1
            currSpeech = -1
            detectMission = True

    elif curMission == 3:
        if currSpeech < 2:
            currSpeech += 1
        else:
            curMission += 1
            currSpeech = -1
            spawn = 2
            detectMission = True

    elif curMission == 4 and status.getNewID(1) == False:
        if currSpeech < 6:
            currSpeech += 1
        else:
            curMission += 1
            currSpeech = -1
            detectMission = True

    elif curMission == 5:
        if currSpeech < 0:
            currSpeech += 1
        else:
            curMission = 6
            currSpeech = -1
            detectMission = False
            missionFinal = True


def showMission(surface, posX, posY):
    if detectMission:
        surface.blit(missionTexture,
                     (-posX + 640 + position[curMission][0] - 42, -posY + 360 + position[curMission][1] - 45))


def detectSign(posX, posY):
    posX += 50
    posY += 50
    for i in range(0, len(positionMap)):
        distance = int((posX - positionMap[i][0]) * (posX - positionMap[i][0]) + (posY - positionMap[i][1]) * (
            posY - positionMap[i][1]))
        if distance < (positionMap[i][2] * positionMap[i][2]):
            return True
    return False


def changeMapShow(posX, posY):
    global mapShow
    if detectSign(posX, posY):
        if (mapShow == True):
            mapShow = False
        else:
            mapShow = True


def showMap(surface, posX, posY):
    if (mapShow == True):
        surface.blit(map, (0, 0))
        pygame.draw.circle(surface, (0, 255, 0), (
            380 + int((position[curMission][0]) / 13680 * 500 - 40), 67 + int((position[curMission][1]) / 17150 * 515)),
                           40,
                           1)
        pygame.draw.circle(surface, (255, 0, 0),
                           (380 + int((posX) / 13680 * 500) - 30, 67 + int(posY / 17150 * 515) + 10), 40, 1)


def showDialogMission(surface):
    if currSpeech != -1:
        fonctionDialogue.showDialogue(surface, curMission, currSpeech)


def showMissionFinal(surface):
    pygame.draw.rect(surface, (0, 0, 0), (0, 300, 1280, 150), 0)
    size = 50  # taille de la police
    font = pygame.font.SysFont('verdana', size)
    replique = font.render("MISSION TERMINÉE !", True, (255, 255, 255))
    surface.blit(replique, (400, 350))
