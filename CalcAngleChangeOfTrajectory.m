function dthetas=CalcAngleChangeOfTrajectory(x,y)
%close all
dx=diff(x);
dy=diff(y);
dthetas=[];
for ind=1:length(x)-2
%     clf;
%     subplot(2,1,1)
%     plot(x(ind:ind+2),y(ind:ind+2),'k');hold on;
%     plot(x(ind),y(ind),'.r');
%     subplot(2,1,2)
    v1=[dx(ind),dy(ind)];
    lgv1=sqrt(dx(ind)^2+dy(ind)^2);
    v2=[dx(ind+1),dy(ind+1)];
    lgv2=sqrt(dx(ind+1)^2+dy(ind+1)^2);
%     plot([0,v1(1)]/lgv1,[0,v1(2)]/lgv1,'b'); hold on
%     plot([0,v2(1)]/lgv2,[0,v2(2)]/lgv2,'r');
%     xlim([-1 1])
%     ylim([-1 1])
%     axis 'square'
    theta=atan2(det([v1',v2']),dot(v1',v2'));
    theta=theta*180/pi;
    %     v1=v1(1)+i*v1(2);
    %     v2=v2(1)+i*v2(2);
    %     tet1=angle(v1);
    %     tet2=angle(v2);
    %     theta3=tet2-tet1;
    %     theta3=theta3*180/pi
    % v1 = [x(ind+1),y(ind+1)] - [x(ind),y(ind)];v1=v1';
    % v2 = [x(ind+2),y(ind+2)] - [x(ind+1),y(ind+1)];v2=v2';
    
    %     theta2=sign(theta2);
    dthetas=[dthetas,theta];
    
end
