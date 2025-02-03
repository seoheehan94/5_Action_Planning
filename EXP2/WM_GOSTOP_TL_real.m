% Name          : GOSTOP_TL_real
% Author        : JEH & Kuplex(KB Seo) in Coglab
% Environment   :
% Windows 10 64bit, Matlab R2017b 64bit, PTB 3.0.8
% Version       : 2018.0327
% Note          : real action planning finding T/L 

% ---------- Initialize ----------
clear all; % clear all pre-exist variables (interference prevention)
try % error handling start (error -> automatically close all screen)
echo off; % do not re-show my command
clc; % clear command-window 
fclose('all'); % close all pre-opened files (interference prevention)
ClockRandSeed; % reset random seed
GetSecs; WaitSecs(0); % pre-load timing function for precision timing
% Screen('Preference', 'SkipSyncTests', 1); % ON for just show, OFF for exp

% ---------- Configuration ----------
expName     = 'WM_GOSTOP_TL_real'; % experiment name for data files
expData     = 'result_WM_GOSTOP_TL_real'; % experiment data folder name

% rootdir     = 'E:\JEH\Dropbox\MATLAB\2018_GOSTOP'; % directory setting

bgColor     = 0; % background color (0~255)
txtColor    = 255; % text color (0~255)
fontSize    = 30; % default font size

srcStimPx = [135 135]; % diameter 6 degree
TLStimPx  = [30 30];
srcEccPx  = 450;
fixPx     = 12;
oriPx     = 110; % 3 degree 
linePx    = 149; % 4 degree

notice1     = '실험자의 지시에 따라주시기 바랍니다'; % notice message for phase 1
practiceReady = '<연습시행을 진행하려면 스페이스바를 누르세요>'; % notice message for practice start
noticeReady = '<계속 진행하려면 스페이스바를 누르세요>'; % notice message for trial start
noticeEnd   = {'실험이 끝났습니다.'; '수고하셨습니다. 가셔도 좋습니다.'}; % notice message for ending
practiceEnd = {'연습시행이 종료되었습니다.'; '이제 실험이 시작됩니다.'; '실험자의 지시에 따라 성실하게 임해주세요.'};
surpriseWM  = {'깜짝 과제입니다.'; '마지막으로 T 또는 L이 나왔던 원의 색깔에 해당하는 번호를 고르세요'; '빨강(1)  노랑(2)  초록(3)  파랑(4)  보라(5)  회색(6)'};
confidenceWM  = {'방금의 답에 얼마나 확신하십니까?'; '매우 불확신(1)  조금 불확신(2)  조금 확신(3)  매우 확신(4)'};


inputDelay    = 1; % form input delay to avoid skipping(seconds)
fixTime       = 0.5; % fixation duration
blank1        = 0.5;
preprimeTime  = 0.25;
primeTime     = 0.2;
postprimeTime = 0.3;
srcTime       = 1.5;
ITI           = 1.5;
recTime       = 1.5;

%sound setting
srHz = 44100;  % the sample rate in Hz
frq1 = 1500;  % the tone's frequency
frq2 = 1200;
dt = 0.1;  % the duration in sec
tv = linspace(0, dt, srHz*dt);  % a time vector
tone1 = sin(2*pi*frq1*tv);  % the actual, final tone of first response
tone2 = sin(2*pi*frq2*tv);  % the actual, final tone of second response



% ---------- Participant Information ----------
Ptag = input('P: ', 's'); % 번호
% Ctag = input('C(): ', 's'); % 조건
Stag = input('S(1=m, 2=f): ', 's'); % 성별
Btag = input('B(): ', 's'); % 역균형 조건 1 = target T, 2 = target L

% ---------- Key Setup ----------
goKey       = KbName('space'); % response key to proceed
finKey      = KbName('q');  % administrative key to end experiment
gogoKey     = KbName('p'); % after practice set 
expKeyList  = {'space', 'left', 'right'}; % keys for tasks
for keyP = 1:numel(expKeyList)
    expKeys{keyP} = KbName(expKeyList{keyP});
end
WMKeyList   = {'1!', '2@', '3#', '4$', '5%', '6^'}; % keys for surprise WM task
for keyP2 = 1:numel(WMKeyList)
    WMKeys{keyP2} = KbName(WMKeyList{keyP2});
end

