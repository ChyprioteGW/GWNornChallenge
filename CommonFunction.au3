#include-once
#include "../GWA2.au3"
#include "AddsOn.au3"

#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <FileConstants.au3>
#include <Date.au3>
#include <GuiEdit.au3>


Global $strName = ""
Global $NumberRun = 0, $DeldrimorMade = 0, $IDKitBought = 0, $RunSuccess = 0
Global $BotRunning = False
Global $BotInitialized = False

Global $Faithful_Intervention = 1509 ;

;~  ==== ========================================>   Spirits   <====================================
Global $coords[2] ;  ==>  FightEx
Global $UsedSpirits ;  ==>  AggroMoveToEx

Global $skillCost[9] ; Store skills energy cost ==>  useSkillEx , FightEx  For Dervish
$skillCost[1] = 5
$skillCost[2] = 5
$skillCost[3] = 10
$skillCost[4] = 5
$skillCost[5] = 1
$skillCost[6] = 1
$skillCost[7] = 1
$skillCost[8] = 10
;~  ==== ==========================================>   End  <=======================================

Global $File = @ScriptDir & "\Trace\Traça du " & @MDAY & "-" & @MON & " a " & @HOUR & "h et " & @MIN & "minutes.txt"
Opt("GUIOnEventMode", 1)

; ================== CONFIGURATION ==================
; True or false to load the list of logged in characters or not
Global Const $doLoadLoggedChars = True
; ================ END CONFIGURATION ================

Global $charName = ""
Global $processId = ""
Global $cmdmode = False

If $CmdLine[0] = 0 Then
Else
    $cmdmode = True
    If 1 > UBound($CmdLine) - 1 Then Exit ; element is out of the array bounds
    If 2 > UBound($CmdLine) - 1 Then Exit ;
    $charName = $CmdLine[1]
    $processId = $CmdLine[2]
    LOGIN($charName, $processId)
EndIf

