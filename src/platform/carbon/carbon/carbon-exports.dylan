module: dylan-user

/*
	carbon
*/

define library carbon
	use Dylan;
	use melange-support;
	export carbon;
end library carbon;

define module carbon
  use Dylan;
  use melange-support;
  use system;
  
  export 
// appearance        
        // Types and classes
        <ThemeBrush>, <ThemeBackgroundKind>, <ThemeDrawingState>,	
        // Methods
        RegisterAppearanceClient, UnregisterAppearanceClient,
        GetThemeDrawingState, SetThemeDrawingState,
        
// carbon-events
            // UPPs
            <EventHandlerUPP>, <EventComparatorUPP>, <EventLoopTimerUPP>,
            // Various Classes
            <EventLoopRef>, <EventRef>, <EventQueueRef>, <EventTargetRef>, 
            <EventLoopTimerRef>, <EventHandlerRef>, <EventHandlerCallRef>,
            // Errors
            $eventNotHandledErr,
            // Type codes
            // Mouse Buttons
            $kEventMouseButtonPrimary, $kEventMouseButtonSecondary, $kEventMouseButtonTertiary,
            // Mouse Wheel Axis
            $kEventMouseWheelAxisX, $kEventMouseWheelAxisY,
            // Event Priority
//            <EventPriority>,
            $kEventPriorityLow, $kEventPriorityStandard, $kEventPriorityHigh,
            // Application Activation
            $kEventAppActivated, $kEventAppDeactivated, $kEventAppQuit, 
            $kEventAppLaunchNotification,
            // kEventClassMouse
            $kEventClassMouse, $kEventClassKeyboard, $kEventClassTextInput, 
            $kEventClassApplication, $kEventClassEPPC, $kEventClassMenu, $kEventClassWindow, 
            $kEventClassControl, $kEventClassCommand, $kEventClassTablet,
            // kEventMenuBeginTracking
            $kEventMenuBeginTracking, $kEventMenuEndTracking, $kEventMenuChangeTrackingMode, 
            $kEventMenuOpening, $kEventMenuClosed, $kEventMenuTargetItem, $kEventMenuMatchKey,
            $kEventMenuEnableItems,
            // kEventMouseDown
            $kEventMouseDown, $kEventMouseUp, $kEventMouseMoved, $kEventMouseDragged, 
            $kEventMouseWheelMoved,
            // kEventProcessCommand
            $kEventProcessCommand, $kEventCommandProcess, $kEventCommandUpdateStatus,
            // kEventRawKeyDown
            $kEventRawKeyDown, $kEventRawKeyRepeat, $kEventRawKeyUp, $kEventRawKeyModifiersChanged,
            // kEventUpdateActiveInputArea
            $kEventUpdateActiveInputArea, $kEventUnicodeForKeyEvent, $kEventOffsetToPos, 
            $kEventPosToOffset, $kEventShowHideBottomWindow, $kEventGetSelectedText,
            // Windows
           	$kEventWindowUpdate, $kEventWindowDrawContent, $kEventWindowActivated, $kEventWindowDeactivated,
						$kEventWindowGetClickActivation, $kEventWindowShowing, $kEventWindowHiding, $kEventWindowShown,
						$kEventWindowHidden, $kEventWindowBoundsChanging, $kEventWindowBoundsChanged, 
						$kEventWindowResizeStarted, $kEventWindowResizeCompleted, $kEventWindowDragStarted, 
						$kEventWindowDragCompleted, $kWindowBoundsChangeUserDrag, $kWindowBoundsChangeUserResize, 
						$kWindowBoundsChangeSizeChanged, $kWindowBoundsChangeOriginChanged, $kEventWindowClickDragRgn, 
						$kEventWindowClickResizeRgn, $kEventWindowClickCollapseRgn, $kEventWindowClickCloseRgn, 
						$kEventWindowClickZoomRgn, $kEventWindowClickContentRgn, $kEventWindowClickProxyIconRgn,
						$kEventWindowCursorChange, $kEventWindowCollapse, $kEventWindowCollapsed, 
						$kEventWindowCollapseAll, $kEventWindowExpand, $kEventWindowExpanded, $kEventWindowExpandAll, 
						$kEventWindowClose, $kEventWindowClosed, $kEventWindowCloseAll, $kEventWindowZoom, 
						$kEventWindowZoomed, $kEventWindowZoomAll, $kEventWindowContextualMenuSelect, 
						$kEventWindowPathSelect, $kEventWindowGetIdealSize, $kEventWindowGetMinimumSize, 
						$kEventWindowGetMaximumSize, $kEventWindowConstrain, $kEventWindowHandleContentClick, 
						$kEventWindowProxyBeginDrag, $kEventWindowProxyEndDrag, $kEventWindowFocusAcquired, 
						$kEventWindowFocusRelinquish, $kEventWindowDrawFrame, $kEventWindowDrawPart, 
						$kEventWindowGetRegion, $kEventWindowHitTest, $kEventWindowInit, $kEventWindowDispose, 
						$kEventWindowDragHilite, $kEventWindowModified, $kEventWindowSetupProxyDragImage, 
						$kEventWindowStateChanged, $kEventWindowMeasureTitle, $kEventWindowDrawGrowBox, 
						$kEventWindowGetGrowImageRegion, $kEventWindowPaint,
						// Parameters
						$kEventParamDirectObject, $kEventParamWindowRef, $kEventParamGrafPort, $kEventParamDragRef, 
						$kEventParamMenuRef, $kEventParamEventRef, $kEventParamControlRef, $kEventParamRgnHandle, 
						$kEventParamEnabled, $kEventParamDimensions, $kEventParamAvailableBounds, $kEventParamAEEventID, 
						$kEventParamAEEventClass, $kEventParamCGContextRef, $typeWindowRef, $typeGrafPtr, $typeGWorldPtr, 
						$typeDragRef, $typeMenuRef, $typeControlRef, $typeCollection, $typeQDRgnHandle, $typeOSStatus, 
            $typeQDPoint, $typeChar,
						$typeCGContextRef, $kEventParamMouseLocation, $kEventParamMouseButton, $kEventParamClickCount, 
						$kEventParamMouseWheelAxis, $kEventParamMouseWheelDelta, $kEventParamMouseDelta, $typeMouseButton, 
						$typeMouseWheelAxis, $kEventParamKeyCode, $kEventParamKeyMacCharCodes, $kEventParamKeyModifiers, 
						$kEventParamKeyUnicodes, $typeEventHotKeyID, $kEventParamTextInputSendRefCon, 
						$kEventParamTextInputSendComponentInstance, $kEventParamTextInputSendSLRec, 
						$kEventParamTextInputReplySLRec, $kEventParamTextInputSendText, $kEventParamTextInputReplyText, 
						$kEventParamTextInputSendUpdateRng, $kEventParamTextInputSendHiliteRng, 
						$kEventParamTextInputSendClauseRng, $kEventParamTextInputSendPinRng, $kEventParamTextInputSendFixLen, 
						$kEventParamTextInputSendLeadingEdge, $kEventParamTextInputReplyLeadingEdge, 
						$kEventParamTextInputSendTextOffset, $kEventParamTextInputReplyTextOffset, 
						$kEventParamTextInputReplyRegionClass, $kEventParamTextInputSendCurrentPoint, 
						$kEventParamTextInputSendDraggingMode, $kEventParamTextInputReplyPoint, 
						$kEventParamTextInputReplyFont, $kEventParamTextInputReplyPointSize, 
						$kEventParamTextInputReplyLineHeight, $kEventParamTextInputReplyLineAscent, 
						$kEventParamTextInputReplyTextAngle, $kEventParamTextInputSendShowHide, 
						$kEventParamTextInputReplyShowHide, $kEventParamTextInputSendKeyboardEvent, 
						$kEventParamTextInputSendTextServiceEncoding, $kEventParamTextInputSendTextServiceMacEncoding, 
						$kEventParamHICommand, $typeHICommand, $kEventParamWindowFeatures, $kEventParamWindowDefPart, 
						$kEventParamCurrentBounds, $kEventParamOriginalBounds, $kEventParamPreviousBounds, 
						$kEventParamClickActivation, $kEventParamWindowRegionCode, $kEventParamWindowDragHiliteFlag, 
						$kEventParamWindowModifiedFlag, $kEventParamWindowProxyGWorldPtr, $kEventParamWindowProxyImageRgn, 
						$kEventParamWindowProxyOutlineRgn, $kEventParamWindowStateChangedFlags, 
						$kEventParamWindowTitleFullWidth, $kEventParamWindowTitleTextWidth, $kEventParamWindowGrowRect, 
						$kEventParamAttributes, $typeWindowRegionCode, $typeWindowDefPartCode, $typeClickActivationResult, 
						$kEventParamControlPart, $kEventParamInitCollection, $kEventParamControlMessage, 
						$kEventParamControlParam, $kEventParamControlResult, $kEventParamControlRegion, 
						$kEventParamControlAction, $kEventParamControlIndicatorDragConstraint, 
						$kEventParamControlIndicatorRegion, $kEventParamControlIsGhosting, $kEventParamControlIndicatorOffset, 
						$kEventParamControlClickActivationResult, $kEventParamControlSubControl, 
						$kEventParamControlOptimalBounds, $kEventParamControlOptimalBaselineOffset, 
						$kEventParamControlDataTag, $kEventParamControlDataBuffer, $kEventParamControlDataBufferSize, 
						$kEventParamControlDrawDepth, $kEventParamControlDrawInColor, $kEventParamControlFeatures, 
						$kEventParamControlPartBounds, $kEventParamControlOriginalOwningWindow, 
						$kEventParamControlCurrentOwningWindow, $typeControlActionUPP, $typeIndicatorDragConstraint, 
						$typeControlPartCode, $kEventParamCurrentMenuTrackingMode, $kEventParamNewMenuTrackingMode, 
						$kEventParamMenuFirstOpen, $kEventParamMenuItemIndex, $kEventParamMenuCommand, 
						$kEventParamEnableMenuForKeyEvent, $kEventParamMenuEventOptions, $typeMenuItemIndex, 
						$typeMenuCommand, $typeMenuTrackingMode, $typeMenuEventOptions, $kEventParamProcessID, 
						$kEventParamLaunchRefCon, $kEventParamLaunchErr, $kEventParamTabletPointerRec, 
						$kEventParamTabletProximityRec, $typeTabletPointerRec, $typeTabletProximityRec,
            $kEventControlInitialize, $kEventControlDispose, $kEventControlGetOptimalBounds,
            $kEventControlDefInitialize, $kEventControlDefDispose, $kEventControlHit, $kEventControlSimulateHit,
            $kEventControlHitTest, $kEventControlDraw, $kEventControlApplyBackground, $kEventControlApplyTextColor,
            $kEventControlSetFocusPart, $kEventControlGetFocusPart, $kEventControlActivate,
            $kEventControlDeactivate, $kEventControlSetCursor, $kEventControlContextualMenuClick,
            $kEventControlClick, $kEventControlTrack, $kEventControlGetScrollToHereStartPoint,
            $kEventControlGetIndicatorDragConstraint, $kEventControlIndicatorMoved, $kEventControlGhostingFinished,
            $kEventControlGetActionProcPart, $kEventControlGetPartRegion, $kEventControlGetPartBounds,
            $kEventControlSetData, $kEventControlGetData, $kEventControlValueFieldChanged,
            $kEventControlAddedSubControl, $kEventControlRemovingSubControl, $kEventControlBoundsChanged,
            $kEventControlOwningWindowChanged, $kEventControlArbitraryMessage, $kControlBoundsChangeSizeChanged, 
            $kControlBoundsChangePositionChanged,

            <EventTypeSpec*>,
            eventClass-value, eventClass-value-setter,
            eventKind-value, eventKind-value-setter,
            // methods
            NewEventHandlerUPP, DisposeEventHandlerUPP,
            InstallWindowEventHandler, InstallControlEventHandler, 
            AddEventTypesToHandler, CallNextEventHandler,
            ConvertEventRefToEventRecord, FlushEventQueue, 
            GetEventClass, GetEventKind, // GetEventParameter,
            GetMainEventQueue, GetMenuEventTarget,
            GetMainEventLoop, GetUserFocusEventTarget, GetWindowEventTarget,
            InstallEventHandler,
            //InstallEventLoopTimer, 
            GetEventParameter,
            QuitEventLoop, RemoveEventHandler, RemoveEventLoopTimer,
            RunApplicationEventLoop, QuitApplicationEventLoop,
            GetUserFocusWindow, SetUserFocusWindow,
            RunCurrentEventLoop,        
            $kEventDurationForever, $kEventDurationNoWait,
            GetEventDispatcherTarget, ReceiveNextEvent, SendEventToEventTarget, ReleaseEvent,
            GetControlEventTarget,
            
