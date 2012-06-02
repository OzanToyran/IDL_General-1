pro msclr,noplot,iarr=iarr
;**********************************************************************
; Program governs the interaction between the
; multiscalar widget (wmsclr.pro) and the event manager
; (wmsclr_event.pro). Variables are:
;           dc.................detector code
;           cp.................cluster position
;         iarr.................array of idfs contributing data 
;     pha_edgs.................pha channel grouping edges
;       update.................do changes
;      idf_hdr.................science header data
;       counts.................1 idf counts(position,det,pha_grp,tm_bin)
;        lvtme.................1 idf total livetme(position,det)
;     a_counts.................acc. counts(position,det,pha_grp,tm_bin)
;      a_lvtme.................acc. total livetme(position,det)
;    idfs,idfe.................idf start,stop #s for hist_accum.
;          idf.................current idf
;          dts.................start,date,time array
;           dt.................start,stop date,time array
;          opt.................cluster orientation code
;  num_tm_bins.................# of time bins
;     num_dets.................# detectors
;         disp.................show 1 idf(0) or accumulated(1)
;        start.................first time(0) or subsequent(1)
;          new.................new file(1) or not(0)
;        clear.................clear variable arrays if defined
;        ltime.................time step
;           ft.................plot fft of data if = 1
;      periods.................periods for data folding
;         fold.................fold which period 
;         fnme.................filename for storage
;          typ.................type of data set
;      phz_bns.................number of phase bins 
;         wait.................if activated wait an idf
;       noplot.................if defined, no plotting
;  cluster_pos.................cluster postion vs idf
;        tedgs.................time edges for current idf (IDF or TDB)
; Common blocks:
;  msclr_block.................stores accumulation variables
;    mev_block.................stores event variables for widgets
; First define common blocks and set default values
;**********************************************************************
common msclr_block,idf_hdr,idf,date,spectra,livetime,typ,tedgs
common mev_block,dc,opt,accum,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,det,cp,dt,num_dets,pha_edgs,$
                 num_tm_bins,pha_choice,ltime,ft,periods,fold,fnme,$
                 phz_bns,idf_lvtme,cluster_pos,phz_arr,a_tedgs
common save_block,spec_save,idf_save,wait,num
common parms,start,new,clear
common evt_parms,prms,prms_save,burst
;***************************************************************************
; Return if waiting, else begin
;***************************************************************************
if (wait)then begin
   wait = 0
   return
endif
if (ks(dc) eq 0)then dc = 'DET1'
if (ks(cp) eq 0)then cp = '0 (FOR +/- 1.5 DEG)'
if (ks(opt) eq 0)then opt = 5
if (ks(dts) eq 0)then dts = ['0','0']
if (ks(disp) eq 0)then disp = 0
if (ks(ft) eq 0)then ft = 0
if (ks(accum) eq 0)then accum = 0
if (ks(fold) eq 0)then fold = 0.
if (ks(fnme) eq 0)then fnme = ''
if (ks(periods) eq 0)then periods = [0.,0.,0.]
if (ks(phz_bns) eq 0)then phz_bns = 10
if (keyword_set(iarr) eq 0)then iarr = 0
;**********************************************************************
; Get initial arrays if just starting accumulation
;**********************************************************************
if (clear)then begin
   start = 0
   idf = 0
   counts(*,*,*,*) = 0 & a_counts(*,*,*,*) = 0
   a_lvtme(*,*,*) = 0 & lvtme(*,*,*) = 0
   clear = 0 & a_tedgs(*,*) = 0d
endif
;*********************************************************************
; If starting get the starting idf # and date,etc.
;*********************************************************************
if (start)then begin
   idfs = idf 
   dt = strarr(2,2)
   dt(0,*) = [strmid(date,0,9),strmid(date,10,18)]
   dt(1,*) = dt(0,*)
   if (idf_hdr.nb ne 64)then pha_edgs = idf_hdr.nh 
   nprms = n_elements(prms)
   if (nprms ne 1)then begin
      pha_edgs = prms(3:nprms-1)
      pha_edgs = temporary(pha_edgs(sort(pha_edgs)))
      pha_edgs = temporary(pha_edgs)-1
   endif
   sz_spec = size(spectra)
   num_dets = sz_spec(1)
   if (sz_spec(0) eq 3)then begin
      num_tm_bins = sz_spec(3) 
      num_pha_bins = sz_spec(2)
   endif
   if (sz_spec(0) eq 2)then begin
      num_tm_bins = 1
      num_pha_bins = sz_spec(2)
   endif
   if (sz_spec(0) eq 1)then begin
      num_tm_bins = 1
      num_pha_bins = 1
   endif
   a_counts = lonarr(3,num_dets,num_pha_bins,num_tm_bins)
   a_tedgs = dblarr(2,num_tm_bins)
   a_lvtme = fltarr(3,num_dets,num_tm_bins)
   counts = a_counts & lvtme = a_lvtme
   idf_lvtme = fltarr(3,num_dets,1)
   phz_arr = lonarr(3,num_dets,num_pha_bins,phz_bns)
   start = 0
