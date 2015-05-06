BIXTCH ;IHS/CMI/MWR - XCALL TO TCH FORECASTER;2015-04-02  6:12 PM
 ;;8.5;IMMUNIZATION;**9**;OCT 01,2014
 ;;* MICHAEL REMILLARD, DDS * CIMARRON MEDICAL INFORMATICS, FOR IHS *
 ;;  XCALL TO TCH FOR FORCASTING IMMUNIZATIONS.
 ;;  Called from ^BIPATUP.
 ;;  PATCH 8: New routine to accommodate new TCH Forecaster   RUN+0
 ;;  PATCH 9: Add DUZ2 to retrieve IP address for call to TCH. RUN+0
 ;
SAMPLE ;
 ;---> Sample Cache Device handling code to interact with TCH Java Forecaster.
 ;---> 6708 is the TCH Forecaster default port (can change in the OS command).
 ; START CHANGES: VEN/SMH - *** NON PORTABLE *** USE ^%ZISTCP.
 ; O "|TCP|4":("127.0.0.1":6708::):10
 ; U "|TCP|4"
 ; W "Bonjour, Monsier le Monde",!
 ; U "|TCP|4" R X:1
 ; C "|TCP|4"
 ; U 0 W !,X
 N POP,X
 D CALL^%ZISTCP("127.0.0.1",6708,10)
 I $G(POP) W "I failed!!!" QUIT
 USE IO
 W "Bonjour, Monsier le Monde",$C(13,10),!
 R X:1
 D CLOSE^%ZISTCP
 W !,X
 QUIT
 ; END CHANGES: VEN/SMH
 ;
 ;
 ;********** PATCH 9, v8.5, OCT 01,2014, IHS/CMI/MWR
 ;---> Add DUZ2 so that BIXTCH can retrieve IP address for TCH.
 ;----------
RUN(BIHX,BIDUZ2,BIRPT,BIDATA,BIERR) ;EP
 ;---> Entry point for XCALL to Immserve Forecast Library.
 ;---> Patient's Immunization History is supplied; ImmServe Forecast
 ;---> is returned as text profile (BIRPT) and as data string (BIDATA).
 ;---> Parameters:
 ;     1 - BIHX   (req) String containing Patient's Immunization History.
 ;     2 - BIDUZ2 (req) User's DUZ(2) to indicate IP address for TCH.
 ;     3 - BIRPT  (ret) String returning text version of forcast.
 ;     4 - BIDATA (ret) String returning data version of forcast.
 ;     5 - BIERR  (ret) String returning text of error code.
 ;
 ;---> Quit if Patient IMM Hx not provided.
 I $G(BIHX)="" S (BIRPT,BIDATA,BIERR)=$$ERROR(999) Q
 ;
 ;---> Uncomment to see Patient History sent to TCH Forecaster.
 ; W !,"Full Input String: ",BIHX R ZZZ
 ;
 S BIERR="",BIRPT="",BIDATA=""
 S BIHX=BIHX_$C(10)
 N BIRESULT
 ;
 N $ET S $ET="GOTO ERRTRAP^BIXTCH"
 ;
 ;---> Preserve the current Device to return to after using TCP.
 N BIDEVICE S BIDEVICE=$IO
 ;
 ;---> Open TCP in Streaming Mode (to accommodate greater data length.).
 ;
 ;---> Get IP address for TCH Forecaster.
 I '$G(BIDUZ2) S (BIRPT,BIDATA,BIERR)=$$ERROR(124) Q
 N BIIP S BIIP=$$IPTCH^BIUTL8(BIDUZ2)
 I BIIP="" S (BIRPT,BIDATA,BIERR)=$$ERROR(125) Q
 ;
 ; VEN/SMH - REPLACE NON-PORTABLE CODE WITH PORTABLE CODE
 ;O "|TCP|4":("127.0.0.1":6708:"S":):3 ;## demo code!!!
 ;O "|TCP|4":(BIIP:6708:"S":):3
 ;**********
 ;
 ;U "|TCP|4"
 ;W BIHX,!
 ;U "|TCP|4" R BIRESULT:1
 ;C "|TCP|4"
 ;
 ; NB: From the Cache documentation regarding "S". In stream mode, Cach? does
 ; not attempt to preserve TCP message boundaries in the data stream. On
 ; sending, if the data does not fit in the message buffer, Cach? flushes the
 ; buffer before placing the data in it.
 ;
 ; In of CONT^%ZISTCP, "S" mode is set with send/rec buffers of 512 bytes
 ;
 ; ZEXCEPT: BISIMERRTRAP - from the Unit Tester
 N POP
 D CALL^%ZISTCP(BIIP,6708,3)
 I $G(POP) S $EC=",U-TCH-TCP-CXN-FAIL,"  ; Invoke the error trap
 I $D(BISIMERRTRAP) S $EC=",U-SIMULATED-ERROR," ; for our unit tests 
 U IO ; Use TCP device
 W BIHX,$C(13,10),! ; TCH Listener seems to use CR/LF as a delimiter.
 R BIRESULT:1
 D CLOSE^%ZISTCP
 ;---> Return to using previous Device.
 U BIDEVICE
 ;
 ;---> For Testing, uncomment next line to see the raw data returned from TCH:
 ; W !,$L(BIRESULT) R ZZZ
 ; W !!!,"Result directly back from forecaster (in BIXTCH): ",!,BIRESULT,!! R ZZZ
 ;
 S BIERR=$P(BIRESULT,"&&&",1)
 I BIERR]"" S (BIRPT,BIDATA,BIERR)=BIERR Q
 ;I BIERR]"" S (BIRPT,BIDATA,BIERR)=$$ERROR^BIXTCH(BIERR) Q
 S BIDATA=$P(BIRESULT,"&&&",2)
 S BIRPT=$P(BIRESULT,"&&&",3)
 S:BIERR=0 BIERR=""
 ;
 Q
 ;
 ;
 ;----------
