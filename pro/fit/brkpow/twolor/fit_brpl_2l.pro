pro fit_brpl_2l,p,p_err,f_b,a1,a2,a3,fit,rmsq1,rmsq2

window, 0
;xl = min(f_b)
;xu = max(f_b)
xl=0.01
xu=256.
yl = 1.e-5
yu = 1.e-1

;set_plot,'ps'
;!p.font=0
;device,/times

; Program for reading in and fitting an rms^2/Hz normalized power spectra

modelname = 'brk_pow_2l' ; the model name should also go here

a = [a1,a2,a3] ; guess for curvefit

; This is just so the error bars on the plot look right
fix1 = p-p_err ; where
fix2 = p
g = where(fix2 gt 0)
b = where(fix1 lt 0)

!x.style = 1
!y.style = 1

read, 'Type 1 to save to ps: ', kk
if (kk eq 1) then set_plot, 'ps'
if (kk eq 1) then device, filename = 'idl.ps'
if (kk eq 1) then device, yoffset = 6.0
if (kk eq 1) then device, ysize = 14.5

cont=0
while cont eq 0 do begin

plot_oo, f_b(g), p(g), psym = 10, $
  xrange = [xl,xu], $
  yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 1.5, charthick = 1.5,/xstyle,/ystyle
;  xtickname=['0.01','0.1','1','10','100']

oploterr, f_b(g), p(g), p_err(g), 3
if total(b) GE 0 then fixup, b, f_b, p, p_err

w = 1.0/(p_err^2)
;bu kisim eklendi

n = 100000
x = 0.001+0.01*findgen(n)

;den0 = x^2 + (0.5*a(1))^2
;den = (x - a(4))^2 + (0.5*a(3))^2
g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 

den1 = (x - a(5))^2 + (0.5*a(4))^2
den2 = (x - a(8))^2 + (0.5*a(7))^2

f=fltarr(n_elements(x))

f(g1) = a(0) +  (a(3)*a(4))/(2.0*!pi*den1(g1)) + (a(6)*a(7))/(2.0*!pi*den2(g1)) 
f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) + (a(3)*a(4))/(2.0*!pi*den1(g2)) + $
(a(6)*a(7))/(2.0*!pi*den2(g2))

;f = a(0)*x^(-a(1)) + (a(2)*a(3))/(2.0*!pi*den)
oplot, x, f, thick = 2

; plotting individual components

c1_1 = a(0) 
oplot, [0.01,max(x(g1))], [c1_1,c1_1],linestyle = 2, thick = 1
c1_2 = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))
oplot, x(g2), c1_2, linestyle = 2, thick = 1

c2_1 = (a(3)*a(4))/(2.0*!pi*den1(g1))
oplot, x(g1), c2_1, linestyle = 2, thick = 1
c2_2 = (a(3)*a(4))/(2.0*!pi*den1(g2))
oplot, x(g2), c2_2, linestyle = 2, thick = 1

c3_1 = (a(6)*a(7))/(2.0*!pi*den2(g1))
oplot, x(g1), c3_1, linestyle = 2, thick = 1
c3_2 = (a(6)*a(7))/(2.0*!pi*den2(g2))
oplot, x(g2), c3_2, linestyle = 2, thick = 1
if kk eq 1 then device,/close

 print,'which parameter you want to change, or 9 to exit'
 read,ind
 case ind of
  0: begin
     print,a(0)
     read,var
     a(0)=var
  end
  
  1: begin
     print,a(1)
     read,var
     a(1)=var
  end
  
  2: begin 
     print,a(2)
     read,var
     a(2)=var
  end 
  
  3: begin
     print,a(3)
     read,var
     a(3)=var
  end

  4: begin
     print,a(4)
     read,var
     a(4)=var
  end

  5: begin
     print,a(5)
     read,var
     a(5)=var
  end

  6: begin
     print,a(6)
     read,var
     a(6)=var
  end

  7: begin
     print,a(7)
     read,var
     a(7)=var
  end
  
  8: begin
     print,a(8)
     read,var
     a(8)=var
  end

  9: cont=1
