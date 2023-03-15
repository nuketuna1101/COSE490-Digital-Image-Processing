function output = myCDF(image)

output=zeros(256,1);

% todo
% -- check code using CUMSUM
%hnorm = imhist(image)./numel(image);
%output = cumsum(hnorm);
% --

pdf = zeros(256, 1);
pdf = getPDF(image);

% build cdf by adding up
output(1) = output(1) + pdf(1);
for i = 2:256
    output(i) = output(i - 1) + pdf(i); 
end
for i = 1:256
    output(i) = 255 * output(i); 
end

end

function result = getPDF(image)
result = zeros(256, 1);
rowmax = size(image, 1);
colmax = size(image, 2);
for row = 1:rowmax
    for col = 1:colmax
        temp = image(row, col);
        % temp possibly be zero-value
        result(temp + 1) = result(temp + 1) + 1 / (rowmax * colmax);
    end
end
end
