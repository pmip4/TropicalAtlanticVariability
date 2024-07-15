load "cvdp_data.functions.ncl"

plot_regions=(/(/-20,20/),(/-70,30/)/);lat and lons of the edge of the plots

;some plot switches
INSOL_EXPTS=False
MAKE_PLOT=True;if True, this will actually output the plot in it's pretty form
OUTPUT_PLOT_DATA=False;if True, this will actually output the combined
if MAKE_PLOT.eq.OUTPUT_PLOT_DATA then 
   print("You set both MAKE_PLOT and OUTPUT_PLOT_DATA to "+MAKE_PLOT+". The code is not set-up for both options to be True, and will do all")
   print("The code is not set-up for both options to be True, and will do all computation and not output anythign is both are False")
   exit
end if
OUTPUT_TYPE="png"; either "png" or "pdf"
VERBOSE=False ;if True, provides a modicum of more information about whats goign on in the plots - used for debugging mainly.
OVERLAY_PREIND=True
ENSEMBLE="PMIP4";choose which ensemble to use: options are "PMIP4","PMIP3" or "BOTH"

;First deal with the data outputting (uses default plotting and creates lots of maps) 
if OUTPUT_PLOT_DATA then
  expts=(/"midHolocene-cal-adj","lig127k-cal-adj","midPliocene-eoi400","abrupt4xCO2"/)
  vars=(/"atl3_pr_regression_mon","atl3_pattern_mon"/)
  vars@ensemble=ENSEMBLE
  OPTS=True
  OPTS@filetype=OUTPUT_TYPE
  OPTS@VERBOSE=VERBOSE
  do expt_i=0,dimsizes(expts)-1
    do var_i=0,2
        title="summary_data/"+expts(expt_i)+"-piControl_"+vars(var_i)+"_EnsembleMean"
        plot_output_DiffEnsMn(expts(expt_i),"piControl",vars(var_i),title,OPTS)
    end do
  end do
end if

;Otherwise actually make the plot
if MAKE_PLOT then
  vars=(/"atl3_pattern_mon","atl3_pr_regression_mon"/)
  vars@ensemble=ENSEMBLE
  if INSOL_EXPTS then
    expts=(/"midHolocene-cal-adj","lig127k-cal-adj"/) ;experiments to plot
    expt_str="_orbit"
  else
    expts=(/"midPliocene-eoi400","abrupt4xCO2"/) ;experiments to plot
    expt_str="_pliofuture"
  end if
  plot_str="plots/atl3_change_maps"+expt_str


  opt=True
    opt@CONSISTENCY=True
    opt@OVERLAY_CONTROL=OVERLAY_PREIND
    opt@OVERLAY_CONTROL_MANUALLEVS=(/-1.,1.,0.2/)
    opt@mpProjection="CylindricalEqualArea"
    opt@mpLimitMode="LatLon"
    opt@lbLabelBarOn=False
    opt@mpMinLonF=plot_regions(1,0)
    opt@mpMaxLonF=plot_regions(1,1)
    opt@mpMinLatF=plot_regions(0,0)
    opt@mpMaxLatF=plot_regions(0,1)
    opt@gsnCenterString=""
    opt@gsnRightString=""
    opt@lbTitleFontHeightF=0.016
    opt@lbLabelFontHeightF=0.016
    opt@gsnStringFontHeightF=0.04
    opt@gsnCenterString=""  
    opt@tiMainString=""
    opt@gsnFrame=False

  opt_pan=True
    opt_pan@lbTitleFontHeightF=0.01
    opt_pan@lbLabelFontHeightF=0.016
    opt_pan@gsnFrame=False
    opt_pan@gsnPanelLabelBar=True

  wks=gsn_open_wks(OUTPUT_TYPE,plot_str)
  wks@VERBOSE=VERBOSE

  ;Start with the first experiment: 
  expt_i=0
  if VERBOSE then
    print("Working on "+expts(expt_i))
  end if
  opt_pan@gsnPanelTop=0.85
  opt_pan@gsnPanelBottom=0.6
  opt_pan@gsnPanelLabelBar=False
  ;plot atl3 patterns
  opt_pan@gsnPanelLeft=0.1      
  opt_pan@gsnPanelRight=0.5
  opt@cnFillPalette="BlueDarkRed18"
  opt@cnMissingValFillColor = "grey" ; color missing values rather than just land.
  opt@cnMissingValFillPattern = "SolidFill"
  opt@mpLandFillColor="gainsboro"
  opt@gsnLeftString="a"  
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=2*(/-0.1,-0.08,-0.06,-0.04,-.02,0.02,.04,0.06,0.08,.1/)
  plotDiffEnsMnMaps(expts(expt_i),"piControl",vars(0),wks,opt,opt_pan)
  delete([/opt@cnLevels,opt@mpLandFillColor/])
  ;plot atl3 rainfall 
  opt@gsnLeftString="b"
  opt@cnFillPalette="CBR_drywet"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-0.5,-0.3,-0.1,-0.05,0.05,0.1,0.3,0.5/)
  opt_pan@lbLabelFontHeightF=0.016
  opt_pan@gsnPanelRight=0.9
  opt_pan@gsnPanelLeft=0.5      
  plotDiffEnsMnMaps(expts(expt_i),"piControl",vars(1),wks,opt,opt_pan)
  delete(opt@cnLevels)

  ;Move onto the second experiment:
  expt_i=1
  if VERBOSE then
    print("Working on "+expts(expt_i))
  end if
  opt_pan@gsnPanelTop=0.6
  opt_pan@gsnPanelBottom=0.3
  opt_pan@gsnPanelLabelBar=True
  ;plot atl3 patterns
  opt_pan@gsnPanelLeft=0.1      
  opt_pan@gsnPanelRight=0.5
  opt@cnFillPalette="BlueDarkRed18"
  opt@cnMissingValFillColor = "grey" ; color missing values rather than just land.
  opt@cnMissingValFillPattern = "SolidFill"
  opt@mpLandFillColor="gainsboro"
  opt@gsnLeftString="c"  
  opt_pan@lbTitleString="Change in AZM SST (~F35~J~F21~C/~F35~J~F21~C)"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=2*(/-0.1,-0.08,-0.06,-0.04,-.02,0.02,.04,0.06,0.08,.1/)
  plotDiffEnsMnMaps(expts(expt_i),"piControl",vars(0),wks,opt,opt_pan)
  delete([/opt@cnLevels,opt@mpLandFillColor/])
  ;plot atl3 rainfall 
  opt@gsnLeftString="d"
  opt@cnFillPalette="CBR_drywet"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-0.5,-0.3,-0.1,-0.05,0.05,0.1,0.3,0.5/)
  opt_pan@lbLabelFontHeightF=0.016
  opt_pan@gsnPanelRight=0.9
  opt_pan@gsnPanelLeft=0.5      
  opt_pan@lbTitleString="Change in AZM rainfall (mm/day/~F35~J~F21~C)"
  plotDiffEnsMnMaps(expts(expt_i),"piControl",vars(1),wks,opt,opt_pan)
  delete(opt@cnLevels)


  frame(wks)
  delete(wks)

  ;trim white space with convert if png
  if OUTPUT_TYPE.eq."png" then
    system("convert "+plot_str+"."+OUTPUT_TYPE+" -trim output.png")
    system("mv output.png "+plot_str+"."+OUTPUT_TYPE)
  end if 
end if

