function Occupancy = CalculateOccupancy(PointX, PointY, X, Y, Range, TrackingInterval, GridsInRange)
XOccupancy = pdf('norm', bsxfun(@plus,PointX,-X)/Range, 0, 1);
YOccupancy = pdf('norm', bsxfun(@plus,PointY,-Y)/Range, 0, 1);
Occupancy =YOccupancy'* XOccupancy * TrackingInterval / GridsInRange^2;
