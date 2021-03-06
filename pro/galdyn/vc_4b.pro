pro vc_4b

    X=[0.1,0.75,1.5,2.25,3.0,3.75,4.5,5.25,6.0,6.75,7.5]

    So=60.*2.0*0.001/(3.1^2)
    I_pr=[.0108,.005,.0014,0.,0.,0.,0.,0.,0.,0.,0.]
    I2=[.0108,.0106,.0088,.0061,.0046,.0032,.0024,.0017,.0011,.00061,.00038]
    G=6.67e-8
    kpc=3.086e21
    Rdg=2.
    Kg=fltarr(11)
    Ks=fltarr(11)
    vcs=fltarr(11)
   
   for i=0,10 do $
Kg(i)=beseli(X(i)/(2.*Rdg),0)*beselk0(X(i)/(2.*Rdg))-beseli(X(i)/(2.*Rdg),1)*$
             beselk1(X(i)/(2.*Rdg))
    
    vcg=sqrt(!PI*So*G*X^2*Kg/Rdg)
    vcgr=vcg*sqrt(kpc)/1.e5
    
    
    Rds=0.5
    MoL=0.5
    for i=0,10 do $
Ks(i)=beseli(X(i)/(2.*Rds),0)*beselk0(X(i)/(2.*Rds))-beseli(X(i)/(2.*Rds),1)$
             *beselk1(X(i)/(2.*Rds))
    
    for i=0,10 do vcs(i)=sqrt(!PI*G*I2(i)*X(i)^2*MoL*Ks(i)/Rds)
   
    vcsr=vcs*sqrt(kpc)/1.e5

    ;vcd1=G*(A(0)^2)*A(1)
    ;vcd2=G*(A(0)^3)*A(1)*atan(X/A(0))/X
    ;print,vcd1
    ;print,vcd2
    ;if (A(0) EQ 0) then A(0)=0.00000001
    ;dum=(G*(A(0)^2)*(A(1)-A(0)*X))
    ;dum=dum>0 
   ;if (dum LT 0) then dum=0
   ;vcdm=sqrt((vcd1-vcd2)*4.*!PI)
    
    ;vcdm=vcdm*10.^4.5
    ;take care of atan if needed
    
    F=sqrt((vcgr)^2+(vcsr)^2)
    
    ;f1=2.*G*A(0)*A(1)+A(1)*G*A(0)/(1+(X^2/A(0)^2))-$
    ;   3.*A(0)^2*A(1)*G*atan(X/A(0))/X

    ;f2=G*(A(0)^2)-G*(A(0)^3)*atan(X/A(0))/X
    
    ;pder=[[f1/(2*F)],[f2/(2*F)]]


    ;print,F
    vrot=[2.0,14.0,28.0,34.,40.,44.0,46.0,47.5,50.0,48.0,45.0]
    plot,X,vrot,psym=2
    oplot,X,F,psym=1
end
