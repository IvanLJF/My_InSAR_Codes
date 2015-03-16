; Chapter10VolumeRenderExercise.pro
;----------------------------------------------------------------------------
PRO Chapter10VolumeRendeBackground, MyStatus, MyView
    IF MyStatus THEN BEGIN
        MyView->Setproperty, color = [255, 255, 255]
    ENDIF ELSE BEGIN
        MyView->Setproperty, color = [0, 0, 0]
    ENDELSE
END
;----------------------------------------------------------------------------
pro Chapter10VolumeRenderExercise_Event, event
if (TAG_NAMES(event, /STRUCTURE_NAME) eq 'WIDGET_KILL_REQUEST') then begin
    WIDGET_CONTROL, event.top, /DESTROY
    RETURN
endif
WIDGET_CONTROL, event.id, GET_UVALUE=uval
WIDGET_CONTROL, event.top, GET_UVALUE=pState
case uval of
    'LMBMODE' : begin ; Left Mouse-Button Mode.
        WIDGET_CONTROL, event.top, GET_UVALUE=pState, /NO_COPY
        case event.index of
            0: begin
                (*pState).lmb_scale = 0
                (*pState).rModel->SetProperty, CONSTRAIN=0
                end
            1: begin
                (*pState).lmb_scale = 0
                (*pState).rModel->SetProperty, AXIS=0, /CONSTRAIN
                end
            2: begin
                (*pState).lmb_scale = 0
                (*pState).rModel->SetProperty, AXIS=1, /CONSTRAIN
                end
            3: begin
                (*pState).lmb_scale = 0
                (*pState).rModel->SetProperty, AXIS=2, /CONSTRAIN
                end
            4: begin
                (*pState).lmb_scale = 0
                (*pState).rModel->SetProperty, AXIS=0, CONSTRAIN=2
                end
            5: begin
                (*pState).lmb_scale = 0
                (*pState).rModel->SetProperty, AXIS=1, CONSTRAIN=2
                end
            6: begin
                (*pState).lmb_scale = 0
                (*pState).rModel->SetProperty, AXIS=2, CONSTRAIN=2
                end
            7: begin
                (*pState).lmb_scale = 1
                end
            else:
        endcase
        Chapter10VolumeRendeBackground, (*pState).TransparencyStatus, (*pState).rView
        (*pState).rWindow->Draw, (*pState).rView
        WIDGET_CONTROL, event.top, SET_UVALUE=pState, /NO_COPY
     end
    'CUTTING_PLANE' : begin
        WIDGET_CONTROL, event.top, GET_UVALUE=pState, /NO_COPY
        Chapter10VolumeRendeBackground, (*pState).TransparencyStatus, (*pState).rView
        (*pState).rVolume->GetProperty, YRANGE=yrange
        (*pState).rVolume->SetProperty, $
                  CUTTING_PLANE=[0,1,0, -(event.value / 100.) * yrange[1]]
        (*pState).rWindow->Draw, (*pState).rView
        WIDGET_CONTROL, event.top, SET_UVALUE=pState, /NO_COPY
     end
    'LIGHTING': begin
        WIDGET_CONTROL, event.top, GET_UVALUE=pState, /NO_COPY
        Chapter10VolumeRendeBackground, (*pState).TransparencyStatus, (*pState).rView
        (*pState).rVolume->SetProperty, LIGHTING_MODEL=event.select
        (*pState).rWindow->Draw, (*pState).rView
        WIDGET_CONTROL, event.top, SET_UVALUE=pState, /NO_COPY
     end
    'TransparencySlider': begin
        WIDGET_CONTROL, event.top, GET_UVALUE=pState, /NO_COPY
        Chapter10VolumeRendeBackground, (*pState).TransparencyStatus, (*pState).rView
        widget_control, (*pState).TransparencySlider, get_value = myslider
        opac = BYTARR(256)
        opac[0:255] = BINDGEN(256)/myslider
        (*pState).rVolume -> SetProperty, OPACITY_TABLE0=opac
        (*pState).rWindow->Draw, (*pState).rView
        WIDGET_CONTROL, event.top, SET_UVALUE=pState, /NO_COPY
     end
    'Transparency0n': begin
        WIDGET_CONTROL, event.top, GET_UVALUE=pState, /NO_COPY
        (*pState).TransparencyStatus = event.select
        Chapter10VolumeRendeBackground, (*pState).TransparencyStatus, (*pState).rView
        if (*pState).TransparencyStatus then begin
            widget_control, (*pState).TransparencySlider, SENSITIVE = 1
            widget_control, (*pState).TransparencySlider, set_value = 16
            opac = BYTARR(256)
            opac[0:255] = BINDGEN(256)/16
            (*pState).rVolume -> SetProperty, OPACITY_TABLE0 = opac
        endif else begin
            widget_control, (*pState).TransparencySlider, SENSITIVE = 0
            widget_control, (*pState).TransparencySlider, set_value = 0
            opac = BYTARR(256)
            for i=0,255 do opac[i] = i
            (*pState).rVolume -> SetProperty, OPACITY_TABLE0 = opac
        endelse
        (*pState).rWindow->Draw, (*pState).rView
        WIDGET_CONTROL, event.top, SET_UVALUE=pState, /NO_COPY
     end   ; of Transparency

