function mutationChildren = mutationbinaryflipbit(parents,~,GenomeLength, ...
    ~,state,~,thisPopulation,varargin)
%% Crossover function of the GA
persistent StepSize

% parameters
% random seed
randomSeed = 'mlfg6331_64';

if state.Generation <=2
    StepSize = 1; % Initialization
else
    if isfield(state,'Spread')
        if state.Spread(end) > state.Spread(end-1)
            StepSize = min(1,StepSize*4);
        else
            StepSize = max(sqrt(eps),StepSize/4);
        end
    else
        if state.Best(end) < state.Best(end-1)
            StepSize = min(1,StepSize*4);
        else
            StepSize = max(sqrt(eps),StepSize/4);
        end
    end
end
% Extract information about constraints
% Initialize childrens
mutationChildren = zeros(length(parents),GenomeLength);
% fix the random seed
s = RandStream(randomSeed);

% Create childrens for each parent
for i=1:length(parents)
    x = thisPopulation(parents(i),:);
    % change a 1 by a 0
    ones_idx  = find(x == 1);
    zeros_idx = find(x == 0);
    if ~isempty(ones_idx)&&~isempty(zeros_idx)
        % select the 0/1 to change
        one_pos   = datasample(s,ones_idx,1);
        zero_pos  = datasample(s,zeros_idx,1);
        
        % Change the value of that bits
        x(one_pos)  = 0;
        x(zero_pos) = 1;
    end
    mutationChildren(i,:) = x;
end
