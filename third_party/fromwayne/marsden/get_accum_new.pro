pro get_accum,fil,a_counts,a_livetime,idfs,idfe,dt,pha_edgs,det_str,$
              idf_lvtme,area,clstr_pos,mode=mode,num=num,$
              period=period,noroll=noroll,idfrange=idfrange
;********************************************************************
; Program reads the accumulated file 'rec____.dat' and 
; accumulates the idl arrays.
; Variables are:
;         fil................file(s) for accumulated data
;    a_counts................accumulated counts
;  a_livetime................accumulated livetime
;   idfs,idfe................start/stop idf #s
;          dt................array of dates and times
;    pha_edgs................  "    " pha edges
;                            (multiscalar & archive m.)
;     det_str................which phoswich string (phapsa)
;         chc................data type for event list
;        mode................skip widgets, start events accumulation
;         num................# of IDFs to accumulate
;   idf_lvtme................array of livetimes/idf
;        area................array of areas (cm^2) vs idf per det.
;      ra,dec................ra/dec of source 
;     phz_arr................folded light curve (multiscalar)
;      period................folding period (s) 
;      noroll................doesn't ''decompress'' archist data
;    idfrange................only processes data in spec. idf range
; Define the common blocks:
;**********************************************************************
common parms,start,new,clear
common basecom,base,idfold,beep,chc
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common lastpos,last2pos
common evt_parms,prms,go,prms_save,burst
;**********************************************************************
; Display the usage.
;**********************************************************************
if (n_params() eq 0)then begin
   print,'Usage : get_accum,files,counts,livetime,idfstart,idfend,' + $
         'date,pha,det,idf_lvtme,area,clstr_pos,[MODE=see below],' + $
         '[NUM=# of IDFs to accum.],[PERIOD=period of flc],' + $
         '[NOROLL=no archist decomp.],[IDFRANGE=(startidf,endidf)]'
   print,''
   print,'For operation without widgets, set mode='
   print,'		"h" for histogram bin output'
   print,'		"p" for phapsa output'
   print,'              "m" for multiscalar output'
   print,''
   print,'!!NOTE!! Can do a different IDF range for each file (4/6/96)' 
   return
endif
;**********************************************************************
; Set some control variables
;**********************************************************************
num_files = n_elements(fil)
start = 1 & clear = 0
count = 0 & idfold = 0
go = 0
if (ks(idfrange) eq 0)then idfrange = [0l,0l]
last2pos = ['?','?']
nowait = 0
chc = ''
if (ks(num) eq 0)then num = long(1.e5) else num = num + long(1)
if (ks(mode) ne 0)then begin
   if (mode ne 'h' and mode ne 'p' and mode ne 'm')then begin
      print,'EVENT LIST MODE NOT AVAILABLE'
      return
   endif
   chc = mode  
endif
for i = 0,num_files-1 do begin 
;**********************************************************************
; Start accumulation while there is still data in the file:
;**********************************************************************
 if (n_elements(idfrange) gt 2)then begin
    temp = [idfrange(0,i),idfrange(1,i)]
    idfrnge = [min(temp)-1l,max(temp)]
 endif else idfrnge = [min(idfrange)-1l,max(idfrange)]
 if (num_files eq 1)then file = fil else file = fil(i)
 print,'ACCUMULATING DATA FROM FILE ',file
 new_file = 1 & acc = '1' 
 while (acc eq '1' and count le num-long(1)) do begin
    flag = 1
    new = 1 & idflost = -1
    if (new_file)then begin 
       get_data,file,typ,idf,date,spectra,livetime,lost_events,idf_hdr
       new_file = 0
    endif else begin
       get_data,file,typ,idf,date,spectra,livetime,lost_events,$
                idf_hdr,flag
    endelse
    if (total(idfrange) eq 0)then in = 1 else begin
       in = idf ge idfrnge(0) and idf le idfrnge(1) + 1l
       if (idf ge idfrnge(1) + 1l) then acc = '0'
    endelse
    if (count eq 0 and in eq 1)then idf0 = idf
    if (typ eq 'BRST')then burst = 1 else burst = 0
    special = typ eq 'EVTs' or typ eq 'BRST'
    if (string(flag) eq 'done')then begin
       in = 0 
       acc = '0'
    endif
    if (special and idf ne idfold and in)then begin
;**********************************************************************
; Event list idf:
;**********************************************************************
       nowait = burst
       if (count eq 0 and ks(mode) eq 0)then wevt
       if (chc eq 'h')then begin
          if (count eq 0 and ks(prms) eq 0)then begin
             prms = [1.,0.,63.,2] & prms_save = prms
          endif
          make_hist,typ,spectra
       endif
       if (chc eq 'p')then begin
          if (count eq 0 and ks(prms) eq 0)then begin
             prms = [1.,1.,1.,1.] & prms_save = prms
          endif
          make_ph,typ,spectra,idf_hdr
       endif
       if (chc eq 'm')then begin
          if (count eq 0 and ks(prms) eq 0)then begin
             prms = [16.,2,0,1,10,20,40,70,100,150,200,256]
             prms_save = prms
          endif
          make_ms,typ,spectra,idf_hdr
       endif
       if (chc eq 'prs')then begin
          prs = 1
          if (count eq 0 and ks(prms) eq 0)then begin
             prms = [1.,0.,0.,10.] & prms_save = prms
          endif
          del = dblarr(2)
          del(0) = double(long(16.*(idf-idf0)))
          make_prs,typ,spectra,livetime,idf_hdr,del=del
       endif   
    endif
    if (typ eq 'HSTs' and idf ne idfold) then begin
