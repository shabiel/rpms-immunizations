#!/bin/bash

sedtxt='\^XTMP("K2VC","EXPORT","\^DD",9999999.41,9999999.41,'
greptxt="$sedtxt[.0-9]\{1,\},0"
rpmsfile="../kids/SAM IMM 0.2/KIDComponents/Files/9999999.41+IMMUNIZATION LOT.DD.zwr"
vistafile="../recent_vista_imm_patches/PX_1.0_210/KIDComponents/Files/9999999.41+IMMUNIZATION LOT.DD.zwr"
diff -y -W 150 -t <(grep $greptxt "$rpmsfile" | sed s/$sedtxt//g) <(grep $greptxt "$vistafile" | sed s/$sedtxt//g)
