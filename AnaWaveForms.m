function AnaWaveForms(Waveforms,id)

microVolt = 1e-6;
millisecond = 1e-3;
SamplingRate = 32000;

WF1=squeeze(Waveforms(:,1,:))'; WF2=squeeze(Waveforms(:,2,:))'; WF3=squeeze(Waveforms(:,3,:))'; WF4=squeeze(Waveforms(:,4,:))';

aveWF= squeeze(nanmean(Waveforms, 1));
[PeakVal,PeakT]=max(aveWF');
[TroughVal,TroughT]=min(aveWF');
[val,ThisWF]=(max(PeakVal));
PeakToTroughTime=(TroughT(ThisWF)-PeakT(ThisWF))/SamplingRate;

if ThisWF==1
    HalfWidth=length(find(WF1>PeakVal(1)/2))/SamplingRate;
elseif ThisWF==2
    HalfWidth=length(find(WF2>PeakVal(2)/2))/SamplingRate;
elseif ThisWF==3
    HalfWidth=length(find(WF3>PeakVal(3)/2))/SamplingRate;
elseif ThisWF==4
    HalfWidth=length(find(WF4>PeakVal(4)/2))/SamplingRate;
end
 smysql(['UPDATE STC SET PeakToTroughTime = ' num2str(max(PeakToTroughTime)) ' WHERE STC_id = ' num2str(id)]);
  smysql(['UPDATE STC SET HalfWidth = ' num2str(HalfWidth) ' WHERE STC_id = ' num2str(id)]);