;
;     Slice operation.
;
        'hfslicexslider': begin

            (*pState).rVolume->SetProperty, DATA0 = (*pState).originalvolumedata
         widget_control, (*pState).hSlice_x_slider, get_value = xvalue
         widget_control, (*pState).hSlice_y_slider, get_value = yvalue
         widget_control, (*pState).hSlice_z_slider, get_value = zvalue

         if  (*pState).hSlice_on_x_button_status or $
          (*pState).hSlice_on_y_button_status or $
          (*pState).hSlice_on_z_button_status then begin

             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)

               (*pState).rVolume->SetProperty, CUTTING_PLANE = 0

             if (*pState).hSlice_on_x_button_status then begin
              for j = 0, (*pState).volumeylength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[xvalue-1,j,k] = (*pState).originalvolumedata[xvalue-1,j,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_y_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[i,yvalue-1,k] = (*pState).originalvolumedata[i,yvalue-1,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_z_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for j = 0, (*pState).volumeylength-1 do begin
                   tmpdd[i,j,zvalue-1] = (*pState).originalvolumedata[i,j,zvalue-1]
                 endfor
              endfor
          endif

                (*pState).rVolume->SetProperty,DATA0 = tmpdd

         endif else begin
             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)
                tmpdd = (*pState).originalvolumedata
                (*pState).rVolume->SetProperty,DATA0 = tmpdd
               (*pState).rVolume->SetProperty, $
                   CUTTING_PLANE=[xvalue, yvalue, zvalue, -(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue)]
            endelse
            (*pState).rWindow->Draw, (*pState).rView

        end

        'hfsliceyslider': begin

            (*pState).rVolume->SetProperty, DATA0 = (*pState).originalvolumedata
         widget_control, (*pState).hSlice_x_slider, get_value = xvalue
         widget_control, (*pState).hSlice_y_slider, get_value = yvalue
         widget_control, (*pState).hSlice_z_slider, get_value = zvalue

         if  (*pState).hSlice_on_x_button_status or $
          (*pState).hSlice_on_y_button_status or $
          (*pState).hSlice_on_z_button_status then begin

             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)

               (*pState).rVolume->SetProperty, CUTTING_PLANE = 0

             if (*pState).hSlice_on_x_button_status then begin
              for j = 0, (*pState).volumeylength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[xvalue-1,j,k] = (*pState).originalvolumedata[xvalue-1,j,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_y_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[i,yvalue-1,k] = (*pState).originalvolumedata[i,yvalue-1,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_z_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for j = 0, (*pState).volumeylength-1 do begin
                   tmpdd[i,j,zvalue-1] = (*pState).originalvolumedata[i,j,zvalue-1]
                 endfor
              endfor
          endif

                (*pState).rVolume->SetProperty,DATA0 = tmpdd

         endif else begin
             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)
                tmpdd = (*pState).originalvolumedata
                (*pState).rVolume->SetProperty,DATA0 = tmpdd
               (*pState).rVolume->SetProperty, $
                   CUTTING_PLANE=[xvalue, yvalue, zvalue, -(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue)]
            endelse
            (*pState).rWindow->Draw, (*pState).rView

        end

        'hfslicezslider': begin

            (*pState).rVolume->SetProperty, DATA0 = (*pState).originalvolumedata
         widget_control, (*pState).hSlice_x_slider, get_value = xvalue
         widget_control, (*pState).hSlice_y_slider, get_value = yvalue
         widget_control, (*pState).hSlice_z_slider, get_value = zvalue

         if  (*pState).hSlice_on_x_button_status or $
          (*pState).hSlice_on_y_button_status or $
          (*pState).hSlice_on_z_button_status then begin

             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)

               (*pState).rVolume->SetProperty, CUTTING_PLANE = 0

             if (*pState).hSlice_on_x_button_status then begin
              for j = 0, (*pState).volumeylength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[xvalue-1,j,k] = (*pState).originalvolumedata[xvalue-1,j,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_y_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[i,yvalue-1,k] = (*pState).originalvolumedata[i,yvalue-1,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_z_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for j = 0, (*pState).volumeylength-1 do begin
                   tmpdd[i,j,zvalue-1] = (*pState).originalvolumedata[i,j,zvalue-1]
                 endfor
              endfor
          endif

                (*pState).rVolume->SetProperty,DATA0 = tmpdd

         endif else begin
             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)
                tmpdd = (*pState).originalvolumedata
                (*pState).rVolume->SetProperty,DATA0 = tmpdd
               (*pState).rVolume->SetProperty, $
                   CUTTING_PLANE=[xvalue, yvalue, zvalue, -(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue)]
            endelse
            (*pState).rWindow->Draw, (*pState).rView

        end

        'hfsliceon': begin

          (*pState).hSlice_on_status = event.select

             if (*pState).hSlice_on_status then begin

          widget_control, (*pState).hSlice_x_slider, SENSITIVE = 1
          widget_control, (*pState).hSlice_y_slider, SENSITIVE = 1
          widget_control, (*pState).hSlice_z_slider, SENSITIVE = 1
          widget_control, (*pState).hSlice_on_x_button, SENSITIVE = 1
          widget_control, (*pState).hSlice_on_y_button, SENSITIVE = 1
          widget_control, (*pState).hSlice_on_z_button, SENSITIVE = 1
          widget_control, (*pState).hSlice_save,     SENSITIVE = 1

          widget_control, (*pState).hSlice_x_slider, get_value = xvalue
          widget_control, (*pState).hSlice_y_slider, get_value = yvalue
          widget_control, (*pState).hSlice_z_slider, get_value = zvalue

               (*pState).rVolume->SetProperty, $
                    CUTTING_PLANE=[xvalue, yvalue, zvalue, -(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue)]

               (*pState).rWindow->Draw, (*pState).rView

            endif else begin

          widget_control, (*pState).hSlice_x_slider,    SENSITIVE = 0
          widget_control, (*pState).hSlice_y_slider,    SENSITIVE = 0
          widget_control, (*pState).hSlice_z_slider,    SENSITIVE = 0
          widget_control, (*pState).hSlice_on_x_button, SENSITIVE = 0
          widget_control, (*pState).hSlice_on_y_button, SENSITIVE = 0
          widget_control, (*pState).hSlice_on_z_button, SENSITIVE = 0
          widget_control, (*pState).hSlice_save,        SENSITIVE = 0

          widget_control, (*pState).hSlice_on_x_button, SET_BUTTON = 0
          widget_control, (*pState).hSlice_on_y_button, SET_BUTTON = 0
          widget_control, (*pState).hSlice_on_z_button, SET_BUTTON = 0

          (*pState).hSlice_on_x_button_status = 0
          (*pState).hSlice_on_x_button_status = 0
          (*pState).hSlice_on_x_button_status = 0

          widget_control, (*pState).hSlice_x_slider, set_value = 1
          widget_control, (*pState).hSlice_y_slider, set_value = 1
          widget_control, (*pState).hSlice_z_slider, set_value = 1

             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)
                tmpdd = (*pState).originalvolumedata
                (*pState).rVolume->SetProperty,DATA0 = tmpdd

               (*pState).rVolume->SetProperty, CUTTING_PLANE = 0

               (*pState).rWindow->Draw, (*pState).rView

            endelse

        end

        'hfsliceonxbutton': begin

         (*pState).hSlice_on_x_button_status = event.select

         (*pState).rVolume->SetProperty,DATA0 = (*pState).originalvolumedata

         (*pState).rVolume->SetProperty, CUTTING_PLANE=0

         widget_control, (*pState).hSlice_x_slider, get_value = xvalue
         widget_control, (*pState).hSlice_y_slider, get_value = yvalue
         widget_control, (*pState).hSlice_z_slider, get_value = zvalue


           if (*pState).hSlice_on_x_button_status or $
              (*pState).hSlice_on_y_button_status or $
              (*pState).hSlice_on_z_button_status then begin

          tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)

               (*pState).rVolume->SetProperty, CUTTING_PLANE = 0

             if (*pState).hSlice_on_x_button_status then begin
              for j = 0, (*pState).volumeylength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[xvalue-1,j,k] = (*pState).originalvolumedata[xvalue-1,j,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_y_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[i,yvalue-1,k] = (*pState).originalvolumedata[i,yvalue-1,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_z_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for j = 0, (*pState).volumeylength-1 do begin
                   tmpdd[i,j,zvalue-1] = (*pState).originalvolumedata[i,j,zvalue-1]
                 endfor
              endfor
          endif

                (*pState).rVolume->SetProperty,DATA0 = tmpdd

         endif else begin

             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)
                tmpdd = (*pState).originalvolumedata
                (*pState).rVolume->SetProperty,DATA0 = tmpdd

               (*pState).rVolume->SetProperty, $
                   CUTTING_PLANE=[xvalue, yvalue, zvalue, -(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue)]
            endelse
            (*pState).rWindow->Draw, (*pState).rView
        end

        'hfsliceonybutton': begin

         (*pState).hSlice_on_y_button_status = event.select

         (*pState).rVolume->SetProperty,DATA0 = (*pState).originalvolumedata

         (*pState).rVolume->SetProperty, CUTTING_PLANE=0

         widget_control, (*pState).hSlice_x_slider, get_value = xvalue
           widget_control, (*pState).hSlice_y_slider, get_value = yvalue
         widget_control, (*pState).hSlice_z_slider, get_value = zvalue


           if (*pState).hSlice_on_x_button_status or $
              (*pState).hSlice_on_y_button_status or $
              (*pState).hSlice_on_z_button_status then begin

          tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)

               (*pState).rVolume->SetProperty, CUTTING_PLANE = 0

             if (*pState).hSlice_on_x_button_status then begin
              for j = 0, (*pState).volumeylength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[xvalue-1,j,k] = (*pState).originalvolumedata[xvalue-1,j,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_y_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[i,yvalue-1,k] = (*pState).originalvolumedata[i,yvalue-1,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_z_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for j = 0, (*pState).volumeylength-1 do begin
                   tmpdd[i,j,zvalue-1] = (*pState).originalvolumedata[i,j,zvalue-1]
                 endfor
              endfor
          endif

                (*pState).rVolume->SetProperty,DATA0 = tmpdd

         endif else begin

             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)
                tmpdd = (*pState).originalvolumedata
                (*pState).rVolume->SetProperty,DATA0 = tmpdd

               (*pState).rVolume->SetProperty, $
                   CUTTING_PLANE=[xvalue, yvalue, zvalue, -(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue)]
            endelse
            (*pState).rWindow->Draw, (*pState).rView
        end

        'hfsliceonzbutton': begin

         (*pState).hSlice_on_z_button_status = event.select

         (*pState).rVolume->SetProperty,DATA0 = (*pState).originalvolumedata

         (*pState).rVolume->SetProperty, CUTTING_PLANE=0

         widget_control, (*pState).hSlice_x_slider, get_value = xvalue
           widget_control, (*pState).hSlice_y_slider, get_value = yvalue
         widget_control, (*pState).hSlice_z_slider, get_value = zvalue


           if (*pState).hSlice_on_x_button_status or $
              (*pState).hSlice_on_y_button_status or $
              (*pState).hSlice_on_z_button_status then begin

          tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)

               (*pState).rVolume->SetProperty, CUTTING_PLANE = 0

             if (*pState).hSlice_on_x_button_status then begin
              for j = 0, (*pState).volumeylength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[xvalue-1,j,k] = (*pState).originalvolumedata[xvalue-1,j,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_y_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for k = 0, (*pState).volumezlength-1 do begin
                   tmpdd[i,yvalue-1,k] = (*pState).originalvolumedata[i,yvalue-1,k]
                 endfor
              endfor
          endif

             if (*pState).hSlice_on_z_button_status then begin
              for i = 0, (*pState).volumexlength-1 do begin
                 for j = 0, (*pState).volumeylength-1 do begin
                   tmpdd[i,j,zvalue-1] = (*pState).originalvolumedata[i,j,zvalue-1]
                 endfor
              endfor
          endif

                (*pState).rVolume->SetProperty,DATA0 = tmpdd

         endif else begin

             tmpdd = intarr((*pState).volumexlength,(*pState).volumeylength,(*pState).volumezlength)
                tmpdd = (*pState).originalvolumedata
                (*pState).rVolume->SetProperty,DATA0 = tmpdd

               (*pState).rVolume->SetProperty, $
                   CUTTING_PLANE=[xvalue, yvalue, zvalue, -(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue)]
            endelse
            (*pState).rWindow->Draw, (*pState).rView

        end

        'hfslicesave': begin

         widget_control, (*pState).hSlice_x_slider, get_value = xvalue
         widget_control, (*pState).hSlice_y_slider, get_value = yvalue
         widget_control, (*pState).hSlice_z_slider, get_value = zvalue

         xvalue = float(xvalue)
         yvalue = float(yvalue)
         zvalue = float(zvalue)
         myangleline = float(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue)
         lvalue = myangleline/xvalue
         mvalue = myangleline/yvalue
         nvalue = myangleline/zvalue

         myxrotation = -acos(zvalue / sqrt(yvalue*yvalue+zvalue*zvalue))
         myyrotation = acos(sqrt(yvalue*yvalue+zvalue*zvalue) / sqrt(myangleline))
         myzrotation = !pi/2.0-acos(nvalue*nvalue / $
          (sqrt(mvalue*mvalue+nvalue*nvalue)*sqrt(lvalue*lvalue+nvalue*nvalue)))

         mymax = 3*((*pState).volumexlength>(*pState).volumexlength>(*pState).volumexlength)
         sliceimage = extract_slice((*pState).originalvolumedata, $
          mymax,mymax,xvalue,yvalue,zvalue, $
          myxrotation, myyrotation, myzrotation, out_val=0, /RADIANS)

         window, 0, xsize=mymax, ysize=mymax, $
          TITLE='Slice Show Window',RETAIN=2
         tvscl, sliceimage

         Slice = DIALOG_PICKFILE( FILE='Slice.tif', $
          FILTER='*.tif', /WRITE, TITLE='Saving Window ' )
         if   strlen(strtrim(slice)) ne 0 then begin
          WRITE_TIFF, slice, sliceimage
          result = dialog_message('OK! Slice is already saved !', /information, $
              title='Information Window')

         endif else begin
          result = dialog_message(['Sorry, Slice can not be saved !', '', $
              'File  name  can not be empty !'], $
              title='Warning Window')
         endelse
         WDELETE, 0

        end

    'DRAW': begin
        WIDGET_CONTROL, event.top, GET_UVALUE=pState, /NO_COPY
        Chapter10VolumeRendeBackground, (*pState).TransparencyStatus, (*pState).rView
        if (event.type eq 0) then $
           if (event.press eq 1) AND ((*pState).lmb_scale eq 1) then event.press = 2
;       Rotation updates.
        if (*pState).rModel->Update(event) then begin
              (*pState).rWindow->SetProperty, QUALITY=1
              (*pState).rWindow->Draw, (*pState).rView
        end
;       Mouse button press.
        if (event.type eq 0) then begin
            case event.press of
                2 : begin
;                     Middle mouse-button.  Scale the objects.
                      xy = ([event.x, event.y] - (*pState).center)
                      r= TOTAL(xy^2) ; distance from center of unit circle
                      (*pState).sc[1] = SQRT(r)
                      (*pState).sc[2] = 1.0
                    end
                4 : begin
;                     Right mouse-button
                      j = (*pState).rVolume->pickvoxel( $
                          (*pState).rWindow, (*pState).rView,[event.x, event.y])
                      k = -1
                      if (j[0] NE -1) then begin
                         (*pState).rVolume->GetProperty,DATA0=dd, /NO_COPY
                         k = dd[j[0],j[1],j[2]]
                         (*pState).rVolume->SetProperty,DATA0=dd, /NO_COPY
                      end
;                     Display the point coordinates and its value.
                      str = string(j[0], j[1], j[2], k, $
                         FORMAT='("X=",I3.3,",Y=",I3.3,",Z=",I3.3,",Value=",I3.3)')
                      WIDGET_CONTROL, (*pState).InformationLabel, SET_VALUE = str
                    end
                else:
            endcase
            (*pState).btndown = event.press
            WIDGET_CONTROL,(*pState).wDraw, /DRAW_MOTION
        endif
;       Mouse-button motion.
        if event.type eq 2 then begin
            case (*pState).btndown of
                4: begin ; Right mouse-button.
                     j = (*pState).rVolume->pickvoxel( $
                         (*pState).rWindow, (*pState).rView,[event.x,event.y])
                     k= -1
                     if (j[0] NE -1) then begin
                        (*pState).rVolume->GetProperty, DATA0=dd, /NO_COPY
                         k = dd[j[0],j[1],j[2]]
                        (*pState).rVolume->SetProperty, DATA0=dd, /NO_COPY
                     end
                     str = string( j[0], j[1], j[2], k, $
                        FORMAT='("X=",I3.3,",Y=",I3.3,",Z=",I3.3,",Value=",I3.3)')
                     WIDGET_CONTROL, (*pState).InformationLabel, SET_VALUE = str
                   end
                2: begin
                    xy = ([event.x,event.y] - (*pState).center)
                    r = total(xy^2) ; distance from center of unit circle
                    (*pState).sc[2] = (SQRT(r) / (*pState).sc[1]) / (*pState).sc[2]
                    (*pState).rScaleToys->Scale, $
                        (*pState).sc[2], (*pState).sc[2], (*pState).sc[2]
                    (*pState).rModel->GetProperty, RADIUS=radius
                    (*pState).rModel->SetProperty, RADIUS=radius*(*pState).sc[2]
                    (*pState).sc[2] = (SQRT(r)/(*pState).sc[1])
                    (*pState).rWindow->SetProperty, QUALITY=1
                    (*pState).rWindow->Draw, (*pState).rView
                    end
                else:
            endcase
        end
;       Mouse-button release.
        if (event.type eq 1) then begin
            case (*pState).btndown of
                2: begin
                     (*pState).sc[0] = (*pState).sc[2] * (*pState).sc[0]
                   end
                4: begin
                     j = (*pState).rVolume->pickvoxel( $
                         (*pState).rWindow,(*pState).rView,[event.x,event.y])
                     k = -1
                     if (j[0] NE -1) then begin
                        (*pState).rVolume->GetProperty, DATA0=dd, /NO_COPY
                        k = dd[j[0],j[1],j[2]]
                        (*pState).rVolume->SetProperty, DATA0=dd, /NO_COPY
                        str = string(j[0], j[1], j[2], k,  $
                           FORMAT='("X=",I3.3,",Y=",I3.3,",Z=",I3.3,",Value=",I3.3)')
                        WIDGET_CONTROL, (*pState).InformationLabel, SET_VALUE = str
                     end
                   end
                else:
            endcase
            (*pState).btndown = 0
            WIDGET_CONTROL, (*pState).wDraw, DRAW_MOTION=0
        endif
        WIDGET_CONTROL, event.top, SET_UVALUE=pState, /NO_COPY
      end
      else:
  endcase
end
;----------------------------------------------------------------------------
pro Chapter10VolumeRenderExerciseCleanup,wTopBase
WIDGET_CONTROL, wTopBase, GET_UVALUE=pState
for i=0,n_tags(*pState)-1 do begin
    case size((*pState).(i), /TNAME) of
        'POINTER':  ptr_free,    (*pState).(i)
        'OBJREF' :  obj_destroy, (*pState).(i)
        else:
    endcase
end
end
;----------------------------------------------------------------------------
pro Chapter10VolumeRenderExercise
device, GET_SCREEN_SIZE = scr
xdim = scr[0] * 0.4  &  ydim = xdim * 0.8
rTopModel = OBJ_NEW('IDLgrModel')
rModel = OBJ_NEW('IDLexRotator', [xdim/2.0, ydim/2.0], xdim/2.0)
rView = OBJ_NEW('IDLgrView')
rView->Add, rTopModel
rTopModel->Add, rModel
rScaleToys = obj_new('IDLgrModel')
rModel->Add, rScaleToys
WIDGET_CONTROL, /HOURGLASS
restore, demo_filepath('mri.sav',SUBDIR=['examples','demo','demodata'])
i = SIZE(vol0)
m = i[1] > i[2] > (i[3] * 1.0)
sx = 1.0 / m  &  sy = 1.0 / m  &  sz =(1.0 / m) * 1.0     ; scale  x, y, z.
ox = -i[1] * sx * 0.5 & oy = -i[2] * sy * 0.5 & oz = -i[3] * sz * 0.5 ; offset x,y,z.
rVolume = OBJ_NEW('IDLgrVolume', vol0, /ZERO_OPACITY_SKIP, /ZBUFFER, HINT=2, $
    xcoord_conv=[ox, sx], ycoord_conv=[oy, sy], zcoord_conv=[oz, sz], /NO_COPY)
rScaleToys->Add, rVolume
rModel->Rotate,[0,0,1],-45
rModel->Rotate,[1,0,0],-75
;Create Axes
xpc = [-1.,1.,0.,0.,0.,0.]
ypc = [0.,0.,-1.,1.,0.,0.]
zpc = [0.,0.,0.,0.,-1.,1.]
plc = [2,0,1,2,2,3,2,4,5]
vcc = [[255B,0B,0B],[255B,0B,0B],[0B,255B,0B],[0B,255B,0B],[0B,0B,255B],[0B,0B,255B]]
rObject=OBJ_NEW('IDLgrPolyline',xpc,ypc,zpc,POLYLINES=plc,VERT_COLOR=vcc)
rScaleToys->Add, rObject
vl = OBJ_NEW('IDLgrLight', DIRECTION=[-1,0,1], TYPE=2)
vl->SetProperty, COLOR=[255,255,255], INTENSITY=1.0
sl = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=1.0)
rTopModel->Add, vl
rTopModel->Add, sl
wBase = WIDGET_BASE(/COLUMN,XPAD=0,YPAD=0,TITLE="Volume Rendering", $
        /TLB_KILL_REQUEST_EVENTS, TLB_FRAME_ATTR=1)
