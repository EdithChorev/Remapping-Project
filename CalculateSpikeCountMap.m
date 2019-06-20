function SpikeCountMap=CalculateSpikeCountMap (SpikePerFrame,Theta,Var,ygridMin, ygridMax,griddy,xgridMin, xgridMax,griddx)
dx=real(Var.*asin(Theta));
dy=real(Var.*acos(Theta));

xgrid=[xgridMin:griddx:xgridMax];
ygrid=[ygridMin:griddy:ygridMax];
SpikeCountMap=zeros(length(xgrid)-1,length(xgrid)-1);
for xind=1:length(xgrid)-1
    for yind=1:length(ygrid)-1
        rel_Frames=find(dx>=xgrid(xind) & dx< xgrid(xind+1) & dy>=ygrid(yind) & dy< ygrid(yind+1));
        if ~isempty(rel_Frames)
            SpikeCountMap(xind,yind)= sum(SpikePerFrame(rel_Frames))/length(rel_Frames);
        else
            SpikeCountMap(xind,yind)=nan;
        end
    end
end