% ---------- Display Setup ----------
ListenChar(2); % do not listen to my typed command during experiment
[w, rect] = Screen('OpenWindow', 0, bgColor, [0 0 1920 1080]); % open main screen
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable image blending
    Screen('Preference', 'TextAlphaBlending', 0);
    Screen('Preference', 'TextRenderer', 1);
    Screen('Preference', 'TextAntiAliasing', 2);
    Screen('TextFont',w, 'Malgun Gothic'); % set default text font
    Screen('TextSize',w, fontSize); % set default text size
    Screen('TextStyle', w, 0); % set default text style

[cx, cy] = RectCenter(rect); % get screen center coordinate

% ---------- Start Up ----------
HideCursor; % hide mouse cursor

DrawTextUni(w, notice1); % draw unicode text
Screen('Flip', w); % video memory to main screen
WaitSecs(inputDelay); % notice force-viewing
RestrictKeysForKbCheck(goKey);
FlushEvents('keyDown'); % flush pre-pressed key events
while 1
    [keyIsDown, secs, keyCode] = KbCheck();
    if keyIsDown
        break
    end
end



Screen('Flip', w); % clear screen
WaitSecs(inputDelay);

% ---------- Data, Trials, Stimuli Setup ----------
C = clock; D = '_';
Dtag = [num2str(C(1)) D num2str(C(2)) D num2str(C(3)) D num2str(C(4)) D num2str(C(5))];
fileName = [expData, '/', expName, D, Stag, D, Dtag, D, Btag, D, Ptag];

if ~exist(expData, 'dir')
	mkdir(expData);
end


% search circle setup (6 color)

% image matrix
red      = pngread('red.png');
yellow   = pngread('yellow.png');
green    = pngread('green.png');
blue     = pngread('blue.png');  
purple   = pngread('purple.png');
gray     = pngread('gray.png');
allstim  = pngread('allstim.png');
whitecir = pngread('white.png');

stim_T   = pngread('stim_T_W2.png');
stim_L   = pngread('stim_L_W2.png');

% make texture
texRed       = Screen('MakeTexture', w, red);
texYellow    = Screen('MakeTexture', w, yellow);
texGreen     = Screen('MakeTexture', w, green);
texBlue      = Screen('MakeTexture', w, blue);
texPurple    = Screen('MakeTexture', w, purple);
texGray      = Screen('MakeTexture', w, gray);
texallstim   = Screen('MakeTexture', w, allstim);
texwhitecir  = Screen('MakeTexture', w, whitecir);

tex_T        = Screen('MakeTexture', w, stim_T);
tex_L        = Screen('MakeTexture', w, stim_L);

% index
texCircle = {texRed, texYellow, texGreen, texBlue, texPurple, texGray}; % 1, 2, 3, 4, 5, 6 indexing

if str2num(Btag) == 1
    letterList = {tex_T, tex_L};
elseif str2num(Btag) == 2
    letterList = {tex_L, tex_T};
end

%wordCueList = {'빨강', '노랑', '초록', '파랑', '보라', '회색'}; 

% search array setup

locN    = 5; % 가능한 자극 위치의 수 - 변경 불가
unitTheta	= 360/locN; % 자극 간 간격 단위각도
srcStimXY   = zeros(2,locN); % search array 자극 좌표 초기화
srcStimRectSample = [0 0 srcStimPx(1) srcStimPx(2)]; % 크기만 반영한 자극 샘플 rect

srcStimRects = [];
for locP = 1:locN
    xtheta = unitTheta*(locP-1); % 각 자극 간 간격 별 각도
    srcStimXY(1,locP) = round(srcEccPx * sin(xtheta * 2*pi/360))+cx; % x좌표 계산
    srcStimXY(2,locP) = round(-srcEccPx * cos(xtheta * 2*pi/360))+cy; % y좌표 계산
    t_srcStimRects = CenterRectOnPoint(srcStimRectSample,srcStimXY(1,locP),srcStimXY(2,locP)); % 각 위치별 rect 계산
    srcStimRects{locP} = t_srcStimRects;
end

% practice Matrix
pracMat    = []; % need preallocation
block       = 1;
for blk = 1:block
    [F1, F2, F3] = BalanceFactors(1,1, [1,2], [1, 2, 3, 4, 5, 6], [1, 0]);
    % letter  1 = action, 2 = no-action
    % prime color 1=red, 2=yellow, 3=green, 4=blue, 5=purple, 6=gray
    % validity  1 = valid, 0 = invalid
    pracMat = [pracMat; F1, F2, F3];
end

