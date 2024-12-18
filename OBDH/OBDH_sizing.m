clear
clc

%% 

a     = 400;
m_kal = 7.7e18;
T_kal = 1.4934e4;

T_sc  = 2*pi*sqrt(a^3/(astroConstants(1)*m_kal));
omega_sc = 2*pi/T_sc;
omega_kal = 2*pi/T_kal;

tt    = linspace(0, 10*T_sc, 10*T_sc);
OM    = linspace(0,pi/2,5);
delta = NaN(length(OM),length(tt));

for j=1:length(OM)
    for idx = 1:length(tt)
        delta(j,idx) = norm(V_rel(tt(idx), a, OM(j), omega_sc, omega_kal));
    end
end

save('deltaV.mat', "delta");

%%
clear;clc;
a     = 400;
m_kal = 7.7e18;
T_kal = 1.4934e4;
sma   = [72 117.5 62];

T_sc  = 2*pi*sqrt(a^3/(astroConstants(1)*m_kal));
omega_sc = 2*pi/T_sc;
omega_kal = 2*pi/T_kal;

tt    = linspace(0, 10*T_sc, 10*T_sc);
OM    = linspace(0,pi/2,5);

delta = importdata("deltaV.mat");
[massimo, posizia] = max(delta, [], 'all', 'linear');

n_bit       = 12;       % [bit/pixel]
compression = 1;
GSD         = 1.5778;      % [m]

x_P  = 12288;           % [pixel]
y_P  = 128;             % [pixel]
x_MS = 6144;            % [pixel]
y_MS = 64;              % [pixel]
n_P  = 2;
n_MS = 6;

size_P   = n_bit*x_P*y_P;       % [bit]
size_MS  = n_bit*x_MS*y_MS;     % [bit]

size_TOT_kbit   = (size_P*n_P + size_MS*n_MS) * 1e-6;       % [Mbit]
size_TOT_kB     = size_TOT_kbit /8;                         % [MByte]

t_dwell = y_P*GSD/(massimo*1e3);
f_acq = 1/t_dwell;
datarate_Mbps   = size_TOT_kbit*f_acq/compression;      % [Mbps]
data_out_Gb     = datarate_Mbps * T_sc/2 * 1e-3;        % [Gbit]
data_out_GByte  = data_out_Gb/8;                        % [GByte]

%% AUXILIARY FUNCTIONS

function V = V_rel(t,a,OM,omega_sc,omega_kal)

    % proprietà di Kalliope
    m_kal = 7.7e18;
    sma = [72 117.5 62];
    
    th = omega_sc*t;                                                                    % angolo dello S/C lungo l'orbita rispetto all'apocentro in funzione del tempo
    [r_sc, v_sc] = par2car(a, 0, pi/2, OM, 0, th, astroConstants(1)*m_kal);             % velocità e posizione dello S/C in terna inerziale
    
    Az = atan2(r_sc(2), r_sc(1));                                                       % Azimuth dello S/C in terna inerziale
    Az = Az - omega_kal*t;                                                              % Azimuth dello S/C in terna body
    El = acos(r_sc(3));                                                                 % Elevazione dello S/C in terna inerziale e body (coincidono)
    v_surf = omega_kal * [-sma(2)*sin(El)*sin(Az); sma(1)*cos(El)*sin(Az); 0];          % Velocità della superficie in terna body
    v_surf = rotz(rad2deg(omega_kal*t))*v_surf;                                         % Velocità della superficie in terna inerziale
    V = v_surf - v_sc;                                                                  % Calcolo del DV in terna inerziale

end