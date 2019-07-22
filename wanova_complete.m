%  Function File: [p, F, df1, df2] = wanova (y, g)
%
%  Perform a Welch's alternative to one-way analysis of variance
%  (ANOVA). The goal is to test whether the population means of data
%  taken from k different groups are all equal. This test does not
%  require the condition of homogeneity of variances be satisfied.
%  For post-tests, it is recommended to run the function 'multicmp'.
%
%  Data should be given in a single vector y with groups specified by
%  a corresponding vector of group labels g (e.g., numbers from 1 to
%  k). This is the general form which does not impose any restriction
%  on the number of data in each group or the group labels.
%
%  Under the null of constant means, the Welch's test statistic F
%  follows an F distribution with df1 and df2 degrees of freedom.
%
%  The p-value (1 minus the CDF of this distribution at F) is
%  returned in the p output variable.
%
%  Bibliography:
%  [1] Welch (1951) On the Comparison of Several Mean Values: An
%       Alternative Approach. Biometrika. 38(3/4):330-336
%  [2] Tomarken and Serlin (1986) Comparison of ANOVA alternatives
%       under variance heterogeneity and specific noncentrality
%       structures. Psychological Bulletin. 99(1):90-99.
%
%  The syntax in this function code is compatible with most recent
%  versions of Octave and Matlab.
%
%  wanova v1.0 (last updated: 19/08/2013)
%  Author: Andrew Charles Penn
%  https://www.researchgate.net/profile/Andrew_Penn/

function [p, F, df1, df2] = wanova (y, g1,g2)

  if nargin<2 || nargin>3
    error('Invalid number of input arguments');
  end

  if nargout>4
    error('Invalid number of output arguments');
  end

  if size(y,1)~=numel(y)
    error('The first input argument must be a vector');
  end

  if size(g,1)~=numel(g)
    error('The second input argument must be a vector');
  end

  if nargin==2
      g2=ones(size(y));
  end
  
  % Determine the number of groups
  k1 = max(g1);
  k2 = max(g2);

  % Obtain the size, mean and variance for each sample
  n1 = zeros(k1,1);
  n2 = zeros(k2,1);
  mu1 = zeros(k1,1);
  mu2 = zeros(k2,1);
  v1 = zeros(k1,1);
  v2 = zeros(k2,1);
  for i=1:k1
    n1(i,1) = numel(y(g1==i));
    mu1(i,1) = mean(y(g1==i));
    v1(i,1) = var(y(g1==i));
  end
  for i=1:k2
    n2(i,1) = numel(y(g2==i));
    mu2(i,1) = mean(y(g2==i));
    v2(i,1) = var(y(g2==i));
  end

  % Obtain the standard errors of the mean (SEM) for each sample
  se1 = v1./n1;
  se2 = v2./n2;

  % Take the reciprocal of the SEM
  w1 = 1./se1;
  w2 = 1./se2;

  % Calculate the grand mean: its a weighted mean of samples with weights
  % as the standard errors: 
  grandmean = sum([w1;w2].*[mu1;mu2])./sum([w1;w2]);

  % Calculate Welch's test F ratio
  % for factor one, two and interaction(group 1 and 2+interaction seperately): 
  MSm1=sum(w1.*((mu1-grandmean).^2))/(k1-1);
  MSm2=sum(w2.*((mu2-grandmean).^2))/(k2-1);
  
  F = (k-1)^-1*sum(w.*(mu-grandmean).^2)/...
      (1+((2*(k-2)/(k^2-1))*sum((1-w/sum(w)).^2.*(n-1).^-1)));

  % Calculate the degrees of freedom
  df1 = k-1;
  df2 = (3/(k^2-1)*sum((1-w/sum(w)).^2.*(n-1).^-1))^-1;

  % Calculate the p-value
  p = 1-fcdf(F,df1,df2);

end
