function SpikePerFrame=CalculateSpikesPerFrame (FramesPerWindow, SpikeTs,FramesTs,TrackingInterval)
% calculates trajectory per 'FramesPerWindow': speed and angle
SpikePerFrame=[];
for Frame_ind=1: length(FramesTs)
    rel_SpikeTs=find(SpikeTs*1e-4>=FramesTs(Frame_ind)-(FramesPerWindow*TrackingInterval/2) & SpikeTs*1e-4<=FramesTs(Frame_ind)+(FramesPerWindow*TrackingInterval/2));
    SpikePerFrame=[SpikePerFrame,length(rel_SpikeTs)];
    
end