pracN      = size(pracMat,1);


% trial Matrix
trialMat    = []; % need preallocation
block       = 6; %6
for blk = 1:block
    [F1, F2, F3] = BalanceFactors(1,1, [1,2], [1, 2, 3, 4, 5, 6], [1, 0]);
    % letter  1 = action, 2 = no-action
    % prime color 1=red, 2=yellow, 3=green, 4=blue, 5=purple, 6=gray
    % validity  1 = valid, 0 = invalid
    trialMat = [trialMat; F1, F2, F3];
end

trialN      = size(trialMat,1);
blockSize   = trialN / block;

RAWDATA     = []; % RAWDATA preallocation
WMDATA      = [];
BLOCKTIME   = zeros(block); % blocktime preallocation
expTimer    = GetSecs;



 %% ---------- Practice Phase:  ----------
blockTimer  = GetSecs;

% get ready
% Screen('DrawTexture', w, texallstim);
% Screen('Flip', w); % video memory to main screen
% WaitSecs(inputDelay); % notice force-viewing
% RestrictKeysForKbCheck(goKey);
% FlushEvents('keyDown'); % flush pre-pressed key events
% while 1
%     [keyIsDown, secs, keyCode] = KbCheck();
%     if keyIsDown
%         break
%     end
% end
% 
% Screen('Flip', w); % clear screen
% WaitSecs(inputDelay);

DrawTextUni(w, practiceReady); % draw unicode text
Screen('Flip', w); % video memory to main screen
RestrictKeysForKbCheck(goKey);
FlushEvents('keyDown'); % flush pre-pressed key events
while 1
    [keyIsDown, secs, keyCode] = KbCheck();
    if keyIsDown
        break
    end
end


