
% MIBIcompare_titers
% Interactive script for choosing titers

% MIBIcompare_titers.m
% 
% A common analysis task when building a panel is to compare stains for an antibody (either across titers, across tissues or both). 
% 
% This script compares a single channel between different cores.
% Parameters:
% -	corePath - Path of points to work on. Several can be specified by separating with commas
% -	Headers – Headers for each one of the points (e.g. ‘low titer’,’med titer’ etc.).
% -	Cap – Capping value for plotting. A good number for most antigens is 5. Set to lower to see dynamic range of low-abundant 
% antigens and higher for high-abundant antigens.
% -	Channel – channel to compare.
% -	K - Number of neighbors to use for density calculation. Usually can be kept as 25.
% -	First – 1 if this is the first time running. If loading many points, you can change to 0 after first run to save loading 
% time.
% 
% The script generates the following plot to help compare titers:
% 1.	Images of the target channel across all points, all capped the same way. These are useful for looking at the signal and 
% the noise and seeing how they compare visually between titers.
% 2.	Histograms of positive intensity counts. For each point, a histogram is plotted showing the number of pixels that had a 
% value of 1, 2 etc. Noise is generally random and generates pixels with counts of 1. Signal generally generates more pixels with 
% higher counts. These histograms allow you to see whether a different titer improves the number of high-intensity pixels.
% a.	Important: Be mindful of the tissue architecture when comparing. Differences in these histograms can also result from 
% comparing fields with a different number of positive cells. Use this metric as a guide in your overall decision. Don’t take 
% it as a solid truth.
% 3.	Histograms of density. In MIBI data, positive signal of weak markers may manifest as higher density of positive pixels, 
% rather than higher intensity. For each point, a histogram is plotted showing the KNN-density for all positive pixels. High 
% density (low values on x-axis) are signal and low density (high values on x-axis) are noise. A good titer will provide a good 
% separation between signal and noise.
% a.	Important: Be mindful of the tissue architecture when comparing. Differences in these histograms can also result from 
% comparing fields with a different number of positive cells. Use this metric as a guide in your overall decision. Don’t take 
% it as a solid truth.
% Tips and tricks when choosing titers:
% 1.	Always work on data after it was background-subtracted. A common mistake is to interpret background signal as real signal.
% 2.	Be conscious of bleed-through (when the signal of one channel carries over into another). It is always good to check that 
% your signal is not a result of bleeding from the -1, -16 or -17 channels.
% 3.	Use other channels in your decision. For example: if you’re not sure about the signal of Tbet (a transcription factor
% expressed in T helper cells), compare the staining with that of CD4, CD3 and dsDNA to look for colocalizations.
% 4.	When choosing final titers, take into account the tissue that you will be working on. Many immune markers will require
% high titers in tonsil simply because there are a ton of immune cells there. Some of these will require lower titers in other 
% tissues, because there are less real targets and the excess antibody just binds non-specifically.
% 


corePath = {'SampleData/extracted/Point1/'}; % cores to work on. Can add several paths, separated by commas.
Headers = {'High','Low'}; % Headers describing each one of the points. Will be used for visualization.
channel = {'CD8'}; % Channel to work on
cap = 5; % Capping value for plotting.
K=25; %Nearest neighbours to use for density estimation
First =1; % 1- If this is the first time running. If the script is sloa, you can change to 0 to save the loading time after the first run.


coreNum = length(corePath);
% load all cores
if First == 1
    p=cell(coreNum,1);
    for i=1:coreNum
        p{i} = load([corePath{i},'dataNoBg.mat']);
    end
end

[~,channelInd] = ismember(channel,p{1}.massDS.Label);

% 1. plot titration with same cap
for i=1:coreNum
    MibiPlotDataAndCap(p{i}.countsNoBg(:,:,channelInd),cap,[channel , ' - ' , Headers{i}]); plotbrowser on;
end

% 2. plot intensity histograms
figure;
for i=1:coreNum
    currData = p{i}.countsNoBg(:,:,channelInd);
    currDataLin = currData(:);
    currDataLin(currDataLin == 0) = [];
    hold on;
    histogram(currDataLin,'Normalization','probability','DisplayStyle','stairs');
    xlabel('Intensity');
    ylabel('Counts');
    plotbrowser on;
end

% 3. calculate NN histograms and plot
for i=1:coreNum
    p{i}.IntNormD{channelInd}=MibiGetIntNormDist(p{i}.countsNoBg(:,:,channelInd),p{i}.countsNoBg(:,:,channelInd),K,2,K);
end

figure;
for i=1:coreNum
    hold on;
    histogram(p{i}.IntNormD{channelInd},'DisplayStyle','stairs');
    xlabel('Mean distance to nearest neighbours');
    ylabel('Counts');
    plotbrowser on;
end
