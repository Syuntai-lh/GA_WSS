function data = prepareDataGEFCom2012()
%% Prepare data from GEFCom2012 [1] load forecasting competition
%
% [1] T. Hong, P. Pinson, S. Fan, Global Energy Forecasting Competition 2012,
% International Journal of Forecasting 30 (2) (2014) 357{363. doi:10.1016/
% j.ijforecast.2013.07.001.

% parameters
data_path = fullfile(pwd,'data');

% last point: the 6th hour of 2008/6/30 (HH 5)
temps = readtable(fullfile(data_path,'GEFCom2012','temperature_history.csv'));
temps.date  = datetime(temps.year,temps.month,temps.day);
temps = stack(temps,5:28);
temps.Properties.VariableNames{6} = 'hour';
temps.Properties.VariableNames{7} = 'value';
hours = 1:24;
hours_str = cellstr(strcat('h',num2str(hours')));
hours_str = regexprep(hours_str,' ','');
hours = cellstr(num2str(hours'));
hours = regexprep(hours,' ','');
temps.hour = str2double(regexprep(cellstr(temps.hour),hours_str,hours));
temps.date.Hour =temps.hour-1;

temps(:,{'year','day','month','hour'}) = [];
temps = temps(:,[2,1,3]);
temps = unstack(temps,'value','station_id');
temps.Properties.VariableNames = regexprep(temps.Properties.VariableNames,'x','w');

% load
format = ['%C%d%d%d',repmat('%f',1,24)];
loads = readtable(fullfile(data_path,'GEFCom2012','Load_history.csv'),'Delimiter',';','format',format);
loads.date = datetime(loads.year,loads.month,loads.day);
loads = stack(loads,5:28);
loads.Properties.VariableNames{6} = 'hour';
loads.Properties.VariableNames{7} = 'value';
hours = 1:24;
hours_str = cellstr(strcat('h',num2str(hours')));
hours_str = regexprep(hours_str,' ','');
hours = cellstr(num2str(hours'));
hours = regexprep(hours,' ','');
loads.hour = str2double(regexprep(cellstr(loads.hour),hours_str,hours));
loads.date.Hour =loads.hour-1;

loads(:,{'year','day','month','hour'}) = [];
loads = loads(:,[2,1,3]);
loads = unstack(loads,'value','zone_id');
loads.Properties.VariableNames = regexprep(loads.Properties.VariableNames,'x','y');

% create the zone 21 (aggregated)
loads.y21 = sum(loads{:,2:end},2);
% delete date var (the same that in temps table)
loads.date = [];
% sort loads by zone
zoneIdx     = cellfun(@str2num,regexprep(loads.Properties.VariableNames,'y',''));
[~,zoneIdx] = sort(zoneIdx);
loads = loads(:,zoneIdx);
% Remove NaNs: from 39415 onwards
loads(39415:end,:) = [];
temps(39415:end,:) = [];

% initialize data struct to run the GA
data = struct();

%% separate TR and TS sets
% TR/TV: 2004, 2005 & 2006
% TS: 2007
idTR = temps.date.Year==2004|temps.date.Year==2005|temps.date.Year==2006;
idTS = temps.date.Year==2007;

% prepare data for Vanilla
trend = transpose(1:size(temps,1));

X       = table();
X.wday  = categorical(weekday(temps.date));
X.month = categorical(temps.date.Month);
X.trend = trend;

X.hour  = categorical(temps.date.Hour);
temps   = temps{:,2:end};
Y = loads;

% TR
data.XTR = X(idTR,:);
data.YTR = Y(idTR,:);
data.tempsTR = temps(idTR,:);
% TS
data.XTS = X(idTS,:);
data.YTS = Y(idTS,:);
data.tempsTS = temps(idTS,:);

% Uncomment to load the rest of data provided in GEFCom2012
% (Holidays & Benchmark results)
%
% % holidays
% holidays = readtable(fullfile(data_path,'GEFCom2012','Holiday_list.csv'),'Delimiter',';','ReadVariableNames',true);
% holidays = stack(holidays,2:6);
% holidays.Properties.VariableNames(2:3) = {'year','holiday'};
% holidays.year = str2double(regexprep(cellstr(holidays.year),'x',''));
% % dates
% parts = cellfun(@strsplit,holidays.holiday,repmat({','},numel(holidays.holiday),1),'uniformOutput',false);
% psize = cellfun(@numel,parts);
% % delete empty days
% parts(psize<2) = [];
% holidays(psize<2,:) = [];
% wday  = cellfun(@(s) s(1),parts);
% day   = cellfun(@(s) s(2),parts);
% date  = strcat(num2str(holidays.year),',',day);
% date  = datetime(date,'Format','yyyy, MMMM dd');
%
% holidays      = table();
% holidays.date = temps.date;
% holidays.fes  = false(size(temps.date));
% for i=1:numel(date)
%     idx = holidays.date.Year == date.Year(i)...
%         & holidays.date.Month == date.Month(i)...
%         & holidays.date.Day == date.Day(i);
%     holidays.fes(idx) = true;
% end
% toc
% % load benchmark
% format = ['%d%C%d%d%d',repmat('%f',1,24)];
% benchmark = readtable(fullfile(data_path,'GEFCom2012','Benchmark.csv'),'Delimiter',';','format',format);
% benchmark.id = [];
% benchmark.date  = datetime(benchmark.year,benchmark.month,benchmark.day);
% benchmark = stack(benchmark,5:28);
% benchmark.Properties.VariableNames{6} = 'hour';
% benchmark.Properties.VariableNames{7} = 'value';
% hours = 1:24;
% hours_str = cellstr(strcat('h',num2str(hours')));
% hours_str = regexprep(hours_str,' ','');
% hours = cellstr(num2str(hours'));
% hours = regexprep(hours,' ','');
% benchmark.hour = str2double(regexprep(cellstr(benchmark.hour),hours_str,hours));
% benchmark.date.Hour =benchmark.hour-1;
%
% benchmark(:,{'year','day','month','hour'}) = [];
% benchmark = benchmark(:,[2,1,3]);
% benchmark = unstack(benchmark,'value','zone_id');
%
