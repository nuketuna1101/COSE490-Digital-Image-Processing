%
% Skeleton code for COSE490 Fall 2022 Assignment 3
%
% Won-Ki Jeong (wkjeong@korea.ac.kr)
%

function phi_out = levelset_update(phi_in, g, c, timestep)
phi_out = phi_in;

%
% ToDo
%

% inputs ::
% g as edge term
% c as constant term
% timestep as time derivative

% gradient
[phi_x, phi_y] = gradient(phi_in);
% for normalization
mag_gradPhi = sqrt(phi_x.^2 + phi_y.^2);
% to avoid zero-dividing, add little possitive value
lil_pos = 0.0000000001;

dphix = phi_x./(mag_gradPhi + lil_pos);
dphiy = phi_y./(mag_gradPhi + lil_pos);

[dphix2, dphixy] = gradient(dphix);
[dphiyx, dphiy2]= gradient(dphiy);
div_phi = dphix2 + dphiy2;

% <1> First compute 'dPhi' 
dPhi = mag_gradPhi; % mag(grad(phi))

% 
% <2> Second, compute kappa
kappa = div_phi; % curvature

%%%

smoothness = g.*kappa.*dPhi;
expand = c*g.*dPhi;

phi_out = phi_out + timestep*(expand + smoothness);