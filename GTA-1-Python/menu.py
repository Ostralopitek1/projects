import pygame
import sounds
from pygame.locals import *

continuer_partie = False
health_music = 1
health_son = 1
health_quality = 0
screen = 0
niveau = []
niveauTwo = ['a', 'r', 'y', 'l', 'm']
largeur_sprite = 418
hauteur_sprite = 118
largSpriteParam = 160
hautSpriteParam = 52
largFen = 1280
hautFen = 720
fond = pygame.image.load("resources/menu/fond.png")
btnStart = pygame.image.load("resources/menu/startButon.png")
btnParameter = pygame.image.load("resources/menu/parameterButon.png")
btnExit = pygame.image.load("resources/menu/exitButon.png")
musicOn = pygame.image.load("resources/menu/musiqueOn.png")
musicOff = pygame.image.load("resources/menu/musiqueOff.png")
sonOn = pygame.image.load("resources/menu/sonOn.png")
sonOff = pygame.image.load("resources/menu/sonOff.png")
qualityLow = pygame.image.load("resources/menu/qualityL.png")
qualityHigh = pygame.image.load("resources/menu/qualityH.png")
credits = pygame.image.load("resources/menu/credits.png")
back = pygame.image.load("resources/menu/back.png")

def creation(fenetre):
    global niveau
    global screen

    if screen == 0:
        niveau = ['s', 'p', 'e']
        return niveau

    elif screen == 1:
        pass

def affichageMenu(fenetre):
    global continuer_partie
    global screen
    global niveau
    global niveauTwo
    global health_music
    global health_son
    global health_quality

    while not continuer_partie:
        num_ligne = 0
        fenetre.fill((0,0,0))
        fenetre.blit(fond, (0, 0))
        for sprite in niveau:
            if sprite == 's':
                fenetre.blit(btnStart, (((largFen//2)-(largeur_sprite//2)), ((hautFen//2)-(hauteur_sprite//2)-120)))
            elif sprite == 'p':
                fenetre.blit(btnParameter, (((largFen//2)-(largeur_sprite//2)), ((hautFen//2)-(hauteur_sprite//2))))
            elif sprite == 'e':
                fenetre.blit(btnExit, (((largFen//2)-(largeur_sprite//2)), ((hautFen//2)-(hauteur_sprite//2)+120)))
            elif sprite == 'a':
                fenetre.blit(musicOn, (520, 74))
            elif sprite == 'z':
                fenetre.blit(musicOff, (520, 74))
            elif sprite == 'r':
                fenetre.blit(sonOn, (520, 174))
            elif sprite == 't':
                fenetre.blit(sonOff, (520, 174))
            elif sprite == 'y':
                fenetre.blit(qualityLow, (520, 374))
            elif sprite == 'u':
                fenetre.blit(qualityHigh, (520, 374))
            elif sprite == 'l':
                fenetre.blit(credits, (520, 524))
            elif sprite == 'm':
                fenetre.blit(back, (100, 524))

        pygame.display.update()

        num_ligne += 1

        for event in pygame.event.get():
            if event.type == QUIT:
                continuer_partie = False
                pygame.quit()

            elif event.type == MOUSEBUTTONDOWN and event.button == 1 and screen == 0:
                if event.pos[0] > ((largFen/2)-(largeur_sprite/2)) and event.pos[0] < ((largFen/2)+(largeur_sprite/2)) and event.pos[1] > ((hautFen/2)-(hauteur_sprite/2)-120) and event.pos[1] < ((hautFen/2)+(hauteur_sprite/2)-120):
                    continuer_partie = True
                    return 0

                elif event.pos[0] > ((largFen/2)-(largeur_sprite/2)) and event.pos[0] < ((largFen/2)+(largeur_sprite/2)) and event.pos[1] > ((hautFen/2)-(hauteur_sprite/2)) and event.pos[1] < ((hautFen/2)+(hauteur_sprite/2)):
                    screen = 1
                    niveau = niveauTwo

                elif event.pos[0] > ((largFen/2)-(largeur_sprite/2)) and event.pos[0] < ((largFen/2)+(largeur_sprite/2)) and event.pos[1] > ((hautFen/2)-(hauteur_sprite/2)+120) and event.pos[1] < ((hautFen/2)+(hauteur_sprite/2)+120):
                    continuer_partie = True
                    return 1

            elif event.type == MOUSEBUTTONDOWN and event.button == 1 and screen == 1:
                if event.pos[0] > (520) and event.pos[0] < (680) and event.pos[1] > (74) and event.pos[1] < (126) and health_music == 1:
                    health_music = 0
                    sounds.stop("musique")
                    niveauTwo[0] = 'z'

                elif event.pos[0] > (520) and event.pos[0] < (680) and event.pos[1] > (74) and event.pos[1] < (126) and health_music == 0:
                    health_music = 1
                    sounds.play("musique")
                    niveauTwo[0] = 'a'

                elif event.pos[0] > (520) and event.pos[0] < (680) and event.pos[1] > (174) and event.pos[1] < (226) and health_son == 1:
                    health_son = 0
                    sounds.stopAll()
                    niveauTwo[1] = 't'

                elif event.pos[0] > (520) and event.pos[0] < (680) and event.pos[1] > (174) and event.pos[1] < (226) and health_son == 0:
                    health_son = 1
                    niveauTwo[1] = 'r'

                elif event.pos[0] > (520) and event.pos[0] < (680) and event.pos[1] > (374) and event.pos[1] < (426) and health_quality == 0:
                    health_quality = 3
                    niveauTwo[2] = 'u'

                elif event.pos[0] > (520) and event.pos[0] < (680) and event.pos[1] > (374) and event.pos[1] < (426) and health_quality == 3:
                    health_quality = 0
                    niveauTwo[2] = 'y'

                elif event.pos[0] > (520) and event.pos[0] < (680) and event.pos[1] > (524) and event.pos[1] < (576):
                    pass

                elif event.pos[0] > (100) and event.pos[0] < (150) and event.pos[1] > (524) and event.pos[1] < (574):
                    screen = 0
                    creation(fenetre)
