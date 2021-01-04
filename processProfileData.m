function rsk = processProfileData(inFile)


%% Read Raw File Path
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
rsk(end) = RSKsmooth(rsk,'channel',{'Conductivity','Temperature'},'windowLength',process.smoothCT.windowLength);

% Align CT and DO data
rsk(end) = RSKalignchannel(rsk,'channel','Temperature',...
    'lag',process.alignCT.lag,'lagunits',process.alignCT.lagunits);
rsk(end) = RSKalignchannel(rsk,'channel','Dissolved Oxygen',...
    'lag',process.alignDO.lag,'lagunits',process.alignDO.lagunits); 

% Derive Variables
rsk(end) = RSKderivesalinity(rsk(end)); 

% Split up/down casts
rsk(end) = RSKtimeseries2profiles(rsk(end));

% Loop average (remove loop the in profile)
rsk(end) = RSKremoveloops(rsk(end)); %Default threshold value is 0.25m/s

% Bin average
rsk(end) = RSKbinaverage(rsk(end)); % by default it creates 1m bins

%Write processed data!
RSK2ODV(rsk(end)); % ODV is a good format to use
RSK2CSV(rsk(end)); % Could be useful to
RSKplotprofiles(rsk(end)); % Let's show the resulting plots