;**********************************************************************
; Histogram Idf:
;**********************************************************************
       hist_stor,idf_hdr,idf,date,spectra,livetime,typ,idflost,$
                 no=nowait
       hist,1,pr=prs
       count = count + 1
       idfold = idf 
    endif
    if (typ eq 'PHSs' and idf ne idfold) then begin
;**********************************************************************
; Pha Psa Idf:
;**********************************************************************
       phapsa_stor,idf_hdr,idf,date,spectra,livetime,typ,idflost,$
                  no=nowait
       phapsa,1
       count = count + 1
       idfold = idf
    endif
    if (typ eq 'MSCs' and idf ne idfold)  then begin
;**********************************************************************
; Multiscalar Idf
;**********************************************************************
       msclr_stor,idf_hdr,idf,date,spectra,livetime,typ,idflost,$
                  no=nowait
       msclr,1
       count = count + 1
       idfold = idf 
    endif
;**********************************************************************
; If lost idf print two previous cluster positions
;**********************************************************************
    if (idflost ne -1)then begin
       print,'IDF ',idflost,' LOST, PREVIOUS TWO CLUSTER '+ $
             'POSITIONS WERE : ',last2pos(0),', ',last2pos(1)
       last2pos(0) = '?'
    endif
;**********************************************************************
; Update last two cluster positions
;**********************************************************************
    last2pos = shift(last2pos,1)
    last2pos(0) = idf_hdr.clstr_postn
    if (typ eq 'ARCh' and idf ne idfold) then begin  
;**********************************************************************
; Archive histogram Idf:
;**********************************************************************
       archist_stor,idf_hdr,idf,date,spectra,livetime,typ,noroll
       archist,1
       count = count + 1
       idfold = idf & start = 0
    endif
    if (typ eq 'ARCm' and idf ne idfold)  then begin
;**********************************************************************
; Archive multiscalar Idf
;**********************************************************************
       am_stor,idf_hdr,idf,date,spectra,livetime,typ
       am,1
       count = count + 1
       idfold = idf & start = 0
    endif
    if (typ eq 'CALh' and idf ne idfold) then begin
;**********************************************************************
; Callibration histogram Idf:
;**********************************************************************
       calhist_stor,idf_hdr,idf,date,spectra,livetime,typ
       calhist,1
       count = count + 1
       idfold = idf & start = 0
    endif
 endwhile
endfor
;**********************************************************************
; Load the HEXTE collimator template. Ignore RA and DEC for 
; initial fast accumulation.
;**********************************************************************
if (chc eq 'prs')then period = prms(0)
if (ks(mode) eq 0)then begin
;**********************************************************************
; Option for start of widgets session
;**********************************************************************
   print,'START WIDGETS SESSION (y/n) ?'
   ans = ''
   read,ans
   if (ans eq 'y')then begin
      new = 0 & start = 0
      case typ of 
         'HSTs' : hist,pr=prs
         'ARCh' : archist
         'CALh' : calhist
         'MSCs' : msclr
         'ARCm' : am
         'PHSs' : phapsa
         'EVTs' : wevt
      endcase
   endif
endif
;**********************************************************************
; Done accumulating, now go get accumulated quantities from
; the common blocks:
;**********************************************************************
case typ of
   'HSTs' : hev_get,a_counts,a_livetime,idfs,idfe,dt,idf_lvtme,area,$
            clstr_pos
   'ARCh' : archev_get,a_counts,a_livetime,idfs,idfe,dt,idf_lvtme,$
            area,clstr_pos
   'CALh' : chev_get,a_counts,a_livetime,idfs,idfe,dt,idf_lvtme,$
            area,clstr_pos
   'MSCs' : mev_get,a_counts,a_livetime,idfs,idfe,pha_edgs,dt,$
            idf_lvtme,clstr_pos,phz_arr,period
   'ARCm' : amev_get,a_counts,a_livetime,idfs,idfe,pha_edgs,dt,$
            idf_lvtme,clstr_pos,phz_arr,period
   'PHSs' : pev_get,a_counts,a_livetime,idfs,idfe,det_str,dt,$
            idf_lvtme
endcase
;**********************************************************************
; All done, print idf range and array information
;**********************************************************************
print,'IDFS ',idfs,' TO ',idfe,' ACCUMULATED'
if (typ ne 'EVTs')then begin
   print,'CLUSTER POSITION INDEX :'
   print,'0............OFF SOURCE (+)'
   print,'1............OFF SOURCE (-)'
   print,'2............ON SOURCE'
   print,'3............ANY'
endif
;**********************************************************************
; Flush variables from the common blocks, making it unecessary
; to exit IDL before using it again.
;**********************************************************************
if (chc eq 'prs')then period = prms(0)
base = 0 & idfold = 0 & beep = 0 & chc = 0
whist = 0 & wphapsa = 0 & wcalhist = 0 & wmsclr = 0 & warchist = 0 
wam = 0 & wfit = 0 & wold = 0 & idflost = -1
prms = 0 & go = 0 & prms_save = 0
case typ of 
   'HSTs' : flush_hist
   'ARCh' : flush_arch
   'CALh' : flush_calh
   'MSCs' : flush_mscl
   'ARCm' : flush_amsc
   'PHSs' : flush_phap
   'EVTs' : flush_evts
endcase
;**********************************************************************
; Thats all ffolks
;**********************************************************************
return
end
