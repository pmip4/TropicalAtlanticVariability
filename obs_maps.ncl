;This script was used to create sufficient figures to populate a research publication
;It makes full use of the programs in cvdp_data.functions.ncl to plot figures solely from the output data of cvdp (without needing recomputation).
;The code it set up to look at the Indian Ocean Dipole.
; It makes 1 table (showing simulations used) and many figures. 

;load the NCL functions from Zhao et al (2021; https://doi.org/10.5194/gmd-15-2475-2022)
; These functions are lots of plotting and searching functions. They are hardwired to look for the data in data/
load "cvdp_data.functions.ncl"

mode_name="atl3";variable in the file
plot_regions=(/(/-20,20/),(/-70,30/)/);lat and lons of the edge of the plots (/(/latS,latN/),(/lonW,lonE/)/)

expts=(/"piControl","historical","midHolocene-cal-adj","lgm-cal-adj","lig127k-cal-adj","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey24","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)

;some plot switches
MAKE_MEAN_PLOT=True;if True, this will actually output the plot in it's pretty form
MAKE_ATL3_PLOT=False;if True, this will actually output the plot in it's pretty form
if MAKE_MEAN_PLOT.eq.MAKE_ATL3_PLOT then 
   print("You set both MAKE_MEAN_PLOT and MAKE_ATL3_PLOT to "+MAKE_MEAN_PLOT+". The code is not set-up for both options to be the same")
   exit
end if
OUTPUT_TYPE="pdf"; either "png" or "pdf"
TS_NOT_TAS=True ;if True use SST rather TAS in the figure
ENSEMBLE="PMIP4";choose which ensemble to use: options are "PMIP4","PMIP3" or "BOTH"
BIAS_not_ABSOLUTE=False ;if True this will plot the ensemble mean bias - rather than the ensemble property 
VERBOSE=False ;if True, provides a modicum of more information about whats goign on in the plots - used for debugging mainly.
USE_HIST_not_PREIND=False; adds the preindustrial to all the plots including the Historical 
if USE_HIST_not_PREIND then
  expt="historical"
else
  expt="piControl"
end if
if MAKE_MEAN_PLOT then
  paper_str="plots/obs_maps_mean_"
else
  paper_str="plots/obs_maps_atl3_"
end if


  ; Set-up some initial NCL plot options ;
  opt=True
    opt@mpProjection="CylindricalEqualArea"
    opt@gsnStringFontHeightF=0.03
    opt@lbLabelFontHeightF=0.018
    opt@mpLimitMode="LatLon"
    opt@mpMinLonF=plot_regions(1,0)
    opt@mpMaxLonF=plot_regions(1,1)
    opt@mpMinLatF=plot_regions(0,0)
    opt@mpMaxLatF=plot_regions(0,1)
    opt@cnLevelSelectionMode = "ManualLevels"   
    opt@tiMainString=""
    opt@gsnCenterString=""
    opt@cnMissingValFillColor = "grey" ; color missing values rather than just land.
    opt@cnMissingValFillPattern = "SolidFill"
  opt_pan=True
    opt_pan@lbTitleFontHeightF=0.02
    opt_pan@lbLabelFontHeightF=0.016
    opt_pan@gsnFrame=False
    opt_pan@gsnMaximize=False

  if BIAS_not_ABSOLUTE then 
    opt@lbLabelBarOn=True
    opt@lbTitlePosition="Bottom"
    opt_pan@gsnPanelLabelBar=False
    opt@lbTitleOn=True
  else
    opt@lbLabelBarOn=False
    opt@gsnRightString=""
    opt_pan@dims=(/1,2/)
  end if

  ;Rather than immediately sending the plot to a file, this plot first opens a wks and panels within it. 
if MAKE_MEAN_PLOT then
  if BIAS_not_ABSOLUTE then
    wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"bias_"+ENSEMBLE)
  else
    wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"absolute_"+ENSEMBLE)
  end if
  wks@VERBOSE=VERBOSE

  ;Start with the mean temperature
  t_opt=opt
  if TS_NOT_TAS then
    t_opt@cnMinLevelValF       = 15
    t_opt@cnMaxLevelValF       = 30
    field=(/"sst_spatialmean_djf","sst_spatialmean_jja"/)
    if ENSEMBLE.ne."BOTH" then 
      field@ensemble=ENSEMBLE
    end if
  else
    t_opt@cnMinLevelValF       = 10
    t_opt@cnMaxLevelValF       = 35
    field=(/"tas_spatialmean_djf","tas_spatialmean_jja"/)
    if ENSEMBLE.ne."BOTH" then 
      field@ensemble=ENSEMBLE
    end if
  end if
  t_opt@cnLevelSpacingF = 1
  t_opt@cnFillPalette="WhiteBlueGreenYellowRed"
  t_opt_pan=opt_pan
  t_opt_pan@lbOrientation="Vertical"
  t_opt_pan@lbTitlePosition="Left"
  t_opt_pan@lbTitleDirection     = "Across"                          ; letter angle
  t_opt_pan@lbTitleAngleF        = 90.                               ; title angle
  t_opt_pan@lbTitleFontHeightF   = 0.02                              ; font height
  t_opt_pan@gsnPanelLabelBar=True
  t_opt_pan@lbTitleOn=True
  t_opt_pan@lbLabelFontHeightF=0.018
  t_opt_pan@gsnPanelBottom=0.5
  if BIAS_not_ABSOLUTE then 
    t_opt_pan@gsnPanelLeft=0.
    t_opt_pan@gsnPanelRight=0.5
    t_opt@gsnLeftString=(/"a","b"/)
    t_opt@lbTitleString="Temperature (~F35~J~F21~C)"
    plotCVDPcomparisonMaps("C20-Reanalysis",field,wks,t_opt,t_opt_pan)
    t_opt@cnFillPalette="CBR_coldhot"
    t_opt@cnLevelSelectionMode = "ExplicitLevels"   
    t_opt@cnLevels=(/-5.,-3.,-2.,-1.,-0.5,0.5,1.,2.,3.,5./)
    t_opt@lbTitleString="Temperature Difference (~F35~J~F21~C)"
    t_opt@gsnLeftString=(/"c","d"/)
    t_opt@CONSISTENCY=True ;Turn on Stippling
    t_opt_pan@gsnPanelLeft=0.5
    t_opt_pan@gsnPanelRight=1.
    plotDiffEnsMnMaps(expt,"C20-Reanalysis",field,wks,t_opt,t_opt_pan)
  else
    t_opt_pan@dims=(/2,2/)
    t_opt@gsnLeftString=(/"a","b","c","d"/)
    t_opt@lbTitleString="SST (~F35~J~F21~C)"
    plotCVDPcomparisonMaps((/"C20-Reanalysis",expt/),field,wks,t_opt,t_opt_pan)
  end if

  ;Move onto mean precipitation
  pr_field=(/"pr_spatialmean_djf","pr_spatialmean_jja"/)
  if ENSEMBLE.ne."BOTH" then 
    pr_field@ensemble=ENSEMBLE
  end if
  p_opt=opt
  p_opt@cnMinLevelValF       = 0
  p_opt@cnMaxLevelValF       = 10
  p_opt@cnLevelSpacingF = 1.
  p_opt@cnFillPalette="CBR_wet"
  p_opt_pan=opt_pan
  p_opt_pan@gsnPanelTop=0.5
  p_opt_pan@gsnPanelBottom=0.
  p_opt_pan@lbOrientation="Vertical"
  p_opt_pan@lbTitlePosition="Left"
  p_opt_pan@lbTitleDirection     = "Across"                          ; letter angle
  p_opt_pan@lbTitleAngleF        = 90.                               ; title angle
  p_opt_pan@lbTitleFontHeightF   = 0.02                              ; font height
  p_opt_pan@gsnPanelLabelBar=True
  p_opt_pan@lbTitleOn=True
  p_opt_pan@lbLabelFontHeightF=0.018

  if BIAS_not_ABSOLUTE then 
    p_opt_pan@gsnPanelLeft=0.
    p_opt_pan@gsnPanelRight=0.5
    p_opt@gsnLeftString=(/"c"/)
    p_opt@lbTitleString="Precipitation (mm/day)"
    plotCVDPcomparisonMaps("C20-Reanalysis",pr_field,wks,p_opt,p_opt_pan)
    p_opt@cnFillPalette="CBR_drywet"
    p_opt@cnLevelSelectionMode = "ExplicitLevels"   
    p_opt@cnLevels=(/-5.,-2.,-1.,-0.5,-0.1,0.1,0.5,1.,2.,5./)
    p_opt@lbTitleString="Precipitation Difference (mm/day)"
    p_opt@gsnLeftString=(/"d"/)
    p_opt@CONSISTENCY=True ;Turn on Stippling
    p_opt_pan@gsnPanelLeft=0.5
    p_opt_pan@gsnPanelRight=1.
    plotDiffEnsMnMaps(expt,"C20-Reanalysis",pr_field,wks,p_opt,p_opt_pan)
  else
    p_opt_pan@dims=(/2,2/)
    p_opt@gsnLeftString=(/"a","b","c","d"/)
    p_opt@lbTitleString="(mm/day)"
    plotCVDPcomparisonMaps((/"C20-Reanalysis",expt/),pr_field,wks,p_opt,p_opt_pan)
  end if
