function PointCount  = CalculatePointCount(PointX, PointY, Range, GridsInRange, SpikePosition)
if isempty(SpikePosition)
    PointCount = zeros(numel(PointY), numel(PointX));
else
    % construct PointCount out of its x and y component
    XPointCount = pdf('norm', bsxfun(@plus, PointX,- SpikePosition(:,1))/Range, 0, 1);
    YPointCount = pdf('norm', bsxfun(@plus, PointY,- SpikePosition(:,2))/Range, 0, 1);
    PointCount = YPointCount' * XPointCount / GridsInRange^2;
end
end