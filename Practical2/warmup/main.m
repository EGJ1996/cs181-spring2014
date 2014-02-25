%
% CSCI-E181, Spring 2014, Practical 2, Warmup
% 
% Usage:
%     Start Octave or Matlab
%     octave> main
%


% read in data
input = csvread('motorcycle.csv' );
X = input(:,1);
Y = input(:,2);
m = length(Y); % number of training examples

%
% Part 1 - Calculate and plot via gradient descent
%

fprintf('Press enter to calculate and plot gradient descent.\n');
pause;

% compute via gradient descent
X_bias = [ones(m, 1), input(:,1)]; % Add a column of ones to x
theta = zeros(2, 1); % initialize fitting parameters

% Some gradient descent settings
iterations = 1500;
alpha = 0.001;

% run gradient descent
theta = gradientDescent(X_bias, Y, theta, alpha, iterations);

fprintf('Final gradient descent cost is %f\n', computeCost(X_bias, Y, X_bias*theta));
hold on;
plotRegression(X,Y,X_bias*theta,'Linear Basis')

%
% Part 2 - Calculate and plot via polyfit
%
fprintf('Press enter to calculate polynomial basis.\n');
pause;


% find the best polynomial fit, up to 12
% clearly overfitting, bien sur
bestp = 1;
bestJ = Inf;
for i = 2:12
  p = polyfit(X,Y,i);
  f = polyval(p,X);
  J = computeCost(X,Y,f);
  if J < bestJ
     bestJ = J;
     bestp = i;
  endif

end

fprintf('Final polynomial cost is %f\n', bestJ);
plotRegression(X,Y,f,'Polynomial Basis')

%
% Part 3 - closed form
%
fprintf('Press enter to use Gaussian.\n');
pause;


theta = pinv(X_bias'*X_bias)*X_bias'*Y;

J = computeCost(X,Y,X_bias*theta);
fprintf('Cost via Gaussian%f\n',J);

plotRegression(X,Y,X_bias*theta,'Gaussian / Moore Penrose');

%
% Part 4 - 
% Modified from "Machine Learning, a Probablistic Perspective"
% by Kevin Murphy. Original code can be found at 
% https://github.com/probml/pmtk3
%
fprintf('Press enter to use Gaussian noise.\n');
pause;

trainingPoints = length(Y);

a0 = -0.3; %Parameters of the actual underlying model that we wish to recover
a1 = 0.5;  %We will estimate these values with w0 and w1 respectively. 

noiseSD = 0.2;

priorPrecision = 2.0;

likelihoodSD = noiseSD;
likelihoodPrecision = 1/(likelihoodSD)^2;

xtrain = X;
ytrain = Y;

model = struct('mu', 0, 'Sigma', noiseSD);
noise = gaussSample(model, trainingPoints);

iter = 30;

priorMean = [0;0];
priorSigma = eye(2)./priorPrecision; %Covariance Matrix
priorPDF = @(W)gaussProb(W,priorMean',priorSigma);

mu = priorMean;
sigma = priorSigma;

for i=1:iter
  likelihood = @(W) uniGaussPdf(xtrain(i),W*[1;xtrain(i)],likelihoodSD.^2);

  [postW,mu,sigma] = update([1,xtrain(i)],ytrain(i),likelihoodPrecision,mu,sigma);

end

%J = computeCost(X,Y,X_bias*theta);
%fprintf('Cost via closed form %f\n',J);

%plotRegression(X,Y,X_bias*theta,'Closed form');
