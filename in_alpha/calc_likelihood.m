function likelihood = calc_likelihood(pars,model,targf,luref,scalar)
% Input descriptions are same as most ROC Toolbox functions.
% Scalar input defines a value to scale the likelihood by so Matlab
% does not round to 0 (recommended 10^200 at minimum).

% Get the predicted data
predData = calc_pred_data(model,pars,sum(targf,2),sum(luref,2),'points');
targp = predData.target.proportions;
lurep = predData.lure.proportions;

% Compute likelihood
targl = targp .^ targf;
lurel = lurep .^ luref;
likelihood = vertcat(scalar,targl(:),lurel(:));
likelihood = prod(likelihood);

end