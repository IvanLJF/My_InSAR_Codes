; Chapter14HappyYou3DSControl.pro
;----------------------------------------------------------------------------
function Chapter14HappyYou3DSControlMakeView, xdim, ydim, uval
  aspect = xdim / float(ydim)
  myview = [-1, -1, 2, 2] * sqrt(2)
  if (aspect > 1) then begin
    myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
    myview[2] = myview[2] * aspect
  end else begin
    myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
    myview[3] = myview[3] / aspect
  end
  v = obj_new('IDLgrView', projection=2, eye=3, zclip=[1.5,-1.5], dim=[xdim,ydim],$
      viewplane_rect=myview, color=[30,30,60], uvalue=uval )
  gg = obj_new('IDLgrModel')  &  g = obj_new('IDLgrModel')  &  gg->add,g
  b_verts = fltarr(3,5,5)     &  b_conn = lonarr(5,16)      &  vert_cols=bytarr(3,25)
  j = 0
  for i=0,15 do begin
    b_conn[0,i] = 4       &    b_conn[1,i] = j
    b_conn[2,i] = j+1     &    b_conn[3,i] = j+6
    b_conn[4,i] = j+5     &    j = j + 1
    if (j MOD 5) EQ 4 then j = j + 1
  end
  k = 0
  for i=0,4 do begin
    for j=0,4 do begin
      b_verts[0,i,j] = i   &   b_verts[1,i,j] = j  &   b_verts[2,i,j] = 0
      if (k EQ 1) then begin
        vert_cols[*, i+j*5] = [40,40,40]
      end else begin
        vert_cols[*, i+j*5] = [255,255,255]-40
      end
      k = 1 - k
    end
  end
  b_verts[0,*,*] = (b_verts[0,*,*]-2)/2.0  &  b_verts[1,*,*] = (b_verts[1,*,*]-2)/2.0
  baseplate = obj_new('IDLgrPolygon', b_verts, poly=b_conn, $
    shading=1, vert_colors=vert_cols )
  g->add, baseplate      &      g->add, obj_new('IDLgrModel')
  gg->add, obj_new('IDLgrLight',loc=[2,2,5],type=2,color=[255,255,255],intensity=.5)
  gg->add, obj_new('IDLgrLight',type=0, intensity=.5, color=[255,255,255] )
  v->add, gg
  return, v
end
;----------------------------------------------------------------------------
pro Chapter14HappyYou3DSControlGetViewObjs,view,oWorldRotModel,oBasePlatePolygon,model_top
  gg = view->get()
  oWorldRotModel = gg->get(pos=0)
  oBasePlatePolygon = oWorldRotModel->get(pos=0)
  model_top = oWorldRotModel->get(pos=1)
end
;----------------------------------------------------------------------------
pro Chapter14HappyYou3DSControlCone,verts,conn,n
  verts = fltarr(3,n+1)
  verts[0,0] = 0.0     &    verts[1,0] = 0.0    &    verts[2,0] = 0.1
  t = 0.0     &    tinc = (2.*!PI)/float(n)
  for i=1,n do begin
    verts[0,i] = 0.1*cos(t)  &  verts[1,i] = 0.1*sin(t)  &   verts[2,i] = -0.1
    t = t + tinc
  end
  conn = fltarr(4*n+(n+1))
  i = 0       &      conn[0] = n
  for i=1,n do conn[i] = (n-i+1)
  j = n+1
  for i=1,n do begin
    conn[j] = 3     &    conn[j+1] = i
    conn[j+2] = 0   &    conn[j+3] = i + 1
    if (i EQ n) then conn[j+3] = 1
    j = j + 4
  end
