function [hf1,hf2] = plotProfiles(rsk,x_vars, description,color,timeseries_yaxis)

%% Default values 
if nargin<5
    timeseries_yaxis = 'sea pressure';
end

% Tool use to plot multiple profiles with the RSKTool structure format. 

%% Vertical Profiles
hf1 = figure;
for rsk_id = 1:length(rsk)
    [hl{rsk_id},axl{rsk_id}] = RSKplotprofiles(rsk{rsk_id},'channel',x_vars);
end

% Put Raw lines in red
for rsk_id =1:length(hl)
    for profile_id=1:length(hl{rsk_id}(:))
        hl{rsk_id}(profile_id).Color=color{rsk_id};
        
        % Special case for final description
        if strcmp(description{rsk_id},'final')
            hl{rsk_id}(profile_id).LineStyle='none';
            hl{rsk_id}(profile_id).Marker='o';
            
            [row,col]=ind2sub(size(hl{rsk_id}),profile_id);
            direction = rsk{rsk_id}.data(row).direction;
            if strcmp(direction,'up')
                hl{rsk_id}(profile_id).MarkerFaceColor = 'g';
            elseif strcmp(direction,'down')
                hl{rsk_id}(profile_id).MarkerFaceColor = 'k';
            end
        end
    end
end

%linkaxes([axlr,axlf],'y')
legendLabels = {};
for rsk_id = 1:length(rsk)
    for profile_id=1:length(rsk{rsk_id}.data)
        legendLabels{end+1} = [description{rsk_id},': ',rsk{rsk_id}.data(profile_id).direction];
    end
end
            
            
%Add Legend
h_legend = legend(legendLabels,'Orientation','horizontal');
h_legend.Position = [.5 .03 .04 .02];

%% Retrieve Line Format from profile to reuse it on the timeseries
hl_format = [];
for profile_id=1:length(hl)
    hl_format = [hl_format; hl{profile_id}(:,1)];
end

%% Profile Time Series
hf2 = figure;
y_var = 'depth';
hf_t = {};
for profile_id=1:length(rsk)
    RSKplotdata(rsk{profile_id},'channel',y_var,'direction','down');   
    hold on
    RSKplotdata(rsk{profile_id},'channel',y_var,'direction','up');    
end
set(gca,'ydir','reverse');
hlt1 = flip(findobj(gca,'Type','line'));

line_properties = {'Color','LineStyle','Marker','MarkerFaceColor'};
for line_id=1:length(hlt1)
    for kk = 1:length(line_properties)
        hlt1(line_id).(line_properties{kk}) = hl_format(line_id).(line_properties{kk}) ;
    end
end
%Add Legend
h_legend = legend(legendLabels,'Orientation','horizontal');
h_legend.Position = [.5 .03 .04 .02];

%% Format figure size
set(hf1,'Position',[ 20,70,1500,800])
set(hf2,'Position',[ 20,70,1500,800])

