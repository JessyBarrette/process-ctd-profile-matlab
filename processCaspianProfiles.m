function rsk = processCaspianProfiles(inFile)


%% Default values
% Since we don't know the location exactely we'll use some random 
% location south of the Caspian Sea
metadata.latitude = 37.580321;
metadata.longitude= 51.636416;

%% Load File
[path, file, ext] = fileparts(inFile);

%% Read Data From Different Format
switch lower(ext)
    case '.tob' % Sun & Technology Instrument TOB File
        rsk = RSKreadTOB(inFile);
    case '.rsk' % Default RSK Files
        rsk = RSKopen(inFile);
        rsk = RSKreaddata(rsk);
        rsk = RSKreadcalibrations(rsk);
    otherwise
        error('Can''t recognize the file input format')
end

%% Add profile fields that aren't provided within the basic RSK Format
rsk.profiles = [];
rsk.region = [];
rsk.regionCast = [];

%% Add Metadata
% We don't have access to Metadata but if yes this could be added here...
% somehow.

%% Run CTD Processing
% Zero Depth near the surface
rsk(end+1) = RSKderivedepth(rsk(end),'latitude',metadata.latitude);
rsk(end+1) = RSKderivevelocity(rsk(end));
rsk(end+1) = RSKtimeseries2profiles(rsk(end));
rawRSK = rsk(end);

% Smooth Data
rsk(end+1) = RSKsmooth(rsk(end),'channel',{'Conductivity','Temperature'},'windowLength',3);

% Align Data 
rsk(end+1) = RSKalignchannel(rsk(end),'channel','Temperature','lag',1/4,'lagunits','seconds','direction','up');
rsk(end+1) = RSKalignchannel(rsk(end),'channel','Temperature','lag',-1/8,'lagunits','seconds','direction','down');
rsk(end+1) = RSKalignchannel(rsk(end),'channel','DO_mg','lag',-4,'lagunits','seconds'); 
rsk(end+1) = RSKalignchannel(rsk(end),'channel','Dissolved Oxygen','lag',-4,'lagunits','seconds'); % Seem affected by salinity spikes

% Derive Variables
rsk(end+1) = RSKderivesalinity(rsk(end)); %The Conductivity data isn't in mS/cm, I won't do any recompute it since it will overwrite the value
% Could derive more variables.

% Loop average (remove loop the in profile)
rsk(end+1) = RSKremoveloops(rsk(end),'threshold',.25);
preBin=rsk(end);

% Bin average
maxSeaPressure = max(ceil(rsk(1).data.values(:,getchannelindex(rsk(1),'sea pressure'))));
rsk(end+1) = RSKbinaverage(rsk(end),'direction','down','binBy','sea pressure','boundary',[-.5,maxSeaPressure]); % by default it creates 1m bins
rsk(end+1) = RSKbinaverage(rsk(end),'direction','up','binBy','sea pressure','boundary',[0,maxSeaPressure+.5]); % by default it creates 1m bins

% Plot Result
% Just present CTD and DO data
[hf_profile,hf_timeseries] = figure.plotProfile({rawRSK,preBin,rsk(end)},{'Temperature','Salinity','Conductivity','Dissolved Oxygen','DO_mg'},{'raw','preBin','final'},{'r','b','k'});
print(hf_profile,fullfile(path,[file,'_CTD+DO_processProfile']),'-r300','-dpng')
print(hf_timeseries,fullfile(path,[file,'_CTD+DO_processTimeSeries']),'-r300','-dpng')

%Write processed data!
RSKplotprofiles(rsk(end)); % Let's show the all resulting plots
RSK2ODV(rsk(end)); % ODV is a good format to use
RSK2CSV(rsk(end)); % Could be useful to
end