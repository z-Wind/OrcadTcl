# source {D:\Sun\Work\Software\MyCode\Tcl\Orcad\controlDBC.tcl}

# 顯示 DBC 路徑
proc showDBCName {} {
    set lCfg [OrCISGetDbcConfig]
    set lString [::CPMgtCfg_GetIniDBCName $lCfg]
    puts [DboTclHelper_sGetConstCharPtr $lString]
}

# 進資料庫選擇元件，並擺放位置
proc placePartsInDB {value x y} {
    MenuCommand "14567" 
    # "0402/0R*"
    CISAddSearchQuery VALUE = $value
    CISExecuteQuery
    CISExplorerSelectOption 1 1 0
    CISExplorerSelectOption 1 1 1
    capMoveMouseAndClick $x $y
    EndPlace()
}

#選擇指定值的零件
proc selectRefbyValue {lregValue} {
    set lSession $::DboSession_s_pDboSession
    DboSession -this $lSession

    set lStatus [DboState]
    set lNullObj NULL

    set lDesignsIter [$lSession NewDesignsIter $lStatus]
    # get the first design
    set lDesign [$lDesignsIter NextDesign $lStatus]

    while {$lDesign != $lNullObj} {
        # placeholder: do your processing on $lDesign
        set lSchematicIter [$lDesign NewViewsIter $lStatus $::IterDefs_SCHEMATICS]
        #get the first schematic view
        set lView [$lSchematicIter NextView $lStatus]
        while {$lView != $lNullObj} {
            #dynamic cast from DboView to DboSchematic
            set lSchematic [DboViewToDboSchematic $lView]
            #placeholder: do your processing on $lSchematic
            set lPagesIter [$lSchematic NewPagesIter $lStatus]
            #get the first page
            set lPage [$lPagesIter NextPage $lStatus]
            set lNullObj NULL
            while {$lPage != $lNullObj} {
                #placeholder: do your processing on $lPage
                set lPartInstsIter [$lPage NewPartInstsIter $lStatus]
                #get the first part inst
                set lInst [$lPartInstsIter NextPartInst $lStatus]
                while { $lInst != $lNullObj } {
                    set lRef [DboTclHelper_sMakeCString] 
                    $lInst GetReference $lRef
                    set lRef [DboTclHelper_sGetConstCharPtr $lRef]
                    
                    set lValue [DboTclHelper_sMakeCString] 
                    $lInst GetPartValue $lValue
                    set lValue [DboTclHelper_sGetConstCharPtr $lValue]
                    
                    puts "$lRef: $lValue"
                    if { [regexp $lregValue $lValue] } {
                        selectRefInDBC $lRef
                    }                    

                    set lInst [$lPartInstsIter NextPartInst $lStatus]
                }
                delete_DboPagePartInstsIter $lPartInstsIter
                
                #get the next page
                set lPage [$lPagesIter NextPage $lStatus]
            }
            delete_DboSchematicPagesIter $lPagesIter

            
            #get the next schematic view
            set lView [$lSchematicIter NextView $lStatus]
        }
        delete_DboLibViewsIter $lSchematicIter


        # get the next design
        set lDesign [$lDesignsIter NextDesign $lStatus]
    }
    delete_DboSessionDesignsIter $lDesignsIter
}


proc selectRefInDBC {lRef} {
    # ui::PMActivate "c:/users/chihchieh.sun/desktop/test/tt.opj"
    # Menu "Tools::Part Manager::Open"
    # set lPM [GetPartManagerView]
    SelectGroup Groups Common $lRef
}

proc linkDB {} {
    LinkDataBasePart
    CISExplorerSelectOption 1 1 0
    CISExplorerSelectOption 1 1 1
}

proc deleteSelect {} {
    MenuCommand "33014"  | MessageBox "YES" "INFO(ORCIS-6327): Are you sure"
}