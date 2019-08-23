function data = prepareDataGEFCom2014()
%% Prepare data from GEFCom2014 [1] load forecasting competition (first track)
%
% [1] J. Xie, T. Hong, GEFCom2014 probabilistic electric load forecasting:
% An integrated solution with forecast combination and residual simu-
% lation, International Journal of Forecasting 32 (3) (2016) 1012{1016.
% doi:10.1016/j.ijforecast.2015.11.005.

% parameters
numStations = 25;
data_path = fullfile(pwd,'data');

% flag to activate dataCleansing
dataCleansing = true; 
% performs the same data cleansing procedure presented in:
%
% J. Xie, T. Hong, GEFCom2014 probabilistic electric load forecasting:
% An integrated solution with forecast combination and residual simu-
% 535 lation, International Journal of Forecasting 32 (3) (2016) 1012{1016.
% doi:10.1016/j.ijforecast.2015.11.005.

% Using Vanilla load forecasting model. First proposed in:
%
% T. Hong, Short term electric load forecasting, Ph.D. thesis, North Carolina
% State University (2010).
% definition:
%
vanillaDefinition = 'y~1+trend+temp^3+month+wday+hour+hour*wday+month*temp^3+hour*temp^3';

% read the data
format = ['%d%s',repmat('%f',1,numStations+1)];
data = readtable(fullfile(data_path,'GEFCom2014','L1-train.csv'),'Format',format);

% remove the column ZONEID (there is only one zone)
data.ZONEID = [];
% convert date to datetime
data.date = transpose(datetime(2001,01,01,01,00,00):1/24:datetime(2010,10,01,00,00,00));
data.TIMESTAMP = [];
data= data(:,[end,1:end-1]);

% remove initial period (without LOAD values (NaN))
% FIRST POINT: 01/01/2005 01:00
data = data(data.date>=datetime(2005,01,01,01,00,00),:);
% stations = upper(data.Properties.VariableNames(3:end));

% Parameters
dataGEFCom14 = data;
trend = transpose(1:size(dataGEFCom14,1));

auxData       = table();
auxData.wday  = categorical(weekday(dataGEFCom14.date));
auxData.month = categorical(dataGEFCom14.date.Month);
auxData.trend = trend;

auxData.hour  = categorical(dataGEFCom14.date.Hour);
auxData.y     = dataGEFCom14.LOAD;
temps         = dataGEFCom14{:,3:end};

%% Data cleansing
% fit the model with all the data
if dataCleansing
    X = auxData;
    X.temp = nanmean(temps,2);
    mdl = fitlm(X,vanillaDefinition);
    % calculate APE
    y_est_tr = predict(mdl,X);
    
    ape = abs(X.y-y_est_tr)./abs(X.y);
    % remove APEs > 0.5
    idx = ape>0.5;
    dataGEFCom14{idx,'LOAD'} = y_est_tr(idx);
    
    % new LOAD
    auxData.y     = dataGEFCom14.LOAD;
end

%% separate TR and TS sets
% indices for dividing in TR and TV. Same indices than those used in:
% J. Xie, T. Hong, GEFCom2014 probabilistic electric load forecasting:
% An integrated solution with forecast combination and residual simu-
% 535 lation, International Journal of Forecasting 32 (3) (2016) 1012{1016.
% doi:10.1016/j.ijforecast.2015.11.005.
idTR = dataGEFCom14.date>=datetime(2007,01,01,00,00,00)&dataGEFCom14.date<datetime(2010,01,01,00,00,00);
idTS = dataGEFCom14.date>=datetime(2010,01,01,00,00,00);

% initialize data struct to run the GA
data = struct();
% TR
data.XTR = auxData(idTR,1:end-1);
data.YTR = auxData(idTR,end);
data.tempsTR = dataGEFCom14{idTR,3:end};
% TS
data.XTS = auxData(idTS,1:end-1);
data.YTS = auxData(idTS,end);
data.tempsTS = dataGEFCom14{idTS,3:end};
