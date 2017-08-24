;
; The following resources are recognized by the main "radial_plot"
; function, which is called in the main program below:
;
;  rdlRadius
;  rdlXCenter
;  rdlYCenter
;  rdlRadialLineAngle
;  rdlRadialLineColor
;  rdlRadialLineDashPattern
;  rdlRadialLineThicknessF
;  rdlOuterCircleLabelSpacing
;  rdlInnerCircleLineThickness
;  rdlInnerCircleSpacing
;  rdlInnerCircleLineDashPattern
;  rdlOuterCircleLineColor
;  rdlInnerCircleLineColor
;
;**************************************************************

DEGTORAD = 0.017453292519943

;----------------------------------------------------------------------
; add_radial_circles(wks,plot,res)
;     This procedure draws the outer solid circle and the inner dashed
;     circles for a radial background plot.
;
; Other radial procedures in this example script are:
;   add_radial_lines
;   add_radial_labels
;
; Recognized resources:
;   rdlRadius
;   rdlXCenter
;   rdlYCenter
;   rdlOuterCircleLineThickness
;   rdlOuterCircleLineColor
;   rdlInnerCircleLineDashPattern
;   rdlInnerCircleLineThickness
;   rdlInnerCircleLineColor
;   rdlInnerCircleSpacing
;----------------------------------------------------------------------
undef("add_radial_circles")
procedure add_radial_circles(wks,plot,res)
local xcenter, ycenter, spacing, radius, degrees, xc, yc, \
lnres, dumstr, xcos, xsin, r, res2
begin
  res2 = res   ; Make copy of resources

;---Get customizations for circles.
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  otrthck = get_res_value_keep(res2,"rdlOuterCircleLineThickness",2)
  inrthck = get_res_value_keep(res2,"rdlInnerCircleLineThickness",1)
  spacing = get_res_value_keep(res2,"rdlInnerCircleSpacing",45)
  dpattrn = get_res_value_keep(res2,"rdlInnerCircleLineDashPattern",2)
  otrcolr = get_res_value_keep(res2,"rdlOuterCircleLineColor",1)
  inrcolr = get_res_value_keep(res2,"rdlInnerCircleLineColor",1)
  inrunit = get_res_value_keep(res2,"rdlInnerCircleLabelUnits","")
  
;---Calculate arrays for outer circle.
  degrees = ispan(0,360,5)
  xcos    = cos(DEGTORAD * degrees)
  xsin    = sin(DEGTORAD * degrees)
  xc      = xcenter + radius  * xcos
  yc      = ycenter + radius  * xsin

;---Resources for outer circle
  lnres                  = True
  lnres@gsLineThicknessF = otrthck
  lnres@gsLineColor      = otrcolr
  lnres@tfPolyDrawOrder = "PostDraw"
;---Attach circle to plot
  dumstr        = unique_string("outer_circle")
  plot@$dumstr$ = gsn_add_polyline(wks,plot,xc,yc,lnres)

  if(spacing.gt.radius) then
    print("add_radial_circles: spacing is > radius, can't draw inner circles.")
    return
  end if
    lnres@gsLineDashSegLenF = 0.05
;---Draw inner circles if desired
  if(spacing.gt.0) then
    do r = spacing,radius-spacing,spacing

;---Calculate arrays for inner circle.
      xc = xcenter + (r * xcos)
      yc = ycenter + (r * xsin)

;---Resources for inner circle
      lnres@gsLineColor       := inrcolr
      lnres@gsLineThicknessF  := inrthck
      lnres@gsLineDashPattern = dpattrn
      lnres@gsLineLabelString = r+inrunit
      lnres@gsLineDashSegLenF =  lnres@gsLineDashSegLenF+0.125

;---Attach inner circle to plot
      dumstr        = unique_string("inner_circle")
      plot@$dumstr$ = gsn_add_polyline(wks,plot,xc,yc,lnres)
    end do
  end if
end


undef("fill_radial_segments")
procedure fill_radial_segments(wks,plot,minmaxdegrees[2],radius,res)
local xcenter, ycenter, spacing, radius, degrees, xc, yc, \
lnres, dumstr, xcos, xsin, r, res2, gsres
begin
  res2 = res   ; Make copy of resources

;---Get customizations for circles.
;  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  color = get_res_value_keep(res2,"rdlSegmentColor",0)

