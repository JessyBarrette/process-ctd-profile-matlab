function rsk = RSKreadTOB(inFile)

% rsk = RSKreadTOB(inFile)
% RSKreadTOB is a simple tool that import a instrumentation data from
% Sea and Sun Technology instrumentation standard TOB format to the RSKtool
% data structure. 
%
% Jessy Barrette
% December 18th, 2020

%% Read Header
fid = fopen(inFile);
c = textscan(fid,'%s','delimiter','\n');
fclose(fid);

% Retrieve variable names
isDataHeaderLines = ~cellfun('isempty',regexp(c{1},'^;[\s.]*'));
LastHeaderLine = find(isDataHeaderLines,1,'last');
variableLines = c{1}(isDataHeaderLines);

short_name = strtrim(regexp(char(variableLines(2)),'[^;][\w]+','match'));
long_name = short_name;
long_name(strcmp(short_name,'Temp'))={'Temperature'};
long_name(strcmp(short_name,'Press'))={'sea pressure'};
long_name(strcmp(short_name,'rCond'))={'Conductivity'};
long_name(strcmp(short_name,'Oxygn'))={'Dissolved Oxygen'};
long_name(strcmp(short_name,'Turb'))={'Turbidity'};
long_name(strcmp(short_name,'SALIN'))={'Salinity'};
long_name(strcmp(short_name,'SOUND'))={'Sound Speed'};

units = [{''},regexprep(regexp(char(variableLines(3)),'\[[^\[\]]+\]','match'),'\[|\]|\s*|\_','')];

% Drop Date/Time related variables
variables_to_keep = find(cellfun('isempty',...
    regexp(lower(short_name),'time|date|intd|intt')));

% Add Channel Related information
for ii = 1:length(variables_to_keep)
    rsk.channels(ii).shortName = short_name{variables_to_keep(ii)};
    rsk.channels(ii).longName = long_name{variables_to_keep(ii)};
    rsk.channels(ii).units = units{variables_to_keep(ii)};
end

%% Read data table
% Get data by using readtable
data = readtable(inFile,'delimiter',' ','HeaderLines',LastHeaderLine,...
    'ReadVariableNames',0,'FileType','text','MultipleDelimsAsOne',1);

% Get date and time data and convert to datenum
data(:,4) = regexprep(data{:,4},'È.Ù','AM'); %We will presume that È.Ù
rsk.data.tstamp = datenum(char(char(strcat(data{:,2},{' '},data{:,3},' ',data{:,4}))),'dd/mm/yyyy HH:MM:SS PM');

% Get Data 
dataColumns = 1:width(data);
dataColumns = dataColumns(~ismember(dataColumns,[2,3,4])); % Remove date, time and AM/PM columns 
values = str2double(data{:,dataColumns});
if size(values,2)==length(rsk.channels)
    rsk.data.values = values;
else
    error('Can''t match the values with the right column variables!')
end

% Add Calibration
% This will have a different format than RBR's for now. Can change it if it
% becomes an issue
calibFields = {'ID','Serial','SensorID','Code','short_name','units'};
isCalibrationLines = ~cellfun('isempty', regexp(c{1},'^001.*'));
if any(isCalibrationLines)
    calibrationLines = c{1}(isCalibrationLines);
    
    for jj=1:length(calibrationLines)
       calib{jj} =  regexp(calibrationLines{jj},'[^ ]*','match');
    end
    calibCell = reshape([calib{:}],[length(calib{1}(1,:)),length(calib)]);
    coefCols = strcat('Coef',compose('%02d',1:(length(calibCell)-length(calibFields))));
    
    rsk.calibration=cell2struct(calibCell,[calibFields,coefCols]);
end

% Add Instrument related information

% N Records
nRecLine = c{1}(~cellfun('isempty',regexp(c{1},'^Lines \:\w*\n*')));
if length(nRecLine)==1
    rsk.n_records = str2double(regexp(nRecLine{1},'\d*','match'));
else 
    warning('Failed to retrieve Record Number')
end

%% Fix time issue
% The timestamp values are missing the millisecond data
% We'll assume that every time the seconds change it's a new second and
% interpolate in between
newTimeStamp = [0;diff(rsk.data.tstamp)>0];
rsk.data.tstamp = interp1(rsk.data.values(find(newTimeStamp),1),...
    rsk.data.tstamp(find(newTimeStamp)),rsk.data.values(:,1),...
    'linear','extrap');
%% Time Setup
samplingPeriod = median(diff(rsk.data.tstamp)).*3600*24;
rsk.schedules.mode = 'continuous';
rsk.continuous.samplingPeriod = samplingPeriod;

%% Put back atmospheric pressure component to pressure data since RSKTool expect that
newChan.values = rsk.data.values(:,getchannelindex(rsk,'sea pressure'))+10.1325;
rsk = RSKaddchannel(rsk,newChan,'Pressure','dBar'); 

%% Extra info
rsk.dbInfo.version = 'TOBFile';
rsk.deployments.firmwareVersion = char(regexp(char(c{1}(1)),'rev [\d\.\w\t ]*','match'));
rsk.instruments.model = char(strcat(unique({rsk.calibration.Serial})));
rsk.instruments.serialID = char(strcat(unique({rsk.calibration.Serial})));

rsk.epochs.startTime = rsk.data.tstamp(1);
rsk.epochs.endTime = rsk.data.tstamp(end);

rsk.toolSettings.filename = inFile;
%% Add a log
rsk.log = {now,'Sea and Sun Technology Instrument data imported to RSKTool by RSKreadTOB'};