subBase = WIDGET_BASE(wBase, COLUMN=2)
wLeftbase = WIDGET_BASE(subBase, /COLUMN, /FRAME)
void=WIDGET_LABEL(wLeftBase,VALUE='Left Mouse Button Action:',/ALIGN_LEFT)
wLMBMode = WIDGET_DROPLIST(wLeftBase,       $ ;left mouse-button mode
           VALUE=["Rotate Unconstrained",       "Rotate about Screen X",      $
                  "Rotate about Screen Y",      "Rotate about Screen Z",      $
                  "Rotate about Data X (Red)",  "Rotate about Data Y (Green)",$
                  "Rotate about Data Z (Blue)", "Scale"],                     $
           UVALUE='LMBMODE', /ALIGN_LEFT )
wNonExclusiveBase = WIDGET_BASE(wLeftBase, /NONEXCLUSIVE, /FRAME)
wLightButton=WIDGET_BUTTON(wNonExclusiveBase,VALUE="Lighting",UVALUE='LIGHTING')
wCuttingSlider=WIDGET_SLIDER(wLeftBase, TITLE='Cutting Plane',UVALUE='CUTTING_PLANE')
TransparencyBase = Widget_Base(wLeftBase,  FRAME=1 $
      ,SCR_XSIZE=169 ,SCR_YSIZE=66 ,SPACE=3 ,XPAD=3 ,YPAD=3)
