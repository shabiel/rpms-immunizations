PXVBIVD ;VEN/SMH - Elements to disable from IHS port;05/08/2015
 ;;1.0;VISTA IMMUNIZATIONS;
 ;
 ; ---> Don't Run on RPMS!!!
 QUIT:$$RPMS^BIUTL9()
 ;
 ; ---> Options in the Site Manager menu BI MENU-MANAGER
 D OUT^XPDMENU("BI NDC ADD/EDIT","Not used in VISTA")    ; NDC Code Add/Edit
 D OUT^XPDMENU("BI VACCINE TABLE RESTAND","Not used in VISTA") ; Restandardize Vaccine Table
 D OUT^XPDMENU("BI VACCINE TABLE EDIT","Not used in VISTA") ; Vaccine Table Edit
 D OUT^XPDMENU("BI EXPORT VACCINE TABLE","Won't port. Not imporant") ; Export Vaccine Table to Excel File
 ;
 N % S %=$$DELETE^XPDMENU("BI MENU-MANAGER","BI NDC ADD/EDIT")
 N % S %=$$DELETE^XPDMENU("BI MENU-MANAGER","BI VACCINE TABLE RESTAND")
 N % S %=$$DELETE^XPDMENU("BI MENU-MANAGER","BI VACCINE TABLE EDIT")
 N % S %=$$DELETE^XPDMENU("BI MENU-MANAGER","BI EXPORT VACCINE TABLE")
 QUIT
