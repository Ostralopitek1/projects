import pygame, sys
import xml.etree.ElementTree as ET
from pygame.locals import *


def showDialogue(maSurface,curScene,curRep):
    x = 1080
    y = 720
    pygame.draw.rect(maSurface,(0,0,0),(0,620,1280,120),0)
    white = (255,255,255)
    tree = ET.parse('data/data.xml')
    fr = tree.getroot()
    size = 15 #taille de la police
    font = pygame.font.SysFont('verdana',size)
    replyIndex = fr[0][curScene][curRep]
    strRep = " " + str(replyIndex.text)
    length = len(strRep)
    characterRemaining = length
    curCaracterEnd = 0
    curCaracterStart = 0
    numbersOfLettersMax = int(x / size * 2)+27
    numbersOfLignes = 5#int(length / numbersOfLettersMax + 1)
    space = numbersOfLettersMax
    line = 0
    startText = y - numbersOfLignes * size
    if (length < numbersOfLettersMax):
            replique = font.render(strRep,True,white)
            maSurface.blit(replique,(20,startText))
    else:
        while (characterRemaining > 0):
            for i in range(space,0,-1):
                if (characterRemaining < numbersOfLettersMax):
                    #print(strRep[curCaracterStart:])
                    replique = font.render(strRep[1+curCaracterStart:],True,white)
                    maSurface.blit(replique,(20,startText))
                    characterRemaining = -1
                    break
                elif strRep[i+length-characterRemaining] == " ":
                    curCaracterEnd += i
                    """print("line :", line)
                    print("start :",curCaracterStart)
                    print("end :",curCaracterEnd)
                    print(strRep[curCaracterStart:curCaracterEnd])
                    print(startText + (i*size))"""
                    replique = font.render(strRep[curCaracterStart+1:curCaracterEnd],True,white)
                    maSurface.blit(replique,(20,startText))
                    characterRemaining = characterRemaining - i
                    startText += size
                    space += i
                    line += 1
                    curCaracterStart = curCaracterEnd


"""
pygame.init()
x = 1280
y = 720
maSurface = pygame.display.set_mode((x,y))
pygame.display.set_caption('Hello SUPINFO')
inProgress = True
while inProgress:
    for event in pygame.event.get():
        if event.type == MOUSEBUTTONUP:
            maSurface.fill((255,0,0))
            showDialogue(maSurface,0,3)
        if event.type == QUIT:
            inProgress = False
    pygame.display.update()
pygame.quit()
"""