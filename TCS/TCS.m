clear
close all

%% DATA
% Constants
constant.AU2m       = 149597870707;                     % [AU] -> [m]
constant.AU2km      = 149597870.707;                    % [AU] -> [km]
constant.q0         = 1367.5;                           % Solar flux @ 1 AU [W/m2]
constant.sigma      = 5.67037*1e-8 ;                    % Boltzmann constant [W/m2*K4];      
constant.T_space    = 3;                                % Deep space temperature [K]
constant.T_SC.hot   = 300;
constant.T_SC.cold  = 270;

% Earth
Earth.r         = 1;                                    % Semi-major axis of the Earth [AU]
Earth.R         = 6378;                                 % Earth radius [km]
Earth.alpha     = 0.38;                                 % albedo factor of the Earth [-]
Earth.eps       = 1;                                    % Emissivity of the Earth (0.85 if not black body) [-]
Earth.Temp      = 250;                                  % Earth black-body temperature [K]

% 22 Kalliope
Kalliope.r      = 2.91;                                 % Semi-major axis of 22 Kalliope [AU]
Kalliope.alpha  = 0.166;                                % Albedo factor of 22 Kalliope [-]
Kalliope.eps    = 0.9;                                  % IR emissivity of the asteroid [-]
Kalliope.m      = 7.7e18;                               % mass of Kalliope [kg]
Kalliope.sma    = [72 117.5 62];                        % semi-major axis of Kalliope ellipsoid [km]
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

A_SC_EBox   = 4*3*2.5e-5;           % [m^2]
k_SC_EBox   = 6.7;                  % [W/mK]                 
t_SC_EBox   = 0.01;

A_SC_Optic  = 8*4*(pi*0.01^2);
k_SC_Optic  = 6.7;                  % [W/(mK)]
t_SC_Optic  = 0.1;

payload.theta           = 0;                                                % View factor of the s/c [rad]
payload.EBox.R_sc       = t_SC_EBox / (A_SC_EBox*k_SC_EBox);                % [K/W] Resistenza termica tra Spececraft e nodo E-Box
payload.Optic.R_sc      = t_SC_Optic / (A_SC_Optic*k_SC_Optic);              % [K/W] Resistenza termica tra Spececraft e nodo ottica

payload.MLI.eps_int     = 0.03;
payload.epsilon_rad     = 0.9;

payload.MLI.alpha      = 0.3;
payload.MLI.epsilon    = 0.8;

clear A_SC_EBox k_SC_EBox t_SC_EBox A_SC_Optic k_SC_Optic t_SC_Optic

%% Specific heat Fluxes @ Earth

Earth.q_sun = constant.q0;
Earth.q_albedo = Earth.q_sun * Earth.alpha * cos(payload.theta) * (Earth.R / (Earth.R + Earth.h))^2;
Earth.q_IR = constant.sigma * Earth.eps * Earth.Temp^4 * ( Earth.R / (Earth.R + Earth.h) )^2;

%% Specific heat Fluxes @ Kalliope

Kalliope.q_sun = constant.q0 * ( Earth.r / Kalliope.r )^2;
Kalliope.q_albedo = Kalliope.q_sun * Kalliope.alpha * cos(payload.theta) * (Kalliope.R / (Kalliope.R + Kalliope.h))^2;
Kalliope.q_IR = constant.sigma * Kalliope.eps * Kalliope.Temp^4 * ( Kalliope.R / (Kalliope.R + Kalliope.h) )^2;

%% Geometry Optic

payload.Optic.A_lat             = 0.2160;
payload.Optic.A_mirror          = 0.0707;
payload.Optic.alpha_mirror      = 0.3;
payload.Optic.eps_mirror        = 0.8;

payload.Optic.hot.A_sun         = payload.Optic.A_lat;
payload.Optic.hot.A_albedo      = payload.Optic.A_mirror;
payload.Optic.hot.A_IR          = payload.Optic.A_mirror;
payload.Optic.hot.A_DS_MLI      = 0.3393;

payload.Optic.cold.A_sun        = 0;
payload.Optic.cold.A_albedo     = 0;
payload.Optic.cold.A_IR         = 0;
payload.Optic.cold.A_DS_MLI     = 0.3393;
payload.Optic.cold.A_DS_mir     = 0.0707;

%% Geometry E-Box

payload.EBox.A_face         = 0.12^2;
payload.EBox.A_tot          = 3 * payload.EBox.A_face;

