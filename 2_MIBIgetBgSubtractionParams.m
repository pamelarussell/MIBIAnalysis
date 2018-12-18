
% MIBIgetBgSubtractionParams.m
% 
% This is an interactive script, which allows you to choose a proper threshold for background subtraction. The MIBI data often 
% has background signal, usually coming from bare slide regions. This signal in common across different channels and can obscure 
% the data unless it is removed.
% 
% The script works on a user-defined background channel. This can be a region with no antibody labeling (e.g. masses 128-132) or 
% one of the channels that are strong on the slide (e.g. Si, Ta and Au). This background channel will be used to generate a 
% binary mask according to a user-defined threshold. The binary mask will later be applied to all other channels, and the signal 
% in positive regions in the mask will be attenuated by a specified number of counts. The purpose of this script in to identify 
% adequate parameters for this process.
% The script generates the following plots:
% 1.	Image of the raw background channel.
% 2.	Smoothed histogram of the counts on the raw channel. This is useful for setting the threshold for signal and noise. A 
% recommended signal by Otsu’s method is shown in red.
% 3.	The binary mask of the background channel identified according to the parameters in the script. Regions in yellow will 
% be subtracted across all channels.
% 4.	An evaluation channel, defined by the user, before subtraction.
% 5.	An evaluation channel, defined by the user, after subtraction according to the parameters in the script.
% Parameters to change in case of inadequate background removal:
% •	bgChannel - channel used for background signal. Can use Au/Ta/Si/Background.
% •	gausRad - radius of gaussian to use for signal smoothing (typically 1-3)
% •	t - threshold for binary thresholding (0-1)
% •	removeVal - value to remove from all channels in background-positive areas (increase for more aggressive removal).
% 
% You can test a set of parameters on several cores by adding several paths to the corePath variable. Once you have identified 
% good parameters for background removal, proceed to applying those using the next script.



% Get parameters for background subtraction

% parameters
corePath = {'SampleData/extracted/Point1/'}; % path to data generated from the extraction process
bgChannel = ('Background'); % channel used for background signal. (Typically Au/Ta/Si/Background)
gausRad= 1; % radius of gaussian to use for signal smoothing (typically 1-3)
t= 0.2; % threshold for binary thresholding (0-1)
removeVal= 2; % value to remove from all channels in background-positive areas (increase for more aggressive removal)
evalChannel = ('CD45'); % channel to plot for evaluating the background removal
capBgChannel = 50; % cap for plotting background channel
capEvalChannel = 5; % cap for plotting evaluation channel


coreNum = length(corePath);

for i=1:coreNum
    load([corePath{i},'data.mat']);
    [~,bgChannelInd] = ismember(bgChannel,massDS.Label);
    MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,['Background channel - ',bgChannel]); plotbrowser on;
    mask = MibiGetMask(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,t,gausRad);
    countsNoBg = MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
    [~,evalChannelInd] = ismember(evalChannel,massDS.Label);
    MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,evalChannelInd),capEvalChannel,[evalChannel , ' - before']); plotbrowser on;
    MibiPlotDataAndCap(countsNoBg(:,:,evalChannelInd),capEvalChannel,[evalChannel , ' - after']); plotbrowser on;
end
