function [res,folder] = buildErrorCurveGA(data,dataset_name,zone,numMaxInds,errorMeasure,varargin)
%% buildErrorCurveGA
% build the error curve for a single electric load time series, and a given
% population size
%
% Input parameters
%%%%%%%%
% 'data': dataset including the data required to calculate the fitness
% function (temperatures, trend, hour,load...) (See the folder 'demo' for
% an example data structure)
% The required input variables will depend on the fitness function to use
% in this case, the Vanilla model will be used. It was first proposed in:
%
% T. Hong, Short term electric load forecasting, Ph.D. thesis, North Carolina
% State University (2010).
%%%%%%%%
% 'dataset_name': Name of the problem (string)
%                (e.g. my_dataset, GEFCom2012, GEFCom2014)
%%%%%%%%
% 'zone': Zone to analyze (integer number)
%         (e.g. 1, 2...)
%%%%%%%%
% numMaxInds: specify the maximum number of individuals of the execution.
%             If the maximum number of different individuals is lower than
%             numMaxInds, that value will be taken as population size
%%%%%%%%%%%%%%%%%
% Optional params
%%%%%%%%%%%%%%%%%
% 'replication' (integer number)
% if you want to perform more than one replication for the same value
% of numMaxInds, specify an integer number in the optional parameters
% of this function, in order to specify the path to save the results and do
% not overwrite previous results
%
% Example:
%  1) buildErrorCurveGA(data,'my_dataset_name',1,500)
%     The results of this execution of the GA will be saved in:
%     temp/GA_my_dataset_name_500
%  2) buildErrorCurveGA(data,'my_dataset_name',1,500,1)
%     The results of this execution of the GA will be saved in:
%     temp/GA_my_dataset_name_500_1

%% verify number of input arguments
minArgs=5;
maxArgs=6;
narginchk(minArgs,maxArgs)

% specific replication
if nargin == 6
    replication = varargin{1};
end

%% zone
% select the zone to analyze
data.XTR.y = data.YTR{:,zone};
data.XTS.y = data.YTS{:,zone};

Kmax = size(data.tempsTR,2);

%% parameters, output files and output folder
% maximum number of stall generations 
maxStallGenerations = 50;
% experiment name
experiment = ['GA_',upper(dataset_name),'_',num2str(numMaxInds),'inds'];

% create a folder to save experiment results
if nargin <6
    % only one replication
    folder = fullfile(pwd,'temp',experiment);
else
    % specified number of replication
    folder = fullfile(pwd,'temp',[experiment,'_rep',num2str(replication)]);
end
if ~exist(folder,'dir')
    mkdir(folder);
end
% name for the result files of the GA
zoneName = ['Z',num2str(zone)];
nameFile = fullfile(folder,zoneName);

%% GA Fitness function
% Here, the Vanilla load forecasting model is used
%
% If you want to use a different fitness function, edit the following line
% and indicate the function to use
funGA = @(x)  fitnessVanillaGA(data.XTR,data.tempsTR,nameFile,errorMeasure,x);

%% run the GA for each value of K
% initialize output table
res = table();
% for each number of variables
for k = 1:Kmax
    disp('----------------------------------------------------');
    % max number of combinations:
    % combinations of Kmax variables taking k at a time
    numMaxCombs = factorial(Kmax)/(factorial(k)*factorial(Kmax-k));
    numInds = min(numMaxCombs,numMaxInds);
    
    iniPopulation = initializePopulation(numInds,Kmax,k);
    
    % limit the number of Stall Generations if all the possible individuals
    % are in the first generation
    if numMaxCombs == size(iniPopulation,1)
        ms = 1;
    else
        ms = maxStallGenerations;
    end
    % update execution parameters
    options = optimoptions('ga','Display','final',...
        'PopulationSize',numInds,'InitialPopulationMatrix',iniPopulation,...
        'CrossoverFcn',@crossoverfeasiblebinarysum,...
        'MutationFcn',@mutationbinaryflipbit,...
        'MaxStallGenerations',ms);
    t0 = tic;
    X = ga(funGA,Kmax,[],[],[],[],zeros(1,Kmax),ones(1,Kmax),[],[],options);
    t1 = toc(t0);
    res.vars(k) = {logical(X)};
    res.time(k) = t1;
    % save the results
    save(fullfile(folder,[zoneName,'_GA_Curve_',errorMeasure,'.mat']),'res');
    disp([zoneName,': Vars for K = ', num2str(k), ' selected. Elapsed time: ',num2str(t1)]);
end
