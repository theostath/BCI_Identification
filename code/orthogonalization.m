function [y_orth]=orthogonalization(x,y)

% Finds orthogonalized signal y to x. Calculates linear predictor y(t) = a
% + b*x(t).
% So, y_orth(t) = y(t) - b*x(t).

% transpose matrices
x_trans = x' ;
y_trans = y' ;

b = [ones(length(x_trans),1) x_trans] \ y_trans ;  % x = A\B solves the system of linear equations A*x = B

y_pred = x_trans * b(2) ;  % kanonika o Fraschini exei ston kwdika tou b(2) alla einai mhdenikh h grammh afth

y_orth = y_trans - y_pred ;

y_orth = y_orth' ;
end