end
;----------------------------------------------------------------------------
function Chapter14HappyYou3DSControlMakeObj,type,thefont
oModel= obj_new('IDLgrModel')
case type of
  0 : begin
      s = obj_new('orb',color=[255,0,0],radius=0.1,shading=1,select_target=1)
      str = "Sphere"
  end
  1 : begin
      verts = [[-0.1,-0.1,-0.1],[0.1,-0.1,-0.1],[0.1,0.1,-0.1],[-0.1,0.1,-0.1], $
               [-0.1,-0.1, 0.1],[0.1,-0.1, 0.1],[0.1,0.1, 0.1],[-0.1,0.1,0.1]]
      conn=[[4,3,2,1,0],[4,4,5,6,7],[4,0,1,5,4],[4,1,2,6,5],[4,2,3,7,6],[4,3,0,4,7]]
      s = obj_new('IDLgrPolygon',verts,poly=conn,color=[0,255,0],shading=0)
      str = "Cube"
  end
  2 : begin
      Chapter14HappyYou3DSControlCone,verts,conn,3
      s = obj_new('IDLgrPolygon',verts,poly=conn,color=[0,255,255],shading=0)
      str = "Tetrahedron"
  end
  3 : begin
      Chapter14HappyYou3DSControlCone,verts,conn,20
      s = obj_new('IDLgrPolygon',verts,poly=conn,color=[255,128,255],shading=1)
      str = "Cone"
  end
  4 : begin
      Chapter14HappyYou3DSControlCone,verts,conn,4
      l = obj_new('IDLgrPolygon',verts*0.5,poly=conn,color=[100,255,100],shading=0)
      oModel->add,l
      l = obj_new('IDLgrPolyline',[[0,0,0],[0,0,-0.1]], color=[100,255,100])
      oModel->add,l
      s = obj_new('IDLgrLight',loc=[0,0,0],dir=[0,0,-1],cone=40, $
                               focus=0,type = 3,color=[100,255,100])
      str = "Green Light"
  end
  5 : begin
      e_height = BYTARR(64,64, /NOZERO)
      OPENR, lun, /GET_LUN, demo_filepath('elevbin.dat', SUBDIR=['examples','data'])

      READU, lun, e_height  &  FREE_LUN, lun
      zdata = e_height / (1.7 * max(e_height)) + .001
      xdata = (findgen(64)-32.0)/64.0
      ydata = (findgen(64)-32.0)/64.0
      s = obj_new('IDLgrSurface',zdata,shading=1,style=2,$
                                 datax=xdata,datay=ydata,color=[150,50,150])
      str = "Surface"
  end
  6 : begin
      restore, filename='Chapter14HappyYou3DSColorTable.sav'
      restore, demo_filepath('marbells.dat', subdir=['examples','data'])
      image = bytscl(elev, min=2658, max=4241)
      image = image[8:*, *] ; Trim unsightly junk from left side.
      sz = size(image)
      img = bytarr(3,sz[1],sz[2])
      img[0,*,*]=ctab[0,image] & img[1,*,*]=ctab[1,image] & img[2,*,*]=ctab[2,image]
      oTextureImage = obj_new('IDLgrImage', img, loc=[0.0,0.0],dim=[0.01,0.01],hide=1)
      oModel->add, oTextureImage
      xp=0.5  &  yp=0.5*(72./92.)  &  zp=0.1
      s=obj_new('IDLgrPolygon',[[-xp,-yp,zp],[xp,-yp,zp],[xp,yp,zp],[-xp,yp,zp]],$
                 texture_coord=[[0,0],[1,0],[1,1],[0,1]],texture_map=oTextureImage, $
                 color=[255,255,255] )
      str = "Image"
  end
  7 : begin
      Chapter14HappyYou3DSControlCone, verts, conn, 4
      oModel->add, obj_new('IDLgrPolygon', verts*0.5, poly=conn, $
                                           color=[255,255,255], shading=0 )
      oModel->add, obj_new('IDLgrPolyline', [[0,0,0], [0,0,-0.1]],color=[255,255,255])
      s = obj_new('IDLgrLight', loc=[0,0,0], dir=[0,0,-1], cone=20,focus=0,  type=3, $
                                           color=[255,255,255] )
      str = "White Light"
  end
  8 : begin
      s=obj_new('IDLgrText', "IDL", location=[0,0,0.001], align=0.5, $
                 color=[255,0,255], font=thefont[0] )
      str = "Text"
  end
  9 : begin
      N = 1024 ; number of time samples in data set
      delt = 0.02; sampling interval in seconds
      U = -0.3 + 1.0 * Sin(2*!Pi* 2.8 *delt*FIndGen(N)) $
          + 1.0 * Sin(2*!Pi*6.25*delt*FIndGen(N))+1.0*Sin(2*!Pi*11.0*delt*FIndGen(N))
      V = fft(U)             &    signal_x = FINDGEN(N/2+1) / (N*delt)
      mag = ABS(V[0:N/2])    &    signal_y = 20*ALOG10(mag)
      phi = ATAN(V[0:N/2]) ; phase of first half of v
      xc=[-0.5,1.0/25.0]  &  yc=[0.5,1.0/80.0]
      s=obj_new('IDLgrPolygon', [[-7,-90,-0.002],[30,-90,-0.002], [30,10,-0.002],$
        [-7,10,-0.002]],color=[0,0,0], xcoord_conv=xc, ycoord_conv=yc )
      oModel->add,s
      s=obj_new('IDLgrAxis', 0, range=[0.0,25.0], xcoord_conv=xc, ycoord_conv=yc, $
            location=[0,-80.0], color=[0,255,0], ticklen=5, /exact )
      s->GetProperty,ticktext=tt
      tt->setproperty,font=thefont[3]
      oModel->add,s
      s=obj_new('IDLgrAxis', 0, range=[0.0,25.0], /notext,xcoord_conv=xc, $
            ycoord_conv=yc, location=[0.0,0.0], color=[0,255,0], ticklen=-5, /exact)
      oModel->add,s
      s=obj_new('IDLgrAxis', 1, range=[-80.0,0.0],xcoord_conv=xc, $
            ycoord_conv=yc, color=[0,255,0], ticklen=1.0, /exact )
      s->GetProperty,ticktext=tt
      tt->setproperty,font=thefont[3]
      oModel->add,s
      s=obj_new('IDLgrAxis', 1, range=[-80.0,0.0], /notext,xcoord_conv=xc, $
            ycoord_conv=yc, loc=[25.0,0.0], color=[0,255,0], ticklen=-1.0, /exact )
      oModel->add,s
      s=obj_new('idlgrplot',signal_x,signal_y,xcoord_conv=xc,ycoord_conv=yc, $
                             color=[0,255,255] )
      str = "Plot"
  end
  10 : begin
       x=indgen(200)
       yexp = exp(-x*0.015)
       ysexp = exp(-x*0.015)*sin(x*0.1)
       dataz=fltarr(200,5)
       dataz[*,0] = yexp         &       dataz[*,1] = yexp
       dataz[*,2] = REPLICATE(1.1,200)
       dataz[*,3] = ysexp-0.01   &       dataz[*,4] = ysexp-0.01
       datay = fltarr(200,5)
       datay[*,0] = 0.0   &   datay[*,1] = 1.0  &  datay[*,2] = 0.0
       datay[*,3] = 0.0   &   datay[*,4] = 1.0
       cbins = bytarr(3,60)
       for i=0,59 do begin
         color_convert, float(i)*4., 1., 1., r,g,b, /HSV_RGB
         cbins[*,59-i] = [r,g,b]
       end
       colors = bytarr(3,200*5)
       colors[0,0:599] = REPLICATE(80,3*200)
       colors[1,0:599] = REPLICATE(80,3*200)
       colors[2,0:599] = REPLICATE(200,3*200)
       colors[*,600:799] = cbins[*,(ysexp+1.0)*30.0]
       colors[*,800:999] = cbins[*,(ysexp+1.0)*30.0]
       xc = [-0.5,1.0/200.0]*0.8
       yc = [-0.5,1.0/1.0]*0.1   &   zc = [-0.5,1.0/1.0]*0.4
       s=obj_new('IDLgrAxis', 0, range=[0,200], color=[255,255,255], ticklen=0.2, $
                  xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc )
       oModel->add,s
       s=obj_new('IDLgrAxis', 2, range=[-1.,1.],color=[255,255,255], ticklen=4, $
                  xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc )
       oModel->add,s
       s=obj_new('IDLgrSurface', dataz, style=2, vert_colors=colors,datay=datay, $
             max_value=1.05,shading=1,xcoord_conv=xc,ycoord_conv=yc,zcoord_conv=zc)
       oModel->add,s
       s=obj_new('IDLgrSurface', dataz, style=3, color=[0,0,0],datay=datay, $
             max_value=1.05, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc )
       str = 'Ribbon Plot'
  end
  11 : begin
       dataz = dist(8)
       dataz[1,*] = -1  &  dataz[3,*] = -1  &  dataz[5,*] = -1
       dataz[*,1] = -1  &  dataz[*,3] = -1  &  dataz[*,5] = -1
       dataz = dataz + 1
       cbins=[ [255,  0,0],[255, 85,0],[255,170,0],[255,255,0],$
               [170,255,0],[ 85,255,0],[  0,255,0] ]
       colors = bytarr(3, 8*8)
       minz = min(dataz)  &  maxz = max(dataz)
       zi = round((dataz - minz)/(maxz-minz) * 6.0)
       colors[*,*] = cbins[*,zi]
       xc = [-0.5,1.0/8.0]*0.4  &  yc = [-0.5,1.0/8.0]*0.4  &  zc = [0,1.0/8.0]*0.4
       s=obj_new('IDLgrAxis',0,range=[0,8],major=5,color=[255,255,255],ticklen=0.2, $
                 /exact, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc )
       oModel->add,s
       s=obj_new('IDLgrAxis', 1, range=[0,8], major=5,color=[255,255,255], $
             ticklen=0.2, /exact, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc )
       oModel->add,s
       s=obj_new('IDLgrAxis', 2, range=[0,8], major=5, color=[255,255,255], $
             ticklen=0.2, /exact, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc )
       oModel->add,s
       s=obj_new('IDLgrSurface', dataz, STYLE=6, VERT_COLORS=colors,$
             xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc )
       str = 'Bar Plot'
  end
