# What's missing?
I tried as much as possible in what ended up being about 160 hours alloted
time. This means that I had to omit some items that were in my opinion
tangential to the project or they may be important but I couldn't finish
everything and do them as well. 

All of the menu options in RPMS have been ported except for:
 * BI NDC ADD/EDIT -> VISTA NDCs are added via the NDF patches
 * BI VACCINE TABLE RESTAND -> VISTA Imm table is standardized via MFS
 * BI VACCINE TABLE EDIT -> Ditto
 * BI EXPORT VACCINE TABLE -> Not of any importance

For reference, here's the entire menu system from RPMS:

	PAT    Patient Menu ... [BI MENU-PATIENT]
	   SGL    Single Patient Record [BI PATIENT VIEW/EDIT]
	   LET    Print Individual Patient Letter [BI PATIENT LETTER INDIVIDUAL]
	   LLS    Patient Lists and Letters [BI PATIENT LISTS & LETTERS]


	REP    Reports Menu ... [BI MENU-REPORTS]
	   ADO    Adolescent Report [BI REPORT ADOLESCENT IMMS]
	   ADL    Adult Report [BI REPORT ADULT IMMS]
	   ELI    Eligibility Report [BI REPORT ELIGIBILITY]
	   FLU    Influenza Report [BI REPORT FLU]
	   H1     H1N1 Accountability Report [BI REPORT H1N1 ACCOUNTABILITY]
	   PCV    PCV Report [BI REPORT PCV]
	   QTR    3-27 Month Report [BI REPORT QUARTERLY IMM]
	   TWO    Two-Yr-Old Rates Report [BI REPORT TWO-YR RATES]
	   VAC    Vaccine Accountability Report [BI REPORT VAC ACCOUNTABILITY]
	   

	MGR    Manager Menu ... [BI MENU-MANAGER]
	   ERR    Edit Patient Errors [BI PATIENT ERRORS]
	   CMG    Add/Edit Case Manager [BI CASE MANAGER ADD/EDIT]
	   CMT    Transfer a Case Manager's Patients [BI CASE MANAGER TRANSFER]
	   SCN    Scan For Patients [BI PATIENTS SCAN]
			  ------------------------------ [BI LINE FOR MENUS]
	   ESP    Site Parameters Edit [BI SITE PARAMETERS EDIT]
	   LET    Form Letters Add/Edit [BI LETTER EDIT]
	   LOT    Lot Number Add/Edit [BI LOT NUMBER ADD/EDIT]
	   VAC    Vaccine Table Edit [BI VACCINE TABLE EDIT]
	   ELI    Eligibility Table Edit [BI ELIGIBILITY TABLE EDIT]
	   RES    Restandardize Vaccine Table [BI VACCINE TABLE RESTAND]
	   EXP    Export Immunizations [BI EXPORT IMMUNIZATIONS]
	   KEY    Allocate/Deallocate Imm Menu Keys [BI KEYS ALLOCATE]
	   NDC    NDC Code Add/Edit [BI NDC ADD/EDIT]
	   XVT    Export Vaccine Table to Excel File [BI EXPORT VACCINE TABLE]

Here's a list of the items not completed.

 * Site parameters for Pneumovax forecasting has a section on forecasting 
   differently for Smokers. I can't do that in VISTA because there is nothing
   in VISTA that mirrors the health factor in RPMS. VISTA has tons and tons of
   various indicators, and the only way to do this properly is to evaluate a 
   reminder that the VA released (or maybe not yet) that evaluates a lot of
   criteria. Code is in `RISKP^BISITE4`.
 * Recording the NDC for a lot number in VISTA. This is not hard. You need to 
   make a new NDC field that points to 50.67 rather than the RPMS file for NDC.
 * BILOT expiration date sort doesn't work
 * The BIERR global, containing messages, should go into the DIALOG file. I
   started with a couple of items doing just that, but gave up since it is of
   peripheral clinical utility.
 * On the main Patient Enter/Edit form, if the forecaster is disabled, it's
   considered an error. I disabled that. But the TODO here is that in the form,
   in the imms due section, it should say "forecaster disabled".
 * BI PATIENT ERRORS and BI PATIENTS SCAN menu options in the manager menu have
   not been ported.
 * Off the main BI PATIENT VIEW/EDIT, the patient contraindications Listman
   form is not wide enough to accommodate vaccine names since VISTA does not
   have short vaccine names for all vaccines.
 * On the main form, I hid the patient's designated provider in VISTA. It's
   possible to get the designated provider team in VISTA from PCMM, but I
   didn't want to go down that road.
 * Relating to vaccine groups: When forecasting, the forecast sometimes does
   not show up in the main form because it relies on vaccine groups, and
   vaccine groups are not populated in the file in VISTA. To fix
   this: Series type not found (= OTHER), change FORECASTING to ON.
  
   VACCINE GROUP (SERIES TYPE): OTHER      DISPLAY ORDER: 90
   SHORT NAME: OTHER                     FORECASTING ON/OFF: ON
   AVAILABLE ON FORECASTNG MENU: NO      INCLUDE IN TWO-YR-OLD REPORT: NO

 * I ran out of time to do Skin Test filing.
 * Because of the properties of the `DATA2PCE^PXAPI` API, you cannot edit the
   actual immunization name in a V Immunization after it has been initially
   filed, otherwise it creates a new immunization. Therefore, this field needs 
   to be make uneditable in VISTA. Deleting the V Imm is okay.
 * In VISTA, Admin Date should be Admin Date/Time. It's intended to capture the
   time as well.
 * Adding multiple visits on the same day using the silent API is not possible.
   Whichever visit is entered first wins.
 * Lots get subtracted twice, once in code; and once in new index in VISTA. And
   it goes beyond zero to negative.
 * VIS entry needs to be filtered by immunization.
 * The following reports have not been ported:

	   ADO    Adolescent Report [BI REPORT ADOLESCENT IMMS]
	   FLU    Influenza Report [BI REPORT FLU]
	   H1     H1N1 Accountability Report [BI REPORT H1N1 ACCOUNTABILITY]
	   PCV    PCV Report [BI REPORT PCV]
	   QTR    3-27 Month Report [BI REPORT QUARTERLY IMM]
	   TWO    Two-Yr-Old Rates Report [BI REPORT TWO-YR RATES]
	   VAC    Vaccine Accountability Report [BI REPORT VAC ACCOUNTABILITY]
