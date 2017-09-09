# source {D:\Sun\Work\Software\MyCode\Tcl\Orcad\showProperty.tcl}
package require Tcl 8.4
package require DboTclWriteBasic 16.3.0

namespace eval ::capGUIUtils {
    RegisterAction "ShowProperty" "::capGUIUtils::capShowPropertyEnabler" "" "::capGUIUtils::capShowProperty" "Schematic"
}

proc ::capGUIUtils::capShowPropertyEnabler {} {
    set lEnableAdd 0
    # Get the selected objects
    set lSelObjs [GetSelectedObjects]

    # Enable only for single object selection
    if { [llength $lSelObjs] == 1 } { 
        # Enable only if a part or a hierarchical block is selected 
        set lObj [lindex $lSelObjs 0] 
        set lObjType [DboBaseObject_GetObjectType $lObj] 
        set lEnableAdd 1 
    } 
            
    return $lEnableAdd
}

proc ::capGUIUtils::capShowProperty {} {
    set lStatus [DboState]
    set lNullObj NULL
    
    set lSelObjs [GetSelectedObjects]
    set lInst [lindex $lSelObjs 0] 
    ::capGUIUtils::showUserPropsIter $lInst
    ::capGUIUtils::showDisplayProps $lInst
    ::capGUIUtils::showEffectiveProps $lInst
}

proc ::capGUIUtils::showUserPropsIter {lObject} {
    set lStatus [DboState]
    set lPropsIter [$lObject NewUserPropsIter $lStatus] 

    set lNullObj NULL 

    #get the first user property on the object 
    set lUProp [$lPropsIter NextUserProp $lStatus] 

    while {$lUProp != $lNullObj } { 

        #placeholder: do your processing on $lUProp 
        set lName [DboTclHelper_sMakeCString] 

        set lValue [DboTclHelper_sMakeCString] 

        $lUProp GetName $lName 
        $lUProp GetStringValue $lValue 
        puts "[DboTclHelper_sGetConstCharPtr $lName]: [DboTclHelper_sGetConstCharPtr $lValue]"


        #get the next user property on the object 
        set lUProp [$lPropsIter NextUserProp $lStatus] 

    } 

    delete_DboUserPropsIter $lPropsIter
}

proc ::capGUIUtils::showDisplayProps {lObject} {
    set lStatus [DboState]
    set lPropsIter [$lObject NewDisplayPropsIter $lStatus] 

    set lNullObj NULL 

    #get the first display property on the object 
    set lDProp [$lPropsIter NextProp $lStatus] 

    while {$lDProp != $lNullObj } { 

        #placeholder: do your processing on $lDProp 

        #get the name 
        set lName [DboTclHelper_sMakeCString] 
        $lDProp GetName $lName

        #get the location 
        set lLocation [$lDProp GetLocation $lStatus] 

        #get the rotation 
        set lRot [$lDProp GetRotation $lStatus] 

        #get the font 
        set lFont [DboTclHelper_sMakeLOGFONT] 
        set lStatus [$lDProp GetFont $::DboLib_DEFAULT_FONT_PROPERTY $lFont] 

        #get the color 
        set lColor [$lDProp GetColor $lStatus] 
        
        puts "lName:[DboTclHelper_sGetConstCharPtr $lName], lLocation:([DboTclHelper_sGetCPointX $lLocation], [DboTclHelper_sGetCPointY $lLocation]), lRot:$lRot, lFont:$lFont, lColor:$lColor"

        #get the next display property on the object 
        set lDProp [$lPropsIter NextProp $lStatus] 

    } 

    delete_DboDisplayPropsIter $lPropsIter 
}

proc ::capGUIUtils::showEffectiveProps {lObject} {
    set lStatus [DboState]
    set lPropsIter [$lObject NewEffectivePropsIter $lStatus] 

    set lNullObj NULL 

    #create the input/output parameters 
    set lPrpName [DboTclHelper_sMakeCString] 
    set lPrpValue [DboTclHelper_sMakeCString] 
    set lPrpType [DboTclHelper_sMakeDboValueType] 
    set lEditable [DboTclHelper_sMakeInt] 

    #get the first effective property 
    set lStatus [$lPropsIter NextEffectiveProp $lPrpName $lPrpValue $lPrpType $lEditable] 

    while {[$lStatus OK] == 1} { 

    #placeholder: do your processing for $lPrpName $lPrpValue $lPrpType $lEditable 
    puts "lPrpName:[DboTclHelper_sGetConstCharPtr $lPrpName], lPrpValue:[DboTclHelper_sGetConstCharPtr $lPrpValue], lPrpType:$lPrpType, lEditable:$lEditable"

    #get the next effective property 
    set lStatus [$lPropsIter NextEffectiveProp $lPrpName $lPrpValue $lPrpType $lEditable] 

    } 

    delete_DboEffectivePropsIter $lPropsIter
}