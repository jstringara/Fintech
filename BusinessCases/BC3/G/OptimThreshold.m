function [bestEpsilon bestrec_prec] = OptimThreshold(ycval, p)
% Find the best threshold (epsilon) to use for selecting anomalies
% ycval = responses Y=1 if anomaly, 0 otherwise
% p = density;

bestEpsilon = 0;
bestrec_prec = 0;
rec_= 0;
prec_= 0;
stepsize = (max(p) - min(p)) / 1000;

for epsilon = min(p):stepsize:max(p)

    predictions = p < epsilon;
    tp = sum((predictions == 1) & (ycval == 1));
    fp = sum((predictions == 1) & (ycval == 0));
    fn = sum((predictions == 0) & (ycval == 1));
    tn = sum((predictions == 0) & (ycval == 0));
    prec = tp / (tp + fp);
    rec = tp / (tp + fn);
    acc = (tp + tn) /(tp + tn + fn + fp);
    F1 = 2 * prec * rec / (prec + rec);
%   rec_prec = (89/90)*acc + (1/90)*rec;
%   rec_prec = (tp + tn) /(tp + tn + fn + fp);
%   rec_prec = rec - fp/(tn+fp);
    rec_prec = (2/3)*rec + (1/3)*prec;

    if rec_prec> bestrec_prec
        prec_= prec;
        rec_ = rec;
        bestrec_prec = rec_prec;
        bestEpsilon = epsilon;
    end
end
    disp([prec_,rec_])
end


