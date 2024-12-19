clear
close all

%% DATA
% Constants
constant.AU2m       = 149597870707;                    % [AU] -> [m]
constant.AU2km      = 149597870.707;                   % [AU] -> [km]
constant.q0         = 1367.5;                          % Solar flux @ 1 AU [W/m2]
constant.sigma      = 5.67037*1e-8 ;                   % Boltzmann constant [W/m2*K4];      
constant.T_space    = 3;                               % Deep space temperature [K]
constant.T_SC.hot   = 300;
constant.T_SC.cold  = 270;

% Earth
Earth.r         = 1;                                    % Semi-major axis of the Earth [AU]
Earth.R         = 6378;                                 % Earth radius [km]
Earth.alpha     = 0.38;                                 % albedo factor of the Earth [-]
Earth.eps       = 1;                                    % Emissivity of the Earth (0.85 if not black body) [-]
Earth.Temp      = 250;                                  % Earth black-body temperature [K]

% 22 Kalliope
Kalliope.r      = 2.91;                                % Semi-major axis of 22 Kalliope [AU]
Kalliope.alpha  = 0.166;                               % Albedo factor of 22 Kalliope [-]
Kalliope.eps    = 0.9;                                 % IR emissivity of the asteroid [-]
Kalliope.m      = 7.7e18;                              % mass of Kalliope [kg]
Kalliope.sma    = [72 117.5 62];                       % semi-major axis of Kalliope ellipsoid [km]
Kalliope.R      = max(Kalliope.sma)/2;

% Kalliope Temperature
eta = 0.756;
G = 0.21;
q = 0.290 + 0.684 * G;
Ab = Kalliope.alpha * q;
Ls = 3.827*1e26;
Kalliope.Temp = (Ls*(1-Ab)/(16*pi*Kalliope.eps*...
    constant.sigma*eta*(Kalliope.r*constant.AU2m)^2 ))^(1/4);   % Temperature of Kalliope [K]
clear eta G q Ab Ls

Earth.h      = 500;
Earth.a      = Earth.h+Earth.R;
Kalliope.a   = 400;
Kalliope.h   = Kalliope.a-Kalliope.R;

% PAYLOAD
payload.theta           = 0;                % View factor of the s/c [rad]
payload.Optic.R_sc      = 1.187;            % [K/W] Resistenza termoica tra Spececraft e nodo ottica
payload.EBox.R_sc      = 3e-4;             % [K/W] Resistenza termoica tra Spececraft e nodo E-Box


%% Specific heat Fluxes @ Earth

Earth.q_sun = constant.q0;
Earth.q_albedo = Earth.q_sun * Earth.alpha * cos(payload.theta) * (Earth.R / (Earth.R + Earth.h))^2;
Earth.q_IR = constant.sigma * Earth.eps * Earth.Temp^4 * ( Earth.R / (Earth.R + Earth.h) )^2;

%% Specific heat Fluxes @ Kalliope

Kalliope.q_sun = constant.q0 * ( Earth.r / Kalliope.r )^2;
Kalliope.q_albedo = Kalliope.q_sun * Kalliope.alpha * cos(payload.theta) * (Kalliope.R / (Kalliope.R + Kalliope.h))^2;
Kalliope.q_IR = constant.sigma * Kalliope.eps * Kalliope.Temp^4 * ( Kalliope.R / (Kalliope.R + Kalliope.h) )^2;

%% Geometry Optic

payload.Optic.hot.A_sun     = 0.2145;
payload.Optic.hot.A_albedo  = 0.2145;
payload.Optic.hot.A_IR      = 0.2145;
payload.Optic.hot.A_DS      = 0.2392;

payload.Optic.cold.A_sun     = 0;
payload.Optic.cold.A_albedo  = 0;
payload.Optic.cold.A_IR      = 0;
payload.Optic.cold.A_DS      = 0.4077;

payload.Optic.alpha     = 0.12;
payload.Optic.epsilon   = 0.05;

%% Geometry E-Box

