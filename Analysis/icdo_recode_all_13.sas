******************************************************;
** SEER SCC UVR 									**;
** created Friday June 10, 2016						**;
**													**;
******************************************************;

libname datapath 'C:\REB\SEER_SCC\Data\SAS\' ;

/*libname xptfile xport 'C:\REB\SEER_SCC\Data\SAS\icdo_recode_all_13.xpt' ;

proc copy in = xptfile out = datapath ;*/

proc format library = work ;
    value RACEL
           1 = 'White'
           2 = 'Hispanic'
           3 = 'Black' ;

    value REGISTRY
           1 = 'WA'
           2 = 'MI'
           3 = 'CT'
           4 = 'IA'
           5 = 'NJ'
           6 = 'KY'
           7 = 'SanFrancisco-Oakland'
           8 = 'UT'
           9 = 'Atlanta'
          10 = 'GreaterCA'
          11 = 'SanJose-Monterey'
          12 = 'RuralGA'
          13 = 'GreaterGA'
          14 = 'LA'
          15 = 'Los Angeles'
          16 = 'NM' ;

    value AGECATL
           1 = '0-44'
           2 = '45-64'
           3 = '65+' ;
run;

/*  variable names:
county year_dx agecat racen
year305 qyear305 registry male
all_scc all_non pop lnpop
	
resp_scc resp_non
	resp_nose_scc resp_nose_non resp_larynx_scc resp_larynx_non resp_lung_scc resp_lung_non	
	resp_pleura_scc resp_pleura_non resp_trachea_scc resp_trachea_non
	
oral_scc oral_non
	oral_lip_scc oral_lip_non oral_tongue_scc oral_tongue_non oral_salivary_scc oral_salivary_non 
	oral_floor_scc oral_floor_non oral_gum_scc oral_gum_non oral_nasopharynx_scc oral_nasopharynx_non
	oral_tonsil_scc oral_tonsil_non oral_oropharynx_scc oral_oropharynx_non 
	oral_hypopharynx_scc oral_hypopharynx_non oral_other_scc oral_other_non
	
fema_scc fema_non
	fema_cervix_scc fema_cervix_non fema_corpusUterusNOS_scc fema_corpusUterusNOS_non 
	fema_corpusUteri_scc fema_corpusUteri_non fema_ovary_scc fema_ovary_non 
	fema_vagina_scc fema_vagina_non fema_vulva_scc fema_vulva_non
	
dige_scc dige_non
	dige_esophagus_scc dige_esophagus_non dige_stomach_scc dige_stomach_non dige_colonRectum_scc dige_colonRectum_non 
	dige_rectumJunc_scc dige_rectumJunc_non dige_rectum_scc dige_rectum_non dige_anus_scc dige_anus_non
	dige_gallbladder_scc dige_gallbladder_non dige_pancreas_scc dige_pancreas_non
	
misc_scc misc_non
	
male_scc male_non
	male_penis_scc male_penis_non male_other_scc male_other_non
	
urin_scc urin_non
	urin_bladder_scc urin_bladder_non urin_kidney_scc urin_kidney_non urin_other_scc urin_other_non
	
eye_scc eye_non
	
brea_scc brea_non
	
endo_scc endo_non
	endo_thyroid_scc endo_thyroid_non endo_other_scc endo_other_non
	
soft_scc soft_non
	
bone_scc bone_non
*/

data scc_13;
	set datapath.icdo_recode_all_13;
run;

proc glimmix data=scc_13;
class   registry qyear305 agecat male year_dx ;
  model all_scc=  qyear305 Agecat male year_dx / CL solution offset = lnpop dist=poisson;
  random int / subject = registry;
where  racen=1 ;
run;

proc glimmix data=scc_13 ;
class     registry        Agecat male dxyr5 racen ;
  model CountCALCL =  qyear305 Agecat male dxyr5 racen qyear305*racen/ solution offset = lnpop dist=poisson;
  *random int / subject = registry;
  where racen>1;
TITLE Race interaction, continuous UV;

run;

quit ;
