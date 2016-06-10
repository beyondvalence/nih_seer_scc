
libname datapath 'C:\REB\SEER_SCC\Data\SAS\' ;
libname xptfile xport 'C:\REB\SEER_SCC\Data\SAS\scc_counts_system.xpt' ;

proc copy in = xptfile out = datapath ;

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
quit ;
