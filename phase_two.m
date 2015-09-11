close all;
clear all;
sca;

%Randomized and counterbalanced trial matrix
%{
Column Indices are as follows:
	1 - Face exemplar number
	2 - Emotion number
	3 - Reward/Punishment/No reward
	4 - Rating
%}
%Parameters
reps = 1;
n_faces = 4;
n_emos = 1;
reward = 0.8;

n_trials = reps * n_faces * n_emos * 5; 
trial_mat = ones(n_trials, 4);
%Face exemplars
for i = 1:n_faces
	trial_mat(i:4:end, 1) = i
end
%Reward
trial_mat(:, 3) = 0
trial_mat(1:n_trials*reward/2, 3) = -1
trial_mat(n_trials*reward/2:n_trials*reward, 3) = 1

%Emotion
%there should be a better way to do this
emo_ind = [1 1 1 1 1 1 1 1 1 1 1 1]
for i = 1:n_faces * n_emos
	trial_mat(i:n_faces*n_emos:end, 2) = emo_ind(i)
end


trial_mat = trial_mat(randperm(n_trials), :);


%Right now we can't use this variable for a weird reason
%one_deg = visangcalc(60, 1368, 30);
%10*one_deg





%All of these has to do with the screen object
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'SuppressAllWarnings', 1);
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);


dist_from_center = [-480 480];
rect_pos = (screenXpixels/2) .+ dist_from_center;
base_rect_1 = [0 0 480 480];

for i = 1:2
	%Final positions of rectangle corners
	rects(:, i) = CenterRectOnPointd(base_rect_1, rect_pos(i), screenYpixels/2);

end

baseRect = [0 0 20 200]	
centeredRect = CenterRectOnPointd(baseRect, screenXpixels*0.7, screenYpixels*0.5);
rectColor = [1 0 0];

exemplar_fname = {'01F_', '07F_', '09F_', '17F_'};
emo_fname = {'NE'};

money_pos = [(rects(1,1)+rects(3,1))/2, (rects(1,2)+rects(3,2))/2]

%Trials start here
rects
for trial = 1:n_trials
	
	img_str = strcat('./faces/', exemplar_fname{trial_mat(trial, 1)}, emo_fname{trial_mat(trial, 2)}, '.bmp');
	img = imread(img_str);
	imgTexture = Screen('MakeTexture', window, img);

	%rect_mat = ones(size(img)) * 0.5;
	%rect_mat = SetImageAlpha(rect_mat, 0.5);
	%rectTexture = Screen('MakeTexture', window, rect_mat);


		

	% Inter trial interval
	for i = 1:2	
		Screen('DrawTexture', window, imgTexture, [], rects(:, i), 0);
		%Screen('DrawTexture', window, rectTexture, [], rects(:, i), 0);
		DrawFormattedText(window, strcat(int2str(trial_mat(trial, 3)*50), 'c'), money_pos(i), screenYpixels * 0.9, 0);
	end
		
	Screen('Flip', window);
	WaitSecs(0.1);

	Screen('Flip', window)
	
	end_trial = false;
	rating = 0;
	trial_mat(trial,4) = rating;
	Screen('Flip', window);
	WaitSecs(0.1)
end


for i = 1:4



	img_str = strcat('./faces/', exemplar_fname{i}, emo_fname{1}, '.bmp');
	img = imread(img_str);
	imgTexture = Screen('MakeTexture', window, img);
	

	% Inter trial interval
	
	while end_trial == false

		[keyIsDown,secs, keyCode] = KbCheck;
		
		if keyCode(KbName('LeftArrow'))
			end_trial = true;
		elseif keyCode(KbName('UpArrow'))
			rating = min(rating + 1, 10);
			baseRect(4) = min(baseRect(4) + 10, 500)
			rating = baseRect(4)
			trial_mat(trial, 4) = rating
		elseif keyCode(KbName('DownArrow'))
			baseRect(4) = max(baseRect(4) - 10, 0)
			rating = baseRect(4)
			trial_mat(trial, 4) = rating	

		end
		%Doesn't recognize space character
		centeredRect = CenterRectOnPointd(baseRect, screenXpixels*0.7, screenYpixels*0.9 - baseRect(4)/2);
				
		%Screen('FillRect', window, rec, newRect);
		
		Screen('FillRect', window, rectColor, centeredRect);
		
		Screen('DrawTexture', window, imgTexture, [], [], 0);


		DrawFormattedText(window, 'Please rate the face using up and down arrow keys', 'center', screenYpixels * 0.02, 0);
		Screen('Flip', window);
		WaitSecs(0.07)
	end
	end_trial = false;
	
end
trial_mat

% Clear the screen
sca;







