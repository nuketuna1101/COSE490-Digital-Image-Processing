input=imread('cat-halftone.png');
%input=imread('saturn-rings-sinusoidal-interf.tif');
%input=imread('text-sineshade.tif');

figure,imshow(input);
title('Input Image');

% Get size
dimX = size(input,1);
dimY = size(input,2);

% Convert pixel type to float
[f, revertclass] = tofloat(input);

% Determine good padding for Fourier transform
PQ = paddedsize(size(input));

% Fourier tranform of padded input image
F = fft2(f,PQ(1),PQ(2));
F = fftshift(F);
figure,imshow(log(1+abs((F))), []);

% -------------------------------------------------------------------------

%
% Creating Frequency filter and apply - High pass filter
%

% initialize H(u, v)
D = zeros(PQ(1), PQ(2));
Dneg = zeros(PQ(1), PQ(2));

Hlp = zeros(PQ(1), PQ(2));
Hhp = zeros(PQ(1), PQ(2));
Hneglp = zeros(PQ(1), PQ(2));
Hneghp = zeros(PQ(1), PQ(2));

Hnotch = zeros(PQ(1), PQ(2));

D0 = 100;
n = 2;
k = 2;

%%% Case 1 :: for 'cat-halftone.png'
%%% Symmetric notch pairs - two notch pairs

% notch - origin
uk = (PQ(1) / 2)*(3/5);
vk = (PQ(2) / 2)*(5/8);
%
for u = 1:PQ(1)
    for v = 1:PQ(2)
        D(u, v) = sqrt((u - PQ(1) / 2 - uk).^2 + (v - PQ(2) / 2 - vk).^2);
        Dneg(u, v) = sqrt((u - PQ(1) / 2 + uk).^2 + (v - PQ(2) / 2 + vk).^2);
        
        Hlp(u, v) = 1 / (1 + (D(u, v) / D0).^(2 * n));
        Hhp(u, v) = 1 - Hlp(u, v);
        Hneglp(u, v) = 1 / (1 + (Dneg(u, v) / D0).^(2 * n));
        Hneghp(u, v) = 1 - Hneglp(u, v);        
    end
end

Hnotch = Hhp .* Hneghp;

for u = 1:PQ(1)
    for v = 1:PQ(2)
        D(u, v) = sqrt((u - PQ(1) / 2 + uk).^2 + (v - PQ(2) / 2 - vk).^2);
        Dneg(u, v) = sqrt((u - PQ(1) / 2 - uk).^2 + (v - PQ(2) / 2 + vk).^2);
        
        Hlp(u, v) = 1 / (1 + (D(u, v) / D0).^(2 * n));
        Hhp(u, v) = 1 - Hlp(u, v);
        Hneglp(u, v) = 1 / (1 + (Dneg(u, v) / D0).^(2 * n));
        Hneghp(u, v) = 1 - Hneglp(u, v);        
    end
end

Hnotch = Hnotch .* Hhp .* Hneghp;

F = Hnotch .* F;

%%% Case 1 code end---+

%%% Case 2 :: for 'saturn-rings-sinusoidal-interf.tif'
%%% narrow rectangle
%{
H1 = ones(PQ(1), PQ(2));
H1neg = ones(PQ(1), PQ(2));
for i = 1:PQ(1)/2 - 10
    for j = PQ(2)/2 - 10: PQ(2)/2 + 10
        H1(i, j) = 0;
        H1neg(PQ(1)-i, PQ(2)-j) = 0;
    end
end
Hnotch = H1 .* H1neg;
F = Hnotch .* F;
%}
%%% Case 2 code end---+

%%% Case 3 :: for 'text-sineshade.tif'
%%%
%{
H1 = ones(PQ(1), PQ(2));
H1neg = ones(PQ(1), PQ(2));


for i = 1:PQ(1)/2 - 5
    for j = PQ(2)/2 - 5: PQ(2)/2 + 5
        H1(i, j) = 0;
        H1neg(PQ(1)-i, PQ(2)-j) = 0;
    end
end

for i = 1:PQ(2)/2 - 5
    for j = PQ(1)/2 - 5: PQ(1)/2 + 5
        H1(j, i) = 0;
        H1neg(PQ(1)-j, PQ(2)-i) = 0;
    end
end

Hnotch = H1 .* H1neg;
F = Hnotch .* F;
%}
%%% Case 3 code end---+

%
% ToDo
%
G = F; 
figure,imshow(log(1+abs((G))), []);
% -------------------------------------------------------------------------

% Inverse Fourier Transform
G = ifftshift(G);
g = ifft2(G);

% Revert back to input pixel type
g = revertclass(g);

% Crop the image to undo padding
g = g(1:dimX, 1:dimY);

figure,imshow(g, []);
title('Result Image');