#Region ### START Koda GUI section ### Form=C:\Bot GW\Feather Farm\Storage version \Form1.kxf
Global $win = GUICreate("Status ", 274, 340 + 20, 150, 200)
;~ GUICtrlCreateLabel("NORN", 180, 260 - 70 - 20, 60)
GUICtrlSetFont(-1, 8)
Global Const $Button = GUICtrlCreateButton("Start", 8, 200, 260, 31) ; 8, 172, 219, 31
GUICtrlSetOnEvent($Button, "GuiButtonHandler")
GUICtrlCreateGroup("Status: Runs", 275 - 270, 25, 265, 88 - 35)
GUICtrlCreateLabel("Total Runs:", 285 - 265, 40, 70, 17)
Global $gui_status_runs = GUICtrlCreateLabel("0", 345 - 265, 40, 40, 17, $SS_RIGHT) ; ==  $SS_RIGHT declaré ou?
GUICtrlCreateLabel("Kits Bought:", 410 - 265, 40, 70, 17)
Global $gui_status_kit = GUICtrlCreateLabel("0", 460 - 265, 40, 40, 17, $SS_RIGHT)
GUICtrlCreateLabel("Successful:", 285 - 265, 55, 70, 17)
GUICtrlSetColor(-1, 0x008000)
Global $gui_status_successful = GUICtrlCreateLabel("0", 345 - 265, 55, 40, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x008000)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Status: Title", 275 - 265, 255 - 132 - 35, 150, 185 - 80 - 40)
GUICtrlCreateLabel("Title:", 285 - 265, 275 - 132 - 35, 27, 17)
GUICtrlCreateLabel("Made:", 380 - 265, 275 - 132 - 35, 40, 17)
Global $cbxStone = GUICtrlCreateCheckbox("Use Legion-Stone?", 180,170,80,15)
GUICtrlCreateLabel("NORN", 285 - 265, 310 - 132 - 35 - 15, 70, 17)
GUICtrlSetColor(-1, 0x808000)
Global $gui_status_point = GUICtrlCreateLabel("0", 360 - 265, 310 - 132 - 35 - 15, 40, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x808000)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Status: Time", 10, 300 - 90 - 75 + 20, 255, 43)
GUICtrlCreateLabel("Total:", 20, 320 - 90 - 75 + 20, 50, 17)
Global $label_stat = GUICtrlCreateLabel("min: 000  sec: 00", 70, 320 - 90 - 75 + 20)
Global $UseSpirits = GUICtrlCreateCheckbox("Use Spirits", 180, 85, 80, 15)
Global $HardMode = GUICtrlCreateCheckbox("HardMode", 180, 110, 80, 15)
Global $Rendering = GUICtrlCreateCheckbox("Rendering", 180, 135, 80, 15)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlSetOnEvent(-1, "ToggleRendering")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $GLOGBOX = GUICtrlCreateEdit("", 12, 235, 255, 120, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL))
GUICtrlSetColor($GLOGBOX, 65280)
GUICtrlSetBkColor($GLOGBOX, 0)
GUISetOnEvent($GUI_EVENT_CLOSE, "GuiButtonHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
Global $Input

If $doLoadLoggedChars Then
    $Input = GUICtrlCreateCombo($charName, 8, 1, 260, 25)
    GUICtrlSetData(-1, GetLoggedCharNames())
Else
    $Input = GUICtrlCreateInput("character name", 8, 8, 217, 25)
EndIf

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


Func GuiButtonHandler()
    Switch @GUI_CtrlId
        Case $Button
            If $BotRunning Then
                GUICtrlSetData($Button, "Will pause after this run")
                GUICtrlSetState($Button, $GUI_DISABLE)
                $BotRunning = False
            ElseIf $BotInitialized Then
                GUICtrlSetData($Button, "Pause")
                $BotRunning = True
            Else
                CurrentAction("Initializing")
                Local $charName = GUICtrlRead($Input)
                If $charName == "" Then
                    If Initialize(ProcessExists("gw.exe"), True, True, False) = False Then
                        ; MsgBox(0, "Error", "Guild Wars is not running.")
                        Exit
                    EndIf
                ElseIf $processId And $cmdmode Then
                    $proc_id_int = Number($processId, 2)
                    CurrentAction("Initializing in cmd mode via pid " & $proc_id_int)
                    If Initialize($proc_id_int, True, True, False) = False Then
                        ; MsgBox(0, "Error", "Could not find a processId or somewhat '"&$proc_id_int&"'  "&VarGetType($proc_id_int)&"'")
                        If ProcessExists($proc_id_int) Then
                            ProcessClose($proc_id_int)
                        EndIf
                        Exit
                    EndIf
                    SetPlayerStatus(0)
                Else
                    If Initialize($charName, True, True, False) = False Then
                        MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $charName & "'")
                        Exit
                    EndIf
                EndIf
;~ 				EnsureEnglish(True)
                GUICtrlSetState($Rendering, $GUI_ENABLE)
                GUICtrlSetState($Input, $GUI_DISABLE)
                GUICtrlSetData($Button, "Pause")
                WinSetTitle($win, "", GetCharname() & " - Vanguard")
                $BotRunning = True
                $BotInitialized = True
            EndIf
        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch

EndFunc   ;==>GuiButtonHandler

Func UpdateLock()
    Local $cn = GetCharname()
    If $cn Then
        Local $sFileName = @ScriptDir & "\lock\" & $cn & ".lock"
        Local $hFilehandle = FileOpen($sFileName, $FO_OVERWRITE)
        FileWrite($hFilehandle, @HOUR & ":" & @MIN)
        FileClose($hFilehandle)
    EndIf
EndFunc   ;==>UpdateLock

Func CheckHardMode()
    If (GUICtrlRead($HardMode) == $GUI_CHECKED) Then
        SwitchMode(1)
        GUICtrlSetState($HardMode, $GUI_DISABLE)
    Else
        SwitchMode(0)
        GUICtrlSetState($HardMode, $GUI_DISABLE)
    EndIf
    RndSleep(250)
EndFunc   ;==>CheckHardMode

Func CheckUseSpirits()
    If (GUICtrlRead($UseSpirits) == $GUI_CHECKED) Then
        $UsedSpirits = True
        GUICtrlSetState($UseSpirits, $GUI_DISABLE)
    Else
        $UsedSpirits = False
        GUICtrlSetState($UseSpirits, $GUI_DISABLE)
    EndIf
    RndSleep(250)
