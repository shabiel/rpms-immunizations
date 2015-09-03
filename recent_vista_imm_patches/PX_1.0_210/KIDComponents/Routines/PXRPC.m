PXRPC ;ISL/JLC - PCE DATA2PCE RPC ;08/24/15  18:44
 ;;1.0;PCE PATIENT CARE ENCOUNTER;**200,209,210**;Aug 12, 1996
 ;
 ;
 ;
SAVE(OK,PCELIST,LOC,PKGNAME,SRC) ; save PCE information
 N VSTR
 I '$D(PCELIST(1)) S OK=-3 Q
 S VSTR=$P(PCELIST(1),U,4) K ^TMP("PXRPC",$J,VSTR)
 I $G(PKGNAME)="" S OK=-3 Q
 I $G(SRC)="" S OK=-3 Q
 M ^TMP("PXRPC",$J,VSTR)=PCELIST
DQSAVE ;
 N PKG,TYP,CODE,IEN,I,X,PXAPI,PXDEL,ERROR
 N CAT,NARR,ROOT,ROOT2,PXAVST,LEXIEN
 N PRV,CPT,ICD,IMM,SK,PED,HF,XAM,TRT,MOD,MODCNT,MODIDX,MODS
 N COM,COMMENT,COMMENTS
 N DFN,PROBLEMS,PXAPREDT,ORCPTDEL
 ; Vars for Info Source (IMMIS) Imm. Admin Route (IMMRT), Body Site (IMMAL), Lot, Manufacturer, Exp. Date & Comments
 N IMMISNM,IMMISIEN,IMMRTNM,IMMRTIEN,IMMRTERR,IMMALNAME,IMMALIEN,IMMALERR,IMMLOT,IMMMANUF,IMMEXPDT,IMMCOMM,IMMCOMMS,IMMLOTIEN
 N NUM,REMARK,SEQ,IMMDSG,IMMCVX,IMMCVXER
 S PKG=$$PKG2IEN^VSIT(PKGNAME) I PKG=-1 S OK=-3 Q
 S (PRV,CPT,ICD,IMM,SK,PED,HF,XAM,TRT)=0
 S I="" F  S I=$O(PCELIST(I)) Q:'I  S X=PCELIST(I) D
 . S X=PCELIST(I),TYP=$P(X,U),CODE=$P(X,U,2),CAT=$P(X,U,3),NARR=$P(X,U,4)
 . I $E(TYP,1,3)="PRV" D  Q
 . . Q:'$L(CODE)
 . . S PRV=PRV+1
 . . S ROOT="PXAPI(""PROVIDER"","_PRV_")"
 . . S ROOT2="PXDEL(""PROVIDER"","_PRV_")"
 . . I $E(TYP,4)'="-" D
 . . . S @ROOT@("NAME")=CODE
 . . . S @ROOT@("PRIMARY")=$P(X,U,6)
 . . S @ROOT2@("NAME")=CODE
 . . S @ROOT2@("DELETE")=1
 . . S PXAPREDT=1 ;Allow edit of primary flag
 . I TYP="VST" D  Q
 . . S ROOT="PXAPI(""ENCOUNTER"",1)"
 . . I CODE="DT" S @ROOT@("ENC D/T")=$P(X,U,3) Q
 . . I CODE="PT" S @ROOT@("PATIENT")=$P(X,U,3),DFN=$P(X,U,3) Q
 . . I CODE="HL" S @ROOT@("HOS LOC")=$P(X,U,3) Q
 . . I CODE="PR" S @ROOT@("PARENT")=$P(X,U,3) Q
 . . ;prevents checkout!
 . . I CODE="VC" S @ROOT@("SERVICE CATEGORY")=$P(X,U,3) Q
 . . I CODE="SC" S @ROOT@("SC")=$P(X,U,3) Q
 . . I CODE="AO" S @ROOT@("AO")=$P(X,U,3) Q
 . . I CODE="IR" S @ROOT@("IR")=$P(X,U,3) Q
 . . I CODE="EC" S @ROOT@("EC")=$P(X,U,3) Q
 . . I CODE="MST" S @ROOT@("MST")=$P(X,U,3) Q
 . . I CODE="HNC" S @ROOT@("HNC")=$P(X,U,3) Q
 . . I CODE="CV" S @ROOT@("CV")=$P(X,U,3) Q
 . . I CODE="SHD" S @ROOT@("SHAD")=$P(X,U,3) Q
 . . I CODE="OL" D  Q
 . . . I +$P(X,U,3) S @ROOT@("INSTITUTION")=$P(X,U,3)
 . . . E  I $P(X,U,4)'="",$P(X,U,4)'="0" D
 . . . . I $$PATCH^XPDUTL("PX*1.0*96") S @ROOT@("OUTSIDE LOCATION")=$P(X,U,4)
 . . . . E  S @ROOT@("COMMENT")="OUTSIDE LOCATION:  "_$P(X,U,4)
 . I $E(TYP,1,3)="CPT" D  Q
 . . Q:'$L(CODE)
 . . S CPT=CPT+1,ROOT="PXAPI(""PROCEDURE"","_CPT_")"
 . . S IEN=$$CODEN^ICPTCOD(CODE) ;ICR #1995
 . . S @ROOT@("PROCEDURE")=IEN
 . . I +$P(X,U,9) D
 . . . S MODS=$P(X,U,9),MODCNT=+MODS
 . . . F MODIDX=1:1:MODCNT D
 . . . . S MOD=$P($P(MODS,";",MODIDX+1),"/")
 . . . . S @ROOT@("MODIFIERS",MOD)=""
 . . S:$L(CAT) @ROOT@("CATEGORY")=CAT
 . . S:$L(NARR) @ROOT@("NARRATIVE")=NARR
 . . S:$L($P(X,U,5)) @ROOT@("QTY")=$P(X,U,5)
 . . S:$P(X,U,6)>0 @ROOT@("ENC PROVIDER")=$P(X,U,6)
 . . S:$L($P(X,U,10))>0 COMMENT($P(X,U,10))="PROCEDURE^"_CPT
 . . I $E(TYP,4)="-" S @ROOT@("DELETE")=1,@ROOT@("QTY")=0,ORCPTDEL=CPT
 . I $E(TYP,1,3)="POV" D  Q
 . . N PXDXI,PXDX
 . . Q:'$L(CODE)
 . . F PXDXI=1:1:$L(CODE,"/") D
 . . . S PXDX=$P(CODE,"/",PXDXI)
 . . . S ICD=ICD+1,ROOT="PXAPI(""DX/PL"","_ICD_")"
 . . . S IEN=+$$CODEN^ICDCODE(PXDX,80) ;ICR #3990
 . . . S @ROOT@("DIAGNOSIS")=IEN
 . . . S @ROOT@("PRIMARY")=$S(PXDXI=1:$P(X,U,5),1:0)
 . . . S LEXIEN=$P($$EXP^LEXCODE(CODE,"ICD",DT),U),@ROOT@("LEXICON TERM")=$S(LEXIEN>0:LEXIEN,1:"")
 . . . S:$L(CAT) @ROOT@("CATEGORY")=CAT
 . . . S:$L(NARR) @ROOT@("NARRATIVE")=NARR
 . . . S:$P(X,U,6)>0 @ROOT@("ENC PROVIDER")=$P(X,U,6)
 . . . I $L($P(X,U,7)),($P(X,U,7)=1),(PXDXI=1) S @ROOT@("PL ADD")=$P(X,U,7),PROBLEMS(ICD)=NARR_U_CODE
 . . . S:$L($P(X,U,10))>0&(PXDXI=1) COMMENT($P(X,U,10))="DX/PL^"_ICD
 . . . I $E(TYP,4)="-" S @ROOT@("DELETE")=1
 . I $E(TYP,1,3)="IMM" D  Q
 . . ; If the CVX Code is present, then use it to find the corresponding Immunization,
 . . ; but only if the Immunization IEN is not specified
 . . S IMMCVX=$P(X,U,11)
 . . I CODE="",IMMCVX'="" S CODE=$$FIND1^DIC(9999999.14,,,IMMCVX,"C",,"IMMCVXER")
 . . Q:'$L(CODE)
 . . S IMM=IMM+1,ROOT="PXAPI(""IMMUNIZATION"","_IMM_")"
 . . S @ROOT@("IMMUN")=CODE
 . . S:$L($P(X,U,5)) @ROOT@("SERIES")=$P(X,U,5)
 . . S:$L($P(X,U,7)) @ROOT@("REACTION")=$P(X,U,7)
 . . S:$L($P(X,U,8)) @ROOT@("CONTRAINDICATED")=$P(X,U,8)
 . . S:$L($P(X,U,9)) @ROOT@("REFUSED")=$P(X,U,9)
 . . S:$P(X,U,6)>0 @ROOT@("ENC PROVIDER")=$P(X,U,6)
 . . S:$L($P(X,U,10))>0 COMMENT($P(X,U,10))="IMMUNIZATION^"_IMM
 . . ; These are the additional fields being added by PX*1.0*209
 . . S IMMISIEN=$$IMMSRC($P(X,U,12))
 . . S:IMMISIEN @ROOT@("INFO SOURCE")=IMMISIEN
 . . S IMMRTIEN=$$IMMROUTE($P(X,U,14))
 . . S:IMMRTIEN @ROOT@("ADMIN ROUTE")=IMMRTIEN
 . . S IMMALIEN=$$IMMLOC($P(X,U,15))
 . . S:IMMALIEN @ROOT@("ANATOMIC LOC")=IMMALIEN
 . . S IMMLOT=$$IMMLOT($P(X,U,16),$P(X,U,17),$P(X,U,18))
 . . S IMMLOTIEN=$P(IMMLOT,"^",1)
 . . S IMMCOMM=$P(IMMLOT,"^",2)
 . . S:IMMLOTIEN @ROOT@("LOT NUM")=IMMLOTIEN
 . . S IMMDSG=$$IMMDSG($P(X,U,13))
 . . I $P(IMMDSG,U,1)'="" D
 . . . S @ROOT@("DOSE")=$P(IMMDSG,U,1)
 . . . I $P(IMMDSG,U,2) S @ROOT@("DOSE UNITS")=$P(IMMDSG,U,2)
 . . I $P(IMMDSG,U,3)'="" D  ; add Dosage to comments
 . . . S IMMCOMM=$S($G(IMMCOMM)'="":IMMCOMM_"; ",1:"")_$P(IMMDSG,U,3)
 . . I IMMCOMM'="" D
 . . . ; If we have something to add to the Imm comment, either add it to the existing comment
 . . . ; (if one exists) or just set it in the COMMENT field.
 . . . I $L($P(X,U,10)) S IMMCOMMS($P(X,U,10))=IMMCOMM ; This will get added later to the existing comment
 . . . E  S @ROOT@("COMMENT")=IMMCOMM
 . . S:$P(X,U,19)>0 @ROOT@("EVENT D/T")=$P(X,U,19)
 . . S:$P(X,U,20)>0 @ROOT@("ORD PROVIDER")=$P(X,U,20)
 . . I $P(X,U,21)'="" D IMMVIS($P(X,U,21),ROOT)
 . . I $P(X,U,22)'="" D IMMRMRKS($P(X,U,22),IMM,.REMARK)
 . . I $E(TYP,4)="-" S @ROOT@("DELETE")=1
 . I $E(TYP,1,2)="SK" D  Q
 . . Q:'$L(CODE)
 . . S SK=SK+1,ROOT="PXAPI(""SKIN TEST"","_SK_")"
 . . S @ROOT@("TEST")=CODE
 . . S:$L($P(X,U,5)) @ROOT@("RESULT")=$P(X,U,5)
 . . S:$L($P(X,U,7)) @ROOT@("READING")=$P(X,U,7)
 . . S:$L($P(X,U,8)) @ROOT@("D/T READ")=$P(X,U,8)
 . . S:$L($P(X,U,9)) @ROOT@("EVENT D/T")=$P(X,U,9)
 . . S:$P(X,U,6)>0 @ROOT@("ENC PROVIDER")=$P(X,U,6)
 . . S:$L($P(X,U,10))>0 COMMENT($P(X,U,10))="SKIN TEST^"_SK
 . . I $E(TYP,3)="-" S @ROOT@("DELETE")=1
 . I $E(TYP,1,3)="PED" D  Q
 . . Q:'$L(CODE)
 . . S PED=PED+1,ROOT="PXAPI(""PATIENT ED"","_PED_")"
 . . S @ROOT@("TOPIC")=CODE
 . . S:$L($P(X,U,5)) @ROOT@("UNDERSTANDING")=$P(X,U,5)
 . . S:$P(X,U,6)>0 @ROOT@("ENC PROVIDER")=$P(X,U,6)
 . . S:$L($P(X,U,10))>0 COMMENT($P(X,U,10))="PATIENT ED^"_PED
 . . I $E(TYP,4)="-" S @ROOT@("DELETE")=1
 . I $E(TYP,1,2)="HF" D  Q
 . . Q:'$L(CODE)
 . . S HF=HF+1,ROOT="PXAPI(""HEALTH FACTOR"","_HF_")"
 . . S @ROOT@("HEALTH FACTOR")=CODE
 . . S:$L($P(X,U,5)) @ROOT@("LEVEL/SEVERITY")=$P(X,U,5)
 . . S:$P(X,U,6)'>0 $P(X,U,6)=$G(PXAPI("PROVIDER",1,"NAME"))
 . . S:$P(X,U,6)>0 @ROOT@("ENC PROVIDER")=$P(X,U,6)
 . . S:$L($P(X,U,11)) @ROOT@("EVENT D/T")=$P($P(X,U,11),";",1)
 . . S:$L($P(X,U,11)) SRC=$P($P(X,U,11),";",2)
 . . S:$L($P(X,U,10))>0 COMMENT($P(X,U,10))="HEALTH FACTOR^"_HF
 . . I $E(TYP,3)="-" S @ROOT@("DELETE")=1
 . I $E(TYP,1,3)="XAM" D  Q
 . . Q:'$L(CODE)
 . . S XAM=XAM+1,ROOT="PXAPI(""EXAM"","_XAM_")"
 . . S @ROOT@("EXAM")=CODE
 . . S:$L($P(X,U,5)) @ROOT@("RESULT")=$P(X,U,5)
 . . S:$P(X,U,6)>0 @ROOT@("ENC PROVIDER")=$P(X,U,6)
 . . S:$L($P(X,U,10))>0 COMMENT($P(X,U,10))="EXAM^"_XAM
 . . I $E(TYP,4)="-" S @ROOT@("DELETE")=1
 . I $E(TYP,1,3)="TRT" D  Q
 . . Q:'$L(CODE)
 . . S TRT=TRT+1,ROOT="PXAPI(""TREATMENT"","_TRT_")"
 . . S @ROOT@("IMMUN")=CODE
 . . S:$L(CAT) @ROOT@("CATEGORY")=CAT
 . . S:$L(NARR) @ROOT@("NARRATIVE")=NARR
 . . S:$L($P(X,U,5)) @ROOT@("QTY")=$P(X,U,5)
 . . S:$P(X,U,6)>0 @ROOT@("ENC PROVIDER")=$P(X,U,6)
 . . S:$L($P(X,U,10))>0 COMMENT($P(X,U,10))="TREATMENT^"_TRT
 . . I $E(TYP,4)="-" S @ROOT@("DELETE")=1,@ROOT@("QTY")=0
 . I $E(TYP,1,3)="COM" D  Q
 . . Q:'$L(CODE)
 . . Q:'$L(CAT)
 . . S COMMENTS(CODE)=$P(X,U,3,999)
 ;Store the comments
 S COM=""
 ;F  S COM=$O(COMMENT(COM)) Q:COM=""  S:$D(COMMENTS(COM)) PXAPI($P(COMMENT(COM),"^",1),$P(COMMENT(COM),"^",2),"COMMENT")=COMMENTS(COM)
 F  S COM=$O(COMMENT(COM)) Q:COM=""  D:$D(COMMENTS(COM))
 . I $G(IMMCOMMS(COM))'="" S COMMENTS(COM)=COMMENTS(COM)_$S(COMMENTS(COM)="":"",1:" ")_IMMCOMMS(COM)
 . S PXAPI($P(COMMENT(COM),"^",1),$P(COMMENT(COM),"^",2),"COMMENT")=COMMENTS(COM)
 ;
 ;Store the Remarks (currently used by immunizations) - PX,210
 S COM=""
 F  S COM=$O(REMARK(COM)) Q:COM=""  I $D(COMMENTS(COM)) D
 . S TYP=$P(REMARK(COM),"^",1)
 . S NUM=$P(REMARK(COM),"^",2)
 . S SEQ=$O(PXAPI(TYP,NUM,"REMARKS",""),-1)+1
 . S PXAPI(TYP,NUM,"REMARKS",SEQ,0)=COMMENTS(COM)
 ;
 S PXAPI("ENCOUNTER",1,"ENCOUNTER TYPE")="P"
DATA2PCE ;
 I '$D(PXAPI)#10 S OK=-3 Q
 I '($D(PXAVST)#2) S PXAVST=""
 S OK=$$DATA2PCE^PXAI("PXAPI",PKG,SRC,.PXAVST,"","",.ERROR,"","","")
 Q
 ;
IMMSRC(IMMIS) ; Returns Event Info Source IEN
 N IMMISHL,IMMISIEN,X
 S IMMISHL=$P(IMMIS,";",1)
 S IMMISIEN=$P(IMMIS,";",2)
 ; Look up the value in the "H" Cross-reference
 I 'IMMISIEN D
 . S IMMISIEN=$$FIND1^DIC(920.1,,,IMMISHL,"H",,"IMMISERR")
 Q IMMISIEN
 ;
IMMROUTE(IMMRT) ; Returns Route IEN
 N IMMRTHL,IMMRTIEN,IMMRTNM,X
 S IMMRTNM=$P(IMMRT,";",1)
 S IMMRTHL=$P(IMMRT,";",2)
 S IMMRTIEN=$P(IMMRT,";",3)
 I 'IMMRTIEN,IMMRTHL'="" D
 . S IMMRTIEN=$$FIND1^DIC(920.2,,,IMMRTHL,"H",,"IMMRTERR")
 I 'IMMRTIEN,IMMRTNM'="" D
 . S IMMRTIEN=$$FIND1^DIC(920.2,,,IMMRTNM,"B",,"IMMRTERR")
 Q IMMRTIEN
 ;
IMMLOC(IMMAL) ; Returns Anatomic Location IEN
 N IMMALHL,IMMALIEN,IMMALNM,X
 S IMMALNM=$P(IMMAL,";",1)
 S IMMALHL=$P(IMMAL,";",2)
 S IMMALIEN=$P(IMMAL,";",3)
 I 'IMMALIEN,IMMALHL'="" D
 . S IMMALIEN=$$FIND1^DIC(920.3,,,IMMALHL,"B",,"IMMALERR")
 I 'IMMALIEN,IMMALNM'="" D
 . S IMMALIEN=$$FIND1^DIC(920.3,,,IMMALNM,"B",,"IMMALERR")
 Q IMMALIEN
 ;
IMMLOT(IMMLOT,IMMMANUF,IMMEXPDT) ; Returns Lot_IEN^Comment
 N IMMCOMM,IMMLOTIEN,IMMLOTNM,X
 S IMMLOTNM=$P(IMMLOT,";",1)
 S IMMLOTIEN=$P(IMMLOT,";",2)
 ;
 I IMMLOTIEN Q IMMLOTIEN
 ;
 ; If the Lot Number, Manufacturer and Expiration Date are all specified,
 ; then find an entry matching all three values in File 9999999.41 (IMMUNIZATION LOT)
 ; If we don't find a match, then add the fields to the Comment.
 ; For now, we will not receive the Expiration Date from Walgreens, so we always update the Comment.
 S IMMCOMM=""
 S:IMMLOTNM'="" IMMCOMM=IMMCOMM_$S(IMMCOMM="":"",1:" ")_"Lot#: "_IMMLOTNM
 S:IMMMANUF'="" IMMCOMM=IMMCOMM_$S(IMMCOMM="":"",1:" ")_"Mfr: "_IMMMANUF
 S:IMMEXPDT'="" IMMCOMM=IMMCOMM_$S(IMMCOMM="":"",1:" ")_"Expiration Date: "_IMMEXPDT
 Q "^"_IMMCOMM
 ;
IMMVIS(IMMVISMULT,ROOT) ; Sets ROOT's VIS multiple
 N IMMVIS,IMMVISDT,IMMVISENTRY,PXSEQ,PXX,X
 S PXSEQ=0
 F PXX=1:1:$L(IMMVISMULT,";") D
 . S IMMVISENTRY=$$TRIM^XLFSTR($P(IMMVISMULT,";",PXX))
 . S IMMVIS=$P(IMMVISENTRY,"/",1)
 . I 'IMMVIS Q
 . S IMMVISDT=$P(IMMVISENTRY,"/",2)
 . I IMMVISDT S IMMVIS=IMMVIS_U_IMMVISDT
 . S PXSEQ=PXSEQ+1
 . S @ROOT@("VIS",PXSEQ,0)=IMMVIS
 Q
 ;
IMMRMRKS(IMMREMARKS,IMMNUM,REMARK) ; Sets REMARK array
 N PXEND,PXSTART,PXX,X
 S PXSTART=$P(IMMREMARKS,";",1)
 S PXEND=$P(IMMREMARKS,";",2)
 I ('PXSTART)!('PXEND)!(PXEND<PXSTART) Q
 F PXX=PXSTART:1:PXEND D
 . S REMARK(PXX)="IMMUNIZATION^"_IMMNUM
 Q
 ;
IMMDSG(IMMDSG) ;
 N IMMDOSE,IMMUNIT,IMMUNITIEN,IMMDOSEV,IMMUNERR,X
 S IMMDSG=$$TRIM^XLFSTR(IMMDSG)
 I IMMDSG="" Q ""
 S IMMDOSE=$P(IMMDSG,";",1)
 S IMMUNIT=$P(IMMDSG,";",2)
 S IMMUNITIEN=$P(IMMDSG,";",3)
 I IMMDSG[" ",IMMDSG'[";" D  ;Remove this DO block when VLER DAS starts using ";" between dose and units
 . S IMMDOSE=$P(IMMDSG," ",1)
 . S IMMUNIT=$P(IMMDSG," ",2)
 ;
 I IMMDOSE="" Q ""
 ;
 I IMMUNIT'="",'IMMUNITIEN D
 . N UCUMDATA
 . D UCUMDATA^LEXMUCUM(IMMUNIT,.UCUMDATA)
 . S IMMUNITIEN=$O(UCUMDATA(0))
 D CHK^DIE(9000010.11,1312,,IMMDOSE,.IMMDOSEV,"IMMUNERR")
 I IMMUNITIEN,IMMDOSEV'="^" Q IMMDOSEV_U_IMMUNITIEN
 ;
 Q U_U_"Dosage: "_IMMDOSE_" "_IMMUNIT
