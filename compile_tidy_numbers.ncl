;This script cycles through all the files in a "data" directory and calculates the standard devations of the timeseries and their correlations/regressions

;History:
; 1. It was originally used to create the supplementary table for Brierley & Wainer (2018) - although that was then tidied up in Excel to make it presentable
; 2. It was then modified to output amplitude of EOF-based modes, as well as index-based ones. The output of this script was then plotted as Fig 3 in Rehfeld et al (2020,Earth Sys. Dynam.)
; 3. Now it's being overwritten to provide some tables as inputs for my PMIP4_past2future_analyzer repo

; run with:
; ncl -n data_scripts/mk_mode_tables.ncl

load "cvdp_data.functions.ncl"

data_dir="data/"

files=systemfunc("ls "+data_dir+"PMIP3/*.nc "+data_dir+"PMIP4/*.nc")
files = str_sub_str(files, data_dir, "")

;define the filename for the outputting
fname="summary_data/tidy_numbers.csv"
system("rm -f "+fname)

; loop over the various CVDP files
do fi = 0, dimsizes(files)-1
  print("Working on "+files(fi))
  ;set up what to look over
  variables=new(50, string)
  headers=new(50, string)
  headers(0)="generation"
  headers(1)="model"
  headers(2)="experiment"
  headers(3)="years"
  dir_parts = str_split(files(fi),"/")
  variables(0)=dir_parts(0) ;generation
  name_parts = str_split(dir_parts(1),".")
  name_strs0 = str_split(name_parts(0),"_")
  name_strs2 = str_split(name_parts(2),"-")
  variables(1)=name_strs0(0) ;model
  if dimsizes(name_strs0).eq.1 then
    variables(2)="observations" ;experiment
  else
    variables(2)=name_strs0(1) ;experiment
  end if
  variables(3)=toint(name_strs2(1))-toint(name_strs2(0))+1 ;years

  ts_opt=True
  ts_opt@NO_EXIT_ON_ERROR=True
  if any(variables(2).eq.(/"1pctCO2","abrupt4xCO2","rcp26","rcp85"/)) then
    ts_opt@subset=True
    ts_opt@subset_syear=-30
    ts_opt@subset_eyear=0
    ts_opt@DETREND=True
  end if

  ;Global Mean TAS
  headers(4)="GMTemp"
  fil=addfile(data_dir+files(fi),"r")
  if .not.isfilevar(fil,"tas_spatialmean_ann") then
    variables(4)=variables@_FillValue
  else
    variables(4)=extract_latlon_areastat(data_dir+files(fi),"tas_spatialmean_ann",(/-90.,90./),(/0.,360./),"mean")
  end if


  ;IOD mean gradient
  ts_opt_abs=ts_opt
  ts_opt_abs@make_absolute=True
  ts_opt_abs@DETREND=False
  headers(5)="ATL3 mean"
  variables(5)=stat_ts_var(data_dir+files(fi),"atl3_timeseries_mon","mean",ts_opt_abs)

  ;IOD Amplitude
  headers(6)="ATL3 stddev"
  variables(6)=stat_ts_var(data_dir+files(fi),"atl3_timeseries_mon","stddev",ts_opt)

  ;Nino3.4 Amplitude
  headers(7)="Nino34 stddev"
  variables(7)=stat_ts_var(data_dir+files(fi),"nino34","stddev",ts_opt)

  ;atlantic_nino mean
  headers(8)="AtlNino mean"
  variables(8)=stat_ts_var(data_dir+files(fi),"atlantic_nino","mean",ts_opt_abs)

  ;atlantic_nino Mode
  headers(9)="AtlNino stddev"
  variables(9)=stat_ts_var(data_dir+files(fi),"atlantic_nino","stddev",ts_opt)

  ;atlantic_nino Annual Cycle
  headers(10)="AtlNino AnnCycAmp"
  variables(10)=stat_ts_var(data_dir+files(fi),"atlantic_nino","AnnCycAmp",ts_opt)

  ;Atlantic Meridional Mode
  headers(11)="AMM mean"
  variables(11)=stat_ts_var(data_dir+files(fi),"atlantic_meridional_mode","mean",ts_opt_abs)

  ;Atlantic Meridional Mode
  headers(12)="AMM stddev"
  variables(12)=stat_ts_var(data_dir+files(fi),"atlantic_meridional_mode","stddev",ts_opt)

  ;AMM Annual Cycle
  headers(13)="AMM AnnCycAmp"
  variables(13)=stat_ts_var(data_dir+files(fi),"atlantic_meridional_mode","AnnCycAmp",ts_opt)

  ;South Asian Monsoon Area
  headers(14)="SAMSmonsoon area mean"
  variables(14)=stat_ts_var(data_dir+files(fi),"monsoon_area_SAMS","mean",ts_opt)

  ;South Asian Monsoon Rainrate
  headers(15)="SAMSmonsoon rain mean"
  variables(15)=stat_ts_var(data_dir+files(fi),"monsoon_rain_SAMS","mean",ts_opt)

  ;South Asian Monsoon Area
  headers(16)="SAMSmonsoon area stddev"
  variables(16)=stat_ts_var(data_dir+files(fi),"monsoon_area_SAMS","stddev",ts_opt)

  ;South Asian Monsoon Rainrate
  headers(17)="SAMSmonsoon rain stddev"
  variables(17)=stat_ts_var(data_dir+files(fi),"monsoon_rain_SAMS","stddev",ts_opt)

  ;NE Brazil annual rain
  if isfilevar(fil,"ipcc_NEB_pr") then
    NEB_pr_name="ipcc_NEB_pr"
  else
    NEB_pr_name="ipcc_NES_pr"
  end if
  delete(fil)
  headers(18)="NEB rain ann"
  variables(18)=stat_ts_var(data_dir+files(fi),NEB_pr_name,"mean",ts_opt_abs)

  ;NE Brazil summer rain
  ts_opt_jja_abs=ts_opt_abs
  ts_opt_jja_abs@SEASON="JJA"
  headers(19)="NEB rain jja"
  variables(19)=stat_ts_var(data_dir+files(fi),NEB_pr_name,"mean",ts_opt_jja_abs)

  ;NE Brazil winter rain
  ts_opt_djf_abs=ts_opt_abs
  ts_opt_djf_abs@SEASON="DJF"
  headers(20)="NEB rain djf"
  variables(20)=stat_ts_var(data_dir+files(fi),NEB_pr_name,"mean",ts_opt_djf_abs)

  ;NE Brazil summer rain stddev
  ts_opt_jja=ts_opt
  ts_opt_jja@SEASON="JJA"
  headers(21)="NEB rain jja stddev"
  variables(21)=stat_ts_var(data_dir+files(fi),NEB_pr_name,"stddev",ts_opt_jja)

  ;NE Brazil winter rain stddev
  ts_opt_djf=ts_opt
  ts_opt_djf@SEASON="DJF"
  headers(22)="NEB rain djf stddev"
  variables(22)=stat_ts_var(data_dir+files(fi),NEB_pr_name,"stddev",ts_opt_djf)

  ;compute correlations
  ts_opt_smooth=ts_opt
  ts_opt_smooth@SMOOTH=True
  ts_opt_smooth@nave=5
  nino34=read_ts(data_dir+files(fi),"nino34",ts_opt_smooth)
  atl3=read_ts(data_dir+files(fi),"atlantic_nino",ts_opt_smooth) 
  amo=read_ts(data_dir+files(fi),"amo_timeseries_lowpass_mon",ts_opt_smooth)

  headers(23)="r(atl3.nino34)"
  if (.not.all(ismissing(nino34))).and.(.not.all(ismissing(atl3))) then
    variables(23)=escorc(nino34,atl3)   
  else
    variables(23)=variables@_FillValue   
  end if

  headers(24)="r(atl3.amo)"
  if (.not.all(ismissing(amo))).and.(.not.all(ismissing(atl3))) then
    variables(24)=escorc(amo,atl3)   
  else
    variables(24)=variables@_FillValue   
  end if  
  delete([/nino34,atl3,amo/])
  

  ;ATL3 Period
  headers(25)="ATL3 Period"
  variables(25)=stat_ts_var(data_dir+files(fi),"atlantic_nino","dominant_period_interann",ts_opt)

  ;ENSO Period
  headers(26)="ENSO Period"
  variables(26)=stat_ts_var(data_dir+files(fi),"nino34","dominant_period_interann",ts_opt)
 
  ;IOD Period
  headers(27)="AMM Period"
  variables(27)=stat_ts_var(data_dir+files(fi),"atlantic_meridional_mode","dominant_period_interann",ts_opt)

  headers(28)="ATL3-sst-interann-stdev"
  fil=addfile(data_dir+files(fi),"r")
  if .not.isfilevar(fil,"sst_spatialstddev_ann") then
    variables(28)=variables@_FillValue
  else
    variables(28)=extract_latlon_areastat(data_dir+files(fi),"sst_spatialstddev_ann",(/-3.,3./),(/-20.,0./),"mean")
  end if

  headers(29)="ATL3-pr-interann-stdev"
  fil=addfile(data_dir+files(fi),"r")
  if .not.isfilevar(fil,"pr_spatialstddev_ann") then
    variables(29)=variables@_FillValue
  else
    variables(29)=extract_latlon_areastat(data_dir+files(fi),"pr_spatialstddev_ann",(/-3.,3./),(/-20.,0./),"mean")
  end if

  headers(30)="ATL3-sst-interjja-stdev"
  fil=addfile(data_dir+files(fi),"r")
  if .not.isfilevar(fil,"sst_spatialstddev_jja") then
    variables(30)=variables@_FillValue
  else
    variables(30)=extract_latlon_areastat(data_dir+files(fi),"sst_spatialstddev_jja",(/-3.,3./),(/-20.,0./),"mean")
  end if

  headers(31)="ATL3-pr-interjja-stdev"
  fil=addfile(data_dir+files(fi),"r")
  if .not.isfilevar(fil,"pr_spatialstddev_jja") then
    variables(31)=variables@_FillValue
  else
    variables(31)=extract_latlon_areastat(data_dir+files(fi),"pr_spatialstddev_jja",(/-3.,3./),(/-20.,0./),"mean")
  end if

  ;write out to file
  exists=ind(.not.ismissing(headers))
  if fi.eq.0 then
    hlist=[/str_join(headers(exists),",")/]
    write_table(fname, "w", hlist, "%s")
  end if 
  vlist=[/str_join(variables(exists),",")/]
  write_table(fname, "a", vlist, "%s")

  delete([/headers,variables,ts_opt,ts_opt_abs,ts_opt_jja,ts_opt_djf,ts_opt_jja_abs,ts_opt_djf_abs,ts_opt_smooth/])
end do