TransparencySlider = Widget_Slider(TransparencyBase , SENSITIVE = 0 $
      ,XOFFSET=10 ,YOFFSET=3 ,MINIMUM=0 ,MAXIMUM=255 ,VALUE=0 $
      ,SCR_XSIZE=148 ,SCR_YSIZE=33 ,UVALUE='TransparencySlider')
TransparencyLabel =  Widget_Label(TransparencyBase, XOFFSET=9 ,YOFFSET=43 $
      ,SCR_XSIZE=80 ,SCR_YSIZE=16 ,/ALIGN_LEFT ,VALUE='Transparency')
TransparencyOnBase = Widget_Base(TransparencyBase, XOFFSET=90 ,YOFFSET=36  $
      ,SCR_XSIZE=60 ,SCR_YSIZE=22 ,XPAD=3 ,YPAD=3 ,COLUMN=1 ,/NONEXCLUSIVE)
TransparencyOn=Widget_Button(TransparencyOnBase,XOFFSET=3,YOFFSET=3,SCR_XSIZE=70  $
      ,SCR_YSIZE=20 ,/ALIGN_LEFT ,VALUE='On/Off', UVALUE='Transparency0n')

hSlice_base = Widget_Base(wLeftBase,  $
      UNAME='hSlice_base' ,FRAME=1 ,XOFFSET=837 ,YOFFSET=20  $
      ,SCR_XSIZE=169 ,SCR_YSIZE=166 ,SPACE=3 ,XPAD=3 ,YPAD=3)

