function [x0,LB,UB] = msd_gen_pars(nBins,nConds,parNames)
% Usage: 
%   x0 = msd_gen_pars(nBins,nConds,parNames)
%	[x0,LB,UB] = msd_gen_pars(nBins,nConds,parNames)
%
% MSD_GEN_PARS creates default starting and bouding paramters for the MSD
% model. The output is three vectors. One contains the starting values of 
% the parameters (x0), one contains the lower bounds of the parameters 
% (LB), and the last contains the upper bounds of the parameters (UB). The 
% LB and UB variables are used with roc_solver to constrain the 
% starting parameters (x0).
%
% Format of Output:
%   The output of this function is a MxN row vector. The length of the
%   vector depends on the number of confidence bins used in the experiment.
%   The vector) output from this function correspond to:
%       [lambda_targ Dprime1_targ var1_targ Dprime2_targ var2_targ ...
%        lambda_lure Dprime1_lure var1_lure Dprime2_lure var2_lure ...
%        criterion]
%
%   Note that the first criterion value in the vector is always -1.5. The
%   remaining values in the vector are the interval between successive
%   criterion points, as this is needed for parameter estimation reasons
%   (i.e., monotonically increasing criterion placements). Hence, the LB
%   for the successive values is 0 rather than -Inf.
%
% Required Input:
%   nBins - This is the number of confidence bins in the scale used in
%   the experiment. This input creates a total of n-1 criterion points 
%   ranging between -1.5 and 1.5 using the following formula:
%       criterion_x0=[-1.5 ones(1,nBins-2)*(3/(nBins-2))];
%       criterion_LB=[-Inf zeros(1,nBins-2)];
%       criterion_UB=[Inf Inf inf(1,nBins-2)];
%
%   nConds - This corresponds to the number of experimental conditions
%   in the data that will be simultaneously fitted. For example, if there
%   is only one group of target items and one group of lure items, then
%   nConds should equal 1, If there are two classes of target and lure
%   items
%
%   parNames - This is a cell array of strings identifying the parameters 
%   to be estimated. To specify the parameters, enter the appropriate 
%   strings listed below into a cell array vector:
%
%   TARGET DISTRIBUTION PARAMETERS:
%
%   'lambda_targ' - This specifies the mixing parameter for target items in
%   the MSD model. If given,x0 is set to .8, LB is set to 0, and UB is set 
%   to 1. If this input is not given, x0, LB, and UB are set to 1 (i.e., 
%   the parameter is not estimated).
%
%   'Dprime1_targ' - This specifies the memory strength (d') parameter for  
%   the target item distribution scaled by lambda_targ. If given, x0 is 
%   1.5, LB is set to 0, and UB is set to Inf. If this input is not given, 
%   x0, LB, and UB are all set to 0. Note that Dprime1_targ is the increase
%   in strength relative to Dprime2_targ. This is for estimation purposes 
%   to constrain Dprime1_targ >= Dprime2_targ. However, do note that the 
%   data output by the ROC_SOLVER reflects Dprime1_targ + Dprime2_targ. 
%
%   'var1_targ' - This specifies the variance of the distribution for 
%   Dprime1_targ. If given, x0 is set to 1, LB is set to 0, and UB is set 
%   to Inf. If not given, then x0, LB, and UB are all set to 1.
%
%   'Dprime2_targ' - This specifies the memory strength (d') parameter of 
%   the target item distribution scaled by 1-lambda_targ. If given, x0 is 
%   1, LB is set to -Inf and UB is set to Inf. If this is not specified, 
%   x0, LB, and UB are all set to 0. 
%
%   'var2_targ' - This specifies the variance of the distribution for 
%   Dprime2_targ. If given, x0 is set to 1, LB is set to 0, and UB is set 
%   to Inf. If not given, then x0, LB, and UB are all set to 1.
%
%   LURE DISTRIBUTION PARAMETERS:
%
%   'lambda_lure' - This specifies the mixing parameter for lure items in
%   the MSD model. If given, x0 is set to .8, LB is set to 0, and UB is set 
%   to 1. If this input is not given, x0, LB, and UB are set to 1 (i.e., 
%   the parameter is not estimated).
%
%   'Dprime1_lure' - This specifies the memory strength (d') parameter for  
%   the lure item distribution scaled by lambda_lure. If given, x0 is 
%   1.5, LB is set to 0, and UB is set to Inf. If this input is not given, 
%   x0, LB, and UB are all set to 0. Note that Dprime1_lure is the increase
%   in strength relative to Dprime2_lure. This is for estimation purposes 
%   to constrain Dprime1_lure >= Dprime2_lure. However, do note that the 
%   data output by the ROC_SOLVER reflects Dprime1_lure + Dprime2_lure. 
%
%   'var1_lure' - This specifies the variance of the distribution for 
%   Dprime1_lure. If given, x0 is set to 1, LB is set to 0, and UB is set 
%   to Inf. If not given, then x0, LB, and UB are all set to 1.
%
%   'Dprime2_lure' - This specifies the memory strength (d') parameter of 
%   the lure item distribution scaled by 1-lambda_lure. If given, x0 is 
%   1, LB is set to -Inf and UB is set to Inf. If this is not specified, 
%   x0, LB, and UB are all set to 0. 
%
%   'var2_lure' - This specifies the variance of the distribution for 
%   Dprime2_lure. If given, x0 is set to 1, LB is set to 0, and UB is set 
%   to Inf. If not given, then x0, LB, and UB are all set to 1.
%
%   Example: If you wanted to estimate lambda_targ, Dprime1_targ, and
%   Dprime2_targ, then you would use the following code:
%       parNames={'lambda_targ' 'Dprime1_targ' 'Dprime2_targ};
%       [x0,LB,UB]=msd_gen_pars(nbins,nconds,parNames)
%
% Authored by: Joshua D. Koen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The ROC Toolbox is the proprietary property of The Regents of the       
% University of California (“The Regents.”)                                
%
% Copyright © 2014 The Regents of the University of California, Davis
% campus. All Rights Reserved.   
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted by nonprofit, research institutions for
% research use only, provided that the following conditions are met:  
%
% •	Redistributions of source code must retain the above copyright 
% notice, this list of conditions and the following disclaimer.  
%
% •	Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.   
%
% •	The name of The Regents may not be used to endorse or promote 
% products derived from this software without specific prior written
% permission.   
%
% The end-user understands that the program was developed for research
% purposes and is advised not to rely exclusively on the program for any
% reason.  
%
% THE SOFTWARE PROVIDED IS ON AN "AS IS" BASIS, AND THE REGENTS HAVE NO
% OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
% MODIFICATIONS. THE REGENTS SPECIFICALLY DISCLAIM ANY EXPRESS OR IMPLIED
% WARRANTIES, INCLUDING BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE REGENTS BE LIABLE TO ANY PARTY FOR DIRECT,
% INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES,
% INCLUDING BUT NOT LIMITED TO  PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES, LOSS OF USE, DATA OR PROFITS, OR BUSINESS INTERRUPTION, 
% HOWEVER CAUSED AND UNDER ANY THEORY OF LIABILITY WHETHER IN CONTRACT,
% STRICT LIABILITY OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             
%
% If you do not agree to these terms, do not download or use the software.
% This license may be modified only in a writing signed by authorized
% signatory of both parties.  
%
% For commercial license information please contact
% copyright@ucdavis.edu. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TARGET DISTRIBUTION PARAMETERS
% Set values for the lambda_targ
if ismember('lambda_targ',parNames)
    lambda_targ=.8;
    llambda_targ=0;
    ulambda_targ=1;
else
    lambda_targ=1;
    llambda_targ=1;
    ulambda_targ=1;
end

% Set values for the Dprime1_targ parameter
if ismember('Dprime1_targ',parNames)
    Dprime1_targ=1.5;
    lDprime1_targ=0;
    uDprime1_targ=Inf;
else
    Dprime1_targ=0;
    lDprime1_targ=0;
    uDprime1_targ=0;
end

% Set values for the var1_targ paramter
if ismember('var1_targ',parNames)
    var1_targ=1;
    lvar1_targ=0;
    uvar1_targ=Inf;
else
    var1_targ=1;
    lvar1_targ=1;
    uvar1_targ=1;
end

% Set values for the Dprime2_targ parameter
if ismember('Dprime2_targ',parNames)
    Dprime2_targ=1;
    lDprime2_targ=-Inf;
    uDprime2_targ=Inf;
else
    Dprime2_targ=0;
    lDprime2_targ=0;
    uDprime2_targ=0;
end

% Set values for the var2_targ paramter
if ismember('var2_targ',parNames)
    var2_targ=1;
    lvar2_targ=0;
    uvar2_targ=Inf;
else
    var2_targ=1;
    lvar2_targ=1;
    uvar2_targ=1;
end

% LURE DISTRIBUTION PARAMETERS
% Set values for the lambda_lure
if ismember('lambda_lure',parNames)
    lambda_lure=.8;
    llambda_lure=0;
    ulambda_lure=1;
else
    lambda_lure=1;
    llambda_lure=1;
    ulambda_lure=1;
end

% Set values for the Dprime1_lure parameter
if ismember('Dprime1_lure',parNames)
    Dprime1_lure=1.5;
    lDprime1_lure=0;
    uDprime1_lure=Inf;
else
    Dprime1_lure=0;
    lDprime1_lure=0;
    uDprime1_lure=0;
end

% Set values for the var1_lure paramter
if ismember('var1_lure',parNames)
    var1_lure=1;
    lvar1_lure=0;
    uvar1_lure=Inf;
else
    var1_lure=1;
    lvar1_lure=1;
    uvar1_lure=1;
end

% Calculate criterion parameters
criterion=[-1.5 ones(1,nBins-2)*(3/(nBins-2))];
lcriterion=[-Inf zeros(1,nBins-2)];
ucriterion=[Inf inf(1,nBins-2)];

% Preallocate variables
x0=zeros(nConds,8+length(criterion));
LB=zeros(nConds,8+length(criterion));
UB=zeros(nConds,8+length(criterion));

% Create output vectors
for a=1:nConds
    x0(a,:)=[lambda_targ Dprime1_targ var1_targ Dprime2_targ var2_targ ...
        lambda_lure Dprime1_lure var1_lure criterion];
    LB(a,:)=[llambda_targ lDprime1_targ lvar1_targ lDprime2_targ lvar2_targ ...
             llambda_lure lDprime1_lure lvar1_lure lcriterion];
    UB(a,:)=[ulambda_targ uDprime1_targ uvar1_targ uDprime2_targ uvar2_targ ...
             ulambda_lure uDprime1_lure uvar1_lure ucriterion];
end

end