endcase

endwhile

     


;bu kisim

yfit = curvefit(f_b, p, w, a, sigmaa, function_name = modelname)

array = [transpose(a), transpose(sigmaa)]
print, array
plot_oo, f_b(g), p(g), psym = 10, $
  xrange = [xl,xu], $
  yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 1.5, charthick = 1.5,/xstyle,/ystyle
;  xtickname=['0.01','0.1','1','10','100']
oploterr, f_b(g), p(g), p_err(g), 3
if total(b) GE 0 then fixup, b, f_b, p, p_err



; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
dof = n_elements(f_b)-n_elements(a)
print, 'chi2 = ', total(chi)
print, 'dof = ', dof

; plotting the fit on the data

n = 100000
x = 0.001+0.01*findgen(n)

;den0 = x^2 + (0.5*a(1))^2
;den = (x - a(4))^2 + (0.5*a(3))^2
g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 

den1 = (x - a(5))^2 + (0.5*a(4))^2
den2 = (x - a(8))^2 + (0.5*a(7))^2

f=fltarr(n_elements(x))

f(g1) = a(0) +  (a(3)*a(4))/(2.0*!pi*den1(g1)) + (a(6)*a(7))/(2.0*!pi*den2(g1)) 
f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) + (a(3)*a(4))/(2.0*!pi*den1(g2)) + $
(a(6)*a(7))/(2.0*!pi*den2(g2))

;f = a(0)*x^(-a(1)) + (a(2)*a(3))/(2.0*!pi*den)
oplot, x, f, thick = 2

; plotting individual components

c1_1 = a(0) 
oplot, [0.01,max(x(g1))], [c1_1,c1_1],linestyle = 2, thick = 1
c1_2 = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))
oplot, x(g2), c1_2, linestyle = 2, thick = 1

c2_1 = (a(3)*a(4))/(2.0*!pi*den1(g1))
oplot, x(g1), c2_1, linestyle = 2, thick = 1
c2_2 = (a(3)*a(4))/(2.0*!pi*den1(g2))
oplot, x(g2), c2_2, linestyle = 2, thick = 1

c3_1 = (a(6)*a(7))/(2.0*!pi*den2(g1))
oplot, x(g1), c3_1, linestyle = 2, thick = 1
c3_2 = (a(6)*a(7))/(2.0*!pi*den2(g2))
oplot, x(g2), c3_2, linestyle = 2, thick = 1

; calculating fractional rms amplitudes
print, 'broken power law'
print, 'f_break = ', a(1), sigmaa(1)
print, 'index = ', a(2), sigmaa(2)
rms_brpl_er,a(0),a(1),a(2),sigmaa(0),sigmaa(1),sigmaa(2),rm,rme
print, 'frac_rms = ', rm
print, 'frac_rms_err = ', rme 
print, 'fundamental'
print, 'f_buency = ', a(5), sigmaa(5)
print, 'frac_rms = ', sqrt(a(3)), sigmaa(3)/(2.0*sqrt(a(3)))
print, 'firs harmonic'
print, 'f_buency = ', a(8), sigmaa(8)
print, 'frac_rms = ', sqrt(a(6)), sigmaa(6)/(2.0*sqrt(a(6)))
print, 'chi2 =', total(chi), dof, total(chi)/dof

read, 'Type 1 to show residuals: ', jj
if (jj eq 1) then window, 1
if (jj eq 1) then plot_oi, f_b, chi, psym = 10, xtitle = 'Frequency (Hz)', ytitle = 'Chi!U2!N', charsize = 2, charthick = 2, xrange = [xl,xu]
if (jj eq 1) then oplot, [1.e-5,1.e5],[0,0],linestyle = 1, thick = 2

if (kk eq 1) then device, /close
if (kk eq 1) then set_plot, 'x'
!p.multi = 0

fit=a

end








