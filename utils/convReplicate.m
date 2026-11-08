function y = convReplicate(x, k)
% CONVREPLICATE  2-D correlation of every channel with kernel k, using
%   replicated borders so that image edges are not darkened. Output is double
%   and has the same size as x.
x = double(x);
r = floor(size(k)/2);
y = zeros(size(x));
for c = 1:size(x,3)
    P = padarray(x(:,:,c), r, 'replicate');
    y(:,:,c) = conv2(P, rot90(k,2), 'valid');   % rot90 -> correlation
end
end
