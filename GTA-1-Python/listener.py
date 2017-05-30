import datetime

def onQuit(startTime):
    file = open("data/time.txt", "r+")
    text = file.read()
    file.seek(0, 0)
    lastTime = datetime.datetime.strptime(text[:8], "%H:%M:%S")
    playTime = lastTime + (datetime.datetime.now() - startTime)
    file.write(str(playTime)[11:19])
    file.close()
