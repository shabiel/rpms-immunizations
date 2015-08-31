PXVP210 ;BPOIFO/LMT - PX*1*210 KIDS Routine ;07/15/15  13:34
 ;;1.0;PCE PATIENT CARE ENCOUNTER;**210**;Aug 12, 1996
 ;
 ; Reference to ^PXRMINDX(9000010.11) supported by ICR #4290
 ; Reference to BLDINDEX^PXRMSXRM supported by ICR #6210
 ; Reference to INDEXD^PXRMDIEV supported by ICR #6059
 ;
 Q
 ;
POST ; KIDS Post install for PX*1*210
 D BMES("*** Post install started ***")
 ;
 D CVIMMXR ; Update ACR cross-reference on V IMMUNIZATION file
 D CIMMXR ; Create ACR cross-reference on IMMUNIZATION file
 D BLDVIMM ; Rebuild Clinical Reminder index on V Immunization file
 D DDSEC ; Update DD security on Immunization and Skin Test files
 ;
 D BMES("*** Post install completed ***")
 Q
 ;
CVIMMXR ; Update ACR cross-reference on V IMMUNIZATION file
 N PXERR,PXXR,PXRES
 ;
 D BMES("*** Updating ACR cross-reference on V IMMUNIZATION file ***")
 ;
 S PXXR("FILE")=9000010.11
 S PXXR("NAME")="ACR"
 S PXXR("TYPE")="MU"
 S PXXR("USE")="A"
 S PXXR("EXECUTION")="R"
 S PXXR("ACTIVITY")="IR"
 S PXXR("SHORT DESCR")="Clinical Reminders index."
 S PXXR("DESCR",1)="This cross-reference builds four indexes, two for finding all patients"
 S PXXR("DESCR",2)="with a particular immunization and two for finding all the immunizations a"
 S PXXR("DESCR",3)="patient has. "
 S PXXR("DESCR",4)="The indexes are stored in the Clinical Reminders index global as:"
 S PXXR("DESCR",5)="^PXRMINDX(9000010.11,""IP"",IMMUNIZATION,DFN,DATE,DAS)"
 S PXXR("DESCR",6)="^PXRMINDX(9000010.11,""CVX"",""IP"",CVX CODE,DFN,DATE,DAS) "
 S PXXR("DESCR",7)="and"
 S PXXR("DESCR",8)="^PXRMINDX(9000010.11,""PI"",DFN,IMMUNIZATION,DATE,DAS) "
 S PXXR("DESCR",9)="^PXRMINDX(9000010.11,""CVX"",""PI"",DFN,CVX CODE,DATE,DAS) "
 S PXXR("DESCR",10)="respectively. "
 S PXXR("DESCR",11)="For all the details, see the Clinical Reminders Index Technical"
 S PXXR("DESCR",12)="Guide/Programmer's Manual."
 S PXXR("SET")="D SVFILE^PXPXRM(9000010.11,.X,.DA)"
 S PXXR("KILL")="D KVFILE^PXPXRM(9000010.11,.X,.DA)"
 S PXXR("WHOLE KILL")="K ^PXRMINDX(9000010.11)"
 S PXXR("VAL",1)=.01
 S PXXR("VAL",1,"SUBSCRIPT")=1
 S PXXR("VAL",1,"COLLATION")="F"
 S PXXR("VAL",2)=.02
 S PXXR("VAL",2,"SUBSCRIPT")=2
 S PXXR("VAL",2,"COLLATION")="F"
 S PXXR("VAL",3)=.03
 S PXXR("VAL",3,"SUBSCRIPT")=3
 S PXXR("VAL",3,"COLLATION")="F"
 S PXXR("VAL",4)=1201
 S PXXR("VAL",4,"COLLATION")="F"
 D CREIXN^DDMOD(.PXXR,"K",.PXRES,,"PXERR")
 I $G(PXRES) D
 . D MES("Cross-reference "_$P(PXRES,U,2)_" (#"_$P(PXRES,U,1)_") was updated successfully.")
 I $G(PXRES)="" D
 . D MES("*** ERROR: Failed to update cross-reference. ***")
 Q
 ;
