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
rsk(end) = RSKderivedepth(rsk(end),'latitude',metadata.latitude);
rsk(end) = RSKderivevelocity(rsk(end));

% Smooth Data
rsk(end) = RSKsmooth(rsk,'channel',{'Conductivity','Temperature'},'windowLength',3);

% Align Data (just an example with Oxygen)
rsk(end) = RSKalignchannel(rsk,'channel','Temperature','lag',1/3,'lagunits','seconds');
rsk(end) = RSKalignchannel(rsk,'channel','Dissolved Oxygen','lag',-9,'lagunits','seconds'); % ~10s seems to be matching up and downcast 

% Derive Variables
%rsk(end) = RSKderivesalinity(rsk(end)); # The Conductivity data isn't in mS/cm, I won't do any recompute it since it will overwrite the value

% Split up/down casts
rsk(end) = RSKtimeseries2profiles(rsk(end));

% Loop average (remove loop the in profile)
rsk(end) = RSKremoveloops(rsk(end),'threshold',.25);

% Bin average
rsk(end) = RSKbinaverage(rsk(end)); % by default it creates 1m bins

%Write processed data!
RSK2ODV(rsk(end)); % ODV is a good format to use
RSK2CSV(rsk(end)); % Could be useful to
RSKplotprofiles(rsk(end)); % Let's show the resulting plots
end




