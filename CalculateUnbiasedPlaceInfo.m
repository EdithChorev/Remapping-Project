function [PlaceInfo, p_Value] = CalculateUnbiasedPlaceInfo(GridX, GridY, GridsInRange, TrackingInterval, X, Y, TrackingTimeStamp, SpikeTime, MinimalOccupancy, NumShuffles)
    if ~exist('NumShuffles', 'var')
        NumShuffles = 100;
    end

if isempty(SpikeTime)
    PlaceInfo = 0;
else
    %%
    %%
    Range = GridsInRange * diff(GridX(1:2));
    Occupancy = CalculateOccupancy(GridX, GridY, X, Y, Range, TrackingInterval, GridsInRange);
    Occupancy(Occupancy < MinimalOccupancy) = nan;
    NumberOfFrames = numel(X);
    PlaceInfo = nan(1, NumShuffles);
%     par
    for ThisShuffle = 1:NumShuffles
        if ThisShuffle > 1
            FrameShift = floor(rand * NumberOfFrames);
            NewOrder = [FrameShift + 1 : NumberOfFrames, 1 : FrameShift];
            ShuffledX = X(NewOrder); %#ok<*PFBNS>
            ShuffledY = Y(NewOrder);
        else
            ShuffledX = X;
            ShuffledY = Y;
        end
        SpikePosition = interp1q(TrackingTimeStamp, [ShuffledX ShuffledY], SpikeTime);
        % drop invalid spikepositions (from out-of-tracking-time spike
        % times)
        SpikePosition(any(isnan(SpikePosition), 2), :) = [];
        PointCount  = CalculatePointCount(GridX, GridY, Range, GridsInRange, SpikePosition);
        PointRate = PointCount ./ Occupancy;
        AverageRate = sum(PointCount(:)) / nansum(Occupancy(:));
        PlaceInfo(ThisShuffle) = CalculatePlaceInfo(PointRate, Occupancy, AverageRate);%, MinimalOccupancy);
        if 1%abs(PlaceInfo(ThisShuffle)) > 10
%             figure('Position', [100, 300, 1000, 400])
            subplot(1,2,1)
            plot(ShuffledX,ShuffledY)
            hold on
            plot(SpikePosition(:, 1), SpikePosition(:, 2), 'xr')
            axis image ij
            subplot(1,2,2)
            PaintPlaceField(PointRate,[],GridX,GridY)
            text(GridX(1), GridY(1), num2str(max(PointRate(:))))
            title(PlaceInfo(ThisShuffle))
            pause 
        end
    end
    %     figure
    %     hist(PlaceInfo)
    %     hold on
    %     bar(PlaceInfo(1),1, 'red')
    p_Value = (sum(PlaceInfo(1) <= PlaceInfo(2:end)) + 1) / numel(isfinite(PlaceInfo));
    PlaceInfo = PlaceInfo(1) - mean(PlaceInfo(2:end));
end
end