payload.EBox.hot.A_sun      = payload.EBox.A_face;
payload.EBox.hot.A_albedo   = payload.EBox.A_face;
payload.EBox.hot.A_IR       = payload.EBox.A_face;
payload.EBox.hot.A_DS       = 3 * payload.EBox.A_face;
payload.EBox.hot.A_tot      = 3 * payload.EBox.A_face;

payload.EBox.cold.A_sun      = 0;
payload.EBox.cold.A_albedo   = 0;
payload.EBox.cold.A_IR       = 0;
payload.EBox.cold.A_DS       = 3 * payload.EBox.A_face;

%% HEAT POWER OPTIC

payload.Optic.hot.Q_sun         = Kalliope.q_sun*payload.Optic.hot.A_sun*payload.MLI.alpha;
payload.Optic.hot.Q_IR          = Kalliope.q_IR*0.0707*0.8;
payload.Optic.hot.Q_albedo      = Kalliope.q_albedo*0.0707*0.2;
payload.Optic.hot.Q_int         = 12;

payload.Optic.cold.Q_sun        = Kalliope.q_sun*payload.Optic.cold.A_sun*payload.MLI.alpha;
payload.Optic.cold.Q_IR         = Kalliope.q_IR*payload.Optic.cold.A_IR*payload.MLI.epsilon;
payload.Optic.cold.Q_albedo     = Kalliope.q_albedo*payload.Optic.cold.A_albedo*payload.MLI.alpha;
payload.Optic.cold.Q_int        = 0;

%% HEAT POWER EBOX

payload.EBox.hot.Q_sun          = Kalliope.q_sun*payload.EBox.hot.A_sun*payload.MLI.alpha;
payload.EBox.hot.Q_IR           = 0;
payload.EBox.hot.Q_albedo       = 0;
payload.EBox.hot.Q_int          = 33;

payload.EBox.cold.Q_sun         = Kalliope.q_sun*payload.EBox.cold.A_sun*payload.MLI.alpha;
payload.EBox.cold.Q_IR          = Kalliope.q_IR*payload.EBox.cold.A_IR*payload.MLI.epsilon;
payload.EBox.cold.Q_albedo      = Kalliope.q_albedo*payload.EBox.cold.A_albedo*payload.MLI.alpha;
payload.EBox.cold.Q_int         = 1;

%% SIMULATION, NO THERMAL CONTROL

% set_param('TCS_static/Q ext E-Box', 'Value', 'payload.EBox.hot.Q_sun+payload.EBox.hot.Q_IR+payload.EBox.hot.Q_albedo')
% set_param('TCS_static/Q int E-Box', 'Value', 'payload.EBox.hot.Q_int')
% set_param('TCS_static/Q ext optic', 'Value', 'payload.Optic.hot.Q_sun+payload.Optic.hot.Q_IR+payload.Optic.hot.Q_albedo')
% set_param('TCS_static/Q int optic', 'Value', 'payload.Optic.hot.Q_int')
% set_param('TCS_static/SC', 'temperature', 'constant.T_SC.hot')
% set_param('TCS_static/SC1', 'temperature', 'constant.T_SC.hot')
% 
% res = sim("TCS_static.slx");
% payload.EBox.hot.Temp   = res.T_EBox(end);
% payload.Optic.hot.Temp  = res.T_optic(end);
% 
% clear res
% 
% set_param('TCS_static/Q ext E-Box', 'Value', 'payload.EBox.cold.Q_sun+payload.EBox.cold.Q_IR+payload.EBox.cold.Q_albedo')
% set_param('TCS_static/Q int E-Box', 'Value', 'payload.EBox.cold.Q_int')
% set_param('TCS_static/Q ext optic', 'Value', 'payload.Optic.cold.Q_sun+payload.Optic.cold.Q_IR+payload.Optic.cold.Q_albedo')
% set_param('TCS_static/Q int optic', 'Value', 'payload.Optic.cold.Q_int')
% set_param('TCS_static/SC', 'temperature', 'constant.T_SC.cold')
% set_param('TCS_static/SC1', 'temperature', 'constant.T_SC.cold')
% 
% res = sim("TCS_static.slx");
% payload.EBox.cold.Temp   = res.T_EBox(end);
% payload.Optic.cold.Temp  = res.T_optic(end);
% 
% clear res

