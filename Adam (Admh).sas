               /*LIBRARY DEFINATION*/

LIBNAME ADAMRAW '/home/u62043545/NEWDATA';

    /*DERIVING 4 VARIABLES FROM SUPPLIMENTARY MEDICAL HISTORY(SDTM LEVEL) DATASET*/

DATA  VARS1;
    SET ADAMRAW.SUPPMH;
    DOMAIN="ADMH";
    MHSEQ=INPUT(IDVARVAL,BEST.);
    IF UPCASE(QNAM)="MHCLSIG" THEN MHCLSIG=QVAL;
    KEEP DOMAIN MHSEQ MHCLSIG USUBJID;
RUN;

    /*DERIVING ASTDY, AENDY, ASTDT, AND AENDT */

DATA VARS2;
    LENGTH STUDYID $12.;
    SET ADAMRAW.MH;

    ASTDY=MHSTDY;
    AENDY=MHENDY;

    IF LENGTH(MHSTDTC)=4 THEN DO;
       ASTDTC=CATX('-',MHSTDTC,'01','01');
       ASTDTF='M';
END;

    IF LENGTH(MHSTDTC)=7 THEN DO;
       ASTDTC=CATX('-',MHSTDTC,'01');
       ASTDTF='D';
END; 

    IF LENGTH(MHSTDTC)=10 THEN DO;
       ASTDTC=MHSTDTC;
       ASTDTF='';
END; 

    IF LENGTH(ASTDTC)=10 THEN ASTDT=INPUT(ASTDTC,YYMMDD10.);
    IF LENGTH(MHENDTC)=10 THEN DO;
       AENDT=INPUT(MHENDTC,YYMMDD10.);
       AENDTF='';
END;

    FORMAT ASTDT AENDT DATE9.;
    DROP EPOCH DOMAIN MHSTDY MHENDY AENDTF ASTDTC ASTDTF;
RUN;

       /*DERIVING VARIABLES FROM ADSL DATASET WITHOUT MAJOR DEVIATIONS*/

DATA VARS3;
    SET ADAMRAW.ADSL;
    TRTP=TRT01P;
    TRTPN=TRT01PN;
    TRTA=TRT01A;
    TRTAN=TRT01AN;
    STUDYID='XXX-YYY-103';
    USUBJID=CATX('-',STUDYID,SITEID,SUBJID);

    KEEP USUBJID TRTP TRTPN TRTA TRTAN STUDYID SUBJID RFSTDTC SITEID AGE SEX
         RACE ETHNIC ENRLFL SCRNFL COMPLFL SAFFL SCRFL DCSREAS DCSREASP TRTSDT
         TRTSTM TRTSDTM TRTEDT TRTETM TRTEDTM COHORT COHORTN DOSE DTHDT DTHFL EOSDT
         SUBDISP TRT01P TRT01PN TRT01A TRT01AN ;
RUN;

                   /*MERGING ALL THE DATASETS*/

PROC SORT DATA=VARS1 ;
    BY USUBJID MHSEQ;
RUN;

PROC SORT DATA=VARS2 ;
    BY USUBJID MHSEQ;
RUN;

DATA COMB;
    MERGE VARS1 VARS2;
    BY USUBJID MHSEQ;
RUN;

PROC SORT DATA=COMB ;
    BY USUBJID;
RUN;

PROC SORT DATA=VARS3 ;
    BY USUBJID;
RUN;

DATA COMBA;
    MERGE COMB (IN=A) VARS3 (IN=B);
    BY USUBJID;
    IF A;
RUN;

            /*CREATING MACRO FOR ALL REQUIRED VARIABLES*/

%LET RVARS=STUDYID USUBJID DOMAIN SUBJID RFSTDTC SITEID AGE SEX RACE ETHNIC
ENRLFL SCRNFL COMPLFL SAFFL SCRFL DCSREAS DCSREASP TRT01P TRT01PN TRT01A TRT01AN 
TRTSDT TRTSTM TRTSDTM TRTEDT TRTETM TRTEDTM COHORT COHORTN DOSE DTHDT DTHFL EOSDT 
SUBDISP MHSEQ MHTERM MHLLT MHLLTCD MHDECOD MHPTCD MHHLT MHHLTCD MHHLGT MHHLGTCD MHCAT
MHBODSYS MHBDSYCD MHSOC MHSOCCD MHSTDTC MHENDTC MHENRF MHCLSIG ASTDT AENDT ASTDY AENDY 
TRTP TRTPN TRTA TRTAN;

                             /*FINAL STEP*/

DATA ADMH (KEEP=&RVARS);
    RETAIN &RVARS;
    SET COMBA;
    LABEL STUDYID='Study Identifier'        
    USUBJID='Unique Subject Identifier'
    SUBJID='Subject Identifier for the Study'
    RFSTDTC='Subject Reference Start Date/Time'
    SITEID='Study Site Identifier' 
    AGE='Age'     SEX='Sex'   RACE='Race'    ETHNIC='Ethnicity'
    ENRLFL='Enrolled Flag'                  
    SCRNFL='Screen Failure Flag'
    COMPLFL='Completers Population Flag'    
    SAFFL='Safety Population Flag' 
    SCRFL='Screened Population Flag'       
    DCSREAS='Reason for Discontinuation from Study'
    DCSREASP='Reason Spec for Discont from Study'
    TRT01P='Planned Treatment for Period 01'
    TRT01PN='Planned Treatment for Period 01 (N)'
    TRT01A='Actual Treatment for Period 01'
    TRT01AN='Actual Treatment for Period 01 (N)'
    TRTSDT='Date of First Exposure to Treatment'
    TRTSTM='Time of First Exposure to Treatment'
    TRTSDTM='Datetime of First Exposure to Treatment'
    TRTEDT='Date of Last Exposure to Treatment'
    TRTETM='Time of Last Exposure to Treatment'
    TRTEDTM='Datetime of Last Exposure to Treatment'    
    COHORT='Cohort'
    COHORTN='Cohort (N)'      
    DOSE='Dose'   DTHDT='Date of Death'
    DTHFL='Subject Death Flag'            
    EOSDT='End of Study Date'
    SUBDISP='Subject Id/Age/Gender/Race'   
    DOMAIN='Domain Abbreviation'
    MHSEQ='Sequence Number'               
    MHTERM='Reported Term for the Medical History'
    MHLLT='Lowest Level Term'             
    MHLLTCD='Lowest Level Term Code'
    MHDECOD='Dictionary-Derived Term'     
    MHPTCD='Preferred Term Code'
    MHHLT='High Level Term'               
    MHHLTCD='High Level Term Code'
    MHHLGT='High Level Group Term'         
    MHHLGTCD='High Level Group Term Code'
    MHCAT='Category for Medical History' 
    MHBODSYS='Body System or Organ Class'
    MHBDSYCD='Body System or Organ Class Code' 
    MHSOC='Primary System Organ Class'
    MHSOCCD='Primary System Organ Class Code'
    MHSTDTC='Start Date/Time of Medical History Event'
    MHENDTC='End Date/Time of Medical History Event'
    MHENRF='End Relative to Reference Period'
    MHCLSIG='Clinically Significant'
    ASTDT='Analysis Start Date'
    AENDT='Analysis End Date'
    ASTDY='Analysis Start Relative Day' 
    AENDY='Analysis End Relative Day'
    TRTP='Planned Treatment' 
    TRTPN='Planned Treatment (N)'
    TRTA='Actual Treatment'
    TRTAN='Actual Treatment (N)';
run;

/**************************************************************************************/