// Control manager.
		$pushButProc, $checkBoxProc, $radioButProc, $scrollBarProc, $popupMenuProc,
		$kControlEditTextProc, $kControlEditTextPasswordProc, $kControlEditTextInlineInputProc, 
		$kControlStaticTextProc, $kControlPictureProc, $kControlPictureNoTrackProc,
    $kControlUserPaneProc, $kControlSeparatorLineProc, $kControlGroupBoxTextTitleProc,
    $kControlGroupBoxSecondaryTextTitleProc, $kControlSliderProc, $kControlSliderLiveFeedback,
    $kControlSliderHasTickMarks, $kControlSliderReverseDirection, $kControlSliderNonDirectional,
    $kControlSliderPointsDownOrRight, $kControlSliderPointsUpOrLeft, $kControlSliderDoesNotPoint,
    $kControlListBoxProc, $kControlListBoxAutoSizeProc, $kControlScrollBarProc,
    $kControlScrollBarLiveProc, $kControlPushButtonProc, $kControlRadioButtonProc, $kControlCheckBoxProc,
		$kControlLabelPart, $kControlMenuPart, $kControlTrianglePart, $kControlEditTextPart,
		$kControlPicturePart, $kControlIconPart, $kControlClockPart, $kControlListBoxPart,
		$kControlListBoxDoubleClickPart, $kControlImageWellPart, $kControlRadioGroupPart,
		$kControlButtonPart, $kControlCheckBoxPart, $kControlRadioButtonPart, $kControlUpButtonPart,
		$kControlDownButtonPart, $kControlPageUpPart, $kControlPageDownPart,
		$kControlClockHourDayPart, $kControlClockMinuteMonthPart, $kControlClockSecondYearPart,
		$kControlClockAMPMPart, $kControlDataBrowserPart, $kControlDataBrowserDraggedPart,	
                $kControlKindBevelButton, $kControlKindChasingArrows, $kControlKindClock, 
                $kControlKindDataBrowser, $kControlKindDisclosureButton, $kControlKindDisclosureTriangle,	
                $kControlKindEditText, $kControlKindGroupBox, $kControlKindIcon, $kControlKindImageWell,	
                $kControlKindListBox, $kControlKindLittleArrows, $kControlKindPicture, $kControlKindPlacard,	
                $kControlKindPopupArrow, $kControlKindPopupButton, $kControlKindProgressBar,	
                $kControlKindPushButton, $kControlKindRadioGroup, $kControlKindRoundButton, 
                $kControlKindScrollBar,	$kControlKindScrollingTextBox,$kControlKindSeparator,
                $kControlKindSignatureApple, $kControlKindSlider, $kControlKindStaticText,$kControlKindTabs,	
                $kControlKindUserPane, $kControlKindWindowHeader,
    $kControlUserPaneDrawProcTag, $kControlStaticTextTextTag,
    $kControlEditTextSelectionTag, $kControlEditTextPasswordTag, $kControlEditTextTextTag,
    $kControlListBoxListHandleTag, $kControlEditTextValidationProcTag, $kControlEditTextKeyFilterTag,
    $kControlNoPart, $kControlEntireControl, $kControlEditTextPart,
    $kControlSupportsEmbedding,
    $kControlFontBigSystemFont, $kControlFontSmallSystemFont, $kControlFontSmallBoldSystemFont, 
    $kControlFontViewSystemFont,
    $kControlContentTextOnly,
    $kDataBrowserOrderUndefined, $kDataBrowserOrderIncreasing, $kDataBrowserOrderDecreasing,
    $errDataBrowserPropertyNotSupported,
    $kDataBrowserItemIsActiveProperty, $kDataBrowserItemDoubleClicked, $kDataBrowserItemDeselected,
    $kDataBrowserItemSelected,
    /*$kControlTabDirectionNorth, $kControlTabDirectionSouth, $kControlTabDirectionEast, $kControlTabDirectionWest,
    $kControlTabSizeLarge, $kControlTabSizeSmall,*/
    <ControlHandle>, <ControlRef>,
    <ControlActionUPP>, <ControlEditTextValidationUPP>, <ControlKeyFilterUPP>,
    <DataBrowserItemDataUPP>, <DataBrowserItemNotificationUPP>, <DataBrowserItemCompareUPP>,
		NewControl, DisposeControl, KillControls,
		HiliteControl, ShowControl, HideControl, GetControlBounds,
		GetControlValue, SetControlValue, MoveControl, SizeControl,
		SetControlTitle, GetControlTitle, 
		DragControl, FindControl, HandleControlClick, HandleControlKey, IdleControls, 
                TrackControl, TestControl,
                AdvanceKeyboardFocus, ClearKeyboardFocus, GetKeyboardFocus, ReverseKeyboardFocus, SetKeyboardFocus,
		DrawControls, EmbedControl,
    IsControlVisible, CreateRootControl, SetControlData, GetControlData, GetControlDataSize, 
    NewControlUserPaneDrawUPP, NewControlEditTextValidationUPP, NewControlKeyFilterUPP, NewControlActionUPP,
    NewDataBrowserItemNotificationUPP, NewDataBrowserItemDataUPP, NewDataBrowserItemCompareUPP,
    GetBestControlRect, ActivateControl, DeactivateControl,
    <ControlEditTextSelectionRec*>,
      selStart-value, selEnd-value, selStart-value-setter, selEnd-value-setter,
    SetControl32BitValue, SetControl32BitMinimum, SetControl32BitMaximum, SetControlViewSize,
    GetControl32BitValue, GetControl32BitMinimum, GetControl32BitMaximum, GetControlViewSize,
    SetControlAction,
    CreateSliderControl,
    $kDataBrowserListView, $kDataBrowserColumnView, 
    $kDataBrowserDragSelect, $kDataBrowserSelectOnlyOne, $kDataBrowserResetSelection,
    $kDataBrowserNoItem,
    $kDataBrowserItemNoState, $kDataBrowserItemAnyState, $kDataBrowserItemIsSelected, 
    $kDataBrowserListViewLatestHeaderDesc, $kDataBrowserListViewLatestHeaderDesc, $kDataBrowserListViewLatestHeaderDesc,
    $kDataBrowserItemsAdd, $kDataBrowserItemsAssign, $kDataBrowserItemsToggle, $kDataBrowserItemsRemove,
    $kDataBrowserItemNoProperty, $kDataBrowserCmdTogglesSelection,
    GetDataBrowserItemCount, SetDataBrowserSelectionFlags,
    CreateDataBrowserControl,
    $kDataBrowserListViewLatestHeaderDesc,
    $kDataBrowserIconType, $kDataBrowserTextType, $kDataBrowserIconAndTextType,
    $kDataBrowserDefaultPropertyFlags,
    $kDataBrowserListViewDefaultColumnFlags,
    $kControlUseFontMask, $kControlUseJustMask,
    <DataBrowserListViewColumnDesc*>,
    propertyDesc-value, headerBtnDesc-value,
    <DataBrowserPropertyDesc*>, <DataBrowserTableViewColumnDesc*>,
    propertyID-value, propertyType-value, propertyFlags-value, 
    propertyID-value-setter, propertyType-value-setter, propertyFlags-value-setter,
    AddDataBrowserListViewColumn, AddDataBrowserItems, RemoveDataBrowserItems, GetDataBrowserItemState,
    <DataBrowserCallbacks*>,
    version-value-setter, u-value, v1-value, itemDataCallback-value-setter, itemCompareCallback-value-setter,
    itemNotificationCallback-value-setter,
    $kDataBrowserLatestCallbacks,
    InitDataBrowserCallbacks, SetDataBrowserCallbacks,
    <ControlButtonContentInfo*>,
    contentType-value, contentType-value-setter,
    <ControlFontStyleRec*>, 
    flags-value, flags-value-setter, font-value, font-value-setter, size-value, size-value-setter,
    style-value, style-value-setter, mode-value, mode-value-setter, just-value, just-value-setter,
    foreColor-value, backColor-value, foreColor-value-setter, backColor-value-setter,
    <DataBrowserListViewHeaderDesc*>,
    version-value, version-value-setter, minimumWidth-value, minimumWidth-value-setter, 
    maximumWidth-value, maximumWidth-value-setter, titleOffset-value, titleOffset-value-setter,
    titleString-value, titleString-value-setter, initialOrder-value, initialOrder-value-setter,
    // XXX - No setters for these two. Get them, and set their fields
    btnFontStyle-value, btnContentInfo-value,
    <DataBrowserItemDataRef>,
    SetDataBrowserItemDataText, SetDataBrowserHasScrollBars, SetDataBrowserListViewHeaderBtnHeight,
    /*<ControlTabEntry*>,
    icon-value, icon-value-setter, name-value, name-value-setter, enabled-value, enabled-value-setter,
    CreateTabsControl, SetTabEnabled,*/
    
