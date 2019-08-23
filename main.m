%% Weather station selection method based on Genetic Algorithms
% ----add citation here----

% launchs the execution of all the zones (loads) of the dataset, using
% a given number of individuals (populationSize)
%
% Before running the code, download the dataset you want to use, or prepare
% your own one (to see the required data structure, see the example file in
% the folder 'data/demo').
%
% If on the contrary you want to use GEFCom2012 or GEFCom2014 datasets,
% this script is already prepared to easilly execute both of them (the data
% preparation functions are provided).
%
% Use the variable dataset_name to specify the data to use
%
% To download GEFCom2012:
%%%%%%%%%%%%%
% 1) Download the data of GEFCom2012 from:
%
% http://blog.drhongtao.com/2016/07/gefcom2012-load-forecasting-data.html
%
% 2) Place the files 'temperature_history.csv' and 'Load_history.csv' in this folder: /data/GEFCom2012
%
% 3) To easilly load this data from MATLAB, you can use the function prepareDataGEFCom2012 (in: \util)
%
%
% To download GEFCom2014:
%%%%%%%%%%%%%%
% 1) Download the data of GEFCom2014 from:
%
% http://blog.drhongtao.com/2017/03/gefcom2014-load-forecasting-data.html
%
% 2) Place the files 'L1-train.csv' from the first task of the Load competition of GEFCom2014 in the folder: \data\GEFCom2014
%
% 3) To easilly load this data from MATLAB, you can use the function prepareDataGEFCom2014 (in: \util)

%#ok<*AGROW>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
% select the dataset to use. Currently, you can use: demo, GEFCom2012 or GEFCom2014
dataset_name = 'demo';
% population size for the GA
numInds = 50;
% number of folds for cross validation (selection of K)
nFolds = 10;
% flag to delete the intermediate results and generated files after
% execution
deleteTempFiles = true;
% error measure to use (select RMSE or MAPE)
errorMeasure = 'MAPE';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load the selected dataset
switch upper(dataset_name)
    case 'GEFCOM2012'
        data = prepareDataGEFCom2012;
    case 'GEFCOM2014'
        data = prepareDataGEFCom2014;
    case 'DEMO'
        load(fullfile(pwd,'data','demo','wss_demo.mat'));
    otherwise
        error('Unknown dataset. Check dataset_name');
end
% number of zones of the dataset (number of electric load variables in
% data.Y)
numZones = size(data.YTR,2);
% number of zones of the weather stations (number of temperatures in
% data.temps)
numStations = size(data.tempsTR,2);

%% WSS method
% initialize output table
wss = table();

% for each zone, generate the GA curve (selected variables for each value
% of K) and select the number of variables
for zone = 1:numZones
    %% 1) launch error curves for all the zones
    [GAcurve,tempFolder] = buildErrorCurveGA(data, dataset_name, zone,numInds,errorMeasure);
    
    %% 2) select the K (number of weather stations to use) with cross
    % validation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mat_error = zeros(nFolds,numStations);
    % function to execute Cross Validation
    fcn = @(X,XTS) fitnessVanillaCV(X,XTS,errorMeasure);
    % cross validation
    for k=1:numStations
        X = data.XTR;
        X.y = data.YTR{:,zone};
        c = cvpartition(X.y,'KFold',nFolds);
        GAvars_k = GAcurve.vars{k};
        X.temp = nanmean(data.tempsTR(:,GAvars_k),2);
        vec_error  = crossval(fcn,X,'partition',c);
        mat_error(:,k) = vec_error;
    end
    % one-standard-error rule (1SE)
    % point of minimum error
    vec_error = nanmean(mat_error,1);
    [bestError,bestK] = nanmin(vec_error);
    % std
    c = cvpartition(data.YTR{:,zone},'KFold',nFolds);
    n1 = c.TrainSize(1);
    n2 = c.TestSize(1);
    vec_std = sqrt((1/nFolds+ n2/n1)).*nanstd(mat_error,1);
    maxerror = bestError + vec_std(bestK);
    K = find(vec_error<=maxerror+eps);
    K = K(1);
    % save the results of this zone
    aux = table();
    aux.ZONE = zone;
    aux.K = K;
    aux.SelectedVars = GAcurve.vars{K};
    wss = [wss;aux];
end
% show the results
disp(['Selected variables for each zone of ',dataset_name,':'])
disp(wss);

% delete temporary files generated during execution
if deleteTempFiles
    if exist(tempFolder,'dir')
        status = rmdir(tempFolder,'s');
        if ~status
            disp('Error deleting temporary files');
        end
    end
end
