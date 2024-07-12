;This script was used to create sufficient figures to populate a research publication
;It makes full use of the programs in cvdp_data.functions.ncl to plot figures solely from the output data of cvdp (without needing recomputation).
;The code it set up to look at the Indian Ocean Dipole.
; It makes 1 table (showing simulations used) and many figures. 

;load some functions (first 4 get loaded automatically on newer versions of NCL
load "cvdp_data.functions.ncl"

mode_name="atl3";variable in the file

expts=(/"piControl","midHolocene-cal-adj","lig127k-cal-adj","midPliocene-eoi400","abrupt4xCO2"/)
expts_color=(/"grey24","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)
gcms_all=(/"ACCESS-ESM1-5","AWI-ESM-1-1-LR","BCC-CSM1-1","CCSM4","CESM2","CNRM-CM5","CNRM-CM6-1","COSMOS-ASO","CSIRO-Mk3-6-0","CSIRO-Mk3L-1-2","EC-EARTH-2-2","EC-Earth3-LR","FGOALS-f3-L","FGOALS-g2","FGOALS-g3","FGOALS-s2","GISS-E2-1-G","GISS-E2-R","HadGEM2-CC","HadGEM2-ES","HadGEM3-GC31-LL","INM-CM4-8","IPSL-CM5A-LR","IPSL-CM6A-LR","KCM1-2-2","MIROC-ES2L","MIROC-ESM","MPI-ESM1-2-LR","MPI-ESM-P","MRI-CGCM3","MRI-ESM2-0","NESM3","NorESM1-F","NorESM2-LM","UofT-CCSM-4"/)
gcms_CMIP6=(/"ACCESS-ESM1-5","AWI-ESM-1-1-LR","CESM2","CNRM-CM6-1","EC-Earth3-LR","FGOALS-f3-L","FGOALS-g3","GISS-E2-1-G","HadGEM3-GC31-LL","INM-CM4-8","IPSL-CM6A-LR","MIROC-ES2L","MPI-ESM1-2-LR","MRI-ESM2-0","NESM3","NorESM2-LM"/)
gcms_CMIP6_subset=(/"ACCESS-ESM1-5","AWI-ESM-1-1-LR","CNRM-CM6-1","EC-Earth3-LR","FGOALS-f3-L","FGOALS-g3","GISS-E2-1-G","INM-CM4-8","IPSL-CM6A-LR","MIROC-ES2L","MPI-ESM1-2-LR","MRI-ESM2-0","NESM3","NorESM2-LM"/) ;ECS Screen v. likely from Hausfather et al (2022)

;some plot switches
PRINT_TABLE=True ;if True, create a table (in LaTeX format) showing the simulations used 
GCM_DICTIONARY=False; if True, will not print model names, but alphabetic look up from table
PRINT_OUT_CSV=True

;;;;;;;;;;;
;;Process the GCM choices
;;;;;

paper_str="summary_data/models"
if GCM_DICTIONARY then
  gcm_dict=createGCMsNameDictionary(expts,mode_name+"_timeseries_mon")
else
  gcm_dict=False
end if
plot_letters=(/(/"a","b"/),(/"c","d"/),(/"e","f"/),(/"g","h"/),(/"i","j"/),(/"k","l"/)/)

if PRINT_TABLE then
  if PRINT_OUT_CSV then
    createTableGCMsExptsYears(expts,mode_name+"_timeseries_mon",gcm_dict,"csv",paper_str+"_table.csv")
  else
    createTableGCMsExptsYears(expts,mode_name+"_timeseries_mon",gcm_dict,"tex",paper_str+"_table.tex")
  end if
end if ;PRINT_TABLE
