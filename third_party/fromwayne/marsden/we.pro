pro wcalhist_event,ev
;************************************************************************
; Program handles the events in the callibration histogram widget
; wcalhist.pro, and communicates to the manager program
; calhist.pro via common block variables
; 6/10/94 Current version
; 8/26/94 Annoying print statements eliminated
;************************************************************************
common chev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
 a_counts,a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,rates1,num_chns,$
 num_spec,det_str,fnme
common calhist_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common parms,start,new,clear
on_ioerror, bad
type = tag_names(ev,/structure)
widget_control,ev.id,get_value=value
wold = wcalhist.base
;***********************************************************************
; Change the parameters in fitbox
;***********************************************************************
if (type eq 'WIDGET_TEXT') then begin
   fitbox_parms,ev,num_lines,strtbin,stpbin
   widget_control,ev.id,get_uvalue=ndx
   print,'ndx=',ndx,'entry=',entry(0)
   if (fix(ndx) eq 33)then begin
      widget_control,ev.id,get_value = entry
      entr = entry(0)
      if (fnme eq 'get ascii file')then begin
         make_file,idfs,idfe,dt,a_counts,a_lvtme,entr
         if (entr eq 'error')then fnme = 'get ascii file' else $
                                  fnme = '' 
         new = 0 & start = 0
         calhist
      endif else begin
         fnme = ''
         save,file=entr,idf_hdr,idf,date,spectra,livetime,typ,dc,opt,$
                        counts,lvtme,idfs,idfe,disp,a_counts,$
                        a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,$
                        rates1,num_chns,num_spec,det_str,fnme
         new = 0 & start = 0
         calhist
      endelse
   endif         
endif
if (type eq 'WIDGET_BUTTON') then begin
;***********************************************************************
; Fitting model selected - do fitting widget
;***********************************************************************
   get_mdl,value,mdl
   if (mdl ne '-1')then begin
      fit_stor,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,nfree,rt,$
      idfs,idfe,dt,cp,ltime,opt,det,'CALHIST',strtbin,stpbin,0
      fitit
   endif
;***********************************************************************
; Session buttons
;***********************************************************************
   if(value eq 'DONE') then begin
      spectra(*,*,*) = 0
      counts(*,*,*,*) = 0 & a_counts(*,*,*) = 0
      lvtme(*,*,*) = 0 & a_lvtme(*,*) = 0
      widget_control,/destroy,ev.top
   endif
;***********************************************************************
; Standard buttons
;***********************************************************************
   options,value,opt,disp,det_str,dc,fnme
;***********************************************************************
; Clear button to clear arrays
;***********************************************************************
   if(value eq 'CLEAR')then begin
      clear = 1
      calhist
   endif
;**********************************************************************
; Update button doing changes
;**********************************************************************
   if(value eq 'UPDATE')then begin
      new = 0
      start = 0
      calhist
   endif
endif
;**************************************************************************
; Thats all ffolks I
;**************************************************************************
return
;***********************************************************************
; Error handling routine
;***********************************************************************
bad : print,'BAD FILENAME ENTERED!'
fnme = 'get idl file'
new = 0 & start = 0
calhist
;***********************************************************************
; Thats all ffolks II
;***********************************************************************
return
end