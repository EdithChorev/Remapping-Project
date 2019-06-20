function [t,VarAve,Y]=CalcSpikeTrigAve2(SpikePerFrame,FrameTimes,Vars)
% SpikeTs=SpikeTs*100*1e-6;
% SpikeTs=sort(SpikeTs);
[FrameTimes,IX]=sort(FrameTimes);
SpikePerFrame=SpikePerFrame(IX);
Vars=Vars(IX);
VarAve=[];Y=[];
dt=diff(FrameTimes);
idx=find(dt>0.06);
idx=[idx',length(FrameTimes)];
st=0;
x=[-0.04*5:0.04:0.04*5];xq=[-0.04*5:0.02:0.04*5];
for j=1:length(idx)
    relFs=(st+1:idx(j));
    for ind=6:length(relFs)-5
        tmp=Vars(relFs(ind-5):relFs(ind+5));
        Y=[Y, SpikePerFrame(relFs(ind))];
        tmp=interp1(x,tmp,xq,'spline');
        VarAve=[VarAve;tmp(11-6:11+6)];
    end
   
     st=idx(j);
end
t=[-6:6]*0.02;