endif
dt(1,*) = [strmid(date,0,9),strmid(date,10,18)]
;**********************************************************************
; Accumulate counts arrays and livetime for each cluster position.
; As multiscalar data is accumulated as a function of time, it is
; necessary to extend the accumulated counts array each time. The 
; output pha channel groupings must be the same, however, in order
; to accumulate.
; 2/25/98 Accumulate livetime array just like counts array
;**********************************************************************
idfe = idf
sz_spec = size(spectra)
if (new)then begin
   nprms = n_elements(prms)
   if (idf_hdr.nb ne 64)then pha_edgs_ = idf_hdr.nh
   if (nprms ne 1)then begin
     pha_edgs_ = prms(3:nprms-1)
     pha_edgs_ = temporary(pha_edgs_(sort(pha_edgs_)))
     pha_edgs_ = temporary(pha_edgs_)-1
   endif
   if (sz_spec(0) eq 1 or sz_spec(0) eq 2)then num_tm_bins_ = 1 
   if (sz_spec(0) eq 3)then num_tm_bins_ = sz_spec(3)
   num_dets_ = sz_spec(1)
endif else begin
   pha_edgs_ = pha_edgs
   num_tm_bins_ = num_tm_bins
   num_dets_ = num_dets
endelse
same = where(pha_edgs eq pha_edgs_)
if(n_elements(same) eq n_elements(pha_edgs)) then a = 1 else a = 0
c = num_tm_bins_ eq num_tm_bins
b = num_dets_ eq num_dets
d = idf ge idfe
if (sz_spec(0) eq 1)then npb = 1 else npb = sz_spec(2)
if (a and b and c and d)then begin 
   idfe = idf  
   cp = idf_hdr.clstr_postn
   if(cp eq '0 (FOR +/- 3.0 DEG)' or cp eq '0 (FOR +/- 1.5 DEG)') then $ 
   cp_ndx = 2
   if(cp eq '+3.0' or cp eq '+1.5')then cp_ndx = 0
   if(cp eq '-3.0' or cp eq '-1.5')then cp_ndx = 1
;************************************************************************
; If new file add to old file (concatenate) for accumulated
; multiscalar data. Check for gaps in idfs and add blank data
; if necessary.
;************************************************************************
   if (new)then begin
      nidf = idfe - idfs + long(1)
      nbns = n_elements(spectra(0,0,*)) 
      nidf_old = n_elements(idf_lvtme(0,0,*))
      q = nidf*nbns
      a_tedgs_new = dblarr(2,nidf*nbns)
      a_counts_new = lonarr(3,num_dets,npb,nidf*nbns)
      a_lvtme_new = fltarr(3,num_dets,nidf*nbns)
      a_counts_new(cp_ndx,*,*,nbns*(nidf-1.):nidf*nbns-1) = spectra(*,*,*)
      a_tedgs_new(*,nbns*(nidf-1.):nidf*nbns-1) = tedgs
      a_lvtme_new(cp_ndx,*,nbns*(nidf-1.):nidf*nbns-1) = livetime/double(nbns)
      if (nidf ne 1)then begin
         a_tedgs_new(*,0:nidf_old*nbns-1)=a_tedgs       
         a_counts_new(*,*,*,0:nidf_old*nbns-1)=a_counts(*,*,*,*)
         a_lvtme_new(*,*,0:nidf_old*nbns-1)=a_lvtme(*,*,*)
      endif
      a_counts = a_counts_new
      a_lvtme = a_lvtme_new
      a_tedgs = a_tedgs_new
;************************************************************************
; Append the cluster postion and IDF arrays. If there's a 
; discontinuity in the latest IDF entry, fill the gap with 
; a zero for the missing idf and a '-10' for the missing 
; cluster position.
;************************************************************************
      if (ks(cluster_pos) eq 0) then cluster_pos = cp else $
      cluster_pos = [cluster_pos,cp]
      if (ks(iarr) eq 0)then iarr = idf else iarr = [iarr,idf]
      len  = n_elements(iarr)
      if (len ne 1)then begin
         if (iarr(len-2) ne iarr(len-1)-1l)then begin
            del = iarr(len-1) - iarr(len-2) - 1
            isub = lonarr(del)
            csub = string(isub - 10)
            iarr = [[iarr(0:len-2),isub],idf]
            cluster_pos = [[cluster_pos(0:len-2),csub],cp]
         endif
      endif
;************************************************************************
; Produce the array of livetimes vs idf
;************************************************************************
      idf_lvtme_new = fltarr(3,num_dets,nidf)
      szl = size(livetime)
      if (num_dets ne 1)then begin
         if (szl(0) eq 1)then tl = livetime else tl = total(livetime,2) 
         idf_lvtme_new(cp_ndx,*,nidf-1) = tl
      endif else begin
         idf_lvtme_new(cp_ndx,0,nidf-1) = total(livetime)
      endelse
      if (nidf ne 1)then idf_lvtme_new(*,*,0:nidf_old-1) = idf_lvtme
      idf_lvtme = idf_lvtme_new
   endif
;************************************************************************
; Fill arrays for latest idf
;************************************************************************
   counts(cp_ndx,*,*,*) = spectra
   if (num_dets ne 1)then lvtme(cp_ndx,*,*) = livetime/double(nbns) $
   else lvtme(cp_ndx) = total(livetime)/double(nbns)
   d1 = strcompress('DET' + string(indgen(num_dets) + 1),/remove_all)
   d2 = ['DET SUM','SHOW ALL']
   det_str = [strcompress(d1,/remove_all),d2]
   det = where(det_str eq dc) + 1
   det = det(0)
;***********************************************************************
; Calculate the time step ltime
;***********************************************************************
   nz = where(livetime ne 0.)
   avg_time_idf = total(livetime)/n_elements(nz)
   ltime = avg_time_idf
endif
;***********************************************************************
; Send to multiscalar widget
;***********************************************************************
if (ks(pha_choice) eq 0)then begin
   pha_choice = 0
endif
if (ks(noplot) eq 0)then wmsclr
;***********************************************************************
; Thats all ffolks
;***********************************************************************
return
end     