
% MIBIdenoise.m
% 
% This script denoises the data according to the thresholds identified in the previous step and stored in the ‘NoiseT’
% column in the panel csv folder.
% Parameters:
% -	corePath - Paths of points to denoise. Add several by separating with commas
% -	cleanDataPath - Path to store clean data. Data will be renumbered Point1..PointN.
% -	massPath - Path to panel csv. Make sure it has a column 'NoiseT' which has the noise threshold for each channel.
% -	K - Number of neighbors to use for density calculation. Usually can be kept as 25.
% Output:
% •	TIFsNoBg – directory with TIFs after denoising.
% •	dataDeNoiseCohort.mat – matlab file with the denoised data
% 
% 
% % remove noise for all cores in the study
% 
% % params
corePath = {'SampleData/extracted/Point1/'}; % points to denoise. Add several by separating with commas
cleanDataPath = 'SampleData/extracted/cleanData'; % path to store clean data. Data will be renumbered
massPath = 'SampleData/SamplePanel.csv'; % path to panel csv. Make sure it has a column 'NoiseT' whci has the noise threshold 
% for each channel
K = 25; % number of neighbors to use for density calculation. Usually can be kept as 25.

mkdir(cleanDataPath);
coreNum= length(corePath);

% load noise threshold file
massDSNew = MibiReadMassData(massPath);

% remove noise and replot
for i=1:coreNum
    disp(['Working on core number ' , num2str(i)]);
    load([corePath{i},'dataNoBg.mat']);
    for j=1:length(massDSNew)
        if ~(massDSNew.NoiseT(j)==0)
            IntNormD{j}=MibiGetIntNormDist(countsNoBg(:,:,j),countsNoBg(:,:,j),K,2,K);
        end
    end
    countsNoNoise = MibiFilterAllByNN(countsNoBg,IntNormD,massDSNew.NoiseT);
    mkdir([cleanDataPath,'/Point',num2str(i)]);
    save([cleanDataPath,'/Point',num2str(i),'/dataDeNoiseCohort.mat'],'countsNoNoise');
    MibiSaveTifs ([corePath{i},'/TIFsNoNoise/'], countsNoNoise, massDS.Label)
    close all;
end
