function [speed,acceleration] = CalculateMotionPerFrame(FramesPerWindow,X,Y,TrackingInterval)%%%%%%%%%
% This function recieves the tracking data and calculates speed,
% acceleration, and angle per frame/s 

speed=sqrt((X(FramesPerWindow+1:length(X))-X(1:length(X)-FramesPerWindow)).^2+(Y(FramesPerWindow+1:length(Y))-Y(1:length(Y)-FramesPerWindow)).^2);
speed=[ones(1,FramesPerWindow)*speed(1),speed']/(FramesPerWindow*TrackingInterval);
acceleration= diff(speed);
acceleration= [acceleration(1),acceleration];



