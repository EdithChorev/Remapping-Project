function OccupencyMap=CalculateOccupencyMap(Theta,Var,ygridMin, ygridMax,griddy,xgridMin, xgridMax,griddx)
dx=real(Var.*asin(Theta));
dy=real(Var.*acos(Theta));
xgrid=[xgridMin:griddx:xgridMax];
ygrid=[ygridMin:griddy:ygridMax];
OccupencyMap=zeros(length(xgrid)-1,length(xgrid)-1);
for xind=1:length(xgrid)-1
    for yind=1:length(ygrid)-1
        rel_Frames=find(dx>=xgrid(xind) & dx< xgrid(xind+1) & dy>=ygrid(yind) & dy< ygrid(yind+1));
        OccupencyMap(xind,yind)=length(rel_Frames);
    end
end