#Region About
#cs
	##################################
	#                                #
	#      	   Asura Bot         	 #
	#                          	     #
	#           Updated              #
	#          by Bibopp        	 #
	#         March 2019          	 #
	#                                #
	##################################

#ce
#EndRegion About


#include <GWA2.au3>
#NoTrayIcon

#Region Constants

Global $Array_Store_ModelIDs[77] = [910, 2513, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 36682 _ ; Alcohol
		, 21492, 21812, 22269, 22644, 22752, 28436, 36681 _ ; FruitCake, Blue Drink, Cupcake, Bunnies, Eggs, Pie, Delicious Cake
		, 6376, 21809, 21810, 21813, 36683 _ ; Party Spam
		, 6370, 21488, 21489, 22191, 26784, 28433 _ ; DP Removals
		, 15837, 21490, 30648, 31020 _ ; Tonics
		, 556, 18345, 21491, 37765, 21833, 28433, 28434, 522 _ ; CC Shards, Victory Token, Wayfarer, Lunar Tokens, ToTs, Dark Remains
		, 921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533] ; All Materials

Global Const $RARITY_GOLD = 2624
Global Const $RARITY_PURPLE = 2626
Global Const $RARITY_BLUE = 2623
Global Const $RARITY_WHITE = 2621
Global Const $ITEM_ID_Dyes = 146
Global Const $ITEM_ExtraID_BlackDye = 10
Global Const $ITEM_ExtraID_WhiteDye = 12
Global Const $ITEM_ID_GLACIAL_STONES = 27047
Global Const $ITEM_ID_TOTS = 28434
Global Const $ITEM_ID_GOLDEN_EGGS = 22752
Global Const $ITEM_ID_BUNNIES = 22644
Global Const $ITEM_ID_GROG = 30855
Global Const $ITEM_ID_CLOVER = 22191
Global Const $ITEM_ID_PIE = 28436
Global Const $ITEM_ID_CIDER = 28435
Global Const $ITEM_ID_POPPERS = 21810
Global Const $ITEM_ID_ROCKETS = 21809
Global Const $ITEM_ID_CUPCAKES = 22269
Global Const $ITEM_ID_SPARKLER = 21813
Global Const $ITEM_ID_HONEYCOMB = 26784
Global Const $ITEM_ID_VICTORY_TOKEN = 18345
Global Const $ITEM_ID_LUNAR_TOKEN = 21833
Global Const $ITEM_ID_HUNTERS_ALE = 910
Global Const $ITEM_ID_LUNAR_TOKENS = 28433
Global Const $ITEM_ID_KRYTAN_BRANDY = 35124
Global Const $ITEM_ID_BLUE_DRINK = 21812
Global Const $ITEM_ID_GHOST_IN_A_BOX = 6368
Global Const $ITEM_ID_SHAMROCK_ALE = 22190
Global Const $ITEM_ID_WAYFARERS_MARK = 37765
;~ General Items
Global $General_Items_Array[6] = [2989, 2991, 2992, 5899, 5900, 22751]
Global Const $ITEM_ID_Lockpicks = 22751

#EndRegion Constants


#Region Functions

Func CheckIfInventoryIsFull()
	If (CountSlots() < 2) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CheckIfInventoryIsFull


Func CountSlots()
	Local $bag
	Local $temp = 0
	$bag = GetBag(1)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(2)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(3)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	Return $temp
EndFunc   ;==>CountSlots

 ; =====================  test vente

Func Inventory()
	Identify()
	Sell()
EndFunc

Func Identify()
	Local $aitem, $lBag
	For $i = 1 To 4
		$lBag = GetBag($i)
		For $j = 1 To DllStructGetData($lBag, 'Slots')
			CurrentAction("IDing item: " & $i & ", " & $j)
			$aitem = GetItemBySlot($lBag, $j)
			If FindIDKit2() = 0 Then
				Local $K = 0
				Do
					BuyItem(6, 1, 500)
					Sleep(GetPing()+250)
					$K = $K + 1
				Until FindIDKit2() <> 0 Or $K = 3
				If $K = 3 Then ExitLoop
				Sleep(GetPing()+250)
			EndIf
			If DllStructGetData($AITEM, "ID") = 0 Then ContinueLoop
			If CanIdentify($aitem) Then
				IdentifyItem($AITEM)
				Sleep(GetPing()+250)
			EndIf
		Next
	Next
EndFunc