// Core Foundation
    <CFTypeRef>,
    CFRetain, CFRelease,
    <CFAllocatorRef>,
    $kCFAllocatorNull,
    CFAllocatorGetDefault,
    <CFStringRef>,
    $kCFStringEncodingMacRoman, $kCFStringEncodingASCII, $kCFStringEncodingUnicode, $kCFStringEncodingUTF8,
    CFStringCreateWithBytes, CFStringCreateWithCStringNoCopy,
    
// Dialog Manager.
		<DialogRef>, <ModalFilterUPP>, $uppModalFilterProcInfo,
		$kControlDialogItem, $kButtonDialogItem, $kCheckBoxDialogItem,
		$kRadioButtonDialogItem, $kResourceControlDialogItem, $kStaticTextDialogItem,
		$kEditTextDialogItem, $kIconDialogItem, $kPictureDialogItem,
		$kUserDialogItem, $kItemDisableBit,
		Alert,
		GetNewDialog, DisposeDialog,
		SetDialogDefaultItem, SetDialogCancelItem,
		IsDialogEvent, DialogSelect,
		GetDialogItem, GetDialogItemText, SetDialogItemText,
		CountDITL,
                GetDialogWindow, GetDialogPort,
                // Appearance
                <AlertStdAlertParam>, <AlertType>,
                $kAlertStopAlert, $kAlertNoteAlert, $kAlertCautionAlert, $kAlertPlainAlert,
                StandardAlert,
                
