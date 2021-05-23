#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Fast Volume changes might trip this protection. Setting it *10 the default!
#HotkeyInterval 2000  ; This is the default value (milliseconds).
#MaxHotkeysPerInterval 700
;This is for performance. See here for more details: https://www.autohotkey.com/docs/misc/Performance.htm
;SetBatchLines -1
;ListLines Off

#Persistent
;#InputLevel 100
#Include <VMR/VMR> ;https://github.com/SaifAqqad/VMR.ahk
#Include <OSD> ;https://github.com/SaifAqqad/AHK_MicMute/blob/master/src/UI/OSD.ahk
Global vm,osd

vm:= new VMR().login()
osd:=new OSD()
osd.setTheme(1)

;Sleep, 500 ; garuntee init? sometimes curious errors pop up.

F18::
    vm.strip[3].mute--
    toggle:=vm.strip[3].muted
    osd.showAndHide("OVC: "(toggle ? "Active" : "Deafened") . "",(toggle?1:-1))
    return
;Mute Other VoiceChat's (aside from discord/primary VoiceChat), that might be active, or not.
F14::
    vm.strip[1].B3:=not vm.strip[1].B3
    toggle:=vm.strip[1].B3
    osd.showAndHide("OVC: "(toggle ? "Muted" : "Unmuted") . "",(toggle?1:-1))
    return

;Deafen Discord/Primary VoiceChat
F15::
    if (vm.strip[2].A1!=vm.strip[2].A2){
        vm.strip[2].A1:=1
        vm.strip[2].A2:=1
    }else{
        vm.strip[2].A1:=not vm.strip[2].A1
        vm.strip[2].A2:=not vm.strip[2].A2
    }
    toggle:=vm.strip[2].A1
    osd.showAndHide("LVC: "(toggle ? "Deafened" : "Active") . "",(toggle?-1:1))
    return
;Mute Discord/Primary VoiceChat
F16::
    vm.strip[1].B1:=not vm.strip[1].B1
    toggle:=vm.strip[1].B1
    osd.showAndHide("LVC: "(toggle ? "Muted" : "Unmuted") . "",(toggle?1:-1))
    return

;Toggle Discord/Primary VoiceChat being Streamed/recorded by OBS
F19::
    vm.strip[2].B2:=not vm.strip[2].B2
    toggle:=vm.strip[2].B2
    osd.showAndHide("LVC to Stream: "(toggle ? "Muted" : "Unmuted") . "",(toggle?1:-1))
    return
;Toggle Mic being Streamed/recorded by OBS
F20::
    vm.strip[1].B2:=not vm.strip[1].B2
    toggle:=vm.strip[1].B2
    osd.showAndHide("Stream: "(toggle ? "Muted" : "Unmuted") . "",(toggle?1:-1))
    return

Volume_Up::incGain(1)
^Volume_Up::incGain(1,false)
Volume_Down::decGain(1)
^Volume_Down::decGain(1,false)
Volume_Mute::vm.bus[1].mute--

+Volume_Up::incGain(2)
^+Volume_Up::incGain(2,false)
+Volume_Down::decGain(2)
^+Volume_Down::decGain(2,false)
+Volume_Mute::vm.bus[2].mute--


incGain(channel,scaling:=true){
    if(scaling){
        updateGain(channel,.05)
    }else{
        vm.bus[channel].gain++
    }
    osd.showAndHide("Vol Up on Ch. " . channel,1,0.2)
}
decGain(channel,scalar:=1){
    if(scaling){
        updateGain(channel,-.05)
    }else{
        vm.bus[channel].gain--
    }
    osd.showAndHide("Vol Down on Ch. " . channel,1,0.2)
}
updateGain(channel,amount){
    OutputDebug, % "channel=" . channel
    db:=vm.bus[channel].gain ;get current db level
    OutputDebug, % "original db= " . db . "db"
    lvl:=dbToLevel(db) ;calc level from db
    OutputDebug, % "original db to lvl= " . lvl . "p"
    lvl:=lvl+amount ; change level
    OutputDebug, % "altered lvl= " . lvl . "p"
    dbn:=levelToDB(lvl) ;calculate new db value
    OutputDebug, % "new altered lvl to db= " . dbn . "db"
    vm.bus[channel].gain:=dbn ; actually set the new db val!
    return
}

levelToDB(lvl){
    OutputDebug, % "arg lvl= " . lvl . "p"
    OutputDebug, % "arg Log(lvl)= " . Log(lvl) . "dp"
    return 20*Log(Max(lvl,0))
}
dbToLevel(db){
    OutputDebug, % "arg db= " . db . "db"
    return 10**(db/20)
}
