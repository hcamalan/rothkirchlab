close all;
clear all;
sca;


%For finding image files
exemplar_fname = {'01F_', '07F_', '09F_', '17F_'};
emo_fname = {'HA', 'AN'};


%Encode randomized and counterbalanced trial matrix
reps = 1;
n_faces = length(exemplar_fname);
n_emos = length(emo_fname);
l_r = 2;
locs = 4;

n_trials = reps * locs * l_r * n_faces * n_emos; %4 locations for face, 2 for left/right appearance

trial_mat = zeros(n_trials, 5); %Column indices: 1: L/R; 2: Face location; 3: Participant response; 4: Face exemplar; 5:Emotion

%Not sure if the counterbalancing is correct
emo_ind = [1 2 1 2 1 2 1 2 1 2 1 2];
face_ind = [1 1 1 2 2 2 3 3 3 4 4 4];

for i = 1:n_faces * n_emos
	trial_mat(i:n_faces*n_emos:end, 4) = face_ind(i);
	trial_mat(i:n_faces*n_emos:end, 5) = emo_ind(i);
end


%L/R
trial_mat(1:end/2, 1) = 1;
trial_mat(:, 1) += 1;

%Face location & exemplar
for i = 1:4
	trial_mat(i:4:end, 2) = i;
end

trial_mat = trial_mat(randperm(n_trials), :);

%Right now we can't use this variable for a weird reason
one_deg = visangcalc(60, 1368, 30);

%All of these has to do with the screen object
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
%Screen('Preference', 'ConserveVRAM', 2);
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5);
%Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

%Necessary for rectangles
[xCenter, yCenter] = RectCenter(windowRect);
dist_from_center = [-10*one_deg 10*one_deg];
rect_pos = xCenter + dist_from_center;
base_rect = [0 0 one_deg*10 one_deg*10];


for i = 1:2
	%Final positions of rectangle corners
	rects(:, i) = CenterRectOnPointd(base_rect, rect_pos(i), yCenter);

end

%Necessary for fixation
fixCrossDimPix = 10;
xCoords = repmat([-fixCrossDimPix fixCrossDimPix 0 0], [2 1]);	
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
lineWidthPix = 4;
dist_from_c = repmat(transpose(dist_from_center), [1, 4]);
xCoords = xCoords - dist_from_c;
allCoords = [xCoords(1, :); yCoords; xCoords(2, :); yCoords];

% Key codes
escapeKey = KbName('ESCAPE');
upper_left = KbName('f'); %position 1
upper_right = KbName('j'); % position 2
lower_left = KbName('v'); % position 3
lower_right = KbName('n'); % position 4


%Mask variable
nmask = 100
masks = make_mondrian_masks(base_rect(3), base_rect(4), nmask, 1, 1);

%Ends experiment if it becomes true
end_experiment = false;

%Trials start here
for trial = 1:n_trials
	% Position the image
	img_LR_ind = mod(trial_mat(trial, 1), 2) + 1; % Switches the indices
	imgpos = trial_mat(trial, 2);

	img_cents = [rects(1, img_LR_ind) + rects(3, img_LR_ind), rects(2, img_LR_ind) + rects(4, img_LR_ind)] / 2; % X and Y averages, respectively
	switch imgpos
		case 1
			img_rect = [rects(1, img_LR_ind), rects(2, img_LR_ind), img_cents(1), img_cents(2)];
		case 2
			img_rect = [img_cents(1), rects(2, img_LR_ind), rects(3, img_LR_ind), img_cents(2)];
		case 3
			img_rect = [rects(1, img_LR_ind), img_cents(2), img_cents(1), rects(4, img_LR_ind)];
		case 4
			img_rect = [img_cents(1), img_cents(2), rects(3, img_LR_ind), rects(4, img_LR_ind)];
	end
	

	img_str = strcat('./faces/', exemplar_fname{trial_mat(trial, 4)}, emo_fname{trial_mat(trial, 5)}, '.bmp');
	img = imread(img_str);
	imgTexture = Screen('MakeTexture', window, img);

	rect_mat = ones(size(img)) * 0.5;
	rectTexture = Screen('MakeTexture', window, rect_mat);

	%Parameter for transparency
	alpha = 1;
	temp_alpha = alpha;

	%Boolean we use to finish the trial
	end_trial = false;

	tstart = GetSecs;
	tstart_abs = GetSecs;

	while end_trial == false
		
		tcurrent = GetSecs;
		if abs(tcurrent - tstart) > 0.1
			tstart = GetSecs;
			whichmask = floor(rand*nmask)+1;
			
			%Set transparency
			%alpha = max(0, alpha - 0.06);

			%If transparency doesn't change anymore, don't make any new textures			
			%if abs(temp_alpha - alpha) > 0.05
			%	rect_mat = SetImageAlpha(rect_mat, alpha);
			%	rectTexture = Screen('MakeTexture', window, rect_mat, 0, 4);
			%end

			maskTexture = Screen('MakeTexture', window, masks{whichmask}, 0, 4);

			%Draw mask and image
			Screen('DrawTexture', window, maskTexture, [], rects(:, trial_mat(trial, 1)), 0);	
			Screen('DrawTexture', window, imgTexture, [], img_rect, 0);
			%Screen('DrawTexture', window, rectTexture, [], img_rect, 0);

			% Draw rectangles and fixation
			Screen('DrawLines', window, allCoords(1:2, :),lineWidthPix, 1, [xCenter yCenter]);
			Screen('DrawLines', window, allCoords(3:end, :),lineWidthPix, 1, [xCenter yCenter]);
			Screen('FrameRect', window, 1, rects, lineWidthPix);
	
			%Flip
			Screen('DrawingFinished', window);
			Screen('Flip', window);
			
		end

		%Get key response, classify key response
		[keyIsDown,secs, keyCode] = KbCheck;
		if keyIsDown
			
			if keyCode(escapeKey)
				end_trial = true;
				end_experiment = true;			
				break;
				
			elseif keyCode(upper_left)
				trial_mat(trial, 3) = 1;
				end_trial = true;
			elseif keyCode(upper_right)
				trial_mat(trial, 3) = 2;
				end_trial = true;
			elseif keyCode(lower_left)
				trial_mat(trial, 3) = 3;
				end_trial = true;
			elseif keyCode(lower_right)
				trial_mat(trial, 3) = 4;
				end_trial = true;
			end
		end

		
	end
	
	%To end the experiment abruptly using ESC key
	if end_experiment == true
		break;
		%sca;
	end
	
	% Inter trial interval
	Screen('DrawLines', window, allCoords(1:2, :),lineWidthPix, 0.5, [xCenter yCenter]);
	Screen('DrawLines', window, allCoords(3:end, :),lineWidthPix, 0.5, [xCenter yCenter]);
	Screen('FrameRect', window, 0.5, rects, lineWidthPix);
	Screen('Flip', window);
	WaitSecs(2);
	%Save information in any case
	dlmwrite ('trial.csv', trial_mat)
end


%for matlab use
%save('trial.mat', trial_mat)
dlmwrite ('trial.csv', trial_mat)


% Clear the screen
sca;
clear all;
close all;