// Event Manager.
		$everyEvent,
		$nullEvent, $mouseDown, $mouseUp, $keyDown, $keyUp, $autoKey, $updateEvt, $diskEvt, $activateEvt,
		$osEvt, $kHighLevelEvent,
		$cmdKey, $cmdKeyBit, $suspendResumeMessage,
		$activeFlag, $charCodeMask, $keyCodeMask,
		<EventRecord*>, what-value, message-value, when-value, 
    where-value, modifiers-value,
		//GetNextEvent, SystemTask, 
		WaitNextEvent, FlushEvents,
                <EventModifiers>,
		//DIBadMount,
		// AppleEvents.
		$kCoreEventClass,
		$kAEOpenApplication, $kAEOpenDocuments, $kAEPrintDocuments, $kAEQuitApplication,
		<RoutineDescriptor>, <UniversalProcPtr>,
		<AEEventClass>, <AEEventID>, <AppleEvent*>,
		<AEDesc*>, <AEDescList*>,
		<AEEventHandlerUPP>, $uppAEEventHandlerProcInfo,
                NewAEEventHandlerUPP,
		AEInstallEventHandler, AERemoveEventHandler, AEProcessAppleEvent,
	// PRP added:
		AEGetParamPtr,	
		// Misc Event Stuff
		TickCount, Button, StillDown, WaitMouseUp, GetMouse,
		//SystemClick,
    