% %% SIMULATION, MLI
% 
% set_param('TCS_MLI/Q ext E-Box', 'Value', 'payload.EBox.hot.Q_sun+payload.EBox.hot.Q_IR+payload.EBox.hot.Q_albedo')
% set_param('TCS_MLI/MLI int', 'Area', 'payload.EBox.hot.A_tot')
% set_param('TCS_MLI/MLI int1', 'Area', 'payload.Optic.hot.A_tot')
% 
% set_param('TCS_MLI/Q int E-Box', 'Value', 'payload.EBox.hot.Q_int')
% set_param('TCS_MLI/Q ext optic', 'Value', 'payload.Optic.hot.Q_sun+payload.Optic.hot.Q_IR+payload.Optic.hot.Q_albedo')
% set_param('TCS_MLI/Q int optic', 'Value', 'payload.Optic.hot.Q_int')
% set_param('TCS_MLI/MLI rad', 'Area', 'payload.EBox.hot.A_DS')
% set_param('TCS_MLI/MLI rad1', 'Area', 'payload.Optic.hot.A_DS')
% set_param('TCS_MLI/SC', 'temperature', 'constant.T_SC.hot')
% set_param('TCS_MLI/SC1', 'temperature', 'constant.T_SC.hot')
% 
% res = sim("TCS_MLI.slx");
% payload.EBox.hot.Temp_MLI   = res.T_EBox(end);
% payload.Optic.hot.Temp_MLI  = res.T_optic(end);
% 
% payload.EBox.hot.Temp_MLI
% payload.Optic.hot.Temp_MLI
% 
% clear res
% 
% set_param('TCS_MLI/Q ext E-Box', 'Value', 'payload.EBox.cold.Q_sun+payload.EBox.cold.Q_IR+payload.EBox.cold.Q_albedo')
% set_param('TCS_MLI/MLI int', 'Area', 'payload.EBox.cold.A_tot')
% set_param('TCS_MLI/MLI int1', 'Area', 'payload.Optic.cold.A_tot')
% set_param('TCS_MLI/Q int E-Box', 'Value', 'payload.EBox.cold.Q_int')
% set_param('TCS_MLI/Q ext optic', 'Value', 'payload.Optic.cold.Q_sun+payload.Optic.cold.Q_IR+payload.Optic.cold.Q_albedo')
% set_param('TCS_MLI/Q int optic', 'Value', 'payload.Optic.cold.Q_int')
% set_param('TCS_MLI/MLI rad', 'Area', 'payload.EBox.cold.A_DS')
% set_param('TCS_MLI/MLI rad1', 'Area', 'payload.Optic.cold.A_DS')
% set_param('TCS_MLI/SC', 'temperature', 'constant.T_SC.cold')
% set_param('TCS_MLI/SC1', 'temperature', 'constant.T_SC.cold')
% 
% res = sim("TCS_MLI.slx");
% payload.EBox.cold.Temp_MLI   = res.T_EBox(end);
% payload.Optic.cold.Temp_MLI  = res.T_optic(end);
% 
% clear res

%% RADIATORS SIZING

payload.EBox.Tmax           = 273.15+40;
payload.EBox.hot.Q_SC       = (payload.EBox.Tmax-constant.T_SC.hot)/payload.EBox.R_sc;
payload.EBox.hot.Q_rad      = constant.sigma*payload.epsilon_rad*(payload.EBox.Tmax^4-constant.T_space^4);
payload.EBox.A_rad          = (payload.EBox.hot.Q_int-payload.EBox.hot.Q_SC)/payload.EBox.hot.Q_rad;

if payload.EBox.A_rad<0
    payload.EBox.A_rad=0;
end

payload.Optic.Tmax          = 273.15+40;
payload.Optic.hot.Q_SC      = (payload.Optic.Tmax-constant.T_SC.hot)/payload.Optic.R_sc;
payload.Optic.hot.Q_rad     = constant.sigma*payload.epsilon_rad*(payload.Optic.Tmax^4-constant.T_space^4);
payload.Optic.A_rad         = (payload.Optic.hot.Q_int-payload.Optic.hot.Q_SC)/payload.Optic.hot.Q_rad;

if payload.Optic.A_rad<0
    payload.Optic.A_rad=0;
end

%% HEATERS SIZING

payload.EBox.Tmin       = 273.15-20; % survivability Ebox during cold case (from PCDU)
payload.Optic.Tmin      = 273.15-20; %  
syms Heat_EBox Heat_Optic

