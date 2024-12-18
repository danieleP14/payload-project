function [rr, vv]=par2car(a,e,i,OM,om,th,mu)

% Calcolo i parametri che non necessitano di rotazione
p=a*(1-e^2);
r=p/(1+e*cos(th));
rr=r*[cos(th);sin(th);0];
vv=sqrt(mu/p)*[-sin(th);e+cos(th);0];

% Ora converto angoli da rad a grad e li ruoto
OM=OM*180/pi;
i=i*180/pi;
om=om*180/pi;
Rz1=rotz(OM);% prima rotazione su z
Rx=rotx(i);% rotazione su x
Rz2=rotz(om);% seconda rotazione su z
T=Rz1*Rx*Rz2;% Matrice rotazione totale

rr=T*rr/norm(rr);
vv=T*vv;