// Files
			$fsCurPerm, $fsRdPerm, $fsWrPerm, $fsRdWrPerm, 
			$fsRdWrShPerm, $fsRdDenyPerm, $fsWrDenyPerm, 
			<FSSpec*>, 
			vRefNum-value, vrefNum-value-setter, parID-value, parID-value-setter, 
      name-value, name-value-setter,
			<FSRef>,
			FSClose, FSRead, FSWrite, Allocate, GetEOF, SetEOF, GetFPos, SetFPos,
			GetVRefNum, FSpOpenRF, FSpOpenDF, FSpCreate, FSpDirCreate, FSpDelete,
			FSpRename, FSpCatMove, FSpExchangeFiles, 
			FSpMakeFSRef,
      
// Gestalt
		Gestalt,
		$gestaltQuickdrawVersion, $gestaltOriginalQD, $gestalt8BitQD, $gestalt32BitQD,
		$gestalt32BitQD11, $gestalt32BitQD12, $gestalt32BitQD13, $gestaltAllegroQD,
		$gestaltSystemVersion,
    
// Lists
      /*<ListRef>, <Cell>, <ListBounds>,
      $lDoVAutoscrollBit, $lDoHAutoscrollBit, $lDoVAutoscroll, $lDoHAutoscroll,
      $lOnlyOneBit, $lExtendDragBit, $lNoDisjointBit, $lNoExtendBit, $lNoRectBit, $lUseSenseBit, $lNoNilHiliteBit, 
      $lOnlyOne, $lExtendDrag, $lNoDisjoint, $lNoExtend, $lNoRect, $lUseSense, 
      $lNoNilHilite, $kListDefUserProcType, $kListDefStandardTextType, $kListDefStandardIconType,
      */
    