% eqns = [payload.EBox.cold.Q_sun+payload.EBox.cold.Q_IR+payload.EBox.cold.Q_albedo+payload.EBox.cold.Q_int-constant.sigma*(T_limit_EBox_down^4- ...
%         constant.T_space^4)*(0.9*A_rad_EBox+payload.EBox.epsilon*payload.EBox.cold.A_DS)+(constant.T_SC.cold-T_limit_EBox_down)/payload.EBox.R_sc+Heat_EBox==0;
%         payload.Optic.cold.Q_sun+payload.Optic.cold.Q_IR+payload.Optic.cold.Q_albedo+payload.Optic.cold.Q_int-constant.sigma*(T_limit_Optic_down^4- ...
%         constant.T_space^4)*(0.9*A_rad_Optic+payload.Optic.epsilon*payload.Optic.cold.A_DS)+(constant.T_SC.cold-T_limit_Optic_down)/payload.Optic.R_sc+Heat_Optic==0];

eqns = [payload.EBox.cold.Q_int-constant.sigma*(payload.EBox.Tmin^4-constant.T_space^4)*(payload.epsilon_rad*payload.EBox.A_rad)+(constant.T_SC.cold-payload.EBox.Tmin)/payload.EBox.R_sc+Heat_EBox==0;
        payload.Optic.cold.Q_int-constant.sigma*(payload.Optic.Tmin^4-constant.T_space^4)*(payload.epsilon_rad*payload.Optic.A_rad+payload.Optic.eps_mirror*payload.Optic.A_mirror)+(constant.T_SC.cold-payload.Optic.Tmin)/payload.Optic.R_sc+Heat_Optic==0];

sol = solve(eqns, [Heat_EBox Heat_Optic]);
payload.EBox.Heaters = double(sol.Heat_EBox);
payload.Optic.Heaters = double(sol.Heat_Optic);

clear Heat_EBox Heat_Optic sol eqns

%% SIMULATION HOT CASE w\ MLI MODEL

set_param('TCS_MLI/Q ext E-Box', 'Value', 'payload.EBox.hot.Q_sun+payload.EBox.hot.Q_IR+payload.EBox.hot.Q_albedo')
set_param('TCS_MLI/Q int E-Box', 'Value', 'payload.EBox.hot.Q_int')

set_param('TCS_MLI/Q ext optic', 'Value', 'payload.Optic.hot.Q_sun+payload.Optic.hot.Q_IR+payload.Optic.hot.Q_albedo')
set_param('TCS_MLI/Q int optic', 'Value', 'payload.Optic.hot.Q_int')

set_param('TCS_MLI/SC', 'temperature', 'constant.T_SC.hot')
set_param('TCS_MLI/SC1', 'temperature', 'constant.T_SC.hot')

set_param('TCS_MLI/EBox Heaters', 'Value', '0');
set_param('TCS_MLI/Optic Heaters', 'Value', '0');

set_param('TCS_MLI/Mirror Target', 'temperature', 'Kalliope.Temp')
set_param('TCS_MLI/Q_albedo mirror', 'Value', 'Kalliope.q_albedo*payload.Optic.A_mirror*payload.Optic.alpha_mirror')

sol_hot = sim("TCS_MLI.slx");

%% SIMULATION COLD CASE w\ MLI

set_param('TCS_MLI/Q ext E-Box', 'Value', 'payload.EBox.cold.Q_sun+payload.EBox.cold.Q_IR+payload.EBox.cold.Q_albedo')
set_param('TCS_MLI/Q int E-Box', 'Value', 'payload.EBox.cold.Q_int')

set_param('TCS_MLI/Q ext optic', 'Value', 'payload.Optic.cold.Q_sun+payload.Optic.cold.Q_IR+payload.Optic.cold.Q_albedo')
set_param('TCS_MLI/Q int optic', 'Value', 'payload.Optic.cold.Q_int')

set_param('TCS_MLI/SC', 'temperature', 'constant.T_SC.cold')
set_param('TCS_MLI/SC1', 'temperature', 'constant.T_SC.cold')

set_param('TCS_MLI/EBox Heaters', 'Value', 'payload.EBox.Heaters');
set_param('TCS_MLI/Optic Heaters', 'Value', 'payload.Optic.Heaters');

set_param('TCS_MLI/Mirror Target', 'temperature', 'constant.T_space')
set_param('TCS_MLI/Q_albedo mirror', 'Value', '0')

sol_cold = sim("TCS_MLI.slx");