for P = 1:pracN
    
    % trial information
    pflip       = [];
    %     blockP      = ceil(P/blockSize);
    letterP     = trialMat(P,1); % 1 = action, 2 = no-action
    priColP     = trialMat(P,2); % 1=red, 2=yellow, 3=green, 4=blue, 5=purple, 6=gray
    validP      = trialMat(P,3); % 1 = valid, 0 = invalid
    
    
    % show fixation
    Screen('DrawLine',w, txtColor, cx-10, cy, cx+10, cy, 3);
    Screen('DrawLine',w, txtColor, cx, cy-10, cx, cy+10, 3);
    pflip = Screen('Flip',w, pflip)+fixTime;
    primeOnset = pflip;

    % show preprime (50ms)
    Screen('DrawTexture', w, texCircle{priColP});
    pflip = Screen('Flip',w, pflip)+preprimeTime;
    
    % show prime (200ms)
    Screen('DrawTexture', w, texCircle{priColP});
    Screen('DrawTexture', w, letterList{letterP});    
    pflip = Screen('Flip',w, pflip)+primeTime;
    
    % get response 
    cueRespP    = 99; % 반응안함을 기본으로
    cueCorrP    = 99; % 반응안함을 기본으로
    cueRTP      = 99; % 반응안함을 기본으로
    RestrictKeysForKbCheck(expKeys{1}); % space 만 허용
    FlushEvents('keyDown'); % flush pre-pressed key events
    while GetSecs - primeOnset <= preprimeTime+primeTime
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            cueRTP = secs - primeOnset - preprimeTime ; % RT 계산
            pressedKeyList = find(keyCode); % 눌러진 키 모두
            pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
            if pressedKey == expKeys{1} % z 누름
                cueRespP = 1;
            end
            break
        end
    end
    
    % show postprime (500ms)
    Screen('DrawTexture', w, texCircle{priColP});
    pflip = Screen('Flip',w, pflip)+postprimeTime;
      
    % get response
    RestrictKeysForKbCheck(expKeys{1}); % space 만 허용
    FlushEvents('keyDown'); % flush pre-pressed key events
    while GetSecs - primeOnset <= preprimeTime+primeTime+postprimeTime
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            cueRTP = secs - primeOnset - preprimeTime; % RT 계산
            pressedKeyList = find(keyCode); % 눌러진 키 모두
            pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
            if pressedKey == expKeys{1} %
                cueRespP = 1;
            end    
            break
        end
    end
    
    if letterP == 1
        cueCorrP = letterP == cueRespP;
    elseif letterP == 2
        cueCorrP = (letterP+97) == cueRespP;
    end
    
    if cueCorrP == 0
        sound(tone1, srHz);
    end
      
    
    % fixation (500ms)
    Screen('DrawLine',w, txtColor, cx-10, cy, cx+10, cy, 3);
    Screen('DrawLine',w, txtColor, cx, cy-10, cx, cy+10, 3);
    pflip = Screen('Flip',w, pflip)+fixTime;
    srcOnset = pflip;
    
    
    % ------ show search display
    targLoc = randi(5); % randomly selected
    targOri = randi(2); % left or right
    anoCol = [1, 2, 3, 4, 5, 6];
    anoCol(anoCol == priColP) = [ ]; % not prime color
    realAnoCol = anoCol(randi(5));
    
    
    % another circle's location, constraint
    if targLoc == 1
        anoLoc = targLoc + randi(2)+1; % 3 or 4
    elseif targLoc == 2
        anoLoc = targLoc + randi(2)+1; % 4 or 5
    elseif targLoc == 3
        aa = [1, 5];
        anoLoc = aa(randi(2)); % 1 or 5
    elseif targLoc == 4
        anoLoc = targLoc - (randi(2)+1); % 2 or 1
    elseif targLoc == 5
        anoLoc = targLoc - (randi(2)+1); % 2 or 3
    end
    
    if validP == 1 % valid
        Screen('DrawTexture', w, texCircle{priColP}, [], srcStimRects{targLoc}); % target color = prime
        Screen('DrawTexture', w, texCircle{realAnoCol}, [], srcStimRects{anoLoc}); % another circle
        if targOri == 1 % left
            Screen('DrawLine', w, 0, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
        elseif targOri == 2 % right
            Screen('DrawLine', w, 0, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
        end
        Screen('DrawLine', w, 0, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)-linePx/2, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)+linePx/2, 3); % vertical line
        
    elseif validP == 0 % invalid
        Screen('DrawTexture', w, texCircle{priColP}, [], srcStimRects{anoLoc}); % prime
        Screen('DrawTexture', w, texCircle{realAnoCol}, [], srcStimRects{targLoc}); % another circle = target
        if targOri == 1 % left
            Screen('DrawLine', w, 0, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
        elseif targOri == 2 % right
            Screen('DrawLine', w, 0, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
        end
        Screen('DrawLine', w, 0, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)-linePx/2, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)+linePx/2, 3); % vertical line
        
    end
    pflip = Screen('Flip',w, pflip)+srcTime;
    
    % get response
    srcRespP    = 99; % 반응안함을 기본으로
    srcCorrP    = 99; % 반응안함을 기본으로
    srcRTP      = 99; % 반응안함을 기본으로
    RestrictKeysForKbCheck([expKeys{2} expKeys{3}]); % left, right 만 허용
    FlushEvents('keyDown'); % flush pre-pressed key events
    while GetSecs - srcOnset <= srcTime
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            srcRTP = secs - srcOnset; % RT 계산
            pressedKeyList = find(keyCode); % 눌러진 키 모두
            pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
            if pressedKey == expKeys{2} % left 누름
                srcRespP = 1;
            elseif pressedKey == expKeys{3} % right 누름
                srcRespP = 2;
            end
   
            srcCorrP = targOri == srcRespP; % 반응 맞으면 1, 틀리면 0
            if srcCorrP == 0
                %                 sound(tone2, srHz);
                sound(tone2, srHz);
            end
            break
        end
    end
    if srcRespP == 99
        sound(tone2, srHz);
    end
    

    
    % ITI (1500ms)
    pflip = Screen('Flip',w, pflip)+ITI;
    
    
    Screen('Flip', w); % clear screen
    WaitSecs(ITI);

    % write data
    PRACDATA(P,:) = [P, letterP, priColP, realAnoCol, cueRespP, cueCorrP, cueRTP, validP, targLoc, anoLoc, targOri, srcRespP, srcCorrP, srcRTP];
    save([fileName,'.mat']);
    %     csvwrite([fileName,'.csv'],PRACDATA);
    
%     WaitSecs(0.3);
%     Screen('Flip', w); % clear screen
    
    if P == length(pracMat)
        DrawTextUni(w, practiceEnd, 'center', 0, 0);
        Screen('Flip', w); % video memory to main screen
        FlushEvents('keyDown'); % flush pre-pressed key events
        oldenablekeys = RestrictKeysForKbCheck(gogoKey);
        KbWait();
        RestrictKeysForKbCheck(oldenablekeys);
    end
    
end

    Screen('Flip', w); % clear screen
    WaitSecs(1);
    