CIMMXR ; Create ACR cross-reference on IMMUNIZATION file
 N PXERR,PXXR,PXRES
 ;
 D BMES("*** Creating ACR cross-reference on IMMUNIZATION file ***")
 ;
 S PXXR("FILE")=9999999.14
 S PXXR("NAME")="ACR"
 S PXXR("TYPE")="MU"
 S PXXR("USE")="A"
 S PXXR("EXECUTION")="R"
 S PXXR("SHORT DESCR")="Updates Clinical Reminder's index when CVX code changes."
 S PXXR("DESCR",1)="This cross-reference updates the Clinical Reminder's index on the V"
 S PXXR("DESCR",2)="Immunization file when a CVX code changes for an immunization. The indexes"
 S PXXR("DESCR",3)="updated are:"
 S PXXR("DESCR",4)="^PXRMINDX(9000010.11,""CVX"",""IP"",CVX CODE,DFN,DATE,DAS) and"
 S PXXR("DESCR",5)="^PXRMINDX(9000010.11,""CVX"",""PI"",DFN,CVX CODE,DATE,DAS)."
 S PXXR("SET")="Q"
 S PXXR("KILL")="D UPDCVX^PXPXRM(.DA,X1(1),X2(1))"
 S PXXR("VAL",1)=.03
 S PXXR("VAL",1,"COLLATION")="F"
 D CREIXN^DDMOD(.PXXR,"K",.PXRES,,"PXERR")
 I $G(PXRES) D
 . D MES("Cross-reference "_$P(PXRES,U,2)_" (#"_$P(PXRES,U,1)_") was created successfully.")
 I $G(PXRES)="" D
 . D MES("*** ERROR: Failed to create cross-reference. ***")
 Q
 ;
BLDVIMM ; Rebuild Clinical Reminder index on V Immunization file
 N PXDESC,PXFILELIST,PXQDT,PXRTN,PXTASK,PXVOTH
 N ZTCPU,ZTDESC,ZTDTH,ZTIO,ZTKIL,ZTPRI,ZTRTN,ZTSAVE,ZTSK,ZTSYNC,ZTUCI
 ;
 D BMES("*** Task job to rebuild the Clinical Reminders index for V IMMUNIZATION ***")
 ;
 I $D(^PXRMINDX(9000010.11,"CVX")) D  Q  ;IA 4290
 . D MES("The index has already been rebuilt by previous installation.")
 . D MES("No need to rebuild it again.")
 ;
 S PXQDT=$G(XPDQUES("POS1"))
 I 'PXQDT S PXQDT=$$NOW^XLFDT
 ;
 I $T(BLDINDEX^PXRMSXRM)'="" D
 . S PXFILELIST(9000010.11)=""
 . S PXTASK=$$BLDINDEX^PXRMSXRM(.PXFILELIST,PXQDT) ;TODO: subscribe to ICR 6210
 I $T(BLDINDEX^PXRMSXRM)="" D
 . S PXRTN="BLDVIMMT^PXVP210"
 . S PXDESC="Clinical Reminders index rebuild for V IMMUNIZATION"
 . S PXVOTH("ZTDTH")=PXQDT
 . S PXTASK=$$NODEV^XUTMDEVQ(PXRTN,PXDESC,,.PXVOTH)
 ;
 I $G(PXTASK)>0 D MES("Task number "_PXTASK_" queued.")
 I $G(PXTASK)=-1 D  Q
 . D MES("*** ERROR: Task failed to queue ***")
 Q
 ;
BLDVIMMT ; Queued entry point to rebuild index
 S ZTREQ="@"
 D VIMM^PXPXRMI1
 D INDEXD^PXRMDIEV(9000010.11) ; IA 6059 ;TODO: subscribe to ICR 6059
 Q
 ;
DDSEC ; Update security access codes on Immunization and Skin Test files
 N PXFILENUM,PXSEC
 ;
 D BMES("*** Updating security access codes on Immunization and Skin Test files ***")
 ;
 S PXSEC("AUDIT")="@"
 S PXSEC("DD")="@"
 S PXSEC("DEL")="@"
 S PXSEC("LAYGO")="@"
 S PXSEC("RD")=""
 S PXSEC("WR")="@"
 ;
 F PXFILENUM=9999999.14,9999999.28 D
 . D FILESEC^DDMOD(PXFILENUM,.PXSEC)
 Q
 ;
BMES(STR) ;
 ; Write string
 D BMES^XPDUTL($$TRIM^XLFSTR($$CJ^XLFSTR(STR,$G(IOM,80)),"R"," "))
 Q
MES(STR) ;
 ; Write string
 D MES^XPDUTL($$TRIM^XLFSTR($$CJ^XLFSTR(STR,$G(IOM,80)),"R"," "))
 Q
