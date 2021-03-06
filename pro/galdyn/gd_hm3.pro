pro gd_hm3

G=6.67 
;1.e-8
Msun=2.
;1e33
M=1e12*Msun
z=1.92
pc=3.1*1.e18
k=1000.
mg=1.e6
a=5.*k*pc

Ho=50.*k/(M*pc)
;/e33
H=((1+z)^1.5)*Ho
;/e33
Vcirc=(10.*G*H*M)^(1./3.)
Rvir=Vcirc/(10.*H)

print,Vcirc/1.e5
print,Rvir/(k*pc)

MRv=4*!PI*qromb('ro1',0.,Rvir/a)

ro=(Vcirc^2)*Rcirc/(G*MRv)

print,ro

end
