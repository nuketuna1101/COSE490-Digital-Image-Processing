function output = myHE(input)

dimX = size(input,1);
dimY = size(input,2);

output = uint8(zeros(dimX,dimY));

% ToDo
% -- check code using HISTEQ
%output = histeq(input, 256);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
% --

% make transform function T(x)
T = myCDF(input);
for row = 1:dimX
    for col = 1:dimY
        value_r = input(row, col) + 1;
        output(row, col) = T(value_r);
    end
end

end
