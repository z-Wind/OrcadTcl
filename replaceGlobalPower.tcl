# source {D:\Sun\Work\Software\MyCode\Tcl\Orcad\replaceGlobalPower.tcl}
package require Tcl 8.4
package require DboTclWriteBasic 16.3.0
# package provide capGUIUtils 1.0

namespace eval ::capGUIUtils {
    # namespace export capRemoveSelectedGlobalsEnabler
    # namespace export capRemoveSelectedGlobals
    # namespace export capRemoveAllGlobals

    RegisterAction "Remove Selected Globals" "::capGUIUtils::capRemoveSelectedGlobalsEnabler" "" "::capGUIUtils::capRemoveSelectedGlobals" "Schematic"
    RegisterAction "Remove All Globals" "return 1" "" "::capGUIUtils::capRemoveAllGlobals" "Schematic"
}

proc ::capGUIUtils::capRemoveSelectedGlobalsEnabler {} {
    set lEnableDS 0
    # Get the selected objects
    set lSelObjs [GetSelectedObjects]

    # Enable only for single object selection
    foreach lSelObj $lSelObjs {
        set lObjType [DboBaseObject_GetObjectType $lSelObj]
        puts "objType: $lObjType"
        if { $lObjType == 37} {
            return 1
        }        
    }
            
    return $lEnableDS
}

proc ::capGUIUtils::capRemoveAllGlobals {} {    
    set lStatus [DboState]
    set lNullObj NULL
    
    set lSession $::DboSession_s_pDboSession
    DboSession -this $lSession
    
    # set lDesignsIter [$lSession NewDesignsIter $lStatus]
    # get the first design
    # set lDesign [$lDesignsIter NextDesign $lStatus]
    # delete_DboSessionDesignsIter $lDesignsIter
    set lDesign [$lSession GetActiveDesign]

    set lSchematicIter [$lDesign NewViewsIter $lStatus $::IterDefs_SCHEMATICS]
    #get the first schematic view
    set lView [$lSchematicIter NextView $lStatus]
    while {$lView != $lNullObj} {
        #dynamic cast from DboView to DboSchematic
        set lSchematic [DboViewToDboSchematic $lView]
        set lSchematicName [_getName $lSchematic]
        #placeholder: do your processing on $lSchematic
        set lPagesIter [$lSchematic NewPagesIter $lStatus]
        #get the first page
        set lPage [$lPagesIter NextPage $lStatus]
        while {$lPage != $lNullObj} {
            #placeholder: do your processing on $lPage  
            set lPageName [_getName $lPage]
            OPage $lSchematicName $lPageName
            ::capGUIUtils::IterAllGlobal $lPage
            
            #get the next page
            set lPage [$lPagesIter NextPage $lStatus]
        }
        delete_DboSchematicPagesIter $lPagesIter
        
        #get the next schematic view
        set lView [$lSchematicIter NextView $lStatus]
    }
    delete_DboLibViewsIter $lSchematicIter  
}

proc ::capGUIUtils::replaceNowPageAll {} {
    if { [IsSchematicViewActive] == 1 } { 
        set lPage [GetActivePage]
        ::capGUIUtils::IterAllGlobal $lPage
    } else {
        capDisplayMessageBox "No schematic view active" "warning"
    }
}

proc ::capGUIUtils::IterAllGlobal {lPage} {
    set lStatus [DboState]
    set lNullObj NULL
    
    #placeholder: do your processing on $lPage            
    set lGlobalsIter [$lPage NewGlobalsIter $lStatus]      
    #get the first global 
    set lGlobal [$lGlobalsIter NextGlobal $lStatus] 
    while { $lGlobal != $lNullObj } { 
        #placeholder: do your processing on $lGlobal 
        ::capGUIUtils::replacePowerToNetName $lGlobal

        #get the next global 
        set lGlobal [$lGlobalsIter NextGlobal $lStatus] 
    } 
    delete_DboPageGlobalsIter $lGlobalsIter 
}
    
proc ::capGUIUtils::capRemoveSelectedGlobals {} {
    set lSelObjs [GetSelectedObjects]
    foreach lSelObj $lSelObjs {
        set lObjType [DboBaseObject_GetObjectType $lSelObj]
        # puts $lObjType
        if { $lObjType == 37} {
            ::capGUIUtils::replacePowerToNetName $lSelObj
        }
        
    }
}

