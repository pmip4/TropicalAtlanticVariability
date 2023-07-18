load "cvdp_data.functions.ncl"

plot_regions=(/(/-20,20/),(/-70,30/)/);lat and lons of the edge of the plots
expts=(/"midHolocene-cal-adj","lig127k-cal-adj","lgm-cal-adj","abrupt4xCO2"/)

;some plot switches
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

expts=(/"midHolocene-cal-adj","lig127k-cal-adj","lgm-cal-adj","abrupt4xCO2"/)
plot_str="plots/atl3_change_maps"
plot_letters=(/(/"a","b"/),(/"c","d"/),(/"e","f"/),(/"g","h"/),(/"i","j"/),(/"k","l"/)/)

;First deal with the data outputting (uses default plotting and creates lots of maps) 
if OUTPUT_PLOT_DATA then
  vars=(/"atl3_pr_regression_mon","atl3_pattern_mon"/)
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

if MAKE_PLOT then
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

  do expt_i=0,dimsizes(expts)-1
    if VERBOSE then
      print("Working on "+expts(expt_i))
    end if
    opt_pan@gsnPanelTop=1.-(tofloat(expt_i)/tofloat(dimsizes(expts)))
    opt_pan@gsnPanelBottom=1.-(tofloat(expt_i)/tofloat(dimsizes(expts)))-.25
    if expt_i.eq.(dimsizes(expts)-1) then 
      opt_pan@gsnPanelLabelBar=True
    end if
    ;plot atl3 patterns
    opt_pan@gsnPanelLeft=0.      
    opt_pan@gsnPanelRight=0.5
    opt@cnFillPalette="BlueDarkRed18"
    opt@cnMissingValFillColor = "grey" ; color missing values rather than just land.
    opt@cnMissingValFillPattern = "SolidFill"
    opt@mpLandFillColor="gainsboro"
    opt_pan@lbTitleString="~F35~J~F21~C/~F35~J~F21~C"
    opt@gsnLeftString=plot_letters(expt_i,0)  
    opt@cnLevelSelectionMode = "ExplicitLevels"   
    opt@cnLevels=2*(/-0.1,-0.08,-0.06,-0.04,-.02,0.02,.04,0.06,0.08,.1/)
    plotDiffEnsMnMaps(expts(expt_i),"piControl","atl3_pattern_mon",wks,opt,opt_pan)
    delete([/opt@cnLevels,opt@mpLandFillColor/])
    ;plot atl3 rainfall 
    opt@gsnLeftString=plot_letters(expt_i,1)
    opt@cnFillPalette="CBR_drywet"
    opt@cnLevelSelectionMode = "ExplicitLevels"   
    opt@cnLevels=(/-0.5,-0.3,-0.1,-0.05,0.05,0.1,0.3,0.5/)
    opt_pan@lbTitleString="mm/day/~F35~J~F21~C"
    opt_pan@lbLabelFontHeightF=0.016
    opt_pan@gsnPanelRight=1.0
    opt_pan@gsnPanelLeft=0.5      
    plotDiffEnsMnMaps(expts(expt_i),"piControl","atl3_pr_regression_mon",wks,opt,opt_pan)
    delete(opt@cnLevels)
  end do

  frame(wks)
  delete(wks)
end if

