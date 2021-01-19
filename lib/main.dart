import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayer2/audioplayer2.dart';
import 'package:volume/volume.dart';
import 'dart:async';

import 'music.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musique',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Spotify de la hess'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Musique>  musicList = [
    new Musique("Grave", "Eddy de Pretto", 'assets/eddy.jpg', 'https://puu.sh/H3Inn/a16703f8b6.mp3'),
    new Musique("Nuvole Bianche", "Ludovico Einaudi", 'assets/le.jpg', 'https://puu.sh/H3IjH/8a679742d7.mp3'),
    new Musique("These days", "Rudimental", 'assets/thesed.jpg', 'https://puu.sh/H3I6z/40ac26b4d4.mp3')
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSub;

  Musique currentMusic;
  int index = 0;
  PlayerState statut = PlayerState.STOPPED;
  Duration position = new Duration(seconds: 0);
  Duration duration = new Duration(seconds: 30);
  bool isMuted = false;
  int maxVolume = 0,
    currentVolume = 0,
    previousVolume = 0;

  @override
  void initState() {
    super.initState();
    currentMusic = musicList[index];
    configAudioPlayer();
    initPlateformState();
    updateVolume();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    int newVol = getVolumePourcent().toInt();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title.toUpperCase()),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              width: deviceWidth/1.5,
              margin: EdgeInsets.only(top: 20.0),
              child: new Image.asset(currentMusic.imgPath),
            ),
            new Container(
              margin: EdgeInsets.only(top: 20.0),
              child: new Text(
                currentMusic.title,
                textScaleFactor: 2,
              ),
            ),
            new Container(
              margin: EdgeInsets.only(top: 5.0),
              child: new Text(
                currentMusic.artist,
                textScaleFactor: .9,
                style: new TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            new Container(
              height: deviceWidth / 5,
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IconButton(icon: new Icon(Icons.fast_rewind), onPressed: rewind),
                  new IconButton(
                    icon: (statut != PlayerState.PLAYING) ? new Icon(Icons.play_arrow) : new Icon(Icons.pause),
                    onPressed: (statut != PlayerState.PLAYING) ? play : pause,
                    iconSize: 50,
                  ),
                  new IconButton(icon: new Icon(Icons.fast_forward), onPressed: forward)
                ],
              ),
            ),
            new Container(
              margin: EdgeInsets.only(top:20.0, left: 15, right: 15),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  textWithStyle(fromDuration(position), .8),
                  textWithStyle(fromDuration(duration), .8)
                ],
              ),
            ),
            new Container(
              margin: EdgeInsets.only(top:5.0),
              child: new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: duration.inSeconds.toDouble(),
                inactiveColor: Colors.grey[500],
                activeColor: Colors.redAccent,
                onChanged: (double d) {
                  setState(() {
                    audioPlayer.seek(d);
                  });
                }
              ),
            ),
            new Container(
              height: deviceWidth/5,
              margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 0.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  new IconButton(
                      icon: new Icon(Icons.remove),
                      iconSize: 18,
                      onPressed: () {
                        if(!isMuted) {
                          Volume.volDown();
                          updateVolume();
                        }
                      }
                  ),
                  new Slider(
                    value: (isMuted) ? 0.0 : currentVolume.toDouble(),
                    min: 0.0,
                    max: maxVolume.toDouble(),
                    inactiveColor: (isMuted) ? Colors.red : Colors.grey[500],
                    activeColor: (isMuted) ? Colors.red : Colors.blue,
                    onChanged: (double d) {
                      setState(() {
                        if(!isMuted) {
                          Volume.setVol(d.toInt());
                          updateVolume();
                        }
                      });
                    }
                  ),
                  new Text(
                    (isMuted) ? 'Mute' : '$newVol%',
                    style: new TextStyle(
                      color: Colors.grey[500]
                    ),
                  ),
                  new IconButton(
                      icon: new Icon(Icons.add),
                      iconSize: 18,
                      onPressed: () {
                        if(!isMuted) {
                          Volume.volUp();
                          updateVolume();
                        }
                      }
                  ),
                  new IconButton(
                      icon: (isMuted) ? new Icon(Icons.headset_off) : new Icon(Icons.headset),
                      iconSize: 18,
                      onPressed: muted
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //Gestion de l'interface
  Text textWithStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.redAccent,
        fontSize: 15.0,
      ),
    );
  }

  IconButton button(IconData icon, double size, ActionMusic action) {
    return new IconButton(
        icon: new Icon(icon),
        iconSize: size,
        color: Colors.white,
        onPressed: () {
          switch(action) {
            case ActionMusic.PLAY:
              play();
              break;
            case ActionMusic.PAUSE:
              pause();
              break;
            case ActionMusic.FORWARD:
              forward();
              break;
            case ActionMusic.REWIND:
              rewind();
              break;
            default: break;

          }
        });
  }

  //Gestion du volume
  double getVolumePourcent() {
    return (currentVolume / maxVolume) * 100;
  }

  Future<void> initPlateformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  updateVolume() async {
    maxVolume = await Volume.getMaxVol;
    currentVolume = await Volume.getVol;
    setState(() {

    });
  }

  setVol(int i) async {
    await Volume.setVol(i);
  }

  void muted() {
    if(isMuted) {
      setState(() {
        previousVolume = currentVolume;
        isMuted = !isMuted;
        Volume.setVol(previousVolume);
      });
    } else {
      setState(() {
        isMuted = !isMuted;
        Volume.setVol(0);
      });
    }
  }

  //Lecteur audio
  void configAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen((pos) {
      setState(() {
        position = pos;
      });
      if(position >= duration) {
        position = new Duration(seconds: 0);
      }
    });
    stateSub = audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == AudioPlayerState.PLAYING) {
        setState(() {
          duration = audioPlayer.duration;
        });
      } else if(state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.STOPPED;
        });
      }
    }, onError: (msg) {
      print(msg);
      setState(() {
        statut = PlayerState.STOPPED;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(currentMusic.musicURL, isLocal: true);
    setState(() {
      statut = PlayerState.PLAYING;
    });
  }
  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.PAUSED;
    });
  }
  Future mute() async {
    await audioPlayer.mute(!isMuted);
    setState(() {
      isMuted = !isMuted;
    });
  }

  void forward() {
    if(index == musicList.length - 1)
      index = 0;
    else
      index++;
    currentMusic = musicList[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }

  void rewind() {
    if(position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if(index == 0)
        index = musicList.length - 1;
      else
        index--;
    }
    currentMusic = musicList[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }

  String fromDuration(Duration duree) {
    String min = duree.inMinutes.remainder(60).toString().padLeft(2, '0');
    String sec = duree.inSeconds.remainder(60).toString().padLeft(2, '0');
    return min + ':' + sec;
  }
}

enum ActionMusic {
  PLAY,
  PAUSE,
  REWIND,
  FORWARD
}

enum PlayerState {
  PLAYING,
  STOPPED,
  PAUSED
}