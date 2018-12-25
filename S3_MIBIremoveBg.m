
% MIBIremoveBg.m
% 
% The purpose of this script is to use the parameters identified in the previous section to subtract background for a list of cores.
% You will need to set the following variables:
% •	corePath – a path to all the cores you want to subtract background from. Several paths can be specified by separating 
% them by commas
% •	bgChannel, gausRad, t, removeVal – parameters for subtraction. See explanation above. These should be set to the values 
% identified as optimal in the script above.
% Output:
% •	TIFsNoBg – directory with TIFs after bg removal
% •	dataNoBg.mat – matlab file with the following variables:
% o	massDS – a table with the information from the CSV
% o	countsNoBg – a matrix of size [x-dimension,y-dimension,number-of-channels] with all the data after background subtraction
% 

% remove background for several cores according to removal params

corePath = {'SampleData/extracted/Point1/'}; % cores to work on. Can add several paths, separated by commas.

% put in here parameters from MIBIgetBgSubtractionParams.m
bgChannel = ('Background');
gausRad= 1;
t= 0.2;
removeVal= 2;
cap = 10;
coreNum = length(corePath);

for i=1:length(corePath)
    disp(['Working on ' num2str(i)]);
    load([corePath{i},'data.mat']);
    [~,bgChannelInd] = ismember(bgChannel,massDS.Label);
    mask = MibiGetMask(countsAllSFiltCRSum(:,:,bgChannelInd),cap,t,gausRad);
    countsNoBg = MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
    save ([corePath{i},'dataNoBg.mat'],'massDS','pointNumber','countsNoBg');
    MibiSaveTifs ([corePath{i},'/TIFsNoBg/'], countsNoBg, massDS.Label)
    close all;
end