payload.EBox.hot.A_sun      = 0.0144;
payload.EBox.hot.A_albedo   = 0.0144;
payload.EBox.hot.A_IR       = 0.0144;
payload.EBox.hot.A_DS       = 0.0288;

payload.EBox.cold.A_sun      = 0;
payload.EBox.cold.A_albedo   = 0;
payload.EBox.cold.A_IR       = 0;
payload.EBox.cold.A_DS       = 0.0432;

payload.EBox.alpha      = 0.12;
payload.EBox.epsilon    = 0.05;

%% HEAT POWER OPTIC

payload.Optic.hot.Q_sun      = Earth.q_sun*payload.Optic.hot.A_sun*payload.Optic.alpha;
payload.Optic.hot.Q_IR       = Earth.q_IR*payload.Optic.hot.A_IR*payload.Optic.epsilon;
payload.Optic.hot.Q_albedo   = Earth.q_albedo*payload.Optic.hot.A_albedo*payload.Optic.alpha;
payload.Optic.hot.Q_int      = 12;

payload.Optic.cold.Q_sun      = Earth.q_sun*payload.Optic.cold.A_sun*payload.Optic.alpha;
payload.Optic.cold.Q_IR       = Earth.q_IR*payload.Optic.cold.A_IR*payload.Optic.epsilon;
payload.Optic.cold.Q_albedo   = Earth.q_albedo*payload.Optic.cold.A_albedo*payload.Optic.alpha;
payload.Optic.cold.Q_int      = 0;

%% HEAT POWER OPTIC

payload.EBox.hot.Q_sun      = Earth.q_sun*payload.EBox.hot.A_sun*payload.EBox.alpha;
payload.EBox.hot.Q_IR       = Earth.q_IR*payload.EBox.hot.A_IR*payload.EBox.epsilon;
payload.EBox.hot.Q_albedo   = Earth.q_albedo*payload.EBox.hot.A_albedo*payload.EBox.alpha;
payload.EBox.hot.Q_int      = 15;

payload.EBox.cold.Q_sun      = Earth.q_sun*payload.EBox.cold.A_sun*payload.EBox.alpha;
payload.EBox.cold.Q_IR       = Earth.q_IR*payload.EBox.cold.A_IR*payload.EBox.epsilon;
payload.EBox.cold.Q_albedo   = Earth.q_albedo*payload.EBox.cold.A_albedo*payload.EBox.alpha;
payload.EBox.cold.Q_int      = 0;

%% SIMULATION, NO THERMAL CONTROL

set_param('TCS_static/Q ext E-Box', 'Value', 'payload.EBox.hot.Q_sun+payload.EBox.hot.Q_IR+payload.EBox.hot.Q_albedo')
set_param('TCS_static/Q int E-Box', 'Value', 'payload.EBox.hot.Q_int')
set_param('TCS_static/Q ext optic', 'Value', 'payload.Optic.hot.Q_sun+payload.Optic.hot.Q_IR+payload.Optic.hot.Q_albedo')
set_param('TCS_static/Q int optic', 'Value', 'payload.Optic.hot.Q_int')
set_param('TCS_static/SC', 'temperature', 'constant.T_SC.hot')

res = sim("TCS_static.slx");
payload.EBox.hot.Temp   = res.T_EBox(end);
payload.Optic.hot.Temp  = res.T_optic(end);

clear res

set_param('TCS_static/Q ext E-Box', 'Value', 'payload.EBox.cold.Q_sun+payload.EBox.cold.Q_IR+payload.EBox.cold.Q_albedo')
set_param('TCS_static/Q int E-Box', 'Value', 'payload.EBox.cold.Q_int')
set_param('TCS_static/Q ext optic', 'Value', 'payload.Optic.cold.Q_sun+payload.Optic.cold.Q_IR+payload.Optic.cold.Q_albedo')
set_param('TCS_static/Q int optic', 'Value', 'payload.Optic.cold.Q_int')
set_param('TCS_static/SC', 'temperature', 'constant.T_SC.cold')

res = sim("TCS_static.slx");
payload.EBox.cold.Temp   = res.T_EBox(end);
payload.Optic.cold.Temp  = res.T_optic(end);

clear res