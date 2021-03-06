pro prep_maps,data,hk,numc,maprs,maprs_err,maprt,maprt_err

;No dead time correction

mapc=fltarr(n_elements(numc),19,6)
maprs=fltarr(n_elements(numc),19,6)
maprt=fltarr(19,6)
maprs_err=fltarr(n_elements(numc),19,6)
maprt_err=fltarr(19,6)


mapx=[[1,2,3,4,5,6],[8,9,2,0,6,7],[9,10,11,3,0,1],[2,11,12,13,4,0],$
[0,3,13,14,15,5],[6,0,4,15,16,17],[7,1,0,5,17,18],[100,8,1,6,18,100],$
[100,100,9,1,7,100],[100,100,10,2,1,8],[100,100,100,11,2,9],$
[10,100,100,12,3,2],[11,100,100,100,13,3],[3,12,100,100,14,4],$
[4,13,100,100,100,15],[5,4,14,100,100,16],[17,5,15,100,100,100],$
[18,6,5,16,100,100],[100,7,6,17,100,100]]


;work in scw basis
tnumc=0L

for k=0,n_elements(numc)-1 do begin
   for i=0,18 do begin
     for j=0,5 do begin
       if (k eq 0) then mapc(k,i,j)=n_elements($
where((data[0:numc(0)-1L].dete[0] eq i) and $
(data[0:numc(0)-1L].dete[1] eq mapx[j,i]))) else $
mapc(k,i,j)=n_elements($
where((data[tnumc:tnumc+numc(k)-1L].dete[0] eq i) and $
(data[tnumc:tnumc+numc(k)-1L].dete[1] eq mapx[j,i])))

        if mapc[k,i,j] gt 1. then begin
           ;dtij=max([hk[k].avgdt[i],hk[k].avgdt[mapx[j,i]]]) 
           dtij = 0.  ; No deadtime
           maprs(k,i,j)=mapc(k,i,j)/(hk[k].obtime*(1.-dtij))
           maprt[i,j]=maprt[i,j]+(maprs[k,i,j]*hk[k].obtime)
           maprs_err(k,i,j)=sqrt(mapc(k,i,j)*(1.-dtij))/(hk[k].obtime)
           ; maprt_err[i,j]=maprt_err[i,j]+mapc(k,i,j)
       endif
     endfor
   endfor

tnumc=tnumc+numc(k)

endfor
maprt_err=sqrt(maprt)/total(hk.obtime)
maprt=maprt/total(hk.obtime)

end