%% ---------- Phase 1:  ----------
blockTimer  = GetSecs;

% get ready
DrawTextUni(w, noticeReady); % draw unicode text
Screen('Flip', w); % video memory to main screen
RestrictKeysForKbCheck(goKey);
FlushEvents('keyDown'); % flush pre-pressed key events
while 1
    [keyIsDown, secs, keyCode] = KbCheck();
    if keyIsDown
        break
    end
end


for T = 1:trialN

    % trial information
    tflip       = [];
    blockT      = ceil(T/blockSize);
    letterT     = trialMat(T,1); % 1 = action, 2 = no-action
    priColT     = trialMat(T,2); % 1=red, 2=yellow, 3=green, 4=blue, 5=purple, 6=gray
    validT      = trialMat(T,3); % 1 = valid, 0 = invalid
    
    % show fixation
    Screen('DrawLine',w, txtColor, cx-10, cy, cx+10, cy, 3);
    Screen('DrawLine',w, txtColor, cx, cy-10, cx, cy+10, 3);
    tflip = Screen('Flip',w, tflip)+fixTime;
    primeOnset = tflip;

    % show preprime (50ms)
    Screen('DrawTexture', w, texCircle{priColT});
    tflip = Screen('Flip',w, tflip)+preprimeTime;

    % show prime (200ms)
    Screen('DrawTexture', w, texCircle{priColT});
    Screen('DrawTexture', w, letterList{letterT});
    tflip = Screen('Flip',w, tflip)+primeTime;
    
    % get response 
    cueRespT    = 99; % 반응안함을 기본으로
    cueCorrT    = 99; % 반응안함을 기본으로
    cueRTT      = 99; % 반응안함을 기본으로
    RestrictKeysForKbCheck(expKeys{1}); % space 만 허용
    FlushEvents('keyDown'); % flush pre-pressed key events
    while GetSecs - primeOnset <= preprimeTime+primeTime
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            cueRTT = secs - primeOnset - preprimeTime; % RT 계산
            pressedKeyList = find(keyCode); % 눌러진 키 모두
            pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
            if pressedKey == expKeys{1} % z 누름
                cueRespT = 1;
            end
            break
        end
    end
    
    % show postprime (500ms)
    Screen('DrawTexture', w, texCircle{priColT});
    tflip = Screen('Flip',w, tflip)+postprimeTime;
    
    % get response 
    RestrictKeysForKbCheck(expKeys{1}); % space 만 허용
    FlushEvents('keyDown'); % flush pre-pressed key events
    while GetSecs - primeOnset <= preprimeTime+primeTime+postprimeTime
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            cueRTT = secs - primeOnset - preprimeTime; % RT 계산
            pressedKeyList = find(keyCode); % 눌러진 키 모두
            pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
            if pressedKey == expKeys{1} % z 누름
                cueRespT = 1;
            end
            break
        end
    end
       
    if letterT == 1
        cueCorrT = letterT == cueRespT;
    elseif letterT == 2
        cueCorrT = (letterT+97) == cueRespT;
    end
    
    if cueCorrT == 0
        sound(tone1, srHz);
    end
    
    
    % fixation (500ms)
    Screen('DrawLine',w, txtColor, cx-10, cy, cx+10, cy, 3);
    Screen('DrawLine',w, txtColor, cx, cy-10, cx, cy+10, 3);
    tflip = Screen('Flip',w, tflip)+fixTime; 
    srcOnset = tflip;
    
    
    % ------ show search display 
    targLoc = randi(5); % randomly selected 
    targOri = randi(2); % left or right
    anoCol = [1, 2, 3, 4, 5, 6];
    anoCol(anoCol == priColT) = [ ]; % not prime color
    realAnoCol = anoCol(randi(5));

    
    % another circle's location, constraint 
    if targLoc == 1
        anoLoc = targLoc + randi(2)+1; % 3 or 4
    elseif targLoc == 2
        anoLoc = targLoc + randi(2)+1; % 4 or 5 
    elseif targLoc == 3
        aa = [1, 5];
        anoLoc = aa(randi(2)); % 1 or 5
    elseif targLoc == 4
        anoLoc = targLoc - (randi(2)+1); % 2 or 1 
    elseif targLoc == 5
        anoLoc = targLoc - (randi(2)+1); % 2 or 3 
    end
    
    
    if validT == 1 % valid
        Screen('DrawTexture', w, texCircle{priColT}, [], srcStimRects{targLoc}); % target color = prime
        Screen('DrawTexture', w, texCircle{realAnoCol}, [], srcStimRects{anoLoc}); % another circle
        if targOri == 1 % left
            Screen('DrawLine', w, 0, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
        elseif targOri == 2 % right
            Screen('DrawLine', w, 0, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
        end
        Screen('DrawLine', w, 0, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)-linePx/2, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)+linePx/2, 3); % vertical line
        
    elseif validT == 0 % invalid
        Screen('DrawTexture', w, texCircle{priColT}, [], srcStimRects{anoLoc}); % prime
        Screen('DrawTexture', w, texCircle{realAnoCol}, [], srcStimRects{targLoc}); % another circle = target
        if targOri == 1 % left
            Screen('DrawLine', w, 0, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
        elseif targOri == 2 % right
            Screen('DrawLine', w, 0, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
        end
        Screen('DrawLine', w, 0, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)-linePx/2, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)+linePx/2, 3); % vertical line
        
    end
    tflip = Screen('Flip',w, tflip)+srcTime;
    
    % get response
    srcRespT    = 99; % 반응안함을 기본으로
    srcCorrT    = 99; % 반응안함을 기본으로
    srcRTT      = 99; % 반응안함을 기본으로
    RestrictKeysForKbCheck([expKeys{2} expKeys{3}]); % left, right 만 허용
    FlushEvents('keyDown'); % flush pre-pressed key events
    while GetSecs - srcOnset <= srcTime
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            srcRTT = secs - srcOnset; % RT 계산
            pressedKeyList = find(keyCode); % 눌러진 키 모두
            pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
            if pressedKey == expKeys{2} % left 누름
                srcRespT = 1;
            elseif pressedKey == expKeys{3} % right 누름
                srcRespT = 2;
            end
            
            srcCorrT = targOri == srcRespT; % 반응 맞으면 1, 틀리면 0
            if srcCorrT == 0
                %                 sound(tone2, srHz);
                sound(tone2, srHz);
            end
            break
        end
    end
    if srcRespT == 99
        sound(tone2, srHz);
    end 
   
    
    
    
    % ITI (1500ms)
    tflip = Screen('Flip',w, tflip)+ITI;

    
    
    Screen('Flip', w); % clear screen

    
    % write data
    RAWDATA(T,:) = [T, letterT, priColT, realAnoCol, cueRespT, cueCorrT, cueRTT, validT, targLoc, anoLoc, targOri, srcRespT, srcCorrT, srcRTT];
    save([fileName,'.mat']);
    csvwrite([fileName,'.csv'],RAWDATA);
    
    
    
    % block break & show remained block
    if mod(T,blockSize) == 0 && T ~= trialN
        BLOCKTIME(blockT) = GetSecs - blockTimer;
        blockTimer = GetSecs;
        msg_remBlock = [num2str(block-blockT),'블록 남음'];
        DrawTextUni(w, msg_remBlock, 'center', 0, -60);
        DrawTextUni(w, '눈 피로 방지를 위해 잠시 휴식해도 좋습니다', 'center', 0, 0);
        DrawTextUni(w, '<계속 진행하려면 스페이스바를 누르시오>', 'center', 0, +60);
        Screen('Flip',w);
        RestrictKeysForKbCheck(goKey);
         FlushEvents('keyDown'); % flush pre-pressed key events
         while 1
             [keyIsDown, secs, keyCode] = KbCheck();
             if keyIsDown
                 break
             end
         end
    else
        WaitSecs(ITI);
    end

    Screen('Flip', w); % clear screen
    