EndFunc   ;==>CheckUseSpirits

Func CheckUseStone()
    If (GUICtrlRead($cbxstone) == $GUI_CHECKED) Then
        CurrentAction("Using legion-stone")
        UseLegion()
        GUICtrlSetState($cbxstone, $GUI_DISABLE)
    Else
        $cbxstone = False
        CurrentAction("No legion-stone Selected")
        GUICtrlSetState($cbxstone, $GUI_DISABLE)
    EndIf
    RndSleep(250)
EndFunc   ;==>CheckUseStone


;~ Description: Print to console with timestamp
Func CurrentAction($TEXT)
    GUICtrlSetData($GLOGBOX, GUICtrlRead($GLOGBOX) & @HOUR & ":" & @MIN & " - " & $TEXT & @CRLF)
    _GUICtrlEdit_Scroll($GLOGBOX, $SB_SCROLLCARET)
    _GUICtrlEdit_Scroll($GLOGBOX, $SB_LINEUP)
    UpdateLock()
EndFunc   ;==>CurrentAction


Func WaitForLoad()
    CurrentAction("Loading zone")
    InitMapLoad()
    $deadlock = 0
    Do
        Sleep(100)
        $deadlock += 100
        $load = GetMapLoading()
        $lMe = GetAgentByID(-2)

    Until $load = 2 And DllStructGetData($lMe, 'X') = 0 And DllStructGetData($lMe, 'Y') = 0 Or $deadlock > 10000

    $deadlock = 0
    Do
        Sleep(100)
        $deadlock += 100
        $load = GetMapLoading()
        $lMe = GetAgentByID(-2)

    Until $load <> 2 And DllStructGetData($lMe, 'X') <> 0 And DllStructGetData($lMe, 'Y') <> 0 Or $deadlock > 30000
    CurrentAction("Load complete")
    rndslp(3000)
EndFunc   ;==>WaitForLoad


Func AggroMoveToEx($x, $y, $s = "", $z = 1450)
    Local $TimerToKill = TimerInit()
    CurrentAction("Hunting " & $s)
    $random = 50
    $iBlocked = 0

    If $DeadOnTheRun = 0 Then Move($x, $y, $random)

    $lMe = GetAgentByID(-2)
    $coordsX = DllStructGetData($lMe, "X")
    $coordsY = DllStructGetData($lMe, "Y")

    If $DeadOnTheRun = 0 Then
        Do
            If $DeadOnTheRun = 1 Then ExitLoop
            ;If $DeadOnTheRun = 0 Then RndSlp(250) //////
            $oldCoordsX = $coordsX
            $oldCoordsY = $coordsY
            $nearestenemy = GetNearestEnemyToAgent(-2)
            $lDistance = GetDistance($nearestenemy, -2)
            If $DeadOnTheRun = 1 Then ExitLoop
            If $lDistance < $z And DllStructGetData($nearestenemy, 'ID') <> 0 And $DeadOnTheRun = 0 Then
                ;If $lDistance < $z AND DllStructGetData($nearestenemy, 'ID') <> 0 Then
                If $UsedSpirits = True Then ; 	============= 	Use Fight or FightEx based on GUI checkbox
                    Fight($z, $s = "enemies")
                Else
                    $UsedSpirits = False
                    FightEx($z, $s = "enemies")
                EndIf
            EndIf
            ;If $DeadOnTheRun = 0 Then RndSlp(250) /////
            $lMe = GetAgentByID(-2)
            $coordsX = DllStructGetData($lMe, "X")
            $coordsY = DllStructGetData($lMe, "Y")
            If $oldCoordsX = $coordsX And $oldCoordsY = $coordsY Then
                $iBlocked += 1
                If $DeadOnTheRun = 0 Then Move($coordsX, $coordsY, 500)
                If $DeadOnTheRun = 0 Then RndSlp(350)
                If $DeadOnTheRun = 0 Then Move($x, $y, $random)
            EndIf
        Until ComputeDistanceEx($coordsX, $coordsY, $x, $y) < 250 Or $iBlocked > 20 Or $DeadOnTheRun = 1
    EndIf
    $TimerToKillDiff = TimerDiff($TimerToKill)
    $TEXT = StringFormat("min: %03u  sec: %02u ", $TimerToKillDiff / 1000 / 60, Mod($TimerToKillDiff / 1000, 60))
    FileWriteLine($File, $s & " en ================================== >   " & $TEXT & @CRLF)
