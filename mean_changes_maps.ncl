;This script was used to create sufficient figures to populate a research publication
;It makes full use of the programs in cvdp_data.functions.ncl to plot figures solely from the output data of cvdp (without needing recomputation).
;The code it set up to look at the Indian Ocean Dipole.
; It makes 1 table (showing simulations used) and many figures. 

;load the NCL functions from Zhao et al (2021; https://doi.org/10.5194/gmd-15-2475-2022)
; These functions are lots of plotting and searching functions. They are hardwired to look for the data in data/
load "cvdp_data.functions.ncl"

plot_regions=(/(/-20,20/),(/-70,30/)/);lat and lons of the edge of the plots

;some plot switches
OUTPUT_TYPE="png"; either "png" or "pdf"
INSOL_EXPTS=True
VERBOSE=False ;if True, provides a modicum of more information about whats goign on in the plots - used for debugging mainly.
ENSEMBLE="PMIP4";choose which ensemble to use: options are "PMIP4","PMIP3" or "BOTH"

opt=True
opt@cnLevelSelectionMode = "ManualLevels"
if INSOL_EXPTS then
  expts=(/"midHolocene-cal-adj","lig127k-cal-adj"/) ;experiments to plot
  expt_str="_orbit"
  opt@cnLevelSpacingF=0.2   
  opt@cnMaxLevelValF=1.   
  opt@cnMinLevelValF=-1.   
else
  expts=(/"midPliocene-eoi400","abrupt4xCO2"/) ;experiments to plot
  expt_str="_pliofuture"
  opt@cnFillPalette="sunshine_9lev"
  opt@cnLevelSpacingF=0.5   
  opt@cnMaxLevelValF=5.   
  opt@cnMinLevelValF=0.5   
end if

vars=(/"sst_spatialmean_djf","sst_spatialmean_jja","pr_spatialmean_djf","pr_spatialmean_jja"/)
vars@ensemble=ENSEMBLE
plot_str="plots/mean_changes_maps"+expt_str

plot_letters=(/(/"a","b","c"/),(/"d","e","f"/),(/"g","h","i"/),(/"j","k","l"/)/)

;Rather than immediately sending the plot to a file, this plot first opens a wks and panels within it. 
wks=gsn_open_wks(OUTPUT_TYPE,plot_str)
wks@VERBOSE=VERBOSE

; Set-up some initial NCL plot options ;
  opt@mpProjection="CylindricalEqualArea"
  opt@gsnStringFontHeightF=0.03
  opt@lbLabelFontHeightF=0.018
  opt@mpLimitMode="LatLon"
  opt@mpMinLonF=plot_regions(1,0)
  opt@mpMaxLonF=plot_regions(1,1)
  opt@mpMinLatF=plot_regions(0,0)
  opt@mpMaxLatF=plot_regions(0,1)
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@gsnRightString=""
  opt@lbLabelBarOn=False
  opt@CONSISTENCY=True ;Turn on Stippling
  opt@OVERLAY_CONTROL=True

opt_pan=True
  opt_pan@lbTitleFontHeightF=0.02
  opt_pan@lbLabelFontHeightF=0.016
  opt_pan@gsnFrame=False
  opt_pan@gsnMaximize=True
  opt_pan@gsnPanelLabelBar=False
  opt_pan@lbTitleOn=True
  opt_pan@dims=(/2,1/)
  opt_pan@lbOrientation="Vertical"
  opt_pan@lbTitlePosition="Left"
  opt_pan@lbTitleDirection     = "Across"                          ; letter angle
  opt_pan@lbTitleAngleF        = 90.                               ; title angle
  opt_pan@lbTitleFontHeightF   = 0.02                              ; font height


; Start with SST 
opt_pan@gsnPanelTop=1.
opt_pan@gsnPanelBottom=0.5
opt@OVERLAY_CONTROL_MANUALLEVS=(/20,34,2/);ie 20:34:2 oC
opt@gsnLeftString=(/"a","c"/)
opt_pan@gsnPanelLeft=0.0
opt_pan@gsnPanelRight=0.45
plotDiffEnsMnMaps(expts(0),"piControl",vars(0:1),wks,opt,opt_pan)
opt_pan@gsnPanelLeft=0.45
opt_pan@gsnPanelRight=1.0
opt_pan@lbTitleString="SST Changes (~F35~J~F21~C)"
opt_pan@gsnPanelLabelBar=True
opt@gsnLeftString=(/"b","d"/)
plotDiffEnsMnMaps(expts(1),"piControl",vars(0:1),wks,opt,opt_pan)

; Move onto rainfall
opt@cnFillPalette="CBR_drywet"
opt@cnLevelSelectionMode = "ExplicitLevels"   
opt@cnLevels=(/-5.,-2.,-1.,-0.5,-0.1,0.1,0.5,1.,2.,5./)
opt_pan@gsnPanelTop=0.5
opt_pan@gsnPanelBottom=0.0
opt_pan@gsnPanelLeft=0.0
opt_pan@gsnPanelRight=0.45
opt_pan@gsnPanelLabelBar=False
opt@gsnLeftString=(/"e","g"/)
opt@OVERLAY_CONTROL_MANUALLEVS=(/0,12,2/);ie -2:2:0.5 oC
plotDiffEnsMnMaps(expts(0),"piControl",vars(2:3),wks,opt,opt_pan)
opt@gsnLeftString=(/"f","h"/)
opt_pan@gsnPanelLeft=0.45
opt_pan@gsnPanelRight=1.0
opt_pan@gsnPanelLabelBar=True
opt_pan@lbTitleString="Rainfall change (mm/day)"
plotDiffEnsMnMaps(expts(1),"piControl",vars(2:3),wks,opt,opt_pan)

frame(wks)
delete(wks)

if OUTPUT_TYPE.eq."png" then
  system("convert "+plot_str+"."+OUTPUT_TYPE+" -trim output.png")
  system("mv output.png "+plot_str+"."+OUTPUT_TYPE)
end if 
