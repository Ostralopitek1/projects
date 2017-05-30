import pygame
import menu
import random

sounds = []

def init():
    pygame.mixer.init()
    sounds.append(pygame.mixer.Sound("resources/sounds/choc_parechoc.wav"))
    sounds.append(pygame.mixer.Sound("resources/sounds/explosion.wav"))
    sounds.append(pygame.mixer.Sound("resources/sounds/freinage.wav"))
    sounds.append(pygame.mixer.Sound("resources/sounds/klaxon.wav"))
    sounds.append(pygame.mixer.Sound("resources/sounds/portiere.wav"))
    sounds.append(pygame.mixer.Sound("resources/sounds/ambiant.wav"))
    sounds.append(pygame.mixer.Sound("resources/sounds/pistolet.wav"))
    sounds.append(pygame.mixer.Sound("resources/sounds/voiture.wav"))
    sounds.append(pygame.mixer.Sound("resources/sounds/hitHuman.wav"))

    music = str(random.randint(0, 2))
    strMusic = "resources/sounds/musique" + music + ".wav"
    sounds.append(pygame.mixer.Sound(strMusic))

def play(sound):
    if menu.health_son == 1 or sound == "musique":
        if sound == "shoot":
            sounds[6].play()
        elif sound == "ambiant":
            sounds[5].play(loops=-1)
        elif sound == "enterVehicle":
            sounds[4].play()
        elif sound == "klaxon":
            sounds[3].play()
        elif sound == "brake":
            sounds[2].play()
        elif sound == "explosion":
            sounds[1].play()
        elif sound == "hitVehicle":
            sounds[0].play()
        elif sound == "forward":
            sounds[7].play(loops=-1)
        elif sound == "hitHuman":
            sounds[8].play()
        elif sound == "musique":
            sounds[9].play(loops=-1)

def stop(sound):
    if menu.health_son == 1 or sound == "musique":
        if sound == "shoot":
            sounds[6].stop()
        elif sound == "ambiant":
            sounds[5].stop(loops=-1)
        elif sound == "enterVehicle":
            sounds[4].stop()
        elif sound == "klaxon":
            sounds[3].stop()
        elif sound == "brake":
            sounds[2].stop()
        elif sound == "explosion":
            sounds[1].stop()
        elif sound == "hitVehicle":
            sounds[0].stop()
        elif sound == "forward":
            sounds[7].stop()
        elif sound == "hitHuman":
            sounds[8].stop()
        elif sound == "musique":
            sounds[9].stop()

def stopAll():
    for sound in range(len(sounds)-1):
        sounds[sound].stop()
