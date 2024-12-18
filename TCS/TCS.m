clear
close all

%% DATA
% Constants
constant.AU2m    = 149597870707;                    % [AU] -> [m]
constant.AU2km   = 149597870.707;                   % [AU] -> [km]
constant.q0      = 1367.5;                          % Solar flux @ 1 AU [W/m2]
constant.sigma   = 5.67037*1e-8 ;                   % Boltzmann constant [W/m2*K4];      
constant.T_space = 3;                               % Deep space temperature [K]

% Earth
Earth.r     = 1;                                    % Semi-major axis of the Earth [AU]
Earth.R     = 6378;                                 % Earth radius [km]
Earth.a     = 0.38;                                 % albedo factor of the Earth [-]
Earth.eps   = 1;                                    % Emissivity of the Earth (0.85 if not black body) [-]
Earth.Temp  = 250;                                  % Earth black-body temperature [K]

% 22 Kalliope
Kalliope.r   = 2.91;                                % Semi-major axis of 22 Kalliope [AU]
Kalliope.a   = 0.166;                               % Albedo factor of 22 Kalliope [-]
Kalliope.eps = 0.9;                                 % IR emissivity of the asteroid [-]
Kalliope.m   = 7.7e18;                              % mass of Kalliope [kg]
Kalliope.sma = [72 117.5 62];                       % semi-major axis of Kalliope ellipsoid [km]
Kalliope.R   = max(Kalliope.sma)/2;

% Kalliope Temperature
eta = 0.756;
G = 0.21;
q = 0.290 + 0.684 * G;
Ab = Kalliope.a * q;
Ls = 3.827*1e26;
Kalliope.Temp = (Ls*(1-Ab)/(16*pi*Kalliope.eps*...
    constant.sigma*eta*(Kalliope.r*constant.AU2m)^2 ))^(1/4);   % Temperature of Kalliope [K]
clear eta G q Ab Ls

LEOP.h      = 500;
LEOP.a      = LEOP.h+Earth.R;
science.a   = 400;
science.h   = science.a-Kalliope.R;

% PAYLOAD
payload.theta           = 0;               % View factor of the s/c [rad]

%% Specific heat Fluxes @ Earth

LEOP.q_sun = constant.q0;
LEOP.q_albedo = LEOP.q_sun * Earth.a * cos(payload.theta) * (Earth.R / (Earth.R + LEOP.h))^2;
LEOP.q_IR = constant.sigma * Earth.eps * Earth.Temp^4 * ( Earth.R / (Earth.R + LEOP.h) )^2;

%% Specific heat Fluxes @ Kalliope

science.q_sun = constant.q0 * ( Earth.r / Kalliope.r )^2;
science.q_albedo = science.q_sun * Kalliope.a * cos(payload.theta) * (Kalliope.R / (Kalliope.R + science.h))^2;
science.q_IR = constant.sigma * Kalliope.eps * Kalliope.Temp^4 * ( Kalliope.R / (Kalliope.R + science.h) )^2;