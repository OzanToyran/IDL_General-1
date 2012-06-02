pro prep_map_dis,dis,comb,maprt

;this has the isdc version of the deadtime, max of two detectors

maprt=fltarr(19,6)

mapx=[[1,2,3,4,5,6],[8,9,2,0,6,7],[9,10,11,3,0,1],[2,11,12,13,4,0],$
[0,3,13,14,15,5],[6,0,4,15,16,17],[7,1,0,5,17,18],[100,8,1,6,18,100],$
[100,100,9,1,7,100],[100,100,10,2,1,8],[100,100,100,11,2,9],$
[10,100,100,12,3,2],[11,100,100,100,13,3],[3,12,100,100,14,4],$
[4,13,100,100,100,15],[5,4,14,100,100,16],[17,5,15,100,100,100],$
[18,6,5,16,100,100],[100,7,6,17,100,100]]


for k=0,63 do begin
  ;find indices
    ind1=comb(0,k)
    ind2=where(mapx(*,ind1) eq comb(1,k))
    maprt(ind1,ind2[0])=dis(k)
endfor

end
