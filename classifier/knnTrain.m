function model = knnTrain(X, y, k)
% KNNTRAIN  k-nearest-neighbour classifier, written from scratch.
%   X = n x d feature matrix (one row per eye), y = n x 1 labels (1 = closed, 0 = open)
%   k = number of neighbours (odd). "Training" a KNN just stores the examples;
%   every feature is standardized (mean 0, std 1) so no feature dominates.
if nargin < 3 || isempty(k), k = 5; end
mu = mean(X, 1);
sd = std(X, 0, 1);
sd(sd < 1e-8) = 1;
model = struct('X', (X - mu) ./ sd, 'y', double(y(:)), 'mu', mu, 'sd', sd, 'k', k);
end
