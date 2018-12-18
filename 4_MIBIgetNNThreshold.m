
% MIBIgetNNthreshold.m
% 
% This is an interactive script that allows you to choose a good threshold for noise removal for each channel. For each channel, for each positive pixel a density score is calculated by a KNN approach. This script slows you to identify a density threshold, which separates signal from noise. A different threshold should be identified for each channel.
% The script has three parts:
% A.	Loading the data. If you are working on a single point then this is fast. If you’re working on many points this may take some time. You want to run this part only once, when first loading your data.
% B.	Calculating nearest neighbor density for the marker of choice. The time it takes to calculate the density increases for high-abundance markers. You want to run this part once for every marker that you analyze.
% C.	Plotting density distributions. A nice marker should have a bimodal density distribution, like in the figure below. In this case a good threshold for distinguishing signal from noise is ~3.5 (dashed red line).
% D.	Denoising according to the threshold and plotting images of before and after. You want to run this part for several thresholds until settling on one that you like.
% Parameters:
% -	corePath - Path to cores that you want to evaluate for noise reduction. Specify several paths by separating with commas
% -	massPath - Path to the CSV file with the panel data. The script expects the same panel for all cores.
% -	load_data – Boolean (0/1) indicating whether you need to load the data. If you’re working on many cores it is recommended to change to 0 after the first time that you run the script to save the loading time.
% -	plotChannel - Channel that you want to denoise. Should be spelled as in your CSV file.
% -	new_channel - Boolean (0/1) indicating whether you need to calculate nearest neighbor density for this channel. This should only be done once. After the first time that you run the script for a specific channel you can change to 0 to save the calculation time.
% -	t - Threshold used for separating signal and noise. Play with this number until you're happy with the denoising results.
% -	capImage - Capping value for plotting. Set to lower to see dynamic range of low-abundant antigens.
% -	K = 25 - Number of neighbors to use for density calculation. Usually can be kept as 25.
% It is recommended to first run the script with load_data=1 and new_channel=1 and to start with an easy channel (e.g. CD8), to get the hang of it. After the first time that you run the script you can turn both load_data and new_channel to zero to save time while homing in on the exact threshold that you like for CD8. Once you found a good threshold, write it down in the NoiseT column of your panel csv file. For the example above, that number should be 3.5. You can now proceed to identifying the threshold for the next channel. Make sure to turn new_channel back to one for the first run of the next channel!
% Tips:
% -	It is recommended to test your threshold on more than one point.
% -	Different tissue types may need different thresholds for noise removal. If your cohort contains more than one type, test the parameters on all of them.
% -	After you’ve identified a threshold that you like, store it in your panel csv file in a column names ‘NoiseT’.



% parameters
corePath = {'SampleData/extracted/Point1/','SampleData/extracted/Point1/'}; % path to cores that you want to evaluate for noise rduction. Specify several paths by separating with commas
massPath = 'SampleData/SamplePanel.csv'; % path to panel csv
load_data = 1; % after the first time that you run the script you can change to 0 to save the loading time.
plotChannel = 'CD8'; % channel that you want to denoise.
new_channel = 1; % after the first time that you run the script for a specific channel you can change to 0 to save the calculation time.
t = 3.5; % threshold used for separating signal and noise. Play with this number until you're happy with the results.
capImage = 10; % capping value for plotting. Set to lower to see dynamic range of low-abundant antigens
K = 25; % number of neighbors to use for density calculation. Usually can be kept as 25.


massDS = MibiReadMassData(massPath);
coreNum= length(corePath);
vec=[1:coreNum];
[~, plotChannelInd] = ismember(plotChannel,massDS.Label);

% load data. Do only for the first run of the script
if load_data
    p=cell(coreNum,1);
    for i=vec
        disp(['Loading core number ', num2str(i)]);
        p{i}=load([corePath{i},'dataNoBg.mat']);
    end

    disp('finished loading');
end

%get the NN values for the channel for all cores
if new_channel
    for i=vec
        p{i}.IntNormD{plotChannelInd}=MibiGetIntNormDist(p{i}.countsNoBg(:,:,plotChannelInd),p{i}.countsNoBg(:,:,plotChannelInd),K,2,K);
    end
end

chanelInAllPoints = zeros(size(p{1}.countsNoBg(:,:,plotChannelInd),1),size(p{1}.countsNoBg(:,:,plotChannelInd),2),1,coreNum);
chanelInAllPointsCapped = zeros(size(p{1}.countsNoBg(:,:,plotChannelInd),1),size(p{1}.countsNoBg(:,:,plotChannelInd),2),1,coreNum);

% plot the NN histograms for all points in a single plot, use to find
% noiseT cutoff
f=figure;
hedges = [0:0.25:30];
hline=zeros(coreNum,length(hedges)-1);
for j = vec
    data = p{j}.IntNormD{plotChannelInd};
    h=histogram(data,hedges,'Normalization','probability');
    hline(j,:)=h.Values;
end
clear('h','data');
a = 1:coreNum ;
labels = strread(num2str(a),'%s');
plot(hedges([1:end-1]),hline);
legend(labels);
plotbrowser on;

% test the threshold
for i=1:coreNum
    countsNoNoise{i} = MibiFilterImageByNNThreshold(p{i}.countsNoBg(:,:,plotChannelInd),p{i}.IntNormD{plotChannelInd},t);
    MibiPlotDataAndCap(p{i}.countsNoBg(:,:,plotChannelInd),capImage,['Core number ',num2str(i), ' - Before']); plotbrowser on;
    MibiPlotDataAndCap(countsNoNoise{i},capImage,['Core number ',num2str(i), ' - After. T=',num2str(t)]); plotbrowser on;
end
