
function alignNtrodeandVideo(fname,vidname)
%Updated from Amanda's alignNtrodeandVideo_c 10/2016

% fname='160722-02.mat';
% vidname = '160722_vid-1.mat';
fname2 = vidname;

load(fname)
load(fname2)

pathname = cd;

df = 1000/vidFrameRate;
a=1;
b=1;
%Find threshold value in IR LED signal to use for getting trial start
%frames
%IRLedStartFrames = getIRStartTimes(IRledSignal(1,:),samplingRate);
maxAlignmentError = 100;
check3 = 'y';

%
while maxAlignmentError > 35 && isequal(check3,'y')
    %     [IRLedStartFrames,LedSig] = getIRStartFrames(IRledSignal(1,:),df);
    
    %right now this method works well for me, check the function get
    %IRStartFrames
    a=1;
    for i = 2:size(IRledSignal,2) - 1
        if (IRledSignal(1,i) < IRthresh) && (IRledSignal(1,i+1) > IRthresh) %Use a threshold crossing rather than derivative; more accurate
            if a > 2
                if abs(x(a-1) - i) > (1000/df)
                    x(a) = i;
                    a=a+1;
                end
            else
                x(a) = i;
                a=a+1;
            end
            
        end
    end
    IRLedStartFrames = x;
    IRLedStartTimes = IRLedStartFrames*df;
    df_whisk=df;
    a=1;
    
    disp(['Found ',num2str(length(IRLedStartFrames)), ' video start times'])
    disp(['Found ',num2str(length(trialStartTimes)), ' ntrode start times'])
    
    IRLedStartTimes = IRLedStartFrames*df;
    
    check = 0;
    check2 = 0;
    
    h = figure;
    j = figure;
    
    while isequal(check,0) == 1 && isequal(check2,0) == 1
        
        figure(h)
        subplot(2,1,1)
        plot(trialStartTimes,1,'.g')
        hold on
        plot(IRLedStartTimes,2,'.r')
        %plot(IRLedStartFrames*df,3,'.b')
        %         if ~isempty(spikeTimes)
        %             line([spikeTimes(1) spikeTimes(1)],[-3 6],'Color','b')
        %             line([spikeTimes(end) spikeTimes(end)],[-3 6],'Color','b')
        %         end
        axis([0 1 -3 6])
        axis 'auto x'
        hold off
        title('Unaligned trial start times for ntrode (green) and whisking video (red)')
        subplot(2,1,2)
        plot(diff(trialStartTimes),'.-g')
        hold on
        plot(diff(IRLedStartTimes),'.-r')
        hold off
        
        if ~exist('whiskStart','var') || isequal(b,1)
            whiskStart = str2num(cell2mat(inputdlg('Start trial for whisking (red): ')));
            spikeStart = str2num(cell2mat(inputdlg('Start trial for neuron (green): ')));
        end
        
        trialStartTimes_adj = [];
        IRLedStartTimes_adj = [];
        IRLedStartFrames_adj = [];
        
        
        trialStartTimes_temp = trialStartTimes(spikeStart:end) - trialStartTimes(spikeStart);
        IRLedStartTimes_temp = IRLedStartTimes(whiskStart:end) - IRLedStartTimes(whiskStart);
        
        figure(j)
        subplot(2,1,1)
        plot(trialStartTimes_temp,1,'.g')
        hold on
        plot(IRLedStartTimes_temp,2,'.r')
        %         if ~isempty(spikeTimes)
        %             line([spikeTimes(1) spikeTimes(1)],[-3 6],'Color','b')
        %             line([spikeTimes(end) spikeTimes(end)],[-3 6],'Color','b')
        %         end
        axis([0 1 -3 6])
        axis 'auto x'
        hold off
        title('Aligned trial start times for ntrode (green) and whisking video (red)')
        
        subplot(2,1,2)
        plot(diff(trialStartTimes_temp),'.-g')
        hold on
        plot(diff(IRLedStartTimes_temp),'.-r')
        %axis([0 1 -3 6])
        %axis 'auto x'
        hold off
        
        if ~exist('spikeEnd','var') || isequal(b,1)
            lastStimNtrode = str2num(cell2mat(inputdlg('Number of trials to remove from end of ntrode (green) times (enter "1" to remove last trial, etc.): ')));
            lastStimWhisk = str2num(cell2mat(inputdlg('Number of trials to remove from end of whisking (red) times (enter "1" to remove last trial, etc.): ')));
            
            spikeEnd = length(trialStartTimes) - lastStimNtrode;
            whiskEnd = length(IRLedStartFrames) - lastStimWhisk;
        end
        trialStartTimes_adj = trialStartTimes(spikeStart:spikeEnd) - trialStartTimes(spikeStart);
        IRLedStartFrames_adj = IRLedStartFrames(whiskStart:whiskEnd) - IRLedStartFrames(whiskStart);
        IRLedStartTimes_adj = IRLedStartTimes(whiskStart:whiskEnd) - IRLedStartTimes(whiskStart);
        
        
        %LedSig_adj = LedSig(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd));
        
        if length(trialStartTimes_adj) ~= length(IRLedStartTimes_adj)
            warning('Start times not aligned correctly')
            check2 = 0;
            disp('checking uniqueness')
            FR_ms = unique(IRLedStartTimes_adj);
            FR = unique(IRLedStartFrames_adj);
            if length(FR)~=length(IRLedStartFrames_adj)
                disp('Uh oh! There may be a duplicate frame.')
            end
            [TS,uniq_ind,orig_ind] = unique(trialStartTimes_adj);
            if length(TS)~=length(trialStartTimes_adj)
                disp('Uh oh! There may be a duplicate ntrode trial start.')
                check_uniques = input('Delete duplicate trial start? (yes = 1; no = 0) ');
                if check_uniques==1
                    trialStartTimes_adj =TS;
                    uniq_diff = diff(uniq_ind);
                    ind = find(uniq_diff>1);
                    trialStartDuplicate = ind+1;
                    trialType_orig = trialType;
                    trialType(ind+1)=[];
                    save(fname2,'trialType_orig','trialType','trialStartDuplicate','-append')
                    check2 = 1;
                end
            end
            
        else
            check2 = 1;
        end
        
        subplot(2,1,1)
        plot(trialStartTimes_adj,1,'.g')
        hold on
        plot(IRLedStartTimes_adj,2,'.r')
        %plot(IRLedStartFrames_adj*df,3,'.b')
        axis([0 1 -3 6])
        axis 'auto x'
        hold off
        title('Aligned trial start times for ntrode (green) and whisking video (red)')
        
        subplot(2,1,2)
        plot(diff(trialStartTimes_adj),'.-g')
        hold on
        plot(diff(IRLedStartTimes_adj),'.-r')
        %axis([0 1 -3 6])
        axis tight
        hold off
        
        %        check2 = input('Are these times correctly aligned? (yes = 1; no = 0) ');
        
    end
    
    
    
    %     save(fname2,'LedSig','whiskStart','spikeStart','spikeEnd','whiskEnd','trialStartTimes_adj','IRLedStartTimes_adj','IRLedStartFrames_adj','-append')
    save(fname2,'whiskStart','spikeStart','spikeEnd','whiskEnd','trialStartTimes_adj','IRLedStartTimes_adj','IRLedStartFrames_adj','-append')
    
    maxTime = max(trialStartTimes_adj(end),IRLedStartTimes_adj(end));
    
    figure(3)
    subplot(4,1,1)
    hold on
    plot(trialStartTimes_adj,1,'.g')
    plot(IRLedStartTimes_adj,2,'.r')
    axis([0 maxTime -3 6])
    maxError = max(abs((trialStartTimes_adj - IRLedStartTimes_adj)));
    text(1e4,5,['Max offset error = ',num2str(maxError),' ms'])
    title('Aligned trial start times')
    
    p = polyfit(trialStartTimes_adj,IRLedStartTimes_adj,1);
    yfit = polyval(p,trialStartTimes_adj);
    
    subplot(4,1,2)
    hold on
    plot(trialStartTimes_adj,IRLedStartTimes_adj,'.')
    plot(trialStartTimes_adj,yfit,'k')
    eq = [num2str(p(1)), '*x + ',num2str(p(2))];
    text(min(trialStartTimes_adj) + 2e4,max(IRLedStartTimes_adj) - 2e4,eq)
    axis tight
    
    %Correcting for slightly different timings
    IRLedStartTimes_adj = (IRLedStartTimes_adj/p(1)) - p(2);
    df_adj = df/p(1);
    
    IRLedStartTimes_adj2 = (IRLedStartFrames_adj*df_adj);
    
    subplot(4,1,3)
    hold on
    plot(trialStartTimes_adj,1,'.g')
    plot(IRLedStartTimes_adj2,2,'.r')
    axis([0 maxTime -3 6])
    maxAlignmentError = max(abs((trialStartTimes_adj - IRLedStartTimes_adj2)));
    text(1e4,5,['Max offset error = ',num2str(maxAlignmentError),' ms'])
    title('Aligned & time corrected trial start times')
    
    subplot(4,1,4)
    hold on
    plot(trialStartTimes_adj - IRLedStartTimes_adj2,'.-k')
    
    drawnow limitrate
    
    check3 = input('continue? y or n');
    
    if isequal(check3,'y') %I think this is if you dropped frames???
        d = trialStartTimes_adj - IRLedStartTimes_adj2;
        [y,x] = max(diff(d));
        
        timeOff = round(y);
        
        nFramesAdd = ceil(timeOff/(1000/vidFrameRate));
        if whiskStart > spikeStart
            x = x + (whiskStart-spikeStart);
        end
        IRledSignal = insertFrames(IRledSignal,IRLedStartFrames,nFramesAdd,x);
        
        framesChanged(b,1) = nFramesAdd;
        framesChanged(b,2) = x;
        b = b+1;
        
        save(fname2,'framesChanged','-append')
        
    end
end

disp('Saving mat file...')
save(fname2,'df','IRLedStartFrames', 'IRLedStartTimes',...
    'df_adj','maxAlignmentError','IRLedStartTimes_adj','trialStartTimes_adj','-append')

end