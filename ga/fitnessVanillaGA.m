function fitnessError = fitnessVanillaGA(X,temps,nameFile,errorMeasure,x)
%% Fitness function for the GA, using the Vanilla model
%#ok<*NASGU>
% parameters
% Using Vanilla load forecasting model. First proposed in:
%
% T. Hong, Short term electric load forecasting, Ph.D. thesis, North Carolina
% State University (2010).
% definition:
%
vanillaDefinition = 'y~1+trend+temp^3+month+wday+hour+hour*wday+month*temp^3+hour*temp^3';

% Load table of previous results (to avoid calculating the fitness of
% already tested candidates)
resFile = [nameFile,'_K',num2str(sum(x)),'_',errorMeasure,'.mat'];
if exist(resFile,'file')
    load(resFile,'tRes');
else
    tRes = table();
end
% individual encoding
idx = 0;
ID = bin2dec(sprintf('%d',x));
% Check if the fitness of this individual has been already calculated
if ~isempty(tRes)
    idx = ID==tRes.ID;
end

if sum(idx) == 0
    % New individual: calculate the fitness
    taux = table();
    taux.ID = ID;
    activation = logical(x);
    if sum(activation) == 0
        % error
        fitnessError = Inf;
    else
        % average candidate variables & calculate fitness
        X.temp = nanmean(temps(:,activation),2);
        m = fitlm(X,vanillaDefinition);
        y_est = predict(m,X);
        switch upper(errorMeasure)
            case 'MAPE'
                res   = abs(X.y-y_est)./abs(X.y);
                fitnessError = 100*nanmean(res);
            case 'RMSE'
                res   = X.y-y_est;
                fitnessError  = sqrt(nanmean(res.^2));
            otherwise
                error('Unrecognized error measurement. Please, choose RMSE or MAPE');
        end   
    end
    taux.(errorMeasure) = fitnessError;
    % add the new element and save the new table
    tRes = [tRes;taux];
    save(resFile,'tRes','-v6');
else
    % This individual has been already calculated
    fitnessError = tRes{idx,errorMeasure};
end
end
