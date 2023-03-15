function output = myAHE(input, numtiles)

dimX = size(input,1);
dimY = size(input,2);

output = uint8(zeros(dimX,dimY));

% ToDo
% <1> Split input image into tiles, and setting values for tile
tileNumRow = numtiles(1);       % in this example, 10
tileNumCol = numtiles(2);
tileWidth = ceil(dimX / tileNumRow);       % in this example, 89
tileHeight = ceil(dimY / tileNumCol);

% <2> Compute mapping func CDF for each tile
tileCDF = zeros(tileNumRow, tileNumCol, 256);
for i = 1:tileNumRow
    for j = 1:tileNumCol
        initRow = tileWidth * (i - 1) + 1;
        initCol = tileHeight * (j - 1) + 1;
        currentTile = input(initRow:min(initRow + tileWidth, end), initCol:min(initCol + tileHeight, end));
        tileCDF(i, j, :) = myCDF(currentTile);
    end
end

% <3> Compute four different HE value and Linear Interpolation
% (i,j) as a pixel coordinate for searching
for i = 1:dimX
    for j = 1:dimY
        % want to know which tile (i, j) pixel is located on
        currentTileNumberX = floor(i / tileWidth) + 1;
        currentTileNumberY = floor(j / tileHeight) + 1;
        % the center pixel of the current tile
        cx = TileCenterCoord(currentTileNumberX, tileWidth);
        cy = TileCenterCoord(currentTileNumberY, tileHeight);

        % then we can check the possible neighbor tiles :: multiple cases
        % Horizontal
        if (i < cx) % pixel locates left side of tile center
            if (currentTileNumberX == 1)
                % No Neighbor in left side
                neighborTileNumberX = -1;
            else
                % neighbor in left side
                neighborTileNumberX = currentTileNumberX - 1; 
            end
        else    % pixel locates right side of tile center
            if (currentTileNumberX == tileNumRow)
                % No Neighbor in right side
                neighborTileNumberX = -1;
            else
                % neighbor in right side
                neighborTileNumberX = currentTileNumberX + 1; 
            end            
        end

        % Vertical
        if (j < cy) % pixel locates top of tile center
            if (currentTileNumberY == 1)
                % No Neighbor in top side
                neighborTileNumberY = -1;
            else
                % neighbor in top side
                neighborTileNumberY = currentTileNumberY - 1; 
            end
        else    % pixel locates bottom of tile center
            if (currentTileNumberY == tileNumCol)
                % No Neighbor in bottom side
                neighborTileNumberY = -1;
            else
                % neighbor in bottom side
                neighborTileNumberY = currentTileNumberY + 1; 
            end            
        end
 
        % Compute the Interpolation
        % None of neighbors exists :: itself
        if (neighborTileNumberX == -1 && neighborTileNumberY == -1)
            output(i,j) = tileCDF(currentTileNumberX, currentTileNumberY, input(i,j) + 1);
        elseif (neighborTileNumberX == -1)
            % only Vertical neighbor exists :: y coordinate interpolation
            neighborTileCY = TileCenterCoord(neighborTileNumberY, tileHeight);

            originalInt = tileCDF(currentTileNumberX, currentTileNumberY, input(i,j) + 1);
            neighborVerticalInt = tileCDF(currentTileNumberX, neighborTileNumberY, input(i,j) + 1);

            output(i,j) = LinearInterpolation(j, cy, neighborTileCY, originalInt, neighborVerticalInt);
        elseif (neighborTileNumberY == -1)
            % only Horizontal neighbor exists :: x coordinate interpolation            
            neighborTileCX = TileCenterCoord(neighborTileNumberX, tileWidth);

            originalInt = tileCDF(currentTileNumberX, currentTileNumberY, input(i,j) + 1);
            neighborHorizontalInt = tileCDF(neighborTileNumberX, currentTileNumberY, input(i,j) + 1);

            output(i,j) = LinearInterpolation(i, cx, neighborTileCX, originalInt, neighborHorizontalInt);
        else
            % Bilinear Interpolation
            neighborTileCX = TileCenterCoord(neighborTileNumberX, tileWidth);
            neighborTileCY = TileCenterCoord(neighborTileNumberY, tileHeight);

            originalInt = tileCDF(currentTileNumberX, currentTileNumberY, input(i,j) + 1);
            neighborVerticalInt = tileCDF(currentTileNumberX, neighborTileNumberY, input(i,j) + 1);
            neighborHorizontalInt = tileCDF(neighborTileNumberX, currentTileNumberY, input(i,j) + 1);
            neighborDiagonalInt = tileCDF(neighborTileNumberX, neighborTileNumberY, input(i,j) + 1);

            resultLerp1 = LinearInterpolation (j, cy, neighborTileCY, originalInt, neighborVerticalInt);
            resultLerp2 = LinearInterpolation (j, cy, neighborTileCY, neighborHorizontalInt, neighborDiagonalInt);
            
            output(i,j) = LinearInterpolation(i, cx, neighborTileCX, resultLerp1, resultLerp2);
        end       
    end
end

end

% user custom func : find Center pixel's coordinate with knowing tileNo.
function result = TileCenterCoord(tileNumX, tileWidth)
    result = tileWidth * tileNumX - ceil(tileWidth / 2);
end

% user custom func : for Linear Interpolation
function result = LinearInterpolation(target, point1, point2, value1, value2)
    % suppose <point1 - target - point2>
    a = abs(target - point1);
    b = abs(point2 - target);
    result = abs((a / (a + b)) * value2 + (b / (a+b)) * value1);
    result = round(result);
end