Slice_label = Widget_Label(hSlice_base,  $
      UNAME='Slice_label' ,XOFFSET=12 ,YOFFSET=3  $
      ,SCR_XSIZE=150 ,SCR_YSIZE=18 ,/ALIGN_CENTER ,VALUE='Slice Operation')

hSlice_base_line = Widget_Base(hSlice_base,  $
      UNAME='hSlice_base_line' ,FRAME=1 ,XOFFSET=6  $
      ,YOFFSET=25 ,SCR_XSIZE=146 ,SCR_YSIZE=2 ,SPACE=3 ,XPAD=3 ,YPAD=3)

Slice_x_label = Widget_Label(hSlice_base,  $
      UNAME='Slice_x_label' ,XOFFSET=2 ,YOFFSET=46  $
      ,SCR_XSIZE=18 ,SCR_YSIZE=18 ,/ALIGN_CENTER ,VALUE='X')

Slice_y_label = Widget_Label(hSlice_base,  $
      UNAME='Slice_y_label' ,XOFFSET=2 ,YOFFSET=80  $
      ,SCR_XSIZE=18 ,SCR_YSIZE=18 ,/ALIGN_CENTER ,VALUE='Y')

Slice_z_label = Widget_Label(hSlice_base,  $
      UNAME='Slice_z_label' ,XOFFSET=2 ,YOFFSET=113  $
      ,SCR_XSIZE=19 ,SCR_YSIZE=18 ,/ALIGN_CENTER ,VALUE='Z')