end if; MAKE_PLOT

if MAKE_ATL3_PLOT then
  atl3_sst_field=(/"atl3_pattern_mon"/)
  atl3_pr_field=(/"atl3_pr_regression_mon"/)
  if ENSEMBLE.ne."BOTH" then 
    atl3_sst_field@ensemble=ENSEMBLE
    atl3_pr_field@ensemble=ENSEMBLE
  end if

  if BIAS_not_ABSOLUTE then
    wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"bias_"+ENSEMBLE)
  else
    wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"absolute_"+ENSEMBLE)
  end if
  wks@VERBOSE=VERBOSE
  ;Move onto ATL3 temperatures
  i_opt=opt
  i_opt@cnMinLevelValF = -1.
  i_opt@cnMaxLevelValF = 1
  i_opt@cnLevelSpacingF = 0.2
  i_opt@cnFillPalette="CBR_coldhot"
  i_opt_pan=opt_pan
  i_opt_pan@gsnPanelTop=1.
  i_opt_pan@gsnPanelBottom=0.5
  if BIAS_not_ABSOLUTE then 
    i_opt_pan@gsnPanelLeft=0.
    i_opt_pan@gsnPanelRight=0.5
    i_opt@gsnLeftString=(/"a"/)
    i_opt@lbTitleString="SST Regressed onto ATL3 (~F35~J~F21~C/~F35~J~F21~C)"
    plotCVDPcomparisonMaps("C20-Reanalysis",atl3_sst_field,wks,i_opt,i_opt_pan)
    i_opt@cnMinLevelValF = -0.2
    i_opt@cnMaxLevelValF = 0.2
    i_opt@cnLevelSpacingF = 0.04
    i_opt@lbTitleString="Bias in pattern (~F35~J~F21~C/~F35~J~F21~C)"
    i_opt@gsnLeftString=(/"b"/)
    i_opt@CONSISTENCY=True ;Turn on Stippling
    i_opt_pan@gsnPanelLeft=0.5
    i_opt_pan@gsnPanelRight=1.
    plotDiffEnsMnMaps(expt,"C20-Reanalysis",atl3_sst_field,wks,i_opt,i_opt_pan)
  else
    i_opt@gsnLeftString=(/"a","b"/)
    i_opt_pan@lbTitleString="SST Regressed onto ATL3 (~F35~J~F21~C/~F35~J~F21~C)"
    plotCVDPcomparisonMaps((/"C20-Reanalysis",expt/),atl3_sst_field,wks,i_opt,i_opt_pan)
  end if

  ;Move onto ATL3 rainfall
  ip_opt=opt
  ip_opt@cnFillPalette="CBR_drywet"
  ip_opt@cnLevelSelectionMode = "ExplicitLevels"   
  ip_opt@cnLevels=(/-2.,-1.,-0.5,-0.2,-0.1,0.1,0.2,0.5,1.,2./)
  ip_opt_pan=opt_pan
  ip_opt_pan@gsnPanelTop=0.5
  ip_opt_pan@gsnPanelBottom=0.0
  if BIAS_not_ABSOLUTE then 
    ip_opt_pan@gsnPanelLeft=0.
    ip_opt_pan@gsnPanelRight=0.5
    ip_opt@gsnLeftString=(/"c"/)
    ip_opt@lbTitleString="Precip. regression (mm/day/~F35~J~F21~C)"
    plotCVDPcomparisonMaps("C20-Reanalysis",atl3_pr_field,wks,ip_opt,ip_opt_pan)
    delete(ip_opt@cnLevels)
    ip_opt@cnLevels=(/-0.5,-0.3,-0.1,-0.05,0.05,0.1,0.3,0.5/)
    ip_opt@lbTitleString="Bias in pattern (mm/day/~F35~J~F21~C)"
    ip_opt@gsnLeftString=(/"d"/)
    ip_opt@CONSISTENCY=True ;Turn on Stippling
    ip_opt_pan@gsnPanelLeft=0.5
    ip_opt_pan@gsnPanelRight=1.
    plotDiffEnsMnMaps(expt,"C20-Reanalysis",atl3_pr_field,wks,ip_opt,ip_opt_pan)
  else
    ip_opt@gsnLeftString=(/"c","d"/)
    ip_opt_pan@lbTitleString="Precip. regression (mm/day/~F35~J~F21~C)"
    plotCVDPcomparisonMaps((/"C20-Reanalysis",expt/),atl3_pr_field,wks,ip_opt,ip_opt_pan)
  end if
  frame(wks)
  delete(wks)
end if; MAKE_PLOT  