;~ Description: Returns item ID of ID kit in inventory.
Func FindIDKit2()
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	For $i = 1 To 3
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case 2989
					If DllStructGetData($lItem, 'Value') / 2 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2
					EndIf
				Case 5899
					If DllStructGetData($lItem, 'Value') / 2.5 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2.5
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKit
EndFunc   ;==>FindIDKit

Func CanIdentify($aItem)
	Local $m = DllStructGetData($aitem, "ModelID")
	Local $r = GetRarity($aitem)
	Switch $r
		Case $Rarity_Gold, $Rarity_Purple, $Rarity_Blue ; Remove the gold one if you intend to store them unid and sell later
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>CanSell

Func Sell()
	Local $aitem, $lBag
	For $i = 1 To 3
		$lBag = Getbag($i)
		For $j = 1 To DllStructGetData($lBag, 'Slots')
			CurrentAction("Selling item: " & $i & ", " & $j)
			$aitem = GetItemBySlot($lBag, $j)
			If DllStructGetData($aitem, "ID") = 0 Then ContinueLoop
			If CanSell($aitem) Then
				SellItem($aitem)
				Sleep(GetPing()+250)
			EndIf
		Next
	Next
EndFunc

Func CanSell($aItem)
	Local $LMODELID = DllStructGetData($aitem, "ModelId")
	Local $LRARITY = GetRarity($aitem)
	Local $Requirement = GetItemReq($aItem)
	Local $Outcast1 = 956
	Local $Outcast2 = 958
	If $LRARITY == $RARITY_Gold Then
		Switch DllStructGetData($aitem, "ModelId")
			Case $Outcast1, $Outcast2
				Return False
			Case Else
				Return True
		EndSwitch
	EndIf
	If $LRARITY == $RARITY_Purple Then
		Return True
	EndIf
;~ Leaving Blues and Whites as false for now. Going to make it salvage them at some point in the future. It does not currently pick up whites or blues
	If $LRARITY == $RARITY_Blue Then
		Return True
	EndIf
	If $LMODELID == $ITEM_ID_Dyes Then
		Switch DllStructGetData($aitem, "ExtraId")
			Case $ITEM_ExtraID_BlackDye, $ITEM_ExtraID_WhiteDye
				Return False
			Case Else
				Return True
		EndSwitch
	EndIf

	; ==== General ====
	If CheckArrayGeneralItems($lModelID)			Then Return False ; Lockpicks, Kits


	If $lModelID == 556 							Then Return False
	If $LRARITY == $RARITY_White 					Then Return True
	Return True
EndFunc   ;==>CanSell
Func CheckArrayGeneralItems($lModelID)
	For $p = 0 To (UBound($General_Items_Array) -1)
		If ($lModelID == $General_Items_Array[$p]) Then Return True
	Next
EndFunc


Func CheckArrayAllDrops($m)
	For $p = 0 To (UBound($Array_Store_ModelIDs) -1)
		If ($m == $Array_Store_ModelIDs[$p]) Then Return True
	Next
	Return
EndFunc


Func GetExtraItemInfo($aitem)
	If IsDllStruct($aitem) = 0 Then $aAgent = GetItemByItemID($aitem)
	$lItemExtraPtr = DllStructGetData($aitem, "namestring")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
EndFunc   ;==>GetExtraItemInfo


Func StoreGolds()
	GoldIs(1, 20)
	GoldIs(2, 5)
	GoldIs(3, 10)
	GoldIs(4, 10)
EndFunc   ;==>StoreGolds

Func GoldIs($bagIndex, $numOfSlots)
	For $i = 1 To $numOfSlots
		ConsoleWrite("Checking items: " & $bagIndex & ", " & $i & @CRLF)
		$aitem = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($aitem, 'ID') <> 0 And GetRarity($aitem) = $RARITY_Gold Then
			Do
				For $bag = 8 To 12 ; Storage panels are form 8 till 16 (I have only standard amount plus aniversary one)
					$slot = FindEmptySlot($bag)
					$slot = @extended
					If $slot <> 0 Then
						$FULL = False
						$nSlot = $slot
						ExitLoop 2 ; finding first empty $slot in $bag and jump out
					Else
						$FULL = True ; no empty slots :(
					EndIf
					Sleep(400)
				Next
			Until $FULL = True
			If $FULL = False Then
				MoveItem($aitem, $bag, $nSlot)
				ConsoleWrite("Gold item moved ...." & @CRLF)
				Sleep(Random(450, 550))
			EndIf
		EndIf
	Next
EndFunc   ;==>GoldIs


#EndRegion Functions
