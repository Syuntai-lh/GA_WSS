function mat = matbincombs(nVars)
%% Create the matrix of all possible binary combinations of N variables
% parameters
% initial index (row) to fill the matrix
idx_ini = 1;
% number of rows
nRows = 2^nVars;
mat = false(nRows,nVars);
for i = 1:nVars
    % column to fill in this iteration
    col = nVars-i+1;
    % size of each 0/1 block
    blockSize = 2^i;
    % number of zeros/ones for each block
    nOnes = blockSize/2;
    for idx = idx_ini : blockSize : nRows
        for j = 1:nOnes
            % fill the binary matrix
            mat(idx+j,col)= true;
        end
    end
    % initial row index for next column (size of the blocks of this
    % column, i.e. 2^i)
    idx_ini = blockSize;
end
