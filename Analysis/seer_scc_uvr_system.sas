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

libname seerpath 'C:\REB\SEER_SCC\Data\SAS\';

data scc_sys_uvr;
	set seerpath.scc_county_counts_system_uvr;
run;



proc glimmix data=scc_sys_uvr ;
class   registry  Agecat male year_dx racen ;
  model resp_non=  qyear305 Agecat male year_dx/ CL solution offset = lnpop dist=poisson;
  random int / subject = registry;
where  racen=1 ;
run;



proc glimmix data=working1 ;
class     registry        Agecat male dxyr5 racen ;
  model CountCALCL =  qyear305 Agecat male dxyr5 racen qyear305*racen/ solution offset = lnpop dist=poisson;
  *random int / subject = registry;
  where racen>1;
TITLE Race interaction, continuous UV;
run;


quit ;
