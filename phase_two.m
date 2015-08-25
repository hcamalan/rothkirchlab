close all;
clear all;
sca;

#Randomized and counterbalanced trial matrix
%{
Column Indices are as follows:
	1 - Face exemplar number
	2 - Emotion number
	3 - Reward/Punishment/No reward
	4 - Rating
%}
%Parameters
reps = 1;
n_faces = 4
n_emos = 3
reward = 0.8

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
emo_ind = [1 1 1 1 2 2 2 2 3 3 3 3]
for i = 1:n_faces * n_emos
	trial_mat(i:n_faces*n_emos:end, 2) = emo_ind(i)
end


trial_mat = trial_mat(randperm(n_trials), :);


#Right now we can't use this variable for a weird reason
#one_deg = visangcalc(60, 1368, 30);
#10*one_deg

#All of these has to do with the screen object
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'SuppressAllWarnings', 1);
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5);
#Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);


exemplar_fname = {"01F_", "07F_", "09F_", "17F_"};
emo_fname = {"HA", "NE", "AN"};

#Trials start here
for trial = 1:n_trials
	
	img_str = strcat("./faces/", exemplar_fname{trial_mat(trial, 1)}, emo_fname{trial_mat(trial, 2)}, ".bmp");
	img = imread(img_str);
	imgTexture = Screen('MakeTexture', window, img);

	# Inter trial interval
	Screen('DrawTexture', window, imgTexture, [], [], 0);

	
	DrawFormattedText(window, strcat(int2str(trial_mat(trial, 3)*50), "c"), 'center', screenYpixels * 0.95, 0);
	Screen("Flip", window);
	WaitSecs(0.5);

	Screen("Flip", window)
	
	end_trial = false;
	rating = 0;
	while end_trial == false

		[keyIsDown,secs, keyCode] = KbCheck;
		
		if keyCode(KbName("LeftArrow"))
			end_trial = true;
		elseif keyCode(KbName("UpArrow"))
			rating = min(rating + 1, 10);
		elseif keyCode(KbName("DownArrow"))
			rating = max(rating - 1, 0);
		end
		#Doesn't recognize space character
		DrawFormattedText(window, strcat("Your rating is: ", int2str(rating)), 'center', screenYpixels * 0.5, 0);
		DrawFormattedText(window, "Please rate the face from 1 to 10", 'center', screenYpixels * 0.25, 0);
		Screen("Flip", window);
		WaitSecs(0.07)
	end
	trial_mat(trial,4) = rating;
	Screen("Flip", window);
	WaitSecs(0.2)
end
trial_mat
% Clear the screen
sca;







