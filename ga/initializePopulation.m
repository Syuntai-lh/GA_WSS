function population = initializePopulation(numInds,numVars,maxActs)
%% Create the initial population
% Create matrix of indices: all possible binary condition vectors
mat = matbincombs(numVars);
numActs = sum(mat,2);

% Select candidates with the required number of activated variables (K)
candidates = mat(numActs == maxActs,:);
clear mat;

% Create popolation with the required number of individuals
if numInds<size(candidates,1)
    acts = datasample(1:size(candidates,1),numInds,'Replace',false);
elseif numInds == size(candidates,1)
    acts = 1:size(candidates,1);
else
    acts = 1:size(candidates,1);
    rest = numInds-size(candidates,1);
    acts = [acts,datasample(1:size(candidates,1),rest,'Replace',true)];
end

population = double(candidates(acts,:));
end
