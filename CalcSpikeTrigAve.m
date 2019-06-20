function [t,VarAve]=CalcSpikeTrigAve(SpikeTs,FrameTs,Var)
SpikeTs=SpikeTs*100*1e-6;
SpikeTs=sort(SpikeTs);
[FrameTs,IX]=sort(FrameTs);
Var=Var(IX);
VarAve=zeros(1,13);
dt=diff(FrameTs);
idx=find(dt>0.06);
idx=[idx',length(FrameTs)];
st=0;
for j=1:length(idx)
    relSpks=find(SpikeTs>=FrameTs(st+1) & SpikeTs<=FrameTs(idx(j)));
    relFramesTs=FrameTs(st+1:idx(j));
    Spikes=SpikeTs(relSpks);
    relVar=Var(st+1:idx(j));
    for ind=1:length(Spikes)
        [tmp,spikeFrame]=min(abs(relFramesTs-Spikes(ind)));
        if (spikeFrame>5 & spikeFrame<=length(relFramesTs)-5)
            xq=[relFramesTs(spikeFrame-5):0.02:relFramesTs(spikeFrame+5)];
            vq=interp1(relFramesTs(spikeFrame-5:spikeFrame+5),relVar(spikeFrame-5:spikeFrame+5),xq);
            [tmp,spikeFrame]=min(abs(xq-SpikeTs(ind)));
            VarAve=[VarAve;vq(11-6:11+6)];
        end
       
    end
     st=idx(j);
end
t=[-6:6]*0.02;