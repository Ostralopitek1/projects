import pygame


#Image
pistol = pygame.image.load("resources/items/pistol.png")
rifle = pygame.image.load("resources/items/rifle.png")
health = pygame.image.load("resources/items/heal.png")



def showLife(surface,life):
    pygame.draw.rect(surface,(150,150,150),(1050,10,220,20))
    pygame.draw.rect(surface,(0,100,0),(1052,12,216,16))
    pygame.draw.rect(surface,(0,150,0),(1052,12,int(21.6*life),16))


def showItems(surface,curSlot,allSlot):
    for i in range(0,4):
        pygame.draw.rect(surface,(150,150,150,),(1190,200+i*90,70,70))
        if curSlot == i:
            pygame.draw.rect(surface,(100,100,100),(1190,200+i*90,70,70),2)
        if allSlot[i].type == 1:
            surface.blit(pistol, (1200,210+i*90))
        elif allSlot[i].type == 2:
            surface.blit(rifle, (1200,210+i*90))
        elif allSlot[i].type == 3:
            surface.blit(health, (1200,210+i*90))