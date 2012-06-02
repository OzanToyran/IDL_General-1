pro chi2map2wacsab,map1,map1_err,acs1,map2,map2_err,acs2,file=file,ps=ps,chi2

;This  program takes maps from two different revolutions as inputs and 
;calculates the chi^2 deviation after normalizing each w.r.t to total
;acs high. Tracer: acs_ab

if (NOT keyword_set(ps)) THEN ps=0
if (NOT keyword_set(file)) THEN file='chi2two_acsab.ps'

loadct,0

mapx=[[1,2,3,4,5,6],[8,9,2,0,6,7],[9,10,11,3,0,1],[2,11,12,13,4,0],$
[0,3,13,14,15,5],[6,0,4,15,16,17],[7,1,0,5,17,18],[100,8,1,6,18,100],$
[100,100,9,1,7,100],[100,100,10,2,1,8],[100,100,100,11,2,9],$
[10,100,100,12,3,2],[11,100,100,100,13,3],[3,12,100,100,14,4],$
[4,13,100,100,100,15],[5,4,14,100,100,16],[17,5,15,100,100,100],$
[18,6,5,16,100,100],[100,7,6,17,100,100]]

if ps eq 1 then begin
  set_plot,'ps'
  device,filename=file
  device,/color
  loadct,5
endif

plot,[0.,0.],[0.,0.],xr=[0.,20.],yr=[0.,8.],/xstyle,/ystyle,title='chi2 distribution for ME',xtitle='Detector number',ytitle='Neighbor detector'

xyouts,2.,6.5,file


totchi2=0.
num=0.

chi2=fltarr(19,6)

for i=0,18 do for j=0,5 do begin
  if map1(i,j) ne 0 then begin
      xx=where(acs1.acs_ab ge 100.)
      acsab1=avg(acs1[xx].acs_ab)
;      
      xx=where(acs2.acs_ab ge 100.)
      acsab2=avg(acs2[xx].acs_ab)
;      
      norm1=map1(i,j)*acsab2/acsab1
      norm2=map2(i,j)
;      print,gsr2,gsr1,gsr2/gsr1,map2(i,j)/map1(i,j),norm2/norm1
      err1=map1_err(i,j)
      err2=map2_err(i,j)
      chi2(i,j)=((norm1-norm2)^2)/(err1^2+err2^2)
      totchi2=totchi2+chi2(i,j)
      num=num+1.
;      boxc,i,j,i+1,j+1,256-(floor(chi2(i,j))*20)-55
       boxc,i+0.5,j,i+1,j+1,256-(floor(chi2(i,j))*20)-55
;       xyouts,i,j+0.7,string(chi2(i,j))
       xyouts,i,j+0.2,strtrim(string(mapx(j,i)),1)
  endif
endfor

print,totchi2
print,totchi2/num

x=indgen(256)
;for j=0,255 do boxc,j*20./256,7.,(j+1)*20./256,8.,255-j
for j=0,255 do boxc,j*20./256,7.,(j+1)*20./256,7.5,255-j
xyouts,50*20./256.,7.5,'0'
xyouts,95*20./256.,7.5,'2.5'
xyouts,145*20./256.,7.5,'5.0'
xyouts,195*20./256.,7.5,'7.5'
xyouts,240*20./256.,7.5,'10.0'

xyouts,14,6.5,'Red. chi^2='+strtrim(string(totchi2/num),1)

if ps eq 1 then begin
  device,/close
  set_plot,'x'
endif

end