;---Calculate arrays for outer circle.
  degrees = ispan(minmaxdegrees(0),minmaxdegrees(1),1)
  xcos    = cos(DEGTORAD * degrees)
  xsin    = sin(DEGTORAD * degrees)
  xc      = ndtooned( (/ xcenter + radius(0) * xcos, xcenter + radius(1) * xcos(::-1)/)  )
  yc      = ndtooned( (/ ycenter + radius(0) * xsin, ycenter + radius(1) * xsin(::-1)/) )

  xc := array_append_record( xc, xc(0), 0)
  yc := array_append_record( yc, yc(0), 0)

  ;---Resources for outer circle
  gsres                  = True
  gsres@gsFillColor      = color
  gsres@tfPolyDrawOrder = "PostDraw"
;---Attach circle to plot
  dumstr        = unique_string("filled_piechart")
  plot@$dumstr$ = gsn_add_polygon(wks,plot,xc,yc,gsres)
end


;----------------------------------------------------------------------
; add_radial_lines(wks,plot,res)
;     This procedure draws the radial lines for a radial background plot.
;
; Other radial procedures in this example script are:
;   add_radial_circles
;   add_radial_labels
;
; Recognized resources:
;   rdlRadius
;   rdlXCenter
;   rdlYCenter
;   rdlRadialLineAngle
;   rdlRadialLineColor
;   rdlRadialLineDashPattern
;   rdlRadialLineThicknessF
;----------------------------------------------------------------------
undef("add_radial_lines")
procedure add_radial_lines(wks,plot,res)
local xcenter, ycenter, spacing, radius, degrees, angle, res2, \
degrees, xl, yl, lnres, dumstr, nlines, i, d
begin
  res2 = res   ; Make copy of resources

;---Get customizations for radial lines.
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  angle   = get_res_value_keep(res2,"rdlRadialLineAngle",30)
  lcolor  = get_res_value_keep(res2,"rdlRadialLineColor",1)
  dpattrn = get_res_value_keep(res2,"rdlRadialLineDashPattern",2)
  thcknss = get_res_value_keep(res2,"rdlRadialLineThicknessF",1.)

;---Error checking
  if(angle.le.0.or.angle.ge.360) then
    print("add_radial_lines: angle must be between 0 and 360.")
    print("                  Can't draw radial lines.")
    return
  end if

;---Resources for radial lines
  lnres                   = True
  lnres@gsLineDashPattern = dpattrn
  lnres@gsLineColor       = lcolor
  lnres@gsLineThicknessF  = thcknss
  lnres@tfPolyDrawOrder = "PostDraw"

;---Calculate arrays for lines
  xlines  = 360./angle
  nlines  = toint(ceil(xlines))
  if(xlines.ne.nlines) then
    degrees = fspan(0,360,nlines)
  else
    degrees = fspan(0,360-angle,nlines)
  end if

  nlines  = dimsizes(degrees)
  do i = 0,nlines-1
    xl = (/xcenter, xcenter + (radius  * cos(DEGTORAD * degrees(i)))/)
    yl = (/ycenter, ycenter + (radius  * sin(DEGTORAD * degrees(i)))/)

;---Attach line to plot
  dumstr        = unique_string("radial_lines")+i
  plot@$dumstr$ = gsn_add_polyline(wks,plot,xl,yl,lnres)

  end do
end

;----------------------------------------------------------------------
; add_radial_labels(wks,plot,res)
;     This procedure draws the degree labels around the outer circle
;     for a radial background plot.
;
; Other radial procedures in this example script are:
;   add_radial_lines
;   add_radial_labels
;
; Recognized resources:
;   rdlRadius
;   rdlXCenter
;   rdlYCenter
;   rdlOuterCircleLabelSpacing (in degrees)
;----------------------------------------------------------------------
undef("add_radial_labels")
procedure add_radial_labels(wks,plot,res)
local xcenter, ycenter, spacing, radius, res2, \
angles, labels, nlabels, txres, txid, amid, delta, \
xt, yt, quad1, quad2, quad3, quad4, xmin, xmax, ymin, ymax, xp, yp
begin
  res2 = res   ; Make copy of resources

;---Get customizations for labels
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  spacing = get_res_value_keep(res2,"rdlOuterCircleLabelSpacing",30)
  labels  = get_res_value_keep(res2, "rdlOuterLabelStrings", (/"E","NE","N","NW","W","SW","S","SE"/) )
  angles  = get_res_value_keep(res2, "rdlOuterLabelValues", ispan(0,360-spacing,spacing) )