end

Screen('Flip', w); % clear screen

%% surpriseWM task
    
WMCol    = randi(6);
WMletter = mod(str2num(Ptag),2)+1;
WMvalid  = mod(fix((str2num(Ptag)+1)/2),2);

% show fixation
Screen('DrawLine',w, txtColor, cx-10, cy, cx+10, cy, 3);
Screen('DrawLine',w, txtColor, cx, cy-10, cx, cy+10, 3);
tflip = Screen('Flip',w, tflip)+fixTime;
primeOnset = tflip;

% show preprime (50ms)
Screen('DrawTexture', w, texCircle{WMCol});
tflip = Screen('Flip',w, tflip)+preprimeTime;

% show prime (200ms)
Screen('DrawTexture', w, texCircle{WMCol});
Screen('DrawTexture', w, letterList{WMletter});
tflip = Screen('Flip',w, tflip)+primeTime;

% get response
WMcueResp    = 99; % 반응안함을 기본으로
WMcueCorr    = 99; % 반응안함을 기본으로
WMcueRT      = 99; % 반응안함을 기본으로
RestrictKeysForKbCheck(expKeys{1}); % space 만 허용
FlushEvents('keyDown'); % flush pre-pressed key events
while GetSecs - primeOnset <= preprimeTime+primeTime
    [keyIsDown, secs, keyCode] = KbCheck();
    if keyIsDown
        WMcueRT = secs - primeOnset - preprimeTime; % RT 계산
        pressedKeyList = find(keyCode); % 눌러진 키 모두
        pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
        if pressedKey == expKeys{1} % z 누름
            WMcueResp = 1;
        end
        break
    end
