import pandas as pd
import json
import os
from collections import Counter
import spotipy
from flask import Flask




app=Flask(__name__)

@app.route('/playlister')
def SongRankerForPlaylist():
    directory = "Playlist Maker/spotify_million_playlist_dataset/data"
    #songCrossover = pd.DataFrame(columns = ['track_uri', 'appearances'])
    songCrossover = []

    for filename in os.listdir(directory):
        f = os.path.join(directory, filename)
        # checking if it is a file
        if os.path.isfile(f):
            with open(f) as jfile:
                jdict = json.load(jfile)
                for i in range(len(jdict["playlists"])):
                    for j in range(len(jdict["playlists"][i]["tracks"])):
                        if jdict["playlists"][i]["tracks"][j]["track_uri"]=="spotify:track:6I9VzXrHxO9rA9A5euc8Ak":
                            #print(jdict["playlists"][i]["name"])
                            for k in range(len(jdict["playlists"][i]["tracks"])):
                                #print(jdict["playlists"][i]["tracks"][k]["track_uri"])
                                songCrossover.append(jdict["playlists"][i]["tracks"][k]["track_uri"])



    songFrequency = Counter(songCrossover)
    print(songFrequency)
    playlistLen = 10
    length = 1
    #topRes = dict(list(songFrequency.items())[0: playlistLen])
    finalPlaylist = []

    for value, count in songFrequency.most_common():
        if length>playlistLen:
            break
        if value != "spotify:track:6I9VzXrHxO9rA9A5euc8Ak":
            finalPlaylist.append(value)
            length=length+1

    playlistDict = {}
    for i in range(len(finalPlaylist)):
        playlistDict['song '+str(i)]=finalPlaylist[i]

    return playlistDict