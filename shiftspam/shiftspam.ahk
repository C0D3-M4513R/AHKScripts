#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#MaxThreadsPerHotkey 2

$F13::
    Toggle := !Toggle
    while Toggle
    {
	Send {Shift Down}
	Sleep 5
	Send {Shift Up}	
	;MouseClick Left
	Sleep 15
    }
return
