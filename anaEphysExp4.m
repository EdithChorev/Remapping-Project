%%%Trident_Ana
function anaEphysExp4(Exp_id, TheseSTCs,BS)
close all
  mysqlconnectEC('edith','edith','edith')
global MySQLInFile
TrackingInterval=0.04;
%  STCs=[];fitType=[];fitMD=[];BestSpeed=[];
[Speed,Acceleration,Speed1,Acceleration1,Theta,All_Xs,All_Ys,Vspeed,Vacc,All_TurnsTs,All_TurnTags,All_TurnsTs2,All_TurnTags2,AllFramesTs]=getAllDataForTridentAna(Exp_id);
%define grids
ygridMin=-100; ygridMax=100;griddx=2; griddy=2;
xgridMin=-100; xgridMax=100;
accxgridMax=50;accxgridMin=-50;
accygridMax=50;accygridMin=-50;accgriddx=1;accgriddy=1;
xgrid=[xgridMin:griddx:xgridMax];
ygrid=[ygridMin:griddy:ygridMax];
accxgrid=[-1*accxgridMax:accgriddx:accxgridMax];
accygrid=[-1*accygridMax:accgriddy:accygridMax];

%%% analyze occupency of angular properties
% SpeedOccupencyMap=CalculateOccupencyMap(Theta,Vspeed,ygridMin, ygridMax,griddy,xgridMin, xgridMax,griddx);%%%%%%%%%%%%%
% AccOccupencyMap=CalculateOccupencyMap(Theta,Vacc',accygridMin, accygridMax,accgriddy,accxgridMin, accxgridMax,accgriddx);
% fig=figure;
% 
% subplot(1,3,1)
% compass(Vspeed.*cos(Theta),Vspeed.*sin(Theta));
% title(['Exp_id ',num2str(Exp_id)]);
% subplot(1,3,2)
% M=log(SpeedOccupencyMap');
% %accoccupency=conv2(accoccupency,ones(2),'same');
% pcolor(xgrid(1:end-1),ygrid(1:end-1),M);
% shading interp ;set(gcf,'Renderer','painters');
% xlim([-20 20]);
% ylim([-20 70]);
% xlabel('speed cm/s')
% ylabel('speed cm/s')
% axis('square');
% subplot(1,3,3)
% M=log(AccOccupencyMap');
% pcolor(accxgrid(1:end-1),accygrid(1:end-1),M);
% shading interp ;set(gcf,'Renderer','painters');
% xlim([-10 10]);
% ylim([-25 25]);
% xlabel('acc cm/s^2')
% ylabel('acc cm/s^2')
% axis('square');
% suplabel(['EXP_',num2str( Exp_id)] ,'t');
% filename=[num2str(Exp_id)];
% saveas(fig,filename,'pdf')
% saveas(fig,filename,'eps')
% savefig(filename)

% TheseSTCs=mysql(['SELECT STC_id FROM STC WHERE Exp_id = ' num2str(Exp_id)]);
TheseTrials=mysql(['SELECT Trial_id FROM Trial WHERE Exp_id = ' num2str(Exp_id)]);
for STC_ind=1:length(TheseSTCs)
    spikets=mysql(['SELECT Time FROM Spike WHERE STC_id = ' num2str(TheseSTCs(STC_ind)) ' ORDER BY Time']);
    SpikeTs=[];
    for Trial_ind=1:length(TheseTrials)
        [st,en]=mysql(['SELECT Start, End FROM Trial WHERE Trial_id = ' num2str(TheseTrials(Trial_ind))]);
        %en=6.9658e9;
        rel_SpikeTime=spikets(find(spikets*100>st & spikets*100<en));
        
        SpikeTs=[SpikeTs;rel_SpikeTime];
    end
    FramesPerWindow=2;
    SpikePerFrame=CalculateSpikesPerFrame (FramesPerWindow, SpikeTs,AllFramesTs,TrackingInterval);%%%%%%%
    SpikePerFrame2=CalculateSpikesPerFrame (1, SpikeTs,AllFramesTs,TrackingInterval);%%%%%%%
     speed_grid=[2:5:42];
    acc_grid=[-10:2:10];
    [TuningCurve,SER]=CalcTuning(Speed1,SpikePerFrame2,speed_grid);
    
        rel=find(isnan(TuningCurve)==0);
        x=speed_grid(rel);
        y=TuningCurve(rel);
        [fitlable,MD,BS]=fitSpeedTuning(x,smooth(y,3));
    
    
    filename=[num2str(TheseSTCs(STC_ind)) ' F3'];
    [PercentileSpeed,rauSpeed]=CalcPearsonCorrelation(AllFramesTs,Speed1,SpikePerFrame2,filename);
    %[PercentileSpeed,rauSpeed]=mysql(['SELECT `PrecitileSpeedCorr`,`rauSpeed` FROM STC WHERE STC_id='  num2str(TheseSTCs(STC_ind))]);
    if PercentileSpeed>95 | PercentileSpeed<5

        if rauSpeed<0
            fitlable=2;
        else
            fitlable=1;
        end
    end
    [PercentileSpeed2,rauSpeed2,type]=CalcPearsonCorrelation2(AllFramesTs,Speed1,SpikePerFrame2,BS,filename);
    if PercentileSpeed2<5 & PercentileSpeed<5
        if PercentileSpeed2<PercentileSpeed
            PercentileSpeed=PePercentileSpeed2;
            rauSpeed=rauSpeed2;
            type=3;
        else
            type=2;
        end
    elseif PercentileSpeed2>95 & PercentileSpeed>95
        if PercentileSpeed2>PercentileSpeed
            PercentileSpeed=PercentileSpeed2;
            rauSpeed=rauSpeed2;
            type=3
        else
            type=1;
        end
    elseif PercentileSpeed2>95 & PercentileSpeed<95
        PercentileSpeed=PercentileSpeed2;
        rauSpeed=rauSpeed2;
        type=3;
    elseif PercentileSpeed2<5 & PercentileSpeed>5
        PercentileSpeed=PercentileSpeed2;
        rauSpeed=rauSpeed2;
        type=3;
    elseif PercentileSpeed>95 & PercentileSpeed2<95
%         PercentileSpeed=PePercentileSpeed2;
%         rauSpeed=rawSpeed2;
        type=1;
    elseif PercentileSpeed<5 & PercentileSpeed2>5
%         PercentileSpeed=PePercentileSpeed2;
%         rauSpeed=rawSpeed2;
        type=2;
    end
        
        
        
    
        mysql(['UPDATE `STC` SET `SpeedTuningType` =' num2str(type) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    
      mysql(['UPDATE `STC` SET `rauSpeed` =' num2str(rauSpeed2) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
      mysql(['UPDATE `STC` SET `PrecitileSpeedCorr` =' num2str(PercentileSpeed2) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
      mysql('close')
end
