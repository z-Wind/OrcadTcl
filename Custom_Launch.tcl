package require Tcl 8.4
package require DboTclWriteBasic 16.3.0
package provide capGUIUtils 1.0

set root {D:\Sun\Work\Software\MyCode\Tcl\Orcad}

source [file join $root replaceGlobalPower.tcl]
source [file join $root AddNetsToParts.tcl]
source [file join $root showProperty.tcl]
source [file join $root controlDBC.tcl]