﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if WinExist("TFI Device Control v3.6")
	WinActivate
	WinGetActiveTitle, title
	MouseClick,,176,488
	Sleep, 5000
	



