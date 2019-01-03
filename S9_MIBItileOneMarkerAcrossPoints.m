% MIBItileOneMarkerAcrossPoints
% Script creates a tiles images of each channel in different points in the
% dimensions specified by the user. All points are scaled the same.

% MIBItileOneMarkerAcrossPoints.m
% 
% This script plots a tiled image comparing a single marker between points/titers/tissues. It is useful for summarizing data 
% and getting back to it after a while. It should not replace rigorous examination as detailed in section 5.1. To facilitate
% comparisons, the script will cap all images of a certain marker to the same value. This value can be given on a per-channel 
% basis by adding a ‘Cap’ column to the panel csv file. If a channel-specific cap is not provided, the script will use 
% the default value defined in the script parameters.
% 
% Parameters:
% -	corePath - Path of points to work on. Several can be specified by separating with commas
% -	massFile – File name of panel csv file. Can include a ‘Cap’ column, with numerical capping values for the channels 
% (5 should be adequate for most channels. Particularly strong channels like dsDNA may require higher caps).
% -	xTileNum – Number of rows in the tile
% -	yTileNum – Number of columns in the tile
% -	outDir – Output directory for the tiled images
% -	defaultCap – Default capping value for plotting. Used only if no channel-specific value is mentioned in the csv file. A 
% good number for most antigens is 5. Set to lower to see dynamic range of low-abundant antigens and higher for high-abundant 
% antigens.
% -	xSize – X-Size of the largest image to be tiled. If, for example you’re tiling images of 1024x1024 and 512x512, then 
% this should be 1024. Increase this number (e.g. to 1030) To create space between the images.
% -	ySize – Y-Size of the largest image to be tiled. If, for example you’re tiling images of 1024x1024 and 512x512, then 
% this should be 1024. Increase this number (e.g. to 1030) To create space between the images.
% Output:
% -	Tiled tiff files generated in the output folder. Warning - these are heavy!
% Important:
% -	Use these images for a birds-eye view of the data. Don’t decide titers based on tiled images. To decide titers plot images 
% in full screen as described above.
% 
% 
corePath = {'SampleData/extracted/Point1/dataNoBg.mat'}; % cores to work on. Can add several paths, separated by commas.
massFile = 'SampleData/SamplePanel.csv'; % panel csv
xTileNum = 1; % Number of rows in tile
yTileNum = 2; % Number of columns in tile
outDir = 'SampleData/extracted/TiledImages';
defaultCap = 5; % Cap to use if no other cap is specified in the massFile
xSize = 1030; % X-Size of the largest image to be tiled. Can add a few pixels to generate a border
ySize = 1030; % Y-Size of the largest image to be tiled. Can add a few pixels to generate a border



massDS = MibiReadMassData(massFile);
coreNum = length(corePath);
mkdir (outDir);
% load all cores
p=cell(coreNum,1);
for i=1:coreNum
    p{i} = load([corePath{i}]);
end

for i=1:length(massDS)
    % check if massDS has the cap variable and if it isn't empty
    if ismember('Cap', massDS.Properties.VarNames) && ~isempty(massDS.Cap(i))
        currCap = massDS.Cap(i);
    else
        currCap = defaultCap;
    end
    % Generate the data to plot
    tiledIm = zeros(xTileNum*xSize,yTileNum*ySize);
    for j=1:coreNum
        % cap and pad dat
        data = p{j}.countsNoBg(:,:,i);
        data(data>currCap)=currCap;
        % if data is smaller than expected, pad it
        dataPad = zeros(xSize,ySize);
        dataPad([1:size(data,1)],[1:size(data,2)]) = data;
        % get position
        xpos = floor((j-1)/yTileNum)+1;
        ypos = mod(j,yTileNum);
        if (ypos == 0)
            ypos = yTileNum;
        end
        tiledIm([(xpos-1)*xSize+1:(xpos-1)*xSize+xSize],[(ypos-1)*ySize+1:(ypos-1)*ySize+ySize])=dataPad;
    end
    imwrite(uint16(tiledIm),[outDir,'/',massDS.Label{i},'_tiled.tif']);
end