// Mac Types
    // Basic Types
                        <UInt8>, <SInt8>, <UInt16>, <SInt16>, <UInt32>,
                        <SInt32>,  <OSErr>, <OSStatus>, <FourCharCode>, 
                        <OSType>, <ResType>,
      // Utilities
			os-type,
			Debugger, DebugStr,
      // Error Codes        
      $noErr,
      // Font styles
      $normal, $bold, $italic, $underline, $outline, $shadow, $condense, $extend,
      // pascal string	
			<pascal-string>,
      
// Memory Manager
			$nil, $NULL,
			<Ptr>, 	NewPtr, DisposePtr, 
			<Handle>, NewHandle, DisposeHandle,
			MemError,
      
// Menu Manager.
    $noMark, $kMenuNoModifiers, $kMenuShiftModifier,
    $kMenuOptionModifier, $kMenuControlModifier, $kMenuNoCommandModifier,
		<MenuBarHandle>, <MenuHandle>, <MenuRef>,
		GetNewMBar, SetMenuBar, DrawMenuBar, HiliteMenu,
		MenuSelect, MenuKey,
		GetMenuHandle, GetMenuItemText, EnableMenuItem, 
    DisableMenuItem, CountMenuItems,
		DeleteMenu,
		AppendResMenu,
    GetMBarHeight,
    AcquireRootMenu, SetRootMenu,
    CheckMenuItem, SetMenuItemText, GetItemMark, SetItemMark,
    GetItemCmd, SetItemCmd, SetItemStyle, GetItemStyle,
    GetMenuItemCommandID, SetMenuItemCommandID, GetMenuItemModifiers,
    SetMenuItemModifiers, NewMenu, InsertMenuItem, DeleteMenuItem,
    InsertMenu,DeleteMenu, ClearMenuBar,
    IsValidMenu,
    