endcase
oModel->Add, s
oModel->SetProperty, uvalue=str
return, oModel
end
;----------------------------------------------------------------------------
pro Chapter14HappyYou3DSControlNewMode, state, mode
  widget_control, /hourglass
  state.oModelMan->SetProperty, mode=mode
  widget_control, state.wModelModeRadio, set_value=mode
end
;----------------------------------------------------------------------------
pro Chapter14HappyYou3DSControlAdd, state, oModel, as_child=as_child
  if keyword_set(as_child) then begin
     state.selected->add, oModel
  endif else begin
     state.oCurrentTopModel->add, oModel
  endelse
  state.oCurrentView->GetProperty, uvalue=view_uval
  *(state.model_lists[view_uval.num]) = [oModel, *(state.model_lists[view_uval.num])]
  state.model_cycle_pos = 0
  state.selected = oModel
  g = oModel->get(pos=0)
  if (obj_isa(g,'IDLgrText')) then begin
     rect = state.win->gettextdimensions(g)
  end
  state.oModelMan->SetTarget, state.selected
  state.selected->GetProperty, uvalue=s
  str = "Current selection : " + s
  widget_control, state.text, set_value=str
  widget_control, state.wModelDeleteButton, sensitive=1
  widget_control, state.wAddChildButton, sensitive=1
  widget_control, state.wUnselectButton, sensitive=1
  widget_control, state.wModelModeRadio, sensitive=1
  widget_control, state.wSaveButton, sensitive=([1,0])[lmgr(/demo)]
  widget_control, state.wModelSelectButton, sensitive= $
    n_elements(*(state.model_lists[view_uval.num])) gt 2
  state.win->Draw, state.scene