hSlice_x_slider = Widget_Slider(hSlice_base,  $
      UNAME='Slice_x_slider' ,XOFFSET=20 ,YOFFSET=29  $
      ,SCR_XSIZE=100 ,SCR_YSIZE=32 ,MINIMUM=1 ,MAXIMUM=200 ,VALUE=1 ,$
      UVALUE='hfslicexslider')

hSlice_y_slider = Widget_Slider(hSlice_base,  $
      UNAME='Slice_y_slider' ,XOFFSET=20 ,YOFFSET=62  $
      ,SCR_XSIZE=100 ,SCR_YSIZE=32 ,MINIMUM=1 ,MAXIMUM=200 ,VALUE=1 ,$
      UVALUE='hfsliceyslider')

hSlice_z_slider = Widget_Slider(hSlice_base,  $
      UNAME='Slice_z_slider' ,XOFFSET=20 ,YOFFSET=95  $
      ,SCR_XSIZE=100 ,SCR_YSIZE=32 ,MINIMUM=1 ,MAXIMUM=200 ,VALUE=1 ,$
      UVALUE='hfslicezslider')

Slice_on_label = Widget_Label(hSlice_base,  $
      UNAME='Slice_on_label' ,XOFFSET=130 ,YOFFSET=30  $
      ,/ALIGN_LEFT ,VALUE='On')