// Navigation services
		<NavEventUPP>, <NavPreviewUPP>, <NavObjectFilterUPP>,
		<NavTypeListHandle>, <NavMenuItemSpecArrayHandle>, <FileTranslationSpecArrayHandle>,
		$kNavDefaultNavDlogOptions, $kNavNoTypePopup, $kNavDontAutoTranslate,
		$kNavDontAddTranslateItems, $kNavAllFilesInPopup, $kNavAllowStationery,
		$kNavAllowPreviews, $kNavAllowMultipleFiles, $kNavAllowInvisibleFiles,
		$kNavDontResolveAliases, $kNavSelectDefaultLocation, $kNavSelectAllReadableItem,
		$kNavSupportPackages, $kNavAllowOpenPackages,$kNavDontAddRecents,
		$kNavDontUseCustomFrame, 
		<NavDialogOptions*>, version-value, version-value-setter, 
		dialogOptionFlags-value, dialogOptionFlags-value-setter,
		location-value, location-value-setter, clientName-value, clientName-value-setter, 
		windowTitle-value, windowTitle-value-setter, actionButtonLabel-value, actionButtonLabel-value-setter,
		cancelButtonLabel-value, cancelButtonLabel-value-setter, savedFilename-value, savedFileName-value-setter,
		message-value, message-value-setter, 
		<NavReplyRecord*>, version-value, version-value-setter, 
		validRecord-value, validRecord-value-setter, replacing-value, replacing-value-setter,
		isStationary-value, isStationary-value-setter, translationNeeded-value, translationNeeded-value-setter,
		selection-value, selection-value-setter, 
		NavLoad, NavUnload, NavLibraryVersion, NavGetDefaultDialogOptions,
		NavGetFile, NavPutFile, NavChooseFile, NavChooseFolder, NavDisposeReply,
		NavServicesCanRun,
    
// OS Utils.
			GetDateTime, SecondsToDate,
			<DateTimeRec*>,
			year-value, month-value, day-value, hour-value, minute-value, seconds-value, dayOfWeek-value,
      
// QuickDraw.
    <Point*>, v-value, v-value-setter, h-value, h-value-setter,
		GlobalToLocal, LocalToGlobal,
		<Rect*>, top-value, top-value-setter, left-value, left-value-setter,
				bottom-value, bottom-value-setter, right-value, right-value-setter,
		SetRect, PtInRect, InsetRect,
		<BitMap*>, <PixMapHandle>, bounds-value, GetPixBounds, //<QDGlobals>, screenBits, qd,
    GetQDGlobalsScreenBits,
		<CGrafPtr>, SetPort, GetPort,
		MoveTo, LineTo, DrawString, TextFont,
		PenMode, $patOr, $patCopy, $patXor, 
		SetOrigin,
		EraseRect, FrameRect, InvertRect, PaintRect, FillRect,
		EraseOval, FrameOval, InvertOval, PaintOval, FillOval,
    EraseRoundRect, FrameRoundRect, InvertRoundRect, PaintRoundRect, FillRoundRect,
    EraseArc, FrameArc, InvertArc, PaintArc, FillArc,
		ClipRect, SetClip, GetClip,
		InitCursor, HideCursor, ShowCursor,
		ObscureCursor, GetCursor, SetCursor,
		TextSize, TextFont, TextMode,
		// GetFNum,
    GetCPixel, SetCPixel,
		<RGBColor*>,
		RGBForeColor, RGBBackColor, InvertColor,
		red-value, blue-value, green-value, red-value-setter, green-value-setter, blue-value-setter,
		<GDHandle>, <GWorldPtr>,
		NewGWorld, DisposeGWorld, GetGWorld, GetGWorldPixMap,
		LockPixels, UnlockPixels, GetGWorldDevice, PixMap32Bit,
    <PolyHandle>,
    OpenPoly, ClosePoly, KillPoly,
    OffsetPoly, PaintPoly, FramePoly, FillPoly, InvertPoly, ErasePoly,
    <RgnHandle>,
    NewRgn, OpenRgn, CloseRgn, DisposeRgn,
    SetEmptyRgn, EmptyRgn, SetRectRgn, RectRgn,
    PaintRgn, FrameRgn, FillRgn, InvertRgn, EraseRgn,
    InsetRgn, OffsetRgn, XorRgn, SectRgn, UnionRgn, SectRgn, DiffRgn, CopyRgn,
    QDError,
    GetPortBounds, SetPortBounds, GetPortVisibleRegion, SetPortVisibleRegion,
    GetPortTextFont, GetPortTextFace, GetPortTextMode, GetPortTextSize,
    QDIsPortBuffered, QDIsPortBufferDirty, QDFlushPortBuffer, QDGetDirtyRegion, 
    QDSetDirtyRegion,
    
