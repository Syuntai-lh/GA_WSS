function err = fitnessVanillaCV(X,XTS,errorMeasure)
%% Function to fit and evaluate Vanilla using crossval
%
% parameters
% Using Vanilla load forecasting model. First proposed in:
%
% T. Hong, Short term electric load forecasting, Ph.D. thesis, North Carolina
% State University (2010).
% definition:
%
vanillaDefinition = 'y~1+trend+temp^3+month+wday+hour+hour*wday+month*temp^3+hour*temp^3';
m     = fitlm(X,vanillaDefinition);
y_est = predict(m,XTS);
switch upper(errorMeasure)
    case 'MAPE'
        res   = abs(XTS.y-y_est)./abs(XTS.y);
        err = 100*nanmean(res);
    case 'RMSE'
        res   = XTS.y-y_est;
        err  = sqrt(nanmean(res.^2));
    otherwise
        error('Unrecognized error measurement. Please, choose RMSE or MAPE');
end
