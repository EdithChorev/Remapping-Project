function CalculateAverageFiringRate(Force)
mysqlconnect('edith');
% TheseCells = mysql('SELECT id FROM STC')';
if Force
    TheseSessions = mysql('SELECT Session.id FROM Session')';
else % only calculate Sessions with missing data
    TheseSessions = mysql('SELECT Session.id FROM Session,STC where Session.id=Session_id and ISNULL(MeanFiringRate) GROUP BY Session.id')';
end
for ThisSession = TheseSessions
    [TheseTrials, StartTime, StopTime] = mysql(['SELECT id, StartTime, StopTime FROM Trial WHERE Session_id = ' num2str(ThisSession) ' AND id NOT IN ' OneOf(GetBadTrials) ' ORDER BY Number']);
    % load Tracking
    [TrackingTimeStamp] = mysql(['SELECT Time FROM Frame WHERE Trial_id IN ' OneOf(TheseTrials) ' ORDER BY Time ASC']);
    TrackingInterval = median(diff(TrackingTimeStamp));
    % crop away in between trial tracking
    InTrialTracking = any(bsxfun(@gt, TrackingTimeStamp', StartTime) & bsxfun(@lt, TrackingTimeStamp', StopTime), 1);
    % crop crops
    [CropStart, CropStop] = mysql(['SELECT Start, Stop FROM Crop WHERE Trial_id IN ' OneOf(TheseTrials)]);
    CroppedTracking = false(size(TrackingTimeStamp'));
    for ThisCrop = 1:numel(CropStart)
        CroppedTracking(TrackingTimeStamp > CropStart(ThisCrop) & TrackingTimeStamp < CropStop(ThisCrop)) = true;
    end
    if any(CroppedTracking)
%         keyboard
    end
    %
    ThisSessionCells = mysql(['SELECT id FROM STC WHERE Session_id = ' num2str(ThisSession)])';
    for ThisCell = ThisSessionCells
        mysql(['select DATE(Time), Tetrode, Cluster from Session, STC WHERE Session.id = Session_id and STC.id = ' num2str(ThisCell)])
        SpikeTimes = mysql(['SELECT Time FROM Spike WHERE STC_id = ' num2str(ThisCell) ' ORDER BY Time']);
        SpikeTimes = SpikeTimes * 1e-4;
        disp([num2str(numel(SpikeTimes)) ' spikes loaded'])
        % crop away in between trial spikes
        InTrialSpike = any(bsxfun(@gt, SpikeTimes', StartTime) & bsxfun(@lt, SpikeTimes', StopTime), 1);
        % crop crops
        CroppedSpike = false(size(SpikeTimes'));
        for ThisCrop = 1:numel(CropStart)
            CroppedSpike(SpikeTimes > CropStart(ThisCrop) & SpikeTimes < CropStop(ThisCrop)) = true;
        end
        if any(CroppedSpike)
%             keyboard
        end
        AverageRate = sum(InTrialSpike & ~CroppedSpike) / (sum(InTrialTracking & ~CroppedTracking) * TrackingInterval);
        disp(['mean firing rate ' num2str(AverageRate )])
        mysql(['UPDATE STC SET MeanFiringRate=' num2str(AverageRate) ' WHERE id = ' num2str(ThisCell)]);
    end
end
end