end

% show postprime (500ms)
Screen('DrawTexture', w, texCircle{WMCol});
tflip = Screen('Flip',w, tflip)+postprimeTime;

% get response
RestrictKeysForKbCheck(expKeys{1}); % space 만 허용
FlushEvents('keyDown'); % flush pre-pressed key events
while GetSecs - primeOnset <= preprimeTime+primeTime+postprimeTime
    [keyIsDown, secs, keyCode] = KbCheck();
    if keyIsDown
        WMcueRT = secs - primeOnset - preprimeTime; % RT 계산
        pressedKeyList = find(keyCode); % 눌러진 키 모두
        pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
        if pressedKey == expKeys{1} % z 누름
            WMcueResp = 1;
        end
        break
    end
end

    if WMletter == 1
        WMcueCorr = WMletter == WMcueResp;
    elseif WMletter == 2
        WMcueCorr = (WMletter+97) == WMcueResp;
    end
    
    if WMcueCorr == 0
        sound(tone1, srHz);
    end

% fixation (500ms)
Screen('DrawLine',w, txtColor, cx-10, cy, cx+10, cy, 3);
Screen('DrawLine',w, txtColor, cx, cy-10, cx, cy+10, 3);
tflip = Screen('Flip',w, tflip)+fixTime;
srcOnset = tflip;
    
% ------ show search display
targLoc = randi(5); % randomly selected
targOri = randi(2); % left or right
anoCol = [1, 2, 3, 4, 5, 6];
anoCol(anoCol == WMCol) = [ ]; % not prime color
realAnoCol = anoCol(randi(5));

% another circle's location, constraint
if targLoc == 1
    anoLoc = targLoc + randi(2)+1; % 3 or 4
elseif targLoc == 2
    anoLoc = targLoc + randi(2)+1; % 4 or 5
elseif targLoc == 3
    aa = [1, 5];
    anoLoc = aa(randi(2)); % 1 or 5
elseif targLoc == 4
    anoLoc = targLoc - (randi(2)+1); % 2 or 1
elseif targLoc == 5
    anoLoc = targLoc - (randi(2)+1); % 2 or 3
end
    
    
if WMvalid == 1 % valid
    Screen('DrawTexture', w, texCircle{WMCol}, [], srcStimRects{targLoc}); % target color = prime
    Screen('DrawTexture', w, texCircle{realAnoCol}, [], srcStimRects{anoLoc}); % another circle
    if targOri == 1 % left
        Screen('DrawLine', w, 0, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
    elseif targOri == 2 % right
        Screen('DrawLine', w, 0, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
    end
    Screen('DrawLine', w, 0, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)-linePx/2, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)+linePx/2, 3); % vertical line
    
elseif WMvalid == 0 % invalid
    Screen('DrawTexture', w, texCircle{WMCol}, [], srcStimRects{anoLoc}); % prime
    Screen('DrawTexture', w, texCircle{realAnoCol}, [], srcStimRects{targLoc}); % another circle = target
    if targOri == 1 % left
        Screen('DrawLine', w, 0, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
    elseif targOri == 2 % right
        Screen('DrawLine', w, 0, srcStimXY(1,targLoc)+oriPx, srcStimXY(2,targLoc)-linePx/2, srcStimXY(1,targLoc)-oriPx, srcStimXY(2,targLoc)+linePx/2, 3);
    end
    Screen('DrawLine', w, 0, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)-linePx/2, srcStimXY(1,anoLoc), srcStimXY(2,anoLoc)+linePx/2, 3); % vertical line
    
end
tflip = Screen('Flip',w, tflip)+srcTime;
    