proc ::capGUIUtils::replacePowerToNetName {lGlobal} {
    set ClSymbolName [DboTclHelper_sMakeCString]
    $lGlobal GetSourceSymbolName $ClSymbolName
    set lSymbolName [DboTclHelper_sGetConstCharPtr $ClSymbolName]
    puts "\nSymbolName: $lSymbolName"
            
    # 得到名字
    set lGlobalName [DboTclHelper_sMakeCString]
    $lGlobal GetName $lGlobalName
    set lWireName [DboTclHelper_sGetConstCharPtr $lGlobalName]
    puts "WireName: $lWireName"
    if { [regexp {GND} $lWireName] } {
        return
    }
    
    # 得到座標
    set lStatus [DboState]
    set lLocation [$lGlobal GetLocation $lStatus]
    set lStartX [expr [DboTclHelper_sGetCPointX $lLocation]/100.0]
    set lStartY [expr [DboTclHelper_sGetCPointY $lLocation]/100.0]
    puts "Start: $lStartX , $lStartY"
    
    # 得到端點座標
    set lHotSpotPoint [$lGlobal GetOffsetHotSpot $lStatus]
    set lHotSpotPointX [expr [DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0]
    set lHotSpotPointY [expr [DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0]
    puts "HotSpotPointY: $lHotSpotPointX , $lHotSpotPointY"
    
    # 得到中心座標
    set center [::capGUIUtils::_getCenter $lGlobal]
    set centerX [expr [DboTclHelper_sGetCPointX $center]/100.0]
    set centerY [expr [DboTclHelper_sGetCPointY $center]/100.0]
    puts "center: $centerX , $centerY"
    
    # 得到旋轉方向
    set rotattion [$lGlobal GetRotation $lStatus]
    
    # 命名線並畫線
    switch $rotattion {
        0 { # 上
            set wireX [expr $lHotSpotPointX]
            set wireY [expr $lHotSpotPointY]
            PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+0.01] [expr $lHotSpotPointY+0]
        }
        1 { # 左
            set wireX [expr $lHotSpotPointX]
            set wireY [expr $lHotSpotPointY]
            PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+0] [expr $lHotSpotPointY-0.01]
        }
        2 { # 下
            set wireX [expr $lHotSpotPointX]
            set wireY [expr $lHotSpotPointY]
            PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+0.01] [expr $lHotSpotPointY+0]
        }
        3 { # 右
            set wireX [expr $lHotSpotPointX]
            set wireY [expr $lHotSpotPointY]
            PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+0] [expr $lHotSpotPointY-0.01]
        }
        default {
            puts "No define $rotattion"
        }
    }
    puts "wire: $wireX , $wireY"
    
    # 刪除 Global
    UnSelectAll
    SelectObject [expr $centerX] [expr $centerY] True
    Delete
    
    PlaceNetAlias $wireX $wireY $lWireName
}

proc ::capGUIUtils::_getName {obj} {
    set lname [DboTclHelper_sMakeCString]
    $obj GetName $lname
    return [DboTclHelper_sGetConstCharPtr $lname]
}

proc ::capGUIUtils::_getCenter {obj} {
    set lStatus [DboState]
    # set lBBox [$obj GetBoundingBox]
    
    # set left [DboTclHelper_sGetCPointX [DboTclHelper_sGetCRectTopLeft  $lBBox]]
    # set top [DboTclHelper_sGetCPointY [DboTclHelper_sGetCRectTopLeft  $lBBox]]
    # set right [DboTclHelper_sGetCPointX [DboTclHelper_sGetCRectBottomRight  $lBBox]]
    # set Bottom [DboTclHelper_sGetCPointY [DboTclHelper_sGetCRectBottomRight  $lBBox]]
    
    # 得到端點座標
    set lHotSpotPoint [$obj GetOffsetHotSpot $lStatus]
    set lHotSpotPointX [DboTclHelper_sGetCPointX $lHotSpotPoint]
    set lHotSpotPointY [DboTclHelper_sGetCPointY $lHotSpotPoint]
    
    # 加入 offset
    switch [$obj GetRotation $lStatus] {
        0 { # 上
            set offsetX 0
            set offsetY -5
        }
        1 { # 左
            set offsetX -5
            set offsetY 0
        }
        2 { # 下
            set offsetX 0
            set offsetY 5
        }
        3 { # 右
            set offsetX 5
            set offsetY 0
        }
        default {
            set offsetX 0
            set offsetY 0
        }
    }
    
    set centerX [expr $lHotSpotPointX + $offsetX]
    set centerY [expr $lHotSpotPointY + $offsetY]
    
    set center [DboTclHelper_sMakeCPoint $centerX $centerY]
    return $center
}