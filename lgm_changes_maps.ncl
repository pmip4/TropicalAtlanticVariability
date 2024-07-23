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
VERBOSE=False ;if True, provides a modicum of more information about whats goign on in the plots - used for debugging mainly.
ENSEMBLE="PMIP4";choose which ensemble to use: options are "PMIP4","PMIP3" or "BOTH"

vars=(/"sst_spatialmean_ann","atl3_pattern_mon","pr_spatialmean_ann","atl3_pr_regression_mon"/)
vars@ensemble=ENSEMBLE
plot_str="plots/lgm_changes_maps_"+ENSEMBLE

;Rather than immediately sending the plot to a file, this plot first opens a wks and panels within it. 
wks=gsn_open_wks(OUTPUT_TYPE,plot_str)
wks@VERBOSE=VERBOSE

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
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@gsnRightString=""
  opt@lbLabelBarOn=True
  opt@lbTitleOn=False
  opt@CONSISTENCY=True ;Turn on Stippling
  opt@OVERLAY_CONTROL=True

opt_pan=True
  opt_pan@lbTitleFontHeightF=0.02
  opt_pan@lbLabelFontHeightF=0.016
  opt_pan@gsnFrame=False
  opt_pan@gsnMaximize=True
  opt_pan@gsnPanelLabelBar=False
  opt_pan@lbTitleOn=True
  opt_pan@dims=(/1,2/)

opt_pan@gsnPanelTop=0.9
opt_pan@gsnPanelBottom=0.5
opt@gsnLeftString=(/"a","b"/)
plotDiffEnsMnMaps("lgm-cal-adj","piControl",vars(0:1),wks,opt,opt_pan)
opt_pan@gsnPanelTop=0.5
opt_pan@gsnPanelBottom=0.1
opt@cnFillPalette="CBR_drywet"
opt@gsnLeftString=(/"c","d"/)
plotDiffEnsMnMaps("lgm-cal-adj","piControl",vars(2:3),wks,opt,opt_pan)

frame(wks)
delete(wks)

if OUTPUT_TYPE.eq."png" then
  system("convert "+plot_str+"."+OUTPUT_TYPE+" -trim output.png")
  system("mv output.png "+plot_str+"."+OUTPUT_TYPE)
end if 