% get response
WMsrcResp    = 99; % 반응안함을 기본으로
WMsrcCorr    = 99; % 반응안함을 기본으로
WMsrcRT      = 99; % 반응안함을 기본으로
RestrictKeysForKbCheck([expKeys{2} expKeys{3}]); % left, right 만 허용
FlushEvents('keyDown'); % flush pre-pressed key events
while GetSecs - srcOnset <= srcTime
    [keyIsDown, secs, keyCode] = KbCheck();
    if keyIsDown
        WMsrcRT = secs - srcOnset; % RT 계산
        pressedKeyList = find(keyCode); % 눌러진 키 모두
        pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
        if pressedKey == expKeys{2} % left 누름
            WMsrcResp = 1;
        elseif pressedKey == expKeys{3} % right 누름
            WMsrcResp = 2;
        end
        
        WMsrcCorr = targOri == WMsrcResp; % 반응 맞으면 1, 틀리면 0
        if WMsrcCorr == 0
            sound(tone2, srHz);
        end
        break
    end
end
if WMsrcResp == 99
    sound(tone2, srHz);
end
    
% blank (500ms)
%     Screen('DrawLine',w, txtColor, cx-10, cy, cx+10, cy, 3);
%     Screen('DrawLine',w, txtColor, cx, cy-10, cx, cy+10, 3);
tflip = Screen('Flip',w, tflip)+blank1;
%     memOnset  = tflip;

DrawTextUni(w, surpriseWM);
Screen('Flip', w);
RestrictKeysForKbCheck([WMKeys{1} WMKeys{2} WMKeys{3} WMKeys{4} WMKeys{5} WMKeys{6}]); % left, right 만 허용
    FlushEvents('keyDown'); % flush pre-pressed key events
    while 1
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            pressedKeyList = find(keyCode); % 눌러진 키 모두
            pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
            if pressedKey == WMKeys{1}
                WMResp = 1;
            elseif pressedKey == WMKeys{2}
                WMResp = 2;
            elseif pressedKey == WMKeys{3}
                WMResp = 3;
            elseif pressedKey == WMKeys{4}
                WMResp = 4;
            elseif pressedKey == WMKeys{5}
                WMResp = 5;
            elseif pressedKey == WMKeys{6}
                WMResp = 6;
            end
            break
        end
    end   
WaitSecs(ITI);
    
DrawTextUni(w, confidenceWM);
Screen('Flip', w);
RestrictKeysForKbCheck([WMKeys{1} WMKeys{2} WMKeys{3} WMKeys{4}]); % left, right 만 허용
    FlushEvents('keyDown'); % flush pre-pressed key events
    while 1
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            pressedKeyList = find(keyCode); % 눌러진 키 모두
            pressedKey = pressedKeyList(1); % 오류 방지 위해 첫 키만 인정
            if pressedKey == WMKeys{1}
                cfWMResp = 1;
            elseif pressedKey == WMKeys{2}
                cfWMResp = 2;
            elseif pressedKey == WMKeys{3}
                cfWMResp = 3;
            elseif pressedKey == WMKeys{4}
                cfWMResp = 4;
            end
            break
        end
    end
     
    % Correct
    if WMResp == WMCol
        WMCorr = 1;
    else
        WMCorr = 0;
    end

    
    WMDATA(1,:) = [WMletter, WMvalid, WMcueResp, WMcueCorr, WMcueRT, targOri, WMsrcResp, WMsrcCorr, WMsrcRT, WMCol, realAnoCol, WMResp, WMCorr, cfWMResp];
    save([fileName,'.mat']);
    csvwrite([fileName,'_WM.csv'],WMDATA);        
   
    Screen('Flip', w);
    WaitSecs(1);
%% ---------- End of Experiment ----------
EXPTIME = GetSecs - expTimer;
save([fileName,'.mat']);

DrawTextUni(w, noticeEnd);
Screen('Flip', w);
 RestrictKeysForKbCheck(finKey);
    FlushEvents('keyDown'); % flush pre-pressed key events
    while 1
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyIsDown
            break
        end
    end

% ---------- Clean Up ----------
Screen('CloseAll'); % close all PTB screen(especially main screen)
ShowCursor; % show mouse cursor
ListenChar(0); % now listen to my command
catch ME % if an error occured, run following script and end the experiment
Screen('CloseAll');
ShowCursor;
ListenChar(0);
rethrow(ME); % show me the error
end % error handling end