#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
var1 := "test"
if (%0% > 0){
	var1 := A_Args[1]
}

if WinExist("TFI Device Control v3.6")
	WinActivate ;
	WinGetActiveTitle, title
	MouseClick,,300,433,30
    Sleep, 500
	Send %var1%
    Sleep 100
    Send %A_Tab%
    Send %A_Tab%
    Sleep 750
    Send, {Enter}
	Sleep, 750    
    MouseClick,,197,524,30