ERROR(BIERRNUM) ;EP
 ;---> Return text of error, based on number passed.
 ;---> Parameters:
 ;     1 - BIERRNUM (req) Numeric value of error.
 ;
 Q "BIXTCH Error: "_$$ERRMSG(BIERRNUM)
 ;
 ;
 ;----------
ERRMSG(X) ;EP
 ;---> Error messages.
 Q:X=1 "1;Some cases could not be processed."
 Q "99999;Unknown error"
 ;
 ;
 ;----------
ERRTRAP ;EP
 ; ZEXCEPT: BIERR from above
 ; Emergency Trap: (Replace newed trap; don't create another one)
 S $ET="D ^%ZTER HALT"
 ;
 D ERRCD^BIUTL2(123,.BIERR)
 D CLOSE^%ZISTCP ; close just in case the error happened when are still comm
 ;
 S $EC=""  ; clear error
 ; no need in this code to unwind the stack since there is only a single stack
 ; level
 QUIT
 ;
 ;----------
 ;
 ; 
TEST D EN^%ut($T(+0),1) QUIT  ; ---> vide https://github.com/joelivey/M-Unit
 ;
 ; Expected Results:
 ; FOIA 2015-02>D TEST^BIXTCH
 ;
 ; T1 - Run the sample data in the TCH Technical Manual.------------------  [OK]
 ; T2 - Force an error to test the M error trap.--------------------------  [OK]
 ;
 ;
T1 ; @TEST Run the sample data in the TCH Technical Manual
 ; ---> vide http://www.ihs.gov/RPMS/PackageDocs/BI/TCH%20Forecaster%20Installation%20Instructions.pdf
 N RPT,DATA,ERR
 N S S S="20140424^0^0^0^0^TEST,PAIIENT  Chart#: 00-00-31^31^19830215^Male^U^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^~~~3484^03^20140414^0^0^0|||"
 D RUN(S,DUZ(2),.RPT,.DATA,.ERR)
 D CHKTF^%ut($L($G(RPT)),"No data was obtained")
 QUIT
 ;
T2 ; @TEST Force an error to test the M error trap
 N BISIMERRTRAP S BISIMERRTRAP=1
 N RPT,DATA,ERR
 N S S S="20140424^0^0^0^0^TEST,PATIENT  Chart#: 00-00-31^31^19830215^Male^U^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^~~~3484^03^20140414^0^0^0|||"
 D RUN(S,DUZ(2),.RPT,.DATA,.ERR)
 D CHKTF^%ut($L($G(ERR)),"An error was expected")
 QUIT
 ;
T3 ; [Private; Standalone] Regular test of error trap. See what happens to us
 ; ---> This entry point is just for the developer's use. Really!!!
 ; ---> We are checking that we exit at the right stack level. In this case,
 ; ---> we need to just see that the error message is printed on the screen.
 ; ---> This way we know that we just poped the stack correctly. If we didn't
 ; ---> the stack will keep poping and we won't see the ERR message
 D
 . N BISIMERRTRAP S BISIMERRTRAP=1
 . N RPT,DATA,ERR
 . N S S S="20140424^0^0^0^0^TEST,PATIENT  Chart#: 00-00-31^31^19830215^Male^U^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^~~~3484^03^20140414^0^0^0|||"
 . D RUN(S,DUZ(2),.RPT,.DATA,.ERR)
 . W ERR,!
 QUIT
