PXVUTIL ;BIR/ADM - VIMM UTILITY ROUTINE ;08/20/15
 ;;1.0;PCE PATIENT CARE ENCOUNTER;**201,210**;Aug 12, 1996
 ;
VIS ; display VIS name with identifiers
 N C,PXVNAME,PXVDATE,PXVSTAT,PXVLANG,X
 S X=$G(^AUTTIVIS(Y,0))
 S PXVNAME=$P(X,"^"),PXVDATE=$P(X,"^",2),PXVSTAT=$P(X,"^",3),PXVLANG=$P(X,"^",4)
 S X=PXVDATE,PXVDATE=$E(X,4,5)_"-"_$E(X,6,7)_"-"_$E(X,2,3)
 S Y=PXVSTAT,C=$P(^DD(920,.03,0),"^",2) D:Y'="" Y^DIQ S PXVSTAT=Y
 S Y=PXVLANG,C=$P(^DD(920,.04,0),"^",2) D:Y'="" Y^DIQ S PXVLANG=Y
 S Y=PXVNAME_"   "_PXVDATE_"   "_PXVSTAT_"   "_PXVLANG
 Q
 ;;
DUPDX(PXVIEN,PXVDX) ; extrinsic function to check for duplicate diagnoses
 ; PXVIEN - Internal Entry Number of the event, pointing to the
 ;        V IMMUNIZATION file (9000010.11)
 ; PXVDX is the diagnosis entered and used to check for duplicates
 ;
 ; this code is called by the input transforms of:
 ;        ^DD(9000010.11,1304,0) & ^DD(9000010.113,.01,0)
 ;
 ; RETURNS a 1 if the diagnosis already exists for this
 ;         entry, 0 if not
 ;
 N TXT K TXT S TXT(2)=" ",TXT(1,"F")="?5"
 I PXVDX=$P($G(^AUPNVIMM(PXVIEN,13)),"^",4) S TXT(1)="Selected diagnosis exists as the Primary Diagnosis for this event." D EN^DDIOL(.TXT,"","") Q 1
 I $D(^AUPNVIMM(PXVIEN,3,"B",PXVDX)) S TXT(1)="Selected diagnosis exists for this event." D EN^DDIOL(.TXT,"","") Q 1
 Q 0
 ;;
RSETDA ; code needed for the routine AUPNSICD to have the correct value in
 ;   DA, as AUPNSICD is not designed to be called from a multiple.
 N DA S DA=D0
 D ^AUPNSICD
 Q
HRS ; called by AH new style x-ref in V IMMUNIZATION file
 ; set number of hours between administration and reading of results
 N PXVX,X1,X2,X3
 S X1=$P($G(^AUPNVIMM(DA,14)),"^",3) ; DATE/TIME READ
 S X2=$P($G(^AUPNVIMM(DA,12)),"^") ; EVENT DATE AND TIME
 S X3=2 ; return difference in seconds
 S PXVX=""
 I $G(X1),$L(X1)>7,$G(X2),$L(X2)>7,$G(X2)'>$G(X1) S PXVX=$$FMDIFF^XLFDT(X1,X2,X3)\3600
 S $P(^AUPNVIMM(DA,14),"^",6)=PXVX
 Q
 ;
DOSAGE(PXIEN) ; Used to compute Dosage (9000010.11,1312.5)
 ;Input:
 ;   PXIEN = (Required) Pointer to #9000010.11
 ;Returns:
 ;   Concatenation of DOSE_" "_DOSE UNITS (e.g., ".5 mL")
 N PXDOSE,PXUNITS
 I $G(PXIEN)="" Q ""
 S PXDOSE=$P($G(^AUPNVIMM(PXIEN,13)),U,12)
 I PXDOSE="" Q ""
 S PXDOSE=$FN(PXDOSE,",")
 S PXUNITS=$P($G(^AUPNVIMM(PXIEN,13)),U,13)
 I PXUNITS S PXUNITS=$P($$UCUMCODE^LEXMUCUM(PXUNITS),U)
 Q PXDOSE_$S(PXUNITS'="":" "_PXUNITS,1:"")