;---Generate angle spacings and labels
;  angles  = ispan(0,360-spacing,spacing)
;  labels  = (/"E","NE","N","NW","W","SW","S","SE"/)
  nlabels = dimsizes(labels)
  if( dimsizes(angles).ne. nlabels )
 	print("Dimension sizes of rdlOuterLabelStrings and rdlOuterLabelValues do not match")
 	print("Will try to put labels in correct position -- double check and pass the correct values next time")
 	spacing := 360/nlabels
 	angles := ispan(0,360-spacing,spacing) 
  end if

;---Locations for labels
  xt = xcenter + (radius  * cos(DEGTORAD * angles))
  yt = ycenter + (radius  * sin(DEGTORAD * angles))

;---Get the current axes limits
  getvalues plot
    "trXMinF" : xmin
    "trXMaxF" : xmax
    "trYMinF" : ymin
    "trYMaxF" : ymax
  end getvalues

;---Add a little more space to axes limits for labels.
  delta = (xmax - xmin)/20.
  setvalues plot
    "trXMinF"               : xmin - delta
    "trXMaxF"               : xmax + delta
    "trYMinF"               : ymin - delta
    "trYMaxF"               : ymax + delta
  end setvalues

;---Determine which quadrant each label is in.
  quad1 = ind(  0.lt.angles.and.angles.lt. 90)
  quad2 = ind( 90.lt.angles.and.angles.lt.180)
  quad3 = ind(180.lt.angles.and.angles.lt.270)
  quad4 = ind(270.lt.angles.and.angles.lt.360)
  rgt   = ind(angles.eq.  0)
  top   = ind(angles.eq. 90)
  lft   = ind(angles.eq.180)
  bot   = ind(angles.eq.270)

;---Justifcations for text strings.
  just        = new(nlabels,string)
  just(quad1) = "BottomLeft"  ; "CenterLeft"
  just(quad2) = "BottomRight" ; "CenterRight"
  just(quad3) = "TopRight"    ; "CenterRight"
  just(quad4) = "TopLeft"     ; "CenterLeft"
  if(.not.any(ismissing(rgt))) then
    just(rgt) = "CenterLeft"
    xt(rgt) = xt(rgt) + delta/10.
  end if
  if(.not.any(ismissing(top))) then
    just(top) = "BottomCenter"
    yt(top)   = yt(top) + delta/10.
  end if
  if(.not.any(ismissing(lft))) then
    just(lft) = "CenterRight"
    xt(lft)   = xt(lft) - delta/10.
  end if
  if(.not.any(ismissing(bot))) then
    just(bot) = "TopCenter"
    yt(bot)   = yt(bot) - delta/10.
  end if

;---Resources for radial lines
  txres               = True
  txres@txFontHeightF = 0.02

;---Array to hold text objects
  txid = new(nlabels,graphic)

;---Loop across labels and attach to plot.
  do i = 0,nlabels-1
    txres@txJust  = just(i)
    txid(i)       = gsn_add_text(wks,plot,labels(i),xt(i),yt(i),txres)
  end do
end

;----------------------------------------------------------------------
; This is the main function for creating a radial plot. It checks
; resources, and calls these three routines:
;
;   add_radial_circles
;   add_radial_lines
;   add_radial_labels
;----------------------------------------------------------------------
undef("radial_plot")
function radial_plot(wks,res)
local bres, rres, res2, bplot, radius, xcenter, ycenter
begin
  res2 = res   ; Make copy of resources

;---Get customizations for radial plot
  radius  = get_res_value(res2,"rdlRadius",240)
  xcenter = get_res_value(res2,"rdlXCenter",0)
  ycenter = get_res_value(res2,"rdlYCenter",0)

;---Set resources for a "blank" plot that will become the radial plot
  bres              = get_res_ne(res2,"rdl")
  bres              = True                       ; plot mods desired
  bres@gsnMaximize  = True

  bres@trXMinF      = xcenter - radius
  bres@trXMaxF      = xcenter + radius
  bres@trYMinF      = ycenter - radius
  bres@trYMaxF      = ycenter + radius

  bres@pmTickMarkDisplayMode = "Never"  ; Turn off tickmarks.

  bplot = gsn_blank_plot(wks,bres)

  if(res2) then
    rres = res2       ; Copy attributes
  end if