Slice_on_x_base = Widget_Base(hSlice_base,  $
      UNAME='Slice_on_x_base' ,XOFFSET=130 ,YOFFSET=40  $
      ,SCR_XSIZE=18 ,SCR_YSIZE=22 ,COLUMN=1 ,/NONEXCLUSIVE)

hSlice_on_x_button = Widget_Button(Slice_on_x_base,  $
      UNAME='Slice_on_x_button' ,/ALIGN_LEFT ,VALUE='' ,$
      UVALUE='hfsliceonxbutton')

Slice_on_y_base = Widget_Base(hSlice_base,  $
      UNAME='Slice_on_y_base' ,XOFFSET=130 ,YOFFSET=73  $
      ,SCR_XSIZE=18 ,SCR_YSIZE=22 ,COLUMN=1 ,/NONEXCLUSIVE)

hSlice_on_y_button = Widget_Button(Slice_on_y_base,  $
      UNAME='Slice_on_y_button' ,/ALIGN_LEFT ,VALUE='' ,$
      UVALUE='hfsliceonybutton')

Slice_on_z_base = Widget_Base(hSlice_base,  $
      UNAME='Slice_on_z_base' ,XOFFSET=130 ,YOFFSET=106  $
      ,SCR_XSIZE=18 ,SCR_YSIZE=22 ,COLUMN=1 ,/NONEXCLUSIVE)

