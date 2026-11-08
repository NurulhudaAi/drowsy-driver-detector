function T = tformMatrix(type, a, b)
% TFORMMATRIX  3x3 homogeneous matrices that map input (x,y) -> output (x,y).
%   'translate' (tx=a, ty=b)   'scale' (sx=a, sy=b)
%   'rotate'    (angle=a, degrees, counter-clockwise on screen)
%   'shear'     (shx=a, shy=b)
switch lower(type)
    case 'translate', T = [1 0 a; 0 1 b; 0 0 1];
    case 'scale',     T = [a 0 0; 0 b 0; 0 0 1];
    case 'rotate',    th = deg2rad(a);   % image y axis points down -> this is CCW
                      T = [cos(th) sin(th) 0; -sin(th) cos(th) 0; 0 0 1];
    case 'shear',     T = [1 a 0; b 1 0; 0 0 1];
    otherwise, error('Unknown transform type: %s', type);
end
end
