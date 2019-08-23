function xoverKids  = crossoverfeasiblebinarysum(parents,~,GenomeLength,~,~,thisPopulation)
%% Crossover function of the GA
% uncomment to plot results during execution:
% cla;
% pcolor(thisPopulation);
% shading flat;
% drawnow;
% parameters
randomSeed = 'mlfg6331_64';
% How many children to produce?
nKids = length(parents)/2;
% Allocate space for the kids
xoverKids = zeros(nKids,GenomeLength);
% To move through the parents twice as fast as the kids are
% being produced, a separate index for the parents is needed
index = 1;
% Number of activations of each parent (the same for all them)
nActs = sum(thisPopulation(1,:));
% fix the random seed
s = RandStream(randomSeed);
% for each kid...
for i=1:nKids
    % get parents
    r1 = parents(index);
    index = index + 1;
    r2 = parents(index);
    index = index + 1;
    p1 = find(thisPopulation(r1,:));
    p2 = find(thisPopulation(r2,:));
    % Mix both parents
    mix = sort([p1,p2])';
    % Calculate probability of each element
    [rep,unique_mix]=hist(mix,unique(mix));
    probs = rep./sum(rep);
    % select nActs elements randomly from the mixture of the parents
    idxKid = datasample(s,unique_mix,nActs,'Weights',probs,'Replace',false);
    xoverKids(i,idxKid) = 1;
end
