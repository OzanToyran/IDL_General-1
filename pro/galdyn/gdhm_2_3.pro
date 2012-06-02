pro gdhm_2_3

sg=(26./3.086)*1e-16
k=(36./3.086)*1e-16
ti=8.*!PI*findgen(800)/800.
tipr=ti/sg
xgc=8.5*cos(ti)+1.18*cos(k*tipr)
ygc=8.5*sin(ti)-1.704*sin(k*tipr)

plot,xgc,ygc,xrange=[-15.,15.],yrange=[-15.,15.],/xstyle,/ystyle

end
