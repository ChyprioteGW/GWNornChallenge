#Region About
#cs
    ##################################
    #                                #
    #      		Norn Bot         	 #
    #                          	     #
    #           Updated              #
    #          by Bibopp        	 #
    #         March 2019          	 #
    #                                #
    ##################################

    Changelog V2.9 ((March the 3th  2019) by Bibopp :
    - GUI Update :
    - Resized interface window
    INIT
    - Character selector is not an input.
    - Added an Actions Selector
    DIFFICULTY
    - Added difficulty CheckBox (Normal & Hard mode)
    - Added Select CheckBox (Spirits mode or Dervish)
    Changelog V3.0 ((March the 6th  2019) by Bibopp :
    - Update Stuck Elementals
    - updated Sell Function

    Changelog V3.1 ((September the 26th  2019) by Oneshout :
    - Add CustomPickupLoot (call from CommonFunction) / CustomCanpickup function
    - Now, the bot can be launch with any languages
    - Add Disable rendering checkbox on the GUI
#ce
#EndRegion About

#include "CommonFunction.au3"
#include "../SimpleInventory.au3"

Opt("GUICloseOnESC", False)

; === Maps ===
Global $townOlafstead = 645

Global $norn_title_at_begining
Global $DeadOnTheRun = 0, $tpspirit = 0
Global $NumberRun = 0, $DeldrimorMade = 0, $IDKitBought = 0, $RunSuccess = 0
; === Build ===
Global $SkillBarTemplate = "OACjAuiKpRXTOgfTIT+gPOWTQTA"

While 1
    If $BotRunning = True Then
        If $NumberRun = 0 Then ;first run
            AdlibRegister("status", 1000)
            $TimerTotal = TimerInit()
            AdlibRegister("CheckDeath", 1000)
            FileOpen($File)
            $norn_title_at_begining = GetNornTitle()
        EndIf
        If GetMapID() <> $townOlafstead Then
            ZoneMap($townOlafstead, 0)
            WaitForLoad()
        EndIf
        Sleep(200)
        If InventoryIsFull() Then 
            GoMerchant()
            Inventory()
        EndIf
        RndSleep(500)
        $NumberRun = $NumberRun + 1
        GUICtrlSetData($gui_status_runs, $NumberRun)
        CurrentAction("Begin run number " & $NumberRun)
        RndSleep(500)
        CurrentAction("Check Mode")
        RndSleep(500)
        CheckUseSpirits()
        CheckHardMode()
        GoOutside()
        Vanquish()
    EndIf
    Sleep(50)
WEnd

Func GoMerchant()
    CurrentAction("GoMerchant")
    Local $Imerchant
    $Imerchant = GetNearestNPCToCoords(1497, -985)
    MoveTo(1497, -985)
    Move(1497, -985)
    GoToNPC($Imerchant)
    RndSleep(500)
EndFunc   ;==>GoMerchant


Func GoOutside()
;~ 	CurrentAction("Loading skillbar.")
;~    LoadSkillTemplate("OgCjkqrK7SlXQXjXCYWgDYiXsXA")
;~    RndSleep(500)
    CurrentAction("Leaving town")
    MoveTo(-141, 1416)
    Move(-1448, 1171)
    WaitForLoad()
EndFunc   ;==>GoOutside

Func status()
    $time = TimerDiff($TimerTotal)
    $string = StringFormat("min: %03u  sec: %02u ", $time / 1000 / 60, Mod($time / 1000, 60))
    GUICtrlSetData($label_stat, $string)
EndFunc   ;==>status

Func CheckDeath()
    If Death() = 1 Then
        CurrentAction("We Are Dead")
    EndIf
EndFunc   ;==>CheckDeath

Func CheckPartyDead()
    $DeadParty = 0
    For $i = 1 To GetHeroCount()
        If GetIsDead(GetHeroID($i)) = True Then
            $DeadParty += 1
        EndIf
        If $DeadParty >= 6 Then
            $DeadOnTheRun = 1
            CurrentAction("We Wipe, Waiting For Rez")
        EndIf
    Next
EndFunc   ;==>CheckPartyDead

Func TpSpirit()
    $tpspirit = $tpspirit + 1
    If DllStructGetData(GetSkillbar(), 'Recharge7') = 0 And DllStructGetData(GetAgentByID(-2), 'EnergyPercent') >= 0.30 And $tpspirit = 20 And $DeadOnTheRun = 0 Then
        UseSkill(7, 0)
        rndslp(800)
        $tpspirit = 0
    EndIf
EndFunc   ;==>TpSpirit


Func NornPointUpdate()
    $norn_title = GetNornTitle()
    $point_earn = $norn_title - $norn_title_at_begining
    GUICtrlSetData($gui_status_point, $point_earn)
EndFunc   ;==>NornPointUpdate

Func Vanquish()
    CheckUseStone()
    CurrentAction("Taking blessing")
    MoveTo(-2034, -4512)
    GoNearestNPCToCoords(-2034, -4512)
    ;RndSleep(500)
    ;Dialog(132)
    RndSleep(500)
    Dialog(0x00000084)
    AdlibRegister("CheckPartyDead", 500)
    AdlibRegister("NornPointUpdate", 2000)

    RndSleep(2000)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then MoveTo(-5278, -5771)
        If $DeadOnTheRun = 0 Then $enemy = "Berzerker"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-5278, -5771, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-5456, -7921, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-8793, -5837, $enemy)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Vaettir and Berzerker"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-14092, -9662, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-17260, -7906, $enemy)

        If $DeadOnTheRun = 0 Then $enemy = "Jotun "
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-21964, -12877, $enemy, 2500)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(-21964, -12877)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(-25274, -11970)
    RndSleep(1000)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then MoveTo(-22275, -12462)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Berzerker"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-21671, -2163, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-19592, 772, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-13795, -751, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-17012, -5376, $enemy)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(-17012, -5376)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(-12071, -4274)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then $enemy = "Berzerker"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-8351, -2633, $enemy)
        If $DeadOnTheRun = 0 Then MoveTo(-4362, -1610)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Lake"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-4316, 4033, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-8809, 5639, $enemy)
        ;If $DeadOnTheRun = 0 Then AggroMoveToEx(-14916, 2475, $enemy); ========  old CheckArea(-14916, 2475)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-9640, 6893, $enemy)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(-9640, 6893)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(-11282, 5466) ;; === Coldrok Crannor

    $timer = TimerInit()
    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then $enemy = "Elemental"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-16051, 6492, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-16934, 11145, $enemy)
        CurrentAction("If Stuck ExitLoop")
        If TimerDiff($timer) > 180000 Then ExitLoop
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-19378, 14555, $enemy)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(-19378, 14555)

    CurrentAction("So MoveTo")
    If $DeadOnTheRun = 0 Then MoveTo(-19378, 14555)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(-22751, 14163)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-15932, 9386, $enemy)
        If $DeadOnTheRun = 0 Then MoveTo(-13777, 8097)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Lake"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-4729, 15385, $enemy)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(-4729, 15385)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(-2290, 14879)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then $enemy = "Modnir"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-1810, 4679, $enemy)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Boss"
        If $DeadOnTheRun = 0 Then MoveTo(-6911, 5240)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-15471, 6384, $enemy)
        If $DeadOnTheRun = 0 Then moveTo(-411, 5874)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Modniir "
        If $DeadOnTheRun = 0 Then AggroMoveToEx(2859, 3982, $enemy)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Ice Imp"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(4909, -4259, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(7514, -6587, $enemy)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Berserker"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(3800, -6182, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(7755, -11467, $enemy)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Elementals and Griffins"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(15403, -4243, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(21597, -6798, $enemy)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(21597, -6798)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(24522, -6532)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then AggroMoveToEx(22883, -4248, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(18606, -1894, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(14969, -4048, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(13599, -7339, $enemy)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Ice Imp"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(10056, -4967, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(10147, -1630, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(8963, 4043, $enemy)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(8963, 4043)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(8963, 4043)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then $enemy = ""
        If $DeadOnTheRun = 0 Then AggroMoveToEx(15576, 7156, $enemy)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Berserker"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(22838, 7914, $enemy, 2500)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(22838, 7914)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(22961, 12757)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then $enemy = "Modniir and Elemental"
        If $DeadOnTheRun = 0 Then MoveTo(18067, 8766)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(13311, 11917, $enemy)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(13311, 11917)

    CurrentAction("Taking blessing")
    GoNearestNPCToCoords(13714, 14520)

    Do
        $DeadOnTheRun = 0
        If $DeadOnTheRun = 0 Then $enemy = "Modniir and Elemental"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(11126, 10443, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(5575, 4696, $enemy, 2500)
        ;TpSpirit()
        If $DeadOnTheRun = 0 Then $enemy = "Modniir and Elemental 2"
        If $DeadOnTheRun = 0 Then AggroMoveToEx(-503, 9182, $enemy)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(1582, 15275, $enemy, 2500)
        If $DeadOnTheRun = 0 Then AggroMoveToEx(7857, 10409, $enemy, 2500)
        If $DeadOnTheRun = 1 Then RndSlp(15000)
    Until CheckArea(7857, 10409)

    CurrentAction("RunSuccess")
    Sleep(2000)

    $RunSuccess = $RunSuccess + 1

    AdlibUnRegister("CheckPartyDead")

    AdlibUnRegister("NornPointUpdate")
EndFunc   ;==>Vanquish

;~ Description: standard pickup function, only modified to increment a custom counter when taking stuff with a particular ModelID
Func CustomPickUpLoot()
    Local $lAgent
    Local $lItem
    Local $lDeadlock
    For $I = 1 To GetMaxAgents()
        If CountSlots() < 1 Then Return ;full inventory dont try to pick up
        If GetIsDead(-2) Then Return
        $lAgent = GetAgentByID($I)
        If DllStructGetData($lAgent, 'Type') <> 0x400 Then ContinueLoop
        $lItem = GetItemByAgentID($I)
        If CustomCanPickUp($lItem) Then
            PickUpItem($lItem)
            $lDeadlock = TimerInit()
            While GetAgentExists($I)
                Sleep(100)
                If GetIsDead(-2) Then Return
                If TimerDiff($lDeadlock) > 10000 Then ExitLoop
            WEnd
        EndIf
    Next
EndFunc   ;==>CustomPickUpLoot

; Checks if should pick up the given item. Returns True or False
Func CustomCanPickUp($aItem)
    Local $lModelID = DllStructGetData(($aItem), 'ModelID')
    If InArray($lModelID, $MAP_PIECE_ARRAY)			Then Return False
    Return True
    Local $lModelID = DllStructGetData(($aItem), 'ModelID')
    Local $lRarity = GetRarity($aItem)
    If $lModelID == $GOLD_COINS And GetGoldCharacter() < 99000 Then Return True	; gold coins (only pick if character has less than 99k in inventory)
    If $lModelID == $ITEM_LOCKPICK Then Return True   ; Lockpicks
    ;If $lModelID > 21785 And $lModelID < 21806 Then Return True	; Elite/Normal Tomes
    If $lModelID == $ITEM_DYES Then	; if dye
        Switch DllStructGetData($aItem, "ExtraID")
            Case $ITEM_BLACK_DYE, $ITEM_WHITE_DYE ; only pick white and black ones
                Return True
            Case Else
                Return False
        EndSwitch
    EndIf
    If $lRarity == $RARITY_GOLD 			Then Return True   ; gold items
    If $lRarity == $RARITY_PURPLE 			Then Return False
    If $lRarity == $RARITY_BLUE 			Then Return False
    If $lRarity == $RARITY_WHITE 			Then Return False
    ; If you want to pick up more stuff add it here
    Return False
EndFunc   ;==>CustomCanPickUp

Func UseLegion() ; Helps a lot with Hard mode
    Local $aBag
    Local $aItem
    Sleep(200)
    For $i = 1 To 4
    $aBag = GetBag($i)
    For $j = 1 To DllStructGetData($aBag, "Slots")
        $aItem = GetItemBySlot($aBag, $j)
        If DllStructGetData($aItem, "ModelID") == 37810 Then ; Legion
            UseItem($aItem)
            Return True
        EndIf
    Next
    Next
EndFunc

Func _exit()
    If $Rendering Then
    EnableRendering()
    WinSetState(GetWindowHandle(), "", @SW_SHOW)
    Sleep(500)
    EndIf
    Exit
EndFunc