hSlice_on_z_button = Widget_Button(Slice_on_z_base,  $
      UNAME='Slice_on_z_button' ,/ALIGN_LEFT ,VALUE='' ,$
      UVALUE='hfsliceonzbutton')

Slice_on_base = Widget_Base(hSlice_base,  $
      UNAME='Slice_on_base' ,XOFFSET=14 ,YOFFSET=133  $
      ,SCR_XSIZE=60 ,SCR_YSIZE=20 ,YPAD=3 ,COLUMN=1 ,/NONEXCLUSIVE)

hSlice_on = Widget_Button(Slice_on_base,  $
      UNAME='Slice_on' ,YOFFSET=3 ,SCR_XSIZE=66  $
      ,SCR_YSIZE=20 ,/ALIGN_LEFT ,VALUE='On/Off' ,$
      UVALUE='hfsliceon')

hSlice_save = Widget_Button(hSlice_base,  $
      UNAME='Slice_save' ,XOFFSET=100 ,YOFFSET=135  $
      ,SCR_XSIZE=43 ,SCR_YSIZE=20 ,/ALIGN_CENTER ,VALUE='Save' ,$
      UVALUE='hfslicesave')

InformationLabel=Widget_Label(wLeftBase,VALUE='Information',/FRAME,/DYNAMIC_RESIZE)
      wRightbase = WIDGET_BASE(subBase)
wDraw=WIDGET_DRAW(wRightBase,GRAPHICS_LEVEL=2,XSIZE=xdim,YSIZE=ydim,/BUTTON_EVENTS, $
                  UVALUE='DRAW', RETAIN=0, /EXPOSE_EVENTS, RENDERER=1)
WIDGET_CONTROL, wBase, /REALIZE
WIDGET_CONTROL, wBase, /CLEAR_EVENTS
WIDGET_CONTROL, wDraw, GET_VALUE=rWindow
zoom = sqrt(2)
myview = [-.5, -.5, 1, 1] * zoom
aspect = FLOAT(xdim)/FLOAT(ydim)
if (aspect gt 1) then begin
    myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
    myview[2] = myview[2] * aspect
endif else begin
    myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
    myview[3] = myview[3] / aspect
endelse
rView->SetProperty, VIEWPLANE_RECT=myview, PROJECTION=1, $
    EYE=2.0, ZCLIP=[1.0,-1.0], COLOR=[0,0,0]
rVolume->GetProperty,DATA0 = originalvolumedata
pState = PTR_NEW({         $
    center:[xdim,ydim]/2., radius:ydim/2, lmb_scale:0, btndown: 0b, sc:FLTARR(3), $
    TransparencyStatus:0, TransparencySlider: TransparencySlider,          $
    wDraw: wDraw, rVolume: rVolume, InformationLabel:InformationLabel,     $
    rScaleToys: rScaleToys, rModel:rModel, rView: rView, rWindow: rWindow, $

    originalvolumedata: originalvolumedata,    $
    volumexlength: i[1],            $
    volumeylength: i[2],            $
    volumezlength: i[3],            $

    hSlice_base: hSlice_base,                      $
    hSlice_x_slider: hSlice_x_slider,              $
    hSlice_y_slider: hSlice_y_slider,              $
    hSlice_z_slider: hSlice_z_slider,              $
    hSlice_on_x_button: hSlice_on_x_button,        $
    hSlice_on_y_button: hSlice_on_y_button,        $
    hSlice_on_z_button: hSlice_on_z_button,        $
    hSlice_on_x_button_status: 0,                           $
    hSlice_on_y_button_status: 0,                           $
    hSlice_on_z_button_status: 0,                           $
    hSlice_on: hSlice_on,                          $
    hSlice_on_status: 0,                                    $ ; 1=yes, 0=no
    hSlice_save: hSlice_save                       $
    })
WIDGET_CONTROL, wBase, SET_UVALUE=pState
WIDGET_CONTROL, (*pState).hSlice_x_slider,    SENSITIVE = 0
WIDGET_CONTROL, (*pState).hSlice_y_slider,    SENSITIVE = 0
WIDGET_CONTROL, (*pState).hSlice_z_slider,    SENSITIVE = 0
WIDGET_CONTROL, (*pState).hSlice_on_x_button, SENSITIVE = 0
WIDGET_CONTROL, (*pState).hSlice_on_y_button, SENSITIVE = 0
WIDGET_CONTROL, (*pState).hSlice_on_z_button, SENSITIVE = 0
WIDGET_CONTROL, (*pState).hSlice_save,        SENSITIVE = 0

(*pState).rVolume->SetProperty, VOLUME_SELECT=0
(*pState).rVolume->SetProperty, INTERPOLATE=1
(*pState).rWindow->SetProperty, QUALITY=2
rWindow->Draw, rView
XMANAGER, 'Chapter10VolumeRenderExercise', wBase, $
       CLEANUP='Chapter10VolumeRenderExerciseCleanup', /NO_BLOCK
end
