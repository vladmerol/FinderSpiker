% Input
%   Rclustens: Cells x Frames
%   SimMethod: 'hamming', etc'
%   DistThreshold: Maximum Threshold (at least half of neurons)
% Ouput
%   NonSimilarVectors:  Frames with Vectos non similar
%   MaxDistanceIV: Maximum Distance Intra Vectors
function [NonSimilarIV,MaxDistanceIV]=nonsimilarframes(Rclustens,SimMethod,DistThreshold)
% Distribution of distance between vectors
intraensembledist=pdist(Rclustens',SimMethod);
MaxDistanceIV=max(intraensembledist);
% Nsamp=round(numel(intraensembledist)/5);
% ksdensity(intraensembledist,linspace(0,1,Nsamp))
[NonSimilarIV,~]=find(squareform(intraensembledist)>DistThreshold);