end
;----------------------------------------------------------------------------
Function Chapter14HappyYou3DSControlToggleState, wid
  widget_control, wid, get_value=name
  s = strpos(name,'(off)')
  if (s NE -1) then begin
    strput,name,'(on )',s
    ret = 1
  end else begin
    s = strpos(name,'(on )')
    strput,name,'(off)',s
    ret = 0
  end
  widget_control, wid, set_value=name
  return,ret
end
;----------------------------------------------------------------------------
pro Chapter14HappyYou3DSControlCleanup, wTopBase
  widget_control, wtopbase, get_uvalue=state, /no_copy
  for i=0,n_tags(state)-1 do begin
    case size(state.(i), /TNAME) of
      'POINTER': ptr_free, state.(i)
      'OBJREF':obj_destroy, state.(i)
      else:
    endcase
  end
end
;----------------------------------------------------------------------------
pro Chapter14HappyYou3DSControlEvent, ev
  if tag_names(ev, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
     widget_control,ev.top,/destroy
     return
  end
  ;If mouse buttons are down, only process draw widget events.
  widget_control, ev.top, get_uvalue=state, /no_copy
  widget_control, ev.id, get_uval=uval
  if state.btndown eq 1 then begin
    if uval[0] eq 'DRAW' then begin
      if ev.type eq 0 then begin ; Button down event
        widget_control, ev.top, set_uvalue=state, /no_copy
        return      ;ignore it.A mouse button is already down.
      end
    end else begin
      widget_control, ev.top, set_uvalue=state, /no_copy
      return
    end
  end
  widget_control, ev.top, set_uvalue=state, /no_copy
  ;Normal event handling.
  case uval[0] of
  'QUIT' : begin
      widget_control, ev.top, /destroy
      return
   end
  'HELP' : begin
      Chapter14HappyYou3DSHelp, 'Chapter14HappyYou3DSHelp.txt', TITLE='3DS Help System'
  end
  'ABOUT' : begin
      result=dialog_message(['3DS System v 6.0   ','','Programming : HappyYou','', $
                  '³ÌÐòÉè¼Æ : Happy You ',' ', '      2005.5.30'],/information)
  end
  'VRML' : begin
      widget_control, ev.top, get_uvalue=state, /no_copy
      if (state.oCurrentView NE obj_new()) then begin
        file=dialog_pickfile(/write,file='untitled.wrl',group=ev.top,filter='*.wrl')
        if (file NE '') then begin
          widget_control, /hourglass
          state.win->GetProperty, dimension=wdims, resolution=res,color_model=cm, $
                                  n_colors=icolors
          oVRML = obj_new('IDLgrVRML', dimensions=wdims, resolution=res, $
                 color_model=cm, n_colors=icolors )
          oVRML->setproperty, filename=file
          oVRML->Draw, state.oCurrentView
          obj_destroy,oVRML
        end
      end
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'PRINT' : begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    oPrinter = obj_new('IDLgrPrinter')
    if (dialog_printersetup(oPrinter)) then begin
      if (dialog_printjob(oPrinter)) then begin
        oPrinter->GetProperty,resolution=res
        DPI = 2.54/float(res)
        state.win->GetProperty,resolution=res
        DPI = 2.54/float(res)
        state.win->GetProperty, dimension=wdims
        oViews = state.scene->get(/all)
        for i=0,n_elements(oViews)-1 do begin
          oViews[i]->IDLgrView::getproperty, loc=loc,dim=vdim
          loc = loc/DPI
          vdim = vdim/DPI
          oViews[i]->IDLgrView::setproperty, loc=loc, dim=vdim, units=1
        end
        oPrinter->Draw, state.scene
        oPrinter->newdocument
        for i=0,N_ELEMENTS(oViews)-1 do begin
          oViews[i]->IDLgrView::getproperty, loc=loc,dim=vdim
          loc = loc*DPI
          vdim = vdim*DPI
          oViews[i]->IDLgrView::setproperty, loc=loc,dim=vdim,units=0
        end
      end
    end
    obj_destroy,oPrinter
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'LOAD' : begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    if state.selected ne obj_new() then begin
      file = dialog_pickfile( /read, /must_exist, group=ev.top, filter='*.sav' )
      if (file NE '') then begin
        restore, file, /relaxed_structure_assignment
        Chapter14HappyYou3DSControlAdd, state, tmp_obj
      end
    end
  widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'SAVE' : begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    if state.selected NE obj_new() and $
       state.selected NE state.oCurrentTopModel then begin
      file = dialog_pickfile(/write,file='untitled.sav',group=ev.top, filter='*.sav')
      if (file NE '') then begin
        ; Isolate tmp_obj from the tree.
        state.selected->GetProperty, parent=parent
        parent->remove, state.selected
        state.oModelMan->SetTarget, obj_new()
        tmp_obj = state.selected
        save, tmp_obj, filename=file
        ; Repair the tree.
        parent->add, state.selected
        state.oModelMan->SetTarget, state.selected
      end
    end
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'MODELSELECT': begin ; Select next object.
    widget_control, ev.top, get_uvalue=state, /no_copy
    wDraw = state.wDraw
    widget_control, ev.top, set_uvalue=state, /no_copy
    Chapter14HappyYou3DSControlEvent, $
        {id:wDraw,top:ev.top,handler:0L,type:0,press:4,x:-2,y:-2}
  end
  'UNSELECT': begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    state.selected = state.oCurrentTopModel
    widget_control, state.wModelDeleteButton, sensitive=0
    widget_control, state.wAddChildButton, sensitive=0
    widget_control, state.wUnselectButton, sensitive=0
    widget_control, state.wModelModeRadio, sensitive=0
    widget_control, state.wModelSelectButton, sensitive=1
    widget_control, state.wSaveButton, sensitive=0
    widget_control, state.text, set_value="No current selection  "
    state.oModelMan->SetTarget, obj_new()
    state.win->Draw, state.scene
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'MODELMODE': begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    Chapter14HappyYou3DSControlNewMode, state, ev.value
    state.win->Draw, state.scene
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'ADD': begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    if state.oBasePlatePolygon ne obj_new() then begin
      Chapter14HappyYou3DSControlAdd, state, Chapter14HappyYou3DSControlMakeObj( $
        (where(state.addable_subjects eq uval[1]))[0], state.theFont )
    end
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'ADDCHILD': begin
    widget_control, /hourglass
    widget_control, ev.top, get_uvalue=state, /no_copy
    if state.oBasePlatePolygon ne obj_new() then begin
      Chapter14HappyYou3DSControlAdd, state, Chapter14HappyYou3DSControlMakeObj( $
      (where(state.addable_subjects eq uval[1]))[0], state.theFont ), /as_child
    end
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'DEL': begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    if ((state.selected ne obj_new()) AND $
        (state.selected ne state.oCurrentTopModel)) then begin
        state.oModelMan->SetTarget, obj_new()
        state.selected->GetProperty, parent=p
        p->remove, state.selected
        obj_destroy, state.selected
        state.oCurrentView->GetProperty, uvalue=view_uval
        indx = where( obj_valid(*(state.model_lists[view_uval.num])), count )
        if indx[0] eq -1 then begin
          *(state.model_lists[view_uval.num]) = obj_new()
          state.selected = state.oCurrentTopModel
          str = "No current selection  "
          widget_control, state.text, set_value=str
          widget_control, state.wModelDeleteButton, sensitive=0
          widget_control, state.wAddChildButton, sensitive=0
          widget_control, state.wUnselectButton, sensitive=0
          widget_control, state.wModelSelectButton, sensitive=0
          widget_control, state.wSaveButton, sensitive=0
          widget_control, state.wModelModeRadio, sensitive=0
          state.win->Draw, state.scene
        end else begin
          *(state.model_lists[view_uval.num]) = $
            [(*(state.model_lists[view_uval.num]))[indx], obj_new() ]
          ; Select something.
          wDraw = state.wDraw
          widget_control, ev.top, set_uvalue=state, /no_copy
          Chapter14HappyYou3DSControlEvent, $
               {id: wDraw, top: ev.top, handler:0L, type:0, press:4, x:-1, y:-1 }
          return
        end
    end
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'DRAGQLOW' : begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    state.dragq = 0
    widget_control, state.wDragQLow,sensitive=0
    widget_control, state.wDragQMedium, sensitive=1
    widget_control, state.wDragQHigh, sensitive=1
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'DRAGQMEDIUM' : begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    state.dragq = 1
    widget_control, state.wDragQLow,sensitive=1
    widget_control, state.wDragQMedium, sensitive=0
    widget_control, state.wDragQHigh, sensitive=1
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'DRAGQHIGH' : begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    state.dragq = 2
    widget_control, state.wDragQLow,sensitive=1
    widget_control, state.wDragQMedium, sensitive=1
    widget_control, state.wDragQHigh, sensitive=0
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'GRID' : begin
    widget_control, /hourglass
    widget_control, ev.top, get_uvalue=state, /no_copy
    if (OBJ_VALID(state.oCurrentView)) then begin
      if (OBJ_VALID(state.oBasePlatePolygon)) then begin
        state.oBasePlatePolygon->SetProperty, $
                   hide=1-Chapter14HappyYou3DSControlToggleState(state.wGridButton)
        state.win->Draw, state.scene
      end
    end
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  'DRAW': begin
    widget_control, ev.top, get_uvalue=state, /no_copy
    ; Expose.
    if (ev.type EQ 4) then state.win->Draw, state.scene
    ; Handle trackball updates.
    if state.oTrackballMB2->Update(ev, transform=qmat) then begin
      state.oWorldRotModel->GetProperty, transform=t
      mt = t # qmat
      state.oWorldRotModel->setproperty,transform=mt
      state.win->Draw, state.scene
    end
    have_mb1_transform = state.oTrackballMB1->Update(ev, transform=mb1_transform)
    ; Handle other events
    case ev.type of
      0 : begin ; Button press
        case 1 of
          ev.press EQ 4: begin
            widget_control, /hourglass
            if ev.x lt 0 then begin
              state.oCurrentView->GetProperty, uvalue=view_uval
              if n_elements(*(state.model_lists[view_uval.num])) gt 1 then begin
                state.model_cycle_pos = state.model_cycle_pos + ([0,1])[abs(ev.x) - 1]
                state.model_cycle_pos = state.model_cycle_pos $
                  mod ( n_elements( *(state.model_lists[view_uval.num]) ) - 1 )
                picked = (( $
                  *(state.model_lists[view_uval.num]))[state.model_cycle_pos])->get()
              end else begin
                picked = obj_new()
              end
            end else begin
              state.oModelMan->setproperty,hide=1
              picked = state.win->select( state.oCurrentView,[ev.x,ev.y] )
              state.oModelMan->setproperty,hide=0
            end
            if obj_valid(picked[0]) then begin
              if (picked[0] EQ state.oBasePlatePolygon) then begin
                state.selected = state.oCurrentTopModel
                str = "No current selection  "
                widget_control, state.wModelDeleteButton, sensitive=0
                widget_control, state.wAddChildButton, sensitive=0
                widget_control, state.wUnselectButton, sensitive=0
                widget_control, state.wSaveButton, sensitive=0
              end else begin
                if (obj_isa(picked[0],'IDLgrModel') EQ 1) then begin
                  picked[0]->IDLgrModel::getproperty,parent=p
                end else begin
                  picked[0]->GetProperty, parent=p
                end
                if (state.selected EQ p) then begin
                  state.oModelMan->GetProperty, mode=mode
                  Chapter14HappyYou3DSControlNewMode, state, (mode + 1) mod 3
                end
                state.oCurrentView->GetProperty, uvalue=view_uval
                state.model_cycle_pos = where(*(state.model_lists[view_uval.num]) eq p)
                state.selected = p
                state.selected->GetProperty, uvalue=s
                str = "Current selection :  " + s
                widget_control, state.wModelDeleteButton, sensitive=1
                widget_control, state.wAddChildButton, sensitive=1
                widget_control, state.wUnselectButton, sensitive=1
                widget_control, state.wModelModeRadio, sensitive=1
                widget_control, state.wSaveButton, sensitive=([1,0])[lmgr(/demo)]
                state.oCurrentView->GetProperty, uvalue=view_uval
                if n_elements( *(state.model_lists[view_uval.num]) ) le 2 then begin
                  widget_control, state.wModelSelectButton, sensitive=0
                endif
              end
            end else begin
              state.selected = state.oCurrentTopModel
              str = "No current selection  "
              widget_control, state.wModelDeleteButton, sensitive=0
              widget_control, state.wAddChildButton, sensitive=0
              widget_control, state.wUnselectButton, sensitive=0
              widget_control, state.wModelModeRadio, sensitive=0
              ; try to change the current view...
              if ev.x ge 0 then begin
                state.oViewMan->setproperty,hide=1
                picked = state.win->select(state.scene,[ev.x,ev.y])
                state.oViewMan->setproperty, hide=0
              end
              state.oCurrentView->GetProperty, uvalue=view_uval
              if n_elements( *(state.model_lists[view_uval.num]) ) gt 1 then begin
                widget_control, state.wModelSelectButton, sensitive=1
              endif
            end
            ; point the oModelMan at the node...
            state.oModelMan->GetProperty,target=manip
            if (manip ne state.selected) then begin
              state.oModelMan->SetTarget,obj_new()
            end
            if ((state.selected ne state.oCurrentTopModel) and $
                (state.selected ne obj_new())) then begin
              state.oModelMan->SetTarget,state.selected
            end
            widget_control, state.text, set_value=str
            state.win->Draw, state.scene
          end
          ev.press EQ 2: begin
            state.win->setproperty, QUALITY=state.dragq
            widget_control,state.wDraw,/draw_motion
          end
          ev.press EQ 1: begin
            state.win->SetProperty, QUALITY=state.dragq
            widget_control, state.wDraw, /draw_motion
            state.btndown = 1b
            if ((state.selected ne state.oCurrentTopModel) and $
                (state.selected ne obj_new())) then begin
              state.oModelMan->MouseDown, [ev.x,ev.y], state.win
            end
          end
          else:
        endcase
      end
      2: begin ; Button motion.
        if state.btndown eq 1b then begin
          case 1 of
            (state.selected ne state.oCurrentTopModel) and  $
                              (state.selected ne obj_new()): begin
              state.oModelMan->MouseTrack, [ev.x,ev.y], state.win
              state.win->Draw, state.scene
            end
            else: begin
              ; Rotate.
              if have_mb1_transform then begin
                state.oWorldRotModel->GetProperty, transform=t
                state.oWorldRotModel->SetProperty, transform=t # mb1_transform
                state.win->Draw, state.scene
              end
            end
          endcase
        end
      end
      1: begin ; Button release.
        if state.btndown eq 1b then begin
          case 1 of
            (state.selected ne state.oCurrentTopModel) and $
            (state.selected ne obj_new()):state.oModelMan->MouseUp,[ev.x,ev.y],state.win
            else:
          endcase
        end
        state.btndown = 0b
        state.win->setproperty, QUALITY=2
        state.win->Draw, state.scene
        widget_control,state.wDraw,draw_motion=0
      end
      else:
    endcase
    widget_control, ev.top, set_uvalue=state, /no_copy
  end
  endcase
end
; -----------------------------------------------------------------
pro Chapter14HappyYou3DSControl
  device, get_screen_size = screensize
  xdim = screensize[0]*0.6   &   ydim = xdim*0.6
  wTopBase = widget_base( /column, title="HappyYou 3DS", xpad=0, ypad=0, $
          /tlb_kill_request_events, tlb_frame_attr=1, mbar=FileMenuBase )
  wFileButton = widget_button(FileMenuBase, value='File', /menu)
  wLoadButton = widget_button( wFileButton, value="Load", uval='LOAD' )
  wSaveButton = widget_button( wFileButton, value="Save Selection", uval='SAVE' )
  wPrintButton = widget_button( wFileButton, value="Print", uval='PRINT' )
  wVRMLButton = widget_button( wFileButton, value="Export VRML", uval='VRML' )
  void = widget_button( wFileButton, value='Quit', /separator, uvalue='QUIT' )
  wOptionsButton = widget_button(FileMenuBase, /menu, value="Options")
  wDragQ = widget_button(wOptionsButton, /menu, value="Drag Quality")
  wDragQLow = widget_button( wDragQ, value='Low', uval='DRAGQLOW' )
  wDragQMedium = widget_button( wDragQ, value='Medium', uval='DRAGQMEDIUM' )
  wDragQHigh = widget_button( wDragQ, value='High', uval='DRAGQHIGH' )
  wGridButton = widget_button( wOptionsButton, value="Show Grid (on )", uval='GRID' )
  wHelpButton = widget_button(FileMenuBase, value='3DS Help', /help, /menu)
  waboutbutton = widget_button(wHelpButton, value='Help', uvalue='HELP')
  waboutbutton = widget_button(wHelpButton, value='About 3DS', uvalue='ABOUT')
  wTopRowBase = widget_base(wTopBase,/row,/frame)
  addable_subjects = [ 'Sphere', 'Cube', 'Tetrahedron', 'Cone', 'Green Light', $
                       'Surface', 'Image',     'White Light','3D Text','Plot', $
                       'Ribbon Plot','Bar Plot' ]
  wGuiBase1 = widget_base(wTopRowBase, /column )
  wStackerBase = widget_base(wGuiBase1, xpad=0, ypad=0)
  wModelControlBase = widget_base(wStackerBase, xpad=0, ypad=0, /column )
  wModelModeRadio = cw_bgroup( wModelControlBase, ['Translate','Rotate','Scale'], $
                            /exclusive, /no_release, set_value=0, uvalue='MODELMODE')
  wAddButton = widget_button( wModelControlBase, value='Add', /menu )
  for i=0,n_elements(addable_subjects)-1 do begin
    void = widget_button(wAddButton, value=addable_subjects[i], $
    uvalue=['ADD', addable_subjects[i]] )
  end
  wAddChildButton = widget_button( wModelControlBase, value='Add Child', /menu )
  for i=0,n_elements(addable_subjects)-1 do begin
    void = widget_button(wAddChildButton, value=addable_subjects[i], $
      uvalue=['ADDCHILD', addable_subjects[i]] )
  end
  wModelDeleteButton = widget_button( wModelControlBase, value="Delete", uval='DEL' )
  wModelSelectButton = widget_button( wModelControlBase, value='Select', $
  uvalue='MODELSELECT' )
  wUnselectButton=widget_button(wModelControlBase,value='Unselect',uvalue='UNSELECT')
  wGuiBase2 = widget_base(wTopRowBase, xpad=0, ypad=0)
  wDraw = widget_draw(wGuiBase2, xsize=xdim, ysize=ydim,/button_ev, uval='DRAW', $
            retain=0, /expose_ev, graphics_level=2 )
  wStatusBase = widget_base(wTopBase, /row)
  wText = widget_label(wStatusBase, /dynamic_resize, value='')
  TempText = widget_label(wStatusBase, $
             value='    < Select by Right Button, Operate by Drag Left Button !>')
  widget_control, wTopBase, /realize
  widget_control, wdraw, get_value=win
  Scene=obj_new('IDLgrScene')
  oCurrentView = Chapter14HappyYou3DSControlmakeview(xdim,ydim,{name:'ObjView',num:0})
  oCurrentView->getproperty, dim=dim, loc=loc
  Scene->add, oCurrentView
  Chapter14HappyYou3DSControlgetviewobjs, $
      oCurrentView, oWorldRotModel, oBasePlatePolygon, oCurrentTopModel
  thefont = objarr(4)
  thefont[0] = obj_new('IDLgrFont','times',size=30)
  thefont[1] = obj_new('IDLgrFont','hershey*3',size=9)
  thefont[2] = obj_new('IDLgrFont','helvetica',size=40)
  thefont[3] = obj_new('IDLgrFont','helvetica',size=12)
  state = { oTrackballMB1: obj_new('trackball', (loc + dim/2.0), dim[0] / 2.0 ),   $
    oTrackballMB2: obj_new('trackball', (loc + dim/2.0), dim[0] / 2.0, mouse=2b ), $
    btndown: 0b, thefont: thefont, wDraw: wDraw,   $
    oWorldRotModel: oWorldRotModel, oBasePlatePolygon: oBasePlatePolygon,          $
    oCurrentView: oCurrentView,      $
    oModelMan : obj_new('IDLexModelManip', translate=[1,1,1],        $
    selector_color=[255,255,255], manipulator_color=[255, 60, 60] ), $
    oViewMan : obj_new('IDLexViewManip', color=[255, 0, 0] ),        $
    addable_subjects: addable_subjects, $
    text: wtext, win: win, oCurrentTopModel: oCurrentTopModel, $
    selected: oCurrentTopModel, Scene: Scene, dragq: 1, model_lists: ptrarr(50),  $
    wModelControlBase: wModelControlBase, wModelDeleteButton: wModelDeleteButton, $
    wAddChildButton: wAddChildButton,     wModelSelectButton: wModelSelectButton, $
    wModelModeRadio: wModelModeRadio,     wUnselectButton: wUnselectButton,   $
    wDragQLow: wDragQLow, wDragQMedium: wDragQMedium, wDragQHigh: wDragQHigh, $
    wGridButton: wGridButton, wLoadButton: wLoadButton, wSaveButton: wSaveButton, $
    model_cycle_pos: 1  }
  restore, demo_filepath('objw_surf.sav', subdir=['examples','demo','demodata'] ), $
                         /relaxed_structure_assignment
  tmp_obj->translate, 0, 0, .001, /premultiply
  state.selected->add, tmp_obj
  state.model_lists[0] = ptr_new([ tmp_obj, tmp_obj->get(position=1), obj_new()])
  state.selected = tmp_obj->Get(position=1)
  state.oModelMan->SetTarget, state.selected
  state.selected->getproperty,uvalue=s
  str = "Current selection :  " + s
  widget_control, state.text, set_value=str
  state.oWorldRotModel->rotate, [-1,0,0], 40
  state.oWorldRotModel->rotate, [0,1,0], 20
  state.oWorldRotModel->rotate, [0,0,1], 20
  widget_control, wDragQMedium, sensitive=0
  widget_control, wTopBase, set_uvalue=state, /no_copy
  xmanager,'Chapter14HappyYou3DSControl', $
    wTopBase,event_handler='Chapter14HappyYou3DSControlevent', $
    cleanup='Chapter14HappyYou3DSControlcleanup', /no_block
end
