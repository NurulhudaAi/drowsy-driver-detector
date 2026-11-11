function [pred, pClosed] = knnPredict(model, X)
% KNNPREDICT  Classify eyes with a model from knnTrain.
%   Euclidean distance to every training eye -> the k closest vote.
%   pClosed = share of the k neighbours that are closed eyes (0..1)
%   pred    = true (closed) if pClosed >= 0.5
Z = (X - model.mu) ./ model.sd;
T = model.X;
D = sum(Z.^2, 2) + sum(T.^2, 2)' - 2 * (Z * T');   % squared distances
k = min(model.k, size(T, 1));
[~, idx] = mink(D, k, 2);
votes = reshape(model.y(idx), size(idx));
pClosed = mean(votes, 2);
pred = pClosed >= 0.5;
end
