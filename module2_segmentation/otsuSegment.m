function [out, t] = otsuSegment(img)
% OTSUSEGMENT  Otsu's automatic threshold (maximizes between-class variance).
%   out is a uint8 mask (255 = pixels brighter than t), t is the threshold.
g = toGray(img);
p = histcounts(g(:), 0:256);  p = p / sum(p);
omega = cumsum(p);                         % class probability
mu    = cumsum(p .* (0:255));              % cumulative mean
muT   = mu(end);
sigmaB = (muT*omega - mu).^2 ./ (omega .* (1 - omega));
sigmaB(~isfinite(sigmaB)) = 0;
best = max(sigmaB);
idx  = find(sigmaB >= best - 1e-12);        % if the maximum is a plateau take its middle
t = round(mean(idx)) - 1;
out = uint8(g > t) * 255;
end
