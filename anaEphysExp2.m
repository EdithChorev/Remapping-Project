%%%Trident_Ana
function anaEphysExp2(Exp_id)
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
SpeedOccupencyMap=CalculateOccupencyMap(Theta,Vspeed,ygridMin, ygridMax,griddy,xgridMin, xgridMax,griddx);%%%%%%%%%%%%%
AccOccupencyMap=CalculateOccupencyMap(Theta,Vacc',accygridMin, accygridMax,accgriddy,accxgridMin, accxgridMax,accgriddx);
fig=figure;

subplot(1,3,1)
compass(Vspeed.*cos(Theta),Vspeed.*sin(Theta));
title(['Exp_id ',num2str(Exp_id)]);
subplot(1,3,2)
M=log(SpeedOccupencyMap');
%accoccupency=conv2(accoccupency,ones(2),'same');
pcolor(xgrid(1:end-1),ygrid(1:end-1),M);
shading interp ;set(gcf,'Renderer','painters');
xlim([-20 20]);
ylim([-20 70]);
xlabel('speed cm/s')
ylabel('speed cm/s')
axis('square');
subplot(1,3,3)
M=log(AccOccupencyMap');
pcolor(accxgrid(1:end-1),accygrid(1:end-1),M);
shading interp ;set(gcf,'Renderer','painters');
xlim([-10 10]);
ylim([-25 25]);
xlabel('acc cm/s^2')
ylabel('acc cm/s^2')
axis('square');
suplabel(['EXP_',num2str( Exp_id)] ,'t');
filename=[num2str(Exp_id)];
saveas(fig,filename,'pdf')
saveas(fig,filename,'eps')
savefig(filename)

TheseSTCs=mysql(['SELECT STC_id FROM STC WHERE Exp_id = ' num2str(Exp_id)]);
TheseTrials=mysql(['SELECT Trial_id FROM Trial WHERE Exp_id = ' num2str(Exp_id)]);
for STC_ind=1%1:length(TheseSTCs)
    spikets=mysql(['SELECT Time FROM Spike WHERE STC_id = ' num2str(TheseSTCs(STC_ind)) ' ORDER BY Time']);
    SpikeTs=[];
    for Trial_ind=2:length(TheseTrials)
        [st,en]=mysql(['SELECT Start, End FROM Trial WHERE Trial_id = ' num2str(TheseTrials(Trial_ind))]);
        %en=6.9658e9;
        rel_SpikeTime=spikets(find(spikets*100>st & spikets*100<en));
        
        SpikeTs=[SpikeTs;rel_SpikeTime];
    end
    FramesPerWindow=2;
    SpikePerFrame=CalculateSpikesPerFrame (FramesPerWindow, SpikeTs,AllFramesTs,TrackingInterval);%%%%%%%
    SpikePerFrame2=CalculateSpikesPerFrame (1, SpikeTs,AllFramesTs,TrackingInterval);%%%%%%%
    SpeedSpikeCountMap=CalculateSpikeCountMap (SpikePerFrame,Theta,Vspeed,ygridMin, ygridMax,griddy,xgridMin, xgridMax,griddx);%%%%%%%
    SpeedSpikeCountMap=SpeedSpikeCountMap./TrackingInterval;
    L=(SpeedSpikeCountMap([1:50],:));
    L=L(:);
    R=(SpeedSpikeCountMap([51:100],:));
    R=R(:);
    LdR=nanmean(L)/nanmean(R);
%    mysqlconnectEC('edith','edith','edith')
    if ~isnan(LdR)
        mysql(['UPDATE `STC` SET `Speed L/R`=' num2str(LdR) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    end
    AccSpikeCountMap=CalculateSpikeCountMap (SpikePerFrame,Theta,Vacc',accygridMin, accygridMax,accgriddy,accxgridMin, accxgridMax,accgriddx);%%%%%%%
    AccSpikeCountMap=AccSpikeCountMap./(TrackingInterval);
    L=(AccSpikeCountMap([1:50],:));
    L=L(:);
    R=(AccSpikeCountMap([51:100],:));
    R=R(:);
    LdR=nanmean(L)/nanmean(R);
    if ~isnan(LdR)
        mysql(['UPDATE `STC` SET `Acc L/R` =' num2str(LdR) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    end
    fig=figure;
    title(['Exp_id ' num2str(Exp_id) 'STC_id ' num2str(TheseSTCs(STC_ind))]);
    subplot(4,4,2)
    %SpeedSpikeCountMap(find(SpeedSpikeCountMap==nan))=zeros(1,length(find(SpeedSpikeCountMap==nan)));
    pcolor(xgrid(1:end-1),ygrid(1:end-1),SpeedSpikeCountMap');
    shading interp ;set(gcf,'Renderer','painters');
    xlim([-20 20]);
    ylim([-20 70]);
    subplot(4,4,1)
    plot(nanmean(SpeedSpikeCountMap),ygrid(1:end-1),'k');
    set (gca,'Xdir','reverse')
    ylim([-20 70]);
    subplot(4,4,6)
    plot(xgrid(1:end-1),nanmean(SpeedSpikeCountMap'),'k');
    set (gca,'Ydir','reverse')
    xlim([-20 20]);
    subplot(4,4,4)
    % AccSpikeCountMap(find(M==nan))=zeros(1,length(find(AccSpikeCountMap==nan)));
    pcolor(accxgrid(1:end-1),accygrid(1:end-1),AccSpikeCountMap');
    shading interp ;set(gcf,'Renderer','painters');
    xlim([-10 10]);
    ylim([-25 25]);
    subplot(4,4,3)
    plot(nanmean(AccSpikeCountMap),accygrid(1:end-1),'k');
    set (gca,'Xdir','reverse')
    ylim([-25 25]);
    subplot(4,4,8)
    plot(accxgrid(1:end-1),nanmean(AccSpikeCountMap'),'k');
    set (gca,'Ydir','reverse')
    xlim([-10 10]);
    
    %calculate nondirection speed and acc tunning curves
    speed_grid=[2:5:42];
    acc_grid=[-10:2:10];
    
    [TuningCurve,SER]=CalcTuning(Speed1,SpikePerFrame2,speed_grid);
    
    rel=find(isnan(TuningCurve)==0);
    x=speed_grid(rel);
    y=TuningCurve(rel);
    [fitlable,MD,BS]=fitSpeedTuning(x,smooth(y,3));
    mysql(['UPDATE `STC` SET `SpeedTuningType` =' num2str(fitlable) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    if ~isinf(MD) & ~isnan(MD)
        mysql(['UPDATE `STC` SET `ModulationDepth` =' num2str(MD) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    elseif isinf(MD)
        mysql(['UPDATE `STC` SET `ModulationDepth` =100 WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    end
   if ~isnan(BS)     
        mysql(['UPDATE `STC` SET `BestSpeed` =' num2str(BS) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
   end
    %     fitType=[fitType,fitlable];
    %     fitMD=[fitMD,MD];
    %     BestSpeed=[BestSpeed,BS];
    %     STCs=[STCs,TheseSTCs(STC_ind)];
    subplot(4,4,10)
    plot(smooth(x,3),smooth(y,3),'ok');hold on;
    errorbar(smooth(x,3),smooth(y,3),SER(rel),'.k');
    
    
    [TuningCurve,SER]=CalcTuning(Acceleration1,SpikePerFrame2,acc_grid);
    rel=find(isnan(TuningCurve)==0);
    x=acc_grid(rel);
    y=TuningCurve(rel);
    subplot(4,4,12)
    plot(smooth(x,3),smooth(y,3),'ok');hold on;
    errorbar(smooth(x,3),smooth(y,3),SER(rel),'.k');
    
    %%% spike trig Averages...
    [t,SpeedAve]=CalcSpikeTrigAve(SpikeTs,AllFramesTs,Speed1);
    if length(SpikeTs)<5000
        [M1,M2]=BootStrapSpikeTrig2(SpikeTs,AllFramesTs,Speed1 ,Acceleration1);
    else
        M1=BootStrapSpikeTrig(SpikePerFrame,AllFramesTs,Speed1);
    end
    %[t,SpeedAve,Y]=CalcSpikeTrigAve2(SpikePerFrame,AllFramesTs,Speed1);
    
    subplot(4,4,14)
    for i=1:max(size(SpeedAve))
        SpeedAve(i,:)=SpeedAve(i,:)-mean(SpeedAve(i,5:7));
    end
    
    if length(mean(SpeedAve))==length(t);
        errorbar(t,mean(SpeedAve),std(SpeedAve)/sqrt(max(size(SpeedAve))),'.k');
    end
    %     for i=1:6
    %         COVmat=COVmat+SpeedAve(:,i)'*SpeedAve(:,i);
    %         STA=STA+sum(SpeedAve(:,i));
    %     end
    %     STAw=(1/6*COVmat)^-1*((1/max(size(SpeedAve)))*STA);
    %STAw=13/max(size(SpeedAve))*(SpeedAve'*SpeedAve)^-1*SpeedAve'*ones(1,max(size(SpeedAve)))';
    % STAw=13/sum(Y)*(SpeedAve'*SpeedAve)^-1*SpeedAve'*Y';
    plot(t,M1,'r');hold on;
    % plotyy(t,mean(SpeedAve),t,STAw); hold on;
    plot(t,mean(SpeedAve),'k'); hold on;
    % errorbar(t,mean(SpeedAve),std(SpeedAve)/sqrt(max(size(SpeedAve))),'.k');
    errorbar(t,mean(SpeedAve),std(SpeedAve)/sqrt(max(size(SpeedAve))),'.k');
    xlim([-0.2 0.2]);
    slope=mean(SpeedAve);
    slope= (slope(7)-slope(5))/0.04;
    shuf_slopes=  (M1(:,7)-M1(:,5))/0.04;
    SpkTrigSpeedPercentage=length(find(shuf_slopes<slope))*100/max(size(M1));
    
    [t,AccAve]=CalcSpikeTrigAve(SpikeTs,AllFramesTs,Acceleration1);
    if length(SpikeTs)>=5000
        M2=BootStrapSpikeTrig(SpikePerFrame,AllFramesTs,Acceleration1);
    end
    subplot(4,4,16)
    for i=1:max(size(AccAve))
        AccAve(i,:)=AccAve(i,:)-mean(AccAve(i,5:7));
    end
    
    if length(mean(AccAve))==length(t);
        errorbar(t,mean(AccAve),std(AccAve)/sqrt(max(size(AccAve))),'.k');
    end
    slope=mean(AccAve);
    slope= (slope(7)-slope(5))/0.04;
    shuf_slopes=  (M2(:,7)-M2(:,5))/0.04;
    SpkTrigAccPercentage=length(find(shuf_slopes<slope))*100/max(size(M2));
    %     for i=1:6
    %         COVmat=COVmat+SpeedAve(:,i)'*SpeedAve(:,i);
    %         STA=STA+sum(SpeedAve(:,i));
    %     end
    %     STAw=(1/6*COVmat)^-1*((1/max(size(SpeedAve)))*STA);
    % STAw=13/max(size(AccAve))*(AccAve'*AccAve)^-1*AccAve'*ones(1,max(size(AccAve)))';
    plot(t,M2,'r');hold on;
    % plotyy(t,mean(AccAve),t,STAw); hold on;
    %errorbar(t,mean(AccAve),std(AccAve)/sqrt(max(size(AccAve))),'.k');
    plot(t,mean(AccAve),'k'); hold on;
    errorbar(t,mean(AccAve),std(AccAve)/sqrt(max(size(AccAve))),'.k');
    xlim([-0.2 0.2]);
    suplabel(['STC ', num2str(TheseSTCs(STC_ind))] ,'t');
    filename=[num2str(TheseSTCs(STC_ind)) '_F3'];
    [PercentileSpeed,rauSpeed]=CalcPearsonCorrelation(AllFramesTs,Speed1,SpikePerFrame2,filename);
    filename=[num2str(TheseSTCs(STC_ind)) '_F4'];
    [PercentileAcc,rauAcc]=CalcPearsonCorrelation(AllFramesTs,Acceleration1,SpikePerFrame2,filename);
    %mysqlconnectEC('edith','edith','edith')
    if ~isnan(rauSpeed)
        mysql(['UPDATE `STC` SET `PrecitileSpeedCorr` =' num2str(PercentileSpeed) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
        mysql(['UPDATE `STC` SET `rauSpeed` =' num2str(rauSpeed) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    end
    if ~isnan(rauAcc)
        mysql(['UPDATE `STC` SET `PrecitileAccCorr` =' num2str(PercentileAcc) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
        mysql(['UPDATE `STC` SET `rauAcc` =' num2str(rauAcc) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    end
    mysql(['UPDATE `STC` SET `SpkTrigSpeedPercentage` =' num2str(SpkTrigSpeedPercentage) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    mysql(['UPDATE `STC` SET `SpkTrigAccPercentage` =' num2str(SpkTrigAccPercentage) ' WHERE STC_id= ' num2str(TheseSTCs(STC_ind))]);
    filename=[num2str(TheseSTCs(STC_ind)) '_F1'];
    filename=[num2str(TheseSTCs(STC_ind)) '_F1'];
    saveas(fig,filename,'pdf')
    saveas(fig,filename,'eps')
    savefig(filename)
    
    % calculate turn histograms
    win=2; %time around t in sec
    bin=0.01 % bin size
    
    %     fig=figure;
    %     subplot(4,2,1)
    %     cw=find (All_TurnTags>0);
    %     [x,CWspkHist]=plotRuster(All_TurnsTs(cw),SpikeTs,win,bin);
    %     subplot(4,2,3)
    %     bar(x,smooth(CWspkHist,7),'k');
    %     xlim([-win/2,win/2])
    %     ylim([min(CWspkHist),max(CWspkHist)]);
    %
    %     subplot(4,2,2)
    %     cc=find (All_TurnTags<0);
    %     [x,CCspkHist]=plotRuster(All_TurnsTs(cc),SpikeTs,win,bin);
    %      subplot(4,2,4)
    %     bar(x,smooth(CCspkHist,7),'k');
    %     axis('tight')
    %     xlim([-win/2,win/2])
    %     ylim([min(CCspkHist),max(CCspkHist)]);
    %
    %     subplot(4,2,5)
    %     cw=find (All_TurnTags2>0);
    %     [x,CWspkHist]=plotRuster(All_TurnsTs2(cw),SpikeTs,win,bin);
    %      subplot(4,2,7)
    %     bar(x,smooth(CWspkHist,7),'k');
    %     axis('tight')
    %     xlim([-win/2,win/2])
    %     ylim([min(CWspkHist),max(CWspkHist)]);
    %
    %     subplot(4,2,6)
    %     cc=find (All_TurnTags2<0);
    %     [x,CCspkHist]=plotRuster(All_TurnsTs2(cc),SpikeTs,win,bin);
    %     subplot(4,2,8)
    %     bar(x,smooth(CCspkHist,7),'k');
    %     axis('tight')
    %     xlim([-win/2,win/2])
    %     ylim([min(CCspkHist),max(CCspkHist)]);
    %     suplabel(['STC_', num2str(TheseSTCs(STC_ind))] ,'t');
    %     filename=[num2str(TheseSTCs(STC_ind)) '_F2'];
    %     saveas(fig,filename,'pdf')
    %      saveas(fig,filename,'eps')
    %      savefig(filename)
end