EndFunc   ;==>AggroMoveToEx

Func Fight($z, $s = "enemies")
    Local $lastId = 99999, $coordinate[2], $timer
    If $DeadOnTheRun = 0 Then
        Local $TimerToGetOut = TimerInit()
        Do
            $Me = GetAgentByID(-2)
            $energy = GetEnergy()
            $skillbar = GetSkillbar()
            CurrentAction("Start Targeting")
            If $DeadOnTheRun = 0 Then $useSkill = -1
            If $DeadOnTheRun = 0 Then $target = GetNearestEnemyToAgent(-2)
            ;$target = GetNearestEnemyToAgent(GetHeroID(7))
            If Not $target <> 0 Then
                TargetNearestEnemy()
            EndIf
            $distance = GetDistance($target, -2)
            If DllStructGetData($target, 'ID') <> 0 And $distance < $z And $DeadOnTheRun = 0 Then
                If $DeadOnTheRun = 0 Then ChangeTarget($target)
                If $DeadOnTheRun = 0 Then RndSlp(150)
                If $DeadOnTheRun = 0 Then CallTarget($target)
                If $DeadOnTheRun = 0 Then RndSlp(150)
                If $DeadOnTheRun = 0 Then Attack($target)
                If $DeadOnTheRun = 0 Then RndSlp(150)
            ElseIf DllStructGetData($target, 'ID') = 0 Or $distance > $z Or $DeadOnTheRun = 1 Then
                $lastId = DllStructGetData($target, 'Id')
                $coordinate[0] = DllStructGetData($target, 'X')
                $coordinate[1] = DllStructGetData($target, 'Y')
                $timer = TimerInit()
                CurrentAction("Move To Target")
                Do
                    Move($coordinate[0], $coordinate[1])
                    rndsleep(500)
                    $Me = GetAgentByID(-2)
                    $distance = ComputeDistance($coordinate[0], $coordinate[1], DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'))
                Until $distance < 1800 Or TimerDiff($timer) > 10000
            EndIf
            RndSleep(150)
;~ 			If DllStructGetData($target, 'ID') = 0 Or $distance > $z Or $DeadOnTheRun = 1 Then ExitLoop
            CurrentAction("Kill Target")
            UseSkillEx(7, -1)
            If $DeadOnTheRun = 0 Then
                For $i = 0 To $totalskills

                    $targetHP = DllStructGetData(GetCurrentTarget(), 'HP')
                    If $targetHP = 0 Then ExitLoop

                    $distance = GetDistance($target, -2)
                    If $distance > $z Then ExitLoop

                    $TargetAllegiance = DllStructGetData(GetCurrentTarget(), 'Allegiance')
                    If $TargetAllegiance = 0x1 Or $TargetAllegiance = 0x4 Or $TargetAllegiance = 0x5 Or $TargetAllegiance = 0x6 Then ExitLoop

                    $TargetIsDead = DllStructGetData(GetCurrentTarget(), 'Effects')
                    If $TargetIsDead = 0x0010 Then ExitLoop

                    $TargetItem = DllStructGetData(GetCurrentTarget(), 'Type')
                    If $TargetItem = 0x400 Then ExitLoop

                    $energy = GetEnergy(-2)
                    $recharge = DllStructGetData(GetSkillBar(), "Recharge" & $i + 1)
                    $adrenaline = DllStructGetData(GetSkillBar(), "Adrenaline" & $i + 1)

                    $nearestenemy = GetNearestEnemyToAgent(-2)
                    $lDistance = GetDistance($nearestenemy, -2)

                    If $recharge = 0 And $energy >= $intSkillEnergy[$i] And $adrenaline >= ($intSkillAdrenaline[$i] * 25 - 25) And $lDistance < 1020 Then
                        $useSkill = $i + 1
                        ;PingSleep(250)
                        $variabletosort = 0
                        UseSkill($useSkill, $target)
                        RndSlp($intSkillCastTime[$i] + 500)
                    EndIf
                    If $i = $totalskills Then $i = -1 ; change -1
                    If $DeadOnTheRun = 1 Then ExitLoop
                Next
            EndIf
            $TargetAllegiance = DllStructGetData(GetCurrentTarget(), 'Allegiance')
            $TargetIsDead = DllStructGetData(GetCurrentTarget(), 'Effects')
            $targetHP = DllStructGetData(GetCurrentTarget(), 'HP')
            $TargetItem = DllStructGetData(GetCurrentTarget(), 'Type')
        Until DllStructGetData($target, 'ID') = 0 Or $distance > $z Or $DeadOnTheRun = 1 Or $TargetAllegiance = 0x1 Or $TargetAllegiance = 0x4 Or $TargetAllegiance = 0x5 Or $TargetAllegiance = 0x6 Or $TargetIsDead = 0x0010 Or $targetHP = 0 Or $TargetItem = 0x400 Or TimerDiff($TimerToGetOut) > 240000
        CustomPickUpLoot()
;~ 		PickupItems(-1, 1012)
    EndIf
EndFunc   ;==>Fight


Func FightEx($z, $s = "enemies")
    Local $lastId = 99999, $coordinate[2], $timer
    CurrentAction("Fighting Ex!")

    If $DeadOnTheRun = 0 Then AdlibRegister("keep_A_Live", 2000) ; "keep_A_Live", 200
    If $DeadOnTheRun = 0 Then AdlibRegister("keep_Buff", 5000) ; "keep_Buff", 200
    If $DeadOnTheRun = 0 Then
        Do
            $Me = GetAgentByID(-2)
            $energy = GetEnergy()
            $skillbar = GetSkillbar()
            If $DeadOnTheRun = 0 Then $target = GetNearestEnemyToAgent(-2)
            If Not $target <> 0 Then
                TargetNearestEnemy()
            EndIf
            $distance = GetDistance($target, -2)
            If DllStructGetData($target, 'ID') <> 0 And $distance < $z And $DeadOnTheRun = 0 Then
                If $DeadOnTheRun = 0 Then ChangeTarget($target)
                If $DeadOnTheRun = 0 Then RndSlp(150)
                If $DeadOnTheRun = 0 Then CallTarget($target)
                If $DeadOnTheRun = 0 Then RndSlp(150)
                If $DeadOnTheRun = 0 Then Attack($target)
                If $DeadOnTheRun = 0 Then RndSlp(150)
            ElseIf DllStructGetData($target, 'ID') = 0 Or $distance > $z Or $DeadOnTheRun = 1 Then
                $lastId = DllStructGetData($target, 'Id')
                $coordinate[0] = DllStructGetData($target, 'X')
                $coordinate[1] = DllStructGetData($target, 'Y')
                $timer = TimerInit()
                Do
                    Move($coordinate[0], $coordinate[1])
                    rndsleep(500)
                    $Me = GetAgentByID(-2)
                    $distance = ComputeDistance($coordinate[0], $coordinate[1], DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'))
                Until $distance < 1100 Or TimerDiff($timer) > 10000
            EndIf
            RndSleep(150)
            $timer = TimerInit()
            Do
                $target = GetCurrentTarget()
                If $DeadOnTheRun = 0 And $target <> 0 Then ;  $target <> 0 And
                    Attack($target)
                    UseSkillEx(2, -1)
                    UseSkillEx(3, -1)
                    UseSkillEx(4, -1)
                    UseSkillEx(5, -1)
                    UseSkillEx(6, -1)
                    RndSlp(200)
                EndIf
                $targetHP = DllStructGetData(GetCurrentTarget(), 'HP')
                If $targetHP = 0 Then ExitLoop
                $target = GetAgentByID(DllStructGetData($target, 'Id'))
                $coordinate[0] = DllStructGetData($target, 'X')
                $coordinate[1] = DllStructGetData($target, 'Y')
                $Me = GetAgentByID(-2)
                $distance = ComputeDistance($coordinate[0], $coordinate[1], DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'))
            Until DllStructGetData($target, 'HP') < 0.005 Or $distance > $z Or TimerDiff($timer) > 5000
            $target = GetNearestEnemyToAgent(-2)
            $coordinate[0] = DllStructGetData($target, 'X')
            $coordinate[1] = DllStructGetData($target, 'Y')
            $distance = ComputeDistance(DllStructGetData($target, 'X'), DllStructGetData($target, 'Y'), DllStructGetData(GetAgentByID(-2), 'X'), DllStructGetData(GetAgentByID(-2), 'Y'))
        Until DllStructGetData($target, 'Id') = 0 Or $distance > $z ;; ==
    EndIf
    AdlibUnRegister("keep_A_Live")
    AdlibUnRegister("keep_Buff")
    Sleep(200)
    If getIsDead() Then CurrentAction("Died")
    If CountSlots() = 0 Then
        CurrentAction("Inventory full")
    Else
        CurrentAction("Picking up items")
        CustomPickUpLoot()
;~ 		PickupItems(-1, $z)
    EndIf
EndFunc   ;==>FightEx



Func keep_Buff() ; =========================
    Local $lMe = GetAgentByID(-2)
    Local $lEnergy = GetEnergy($lMe)
    If DllStructGetData(GetEffect($Faithful_Intervention), "SkillID") == 0 Then
        If GetEnergy($lMe) > 5 Then ; == Enchant
            $Target_me = GetAgentByID(-2)
            UseSkill(1, -2)
            Sleep(2000)
            $skillUsed = True
        EndIf
    EndIf

;~ 	If GetIsEnchanted($lMe) <= 1 Then
;~ 		If GetEnergy($lMe) > 10 Then ; == Enchant
;~ 			$Target_me = GetAgentByID(-2)
;~ 			;UseSkillEx(2, -2)
;~ 			Sleep(100)
;~ 			$skillUsed = True
;~ 		EndIf
;~ 	EndIf

EndFunc   ;==>keep_Buff


Func keep_A_Live()
    Local $lMe = GetAgentByID(-2)
    Local $lEnergy = GetEnergy($lMe)
    If DllStructGetData($lMe, "HP") < 0.8 And GetEnergy($lMe) > 10 Then ; == Enchant Heal
        $Target_me = GetAgentByID(-2)
        UseSkill(8, -2)
        Sleep(250)
        $skillUsed = True
    EndIf
EndFunc   ;==>keep_A_Live


; Uses a skill
; It will not use if I am dead, if the skill is not recharged, or if I don't have enough energy for it
; It will sleep until the skill is cast, then it will wait for aftercast.
Func UseSkillEx($lSkill, $lTgt = -2, $aTimeout = 1500)
    If GetIsDead() Then Return ;
    If GetIsDead(-1) Then Return ; Target
    If GetIsDead(-2) Then Return ; me
    If Not IsRecharged($lSkill) Then Return
    If GetEnergy(-2) < $skillCost[$lSkill] Then Return ; $skillCost [$lSkill]
    Local $lDeadlock = TimerInit()
    UseSkill($lSkill, $lTgt)
    Do
        Sleep(50)
        If GetIsDead(-2) = 1 Then Return
    Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)

    If $lSkill > 1 Then RndSleep(50)
EndFunc   ;==>UseSkillEx


Func CheckArea($aX, $aY)
    $ret = False
    $pX = DllStructGetData(GetAgentByID(-2), "X")
    $pY = DllStructGetData(GetAgentByID(-2), "Y")

    If ($pX < $aX + 500) And ($pX > $aX - 500) And ($pY < $aY + 500) And ($pY > $aY - 500) Then
        $ret = True
    EndIf
    Return $ret
EndFunc   ;==>CheckArea


#cs
    $random = 10

    Move($x, $y, $random)
    $Me = GetAgentByID()
    $coords[0] = DllStructGetData($Me, 'X')
    $coords[1] = DllStructGetData($Me, 'Y')
#ce