// QuickDraw Text
    $teFlushDefault, $teCenter, $teFlushRight, $teFlushLeft,
    <FontInfo*>,
    ascent-value, descent-value, widMax-value, leading-value,
    ascent-value-setter, descent-value-setter, widMax-value-setter, leading-value-setter,
    TextFont, TextFace, TextMode, TextSize,
    DrawChar, DrawText, CharWidth, TextWidth, GetFontInfo,
    
// Resource Manager.
		ResError,
		GetResource, ReleaseResource,
    
// Sound Manager.
			SysBeep, 
      
// Window Manager.
		<WindowRef>,
		$dialogKind, $userKind, $kDialogWindowKind, $kApplicationWindowKind,
		$documentProc, $dBoxProc, $plainDBox, $altDBoxProc, $noGrowDocProc, 
		$movableDBoxProc, $zoomDocProc, $zoomNoGrow, $rDocProc,
		$floatProc, $floatGrowProc, $floatZoomProc, $floatZoomGrowProc, $floatSideProc,
		$floatSideGrowProc, $floatSideZoomProc, $floatSideZoomGrowProc,	
		FrontWindow, ShowWindow, HideWindow, SelectWindow, BringToFront, SendBehind, SetWTitle,
		GetNewWindow, NewWindow, DisposeWindow, BeginUpdate, EndUpdate, DrawGrowIcon,
		FindWindow,
		$inDesk, $inMenuBar, $inSysWindow, $inContent, $inDrag, $inGrow, $inGoAway, $inZoomIn, $inZoomOut,
		DragWindow, TrackGoAway, TrackBox, ZoomWindow, GrowWindow, SizeWindow,
		InvalWindowRect,
		SetWRefCon, GetWRefCon, SetWindowKind, GetWindowKind,
    IsWindowVisible,
		// Incomplete list
		$kAlertWindowClass,
		$kMovableAlertWindowClass,
		$kModalWindowClass,
		$kMovableModalWindowClass,
		$kFloatingWindowClass,
		$kDocumentWindowClass,
		$kUtilityWindowClass,
		$kHelpWindowClass,
		$kSheetWindowClass,
		$kToolbarWindowClass,
		$kPlainWindowClass,
		// Incomplete list
		$kWindowNoAttributes,
		$kWindowCloseBoxAttribute,
		$kWindowHorizontalZoomAttribute,
		$kWindowVerticalZoomAttribute,
		$kWindowFullZoomAttribute,
		$kWindowCollapseBoxAttribute,
		$kWindowResizableAttribute,
		$kWindowSideTitlebarAttribute,
		$kWindowNoUpdatesAttribute,
		$kWindowNoActivatesAttribute,
		$kWindowOpaqueForEventsAttribute,
		$kWindowNoShadowAttribute,
		$kWindowHideOnSuspendAttribute,
		$kWindowHideOnSuspendAttribute,
		$kWindowStandardHandlerAttribute,
		$kWindowHideOnFullScreenAttribute,
		$kWindowHideOnFullScreenAttribute,
		$kWindowInWindowMenuAttribute,
		$kWindowLiveResizeAttribute,
		$kWindowStandardDocumentAttributes,
		$kWindowStandardFloatingAttributes,
		// Region codes
		$kWindowTitleBarRgn, $kWindowTitleTextRgn, $kWindowCloseBoxRgn,
		$kWindowZoomBoxRgn, $kWindowDragRgn, $kWindowGrowRgn, $kWindowCollapseBoxRgn,
		$kWindowTitleProxyIconRgn, $kWindowStructureRgn, $kWindowContentRgn,
		$kWindowUpdateRgn, $kWindowOpaqueRgn,$kWindowGlobalPortRgn,
    // Repositioning
    $kWindowCenterOnMainScreen, $kWindowCenterOnParentWindow,
    $kWindowCenterOnParentWindowScreen, $kWindowCascadeOnMainScreen,
    $kWindowCascadeOnParentWindow, $kWindowCascadeOnParentWindowScreen,
    $kWindowAlertPositionOnMainScreen, $kWindowAlertPositionOnParentWindow,
    $kWindowAlertPositionOnParentWindowScreen,
    RepositionWindow,
    // Carbon methods
		CreateNewWindow, CreateWindowFromResource, GetWindowPort, SetPortWindowPort,
    GetWindowPortBounds, GetWindowFromPort,
    GetWindowBounds, SetWindowBounds, GetWindowRegion, MoveWindowStructure;
end module carbon;