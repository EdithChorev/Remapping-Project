function [TuningCurve,SER]=CalcTuning(Var,SpikesPerFrame,grid)
TuningCurve=[];SER=[];
for ind=1:length(grid)-1
    relFrames=find(Var>=grid(ind) & Var<=grid(ind+1));
    if length(relFrames)>=80
        TuningCurve=[TuningCurve,mean(SpikesPerFrame(relFrames)/0.04)];
         SER=[SER,std(SpikesPerFrame(relFrames)/0.04)/sqrt(length(relFrames))];
    else
        TuningCurve=[TuningCurve,nan];
         SER=[SER,nan];
    end
end
