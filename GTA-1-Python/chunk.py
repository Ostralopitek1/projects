import pygame
import menu
#PARAMETRES
chunkLength = 780
totalChunkX = 20
totalChunkY = 21

init = 1


#CONSTANTES GLOBAL
chunkDivide = chunkLength/2

#VARIABLES GLOBAL
savePT = [0, 0]

positionChunkX = 0
positionChunkY = 0

chunkMode = [-1, -1]

chunkLoadTexture = [[[0,0,0], [0,0,0], [0,0,0]],
                    [[0,0,0], [0,0,0], [0,0,0]],
                    [[0,0,0], [0,0,0], [0,0,0]]]

chunkLoadTextureAdress = [[[0,0], [0,0], [0,0]],
                          [[0,0], [0,0], [0,0]],
                          [[0,0], [0,0], [0,0]]]


def initChunkTexture():
    for x in range(0,2):
        for y in range(0,2):
            chunkLoadTexture[y][x][0] = pygame.image.load("resources/map/0/"+ str(y) + "-" +str(x)+".png")

def getChunkUnderPlayer(posPlayerX,posPlayerY):
    return posPlayerX//chunkLength,posPlayerY//chunkLength

def getChunkUnderPlayerCharge(posPlayerX,posPlayerY):
    positionChunkX = posPlayerX//chunkLength
    positionChunkY = posPlayerY//chunkLength

    if positionChunkX <= 0:
        positionChunkX = 1

    if positionChunkY <= 0:
        positionChunkY = 1

    if positionChunkX >= totalChunkX:
        positionChunkX = totalChunkX-1

    if positionChunkY >= totalChunkY:
        positionChunkY = totalChunkY-1
    return positionChunkX,positionChunkY

def getPositionOnChunk(posPlayerX,posPlayerY):
    return int((posPlayerX%chunkLength)//chunkDivide),int((posPlayerY%chunkLength)//chunkDivide)

def setMode(posPlayerX,posPlayerY):
    posPlayerX = int(posPlayerX)
    posPlayerY = int(posPlayerY)

    posPlayerX -= chunkDivide
    posPlayerY -= chunkDivide

    if posPlayerX <0:
        chunkModeX = 0
    else:
        chunkModeX = (posPlayerX // (chunkDivide*2))%2

    if posPlayerY <0:
        chunkModeY = 0
    else:
        chunkModeY = (posPlayerY // (chunkDivide*2))%2

    if chunkModeX == 0:
        chunkModeX = -1
    if chunkModeY == 0:
        chunkModeY = -1

    chunkMode[0]= int(chunkModeX)
    chunkMode[1]=int(chunkModeY)


def prepareTexture(posPlayerX, posPlayerY):
    posPlayerX = int(posPlayerX)
    posPlayerY = int(posPlayerY)

    positionChunkX, positionChunkY = getChunkUnderPlayerCharge(posPlayerX,posPlayerY)
    global init

    if (savePT[0] != positionChunkX) or (savePT[1] != positionChunkY):
        for x in range(0,3):
            for y in range(0,3):
                if(((x == (positionChunkX - savePT[0]) + 1) and (positionChunkX - savePT[0] != 0) ) or  ((y == (positionChunkY - savePT[1]) + 1) and (positionChunkY - savePT[1] != 0)) or (init == 1)):
                    chunkLoadTexture[chunkLoadTextureAdress[y][x][1]][chunkLoadTextureAdress[y][x][0]][0] = pygame.image.load("resources/map/"+ str(menu.health_quality) +"/" + str(positionChunkY - 1 +y) + "-" +str(positionChunkX - 1 +x)+(".jpg" if menu.health_quality ==0 else ".png"))
                    chunkLoadTexture[chunkLoadTextureAdress[y][x][1]][chunkLoadTextureAdress[y][x][0]][1] = pygame.image.load("resources/map/1/"+ str(positionChunkY - 1 +y) + "-" +str(positionChunkX - 1 +x)+".png")
                    chunkLoadTexture[chunkLoadTextureAdress[y][x][1]][chunkLoadTextureAdress[y][x][0]][2] = pygame.image.load("resources/map/2/"+ str(positionChunkY - 1 +y) + "-" +str(positionChunkX - 1 +x)+".jpg")

        init = 0
        savePT[0], savePT[1] = positionChunkX, positionChunkY


def updateScreenChunk(surface, posPlayerX, posPlayerY,mode):
    posPlayerX = int(posPlayerX)
    posPlayerY = int(posPlayerY)
    chunkPosX = savePT[0] - 1
    chunkPosY = savePT[1] - 1

    for x in range(0,3):
        for y in range(0,3):
            surface.blit(chunkLoadTexture[chunkLoadTextureAdress[y][x][1]][chunkLoadTextureAdress[y][x][0]][mode], (-posPlayerX + 640  +(x*chunkLength)+(chunkPosX*chunkLength), -posPlayerY + 360  +(y*chunkLength)+(chunkPosY*chunkLength)))

def prepareChunkLoadTexture(posPlayerX,posPlayerY):
    posPlayerX = int(posPlayerX)
    posPlayerY = int(posPlayerY)

    positionChunkX, positionChunkY = getChunkUnderPlayerCharge(posPlayerX,posPlayerY)

    stepX = positionChunkX%3
    stepY = positionChunkY%3

    for x in range(0,3):
        for y in range(0,3):
            chunkLoadTextureAdress[y][x][0] = (x+stepX)%3
            chunkLoadTextureAdress[y][x][1] = (y+stepY)%3


def showLineChunk(surface,x,y):
    for i in range(0,totalChunkX+2):
        pygame.draw.line(surface,(255,0,0),(i*chunkLength-x+640,0-y+360),(i*chunkLength-x+640,chunkLength*(totalChunkY+1)-y+360),3)

    for j in range(0,totalChunkY+2):
        pygame.draw.line(surface,(255,0,0),(0-x+640,j*chunkLength-y+360),(chunkLength*(totalChunkX+1)-x+640,j*chunkLength-y+360),3)


def getPixelForHitboxe(posX,posY):
    chunkX = posX//chunkLength
    chunkY = posY//chunkLength
    posChunkX = posX%chunkLength
    posChunkY = posY%chunkLength
    global savePT
    x = ((chunkX-2)%3)
    y = ((chunkY-2)%3)
    return chunkLoadTexture[y][x][2].get_at((posChunkX,posChunkY))


