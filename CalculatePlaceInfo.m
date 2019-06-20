function Info = CalculatePlaceInfo(Rate, Occupancy, AverageRate, MinimalOccupancy)
if exist('MinimalOccupancy', 'var') && ~isempty(MinimalOccupancy)
	ValidPixels = Occupancy >= MinimalOccupancy;
    RelativeOccupancy = ones(size(Occupancy)) ./ sum(ValidPixels(:));
    RelativeOccupancy(~ValidPixels) = nan;
else
    RelativeOccupancy = Occupancy ./ nansum(Occupancy(:));
end
Info = nansum(nansum(Rate .* log2(Rate ./ AverageRate) .* RelativeOccupancy));
end