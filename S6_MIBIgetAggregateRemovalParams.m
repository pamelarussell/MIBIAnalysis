
% MIBIgetAggregateRemovalParams
% Find thresholds for aggregate removal
% The script works by gaussian-smoothing the data and then removing connected components below a certain size.

% MIBIgetAggregateRemovalParams.m
% 
% This is an interactive script that allows you to choose parameters for aggregate removal for each channel. The script works 
% by gaussian-smoothing the data and then removing connected components below a certain size. These should remove any experimental 
% aggregates as well as small clumps left over after noise removal. The script has two parts:
% 1.	Loading the data – you can save time by running this only once.
% 2.	Aggregate filtering according to the threshold given by the user.
% Parameters:
% -	corePath - Path to cores that you want to evaluate for aggregate removal. Specify several paths by separating with commas
% -	massPath - Path to the CSV file with the panel data. The script expects the same panel for all cores.
% -	load_data – Boolean (0/1) indicating whether you need to load the data. If you’re working on many cores it is recommended 
% to change to 0 after the first time that you run the script to save the loading time.
% -	plotChannel - Channel that you want to denoise. Should be spelled as in your CSV file.
% -	gausFlag - flag of whether to do gaussian smoothing or not.
% -	gausRad - gauss radius for smoothing (No need to play with this normaly).
% -	capImage - Capping value for plotting. Set to lower to see dynamic range of low-abundant antigens and higher for high-abundant 
% antigens.
% -	t - Threshold used for filtering aggregates. Play with this number until you're happy with the filtering results.
% 
% *** Note from Pam Russell: the following (AggFilter and GausFlag) are handled
% by params below and do not need to be included in the CSV. AggFilter is called "t". ***
% After you’ve identified appropriate t thresholds for each channel:
% -	Store thresholds in your csv file in a column named ‘AggFilter’.
% -	Create a column called ‘GausFlag’. This should have 1 if this threshold was found using gaussian filtering (default), 
% or 0 if you decided to remove the gaussian step.
% 
% 
% % parameters
corePath = {'SampleData/extracted/cleanData/Point1/'}; % path to cores that you want 
% to evaluate for aggregate removal. Specify several paths by separating with commas
massPath = 'SampleData/SamplePanel.csv'; % path to panel csv
load_data = 1; % after the first time that you run the script you can change to 0 to save the loading time.
plotChannel = 'CD4'; % channel that you want to work on.
gausFlag = 1; % flag of whether to do gaussian smoothing or not.
gausRad = 1; % gauss radius for smoothing.
capImage = 5; % value for capping the images when plotting. If colors are saturated, increase this number.
% 
t = 100; % Important: threshold used for aggregate removal. Components smaller than this size will be removed. Play with this 
% number until you're happy with the results.


massDS = MibiReadMassData(massPath);
coreNum= length(corePath);

% load data. Do only for the first run of the script
if load_data
    p=cell(coreNum,1);
    q=cell(coreNum,1);
    for i=1:coreNum
        disp(['Loading core number ', num2str(i)]);
        p{i}=load([cleanDataPath, '/Point', num2str(i), '/dataDeNoiseCohort.mat']);
    end

    disp('finished loading');
end

% perform aggregate removal:
[~, plotChannelInd] = ismember(plotChannel,massDS.Label);
for i=1:length(corePath)
    q{i}.countsNoNoiseNoAgg(:,:,plotChannelInd) = MibiFilterAggregates(p{i}.countsNoNoise(:,:,plotChannelInd),gausRad,t,gausFlag);

    % plot
    MibiPlotDataAndCap(p{i}.countsNoNoise(:,:,plotChannelInd),capImage,['Point ',num2str(i), ' - Before - ',massDS.Label{plotChannelInd}]); plotbrowser on;
    MibiPlotDataAndCap(q{i}.countsNoNoiseNoAgg(:,:,plotChannelInd),capImage,['Point ',num2str(i), ' - After - ',massDS.Label{plotChannelInd}]); plotbrowser on;

end