;---Make sure radius and center are set.
  rres            = True
  rres@rdlRadius  = get_res_value_keep(res2,"rdlRadius",radius)
  rres@rdlXCenter = get_res_value_keep(res2,"rdlXCenter",xcenter)
  rres@rdlYCenter = get_res_value_keep(res2,"rdlYCenter",ycenter)

  add_radial_circles(wks,bplot,rres)
  add_radial_lines(wks,bplot,rres)
  add_radial_labels(wks,bplot,rres)

  return(bplot)
end


;----------------------------------------------------------------------
; Simple function to convert r,theta coord to x,y for adding to plot.
;
;  ranges: dustance from center of radial plot
;  angles: angle around the radial plot (in degrees; 0 = E, 90=N so on, counter clockwise)
;  res : resource used to create radial plot, used to get center location, False will use 0,0
;----------------------------------------------------------------------
undef("convert_to_radial_plot")
function convert_to_radial_plot(ranges, angles, res)
local res, xcenter, ycenter, xarr, yarr
begin
  xcenter = get_res_value_keep(res,"rdlXCenter",0)
  ycenter = get_res_value_keep(res,"rdlYCenter",0)

;---Calculate cartesian coordinates given angles and ranges.
  xarr = xcenter+(ranges*cos(DEGTORAD*angles))
  yarr = ycenter+(ranges*sin(DEGTORAD*angles))

return (/xarr, yarr/) 
end

;----------------------------------------------------------------------
; This procedure adds markers to an existing radial plot, given:
;
;
;   plot  : the radial background plot created with radial_plot
;   dvals : the values used to determine marker size and color
;   xarr, yarr: the x and y location
;
;
;----------------------------------------------------------------------
undef("add_markers_to_radial_plot")
procedure add_markers_to_radial_plot(wks,plot,ranges,angles,res, gs)
local radius, radius, xcenter, ycenter, nlevels, sizes, colors,
mkres, dum_fill, dum_hollow, i, ii, tmpstr, xarr, yarr
begin
  res2    = res
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)

;---Calculate cartesian coordinates given angle and range.
  xarr = xcenter+(ranges*cos(DEGTORAD*angles))
  yarr = ycenter+(ranges*sin(DEGTORAD*angles))

;---Arrays for attaching two sets of markers

;---Resource list for customizing markers.
if(gs .and. .not.isatt(gs, "gsMarkerIndex"))
  gs@gsMarkerOpacityF = 0.6
  gs@gsMarkerOpacityF = 0.6
  gs@gsLineOpacityF = 0.6
  mstring = "7"
  fontnum = 34
  xoffset = 0.0
  yoffset = 0.0
  ratio   = 1.0    ;;;   Create new circle marker so there is no perimeter circle in transparencies
  size    = 1.5
  angle   = 0.0
  new_index = NhlNewMarker(wks, mstring, fontnum, xoffset, yoffset, ratio, size, angle)
  gs@gsMarkerIndex = new_index
end if
    tmpstr = unique_string("fill")
    plot@$tmpstr$ = gsn_add_polymarker(wks,plot,xarr,yarr,gs)

end


;----------------------------------------------------------------------
; This procedure adds a simple polyline to an existing radial plot, given:
;
;
;   plot  : the radial background plot created with radial_plot
;   ranges, angles: r, theta coords of the plot that will be translated to x,y of the background plot
;   res:  resources for the radial plot, used to get center x,y
;   gs : resource for the polyline that will be added. 
;   xarr, yarr: the x and y location
;
;
;----------------------------------------------------------------------
undef("add_line_to_radial_plot")
procedure add_line_to_radial_plot(wks,plot,ranges,angles,res, gs)
local radius, radius, xcenter, ycenter, nlevels, sizes, colors,
mkres, dum_fill, dum_hollow, i, ii, tmpstr, xarr, yarr
begin
  res2    = res
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)

;---Calculate cartesian coordinates given angles and ranges.
  xarr = xcenter+(ranges*cos(DEGTORAD*angles))
  yarr = ycenter+(ranges*sin(DEGTORAD*angles))

;---Resource list for customizing markers.
    tmpstr = unique_string("line")
    plot@$tmpstr$ = gsn_add_polyline(wks,plot,xarr,yarr,gs)

end
