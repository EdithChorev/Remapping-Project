function  [dtheta,vspeed,vacc]=CalculateAngualMotionPerFrame(X,Y,Angle,TrackingInterval)
% trying 
dtheta=CalcAngleChangeOfTrajectory(X,Y);
dtheta=dtheta'*pi/180;
dtheta=[0;dtheta];
dx=diff(X);dy=diff(Y);
vspeed=abs(sqrt(dx.^2+dy.^2)/(TrackingInterval));

vacc=diff(vspeed);
vacc=[vacc(1),vacc'];


% %%% old and good
% Angle = Angle*pi/180;
% thetas=unwrap(Angle);
% thetas=conv((thetas), [0.05,.2,.5,.2,0.05],'same');
% dtheta=thetas(3:end)-thetas(1:end-2);
% 
% dx=X(3:end)-X(1:end-2);
% dy=Y(3:end)-Y(1:end-2);
% vspeed=abs(sqrt(dx.^2+dy.^2)/(2*TrackingInterval));
% vacc=diff(vspeed);
% vacc=[vacc(1),vacc'];