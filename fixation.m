close all;
clear all;
sca;

# Order of the script

# Trials
#

%For finding image files
exemplar_fname = {"01F_", "07F_", "09F_", "17F_"};
emo_fname = {"HA", "AN"};


#Randomized and counterbalanced trial matrix
reps = 1;
n_faces = 4;
n_emos = 2;
l_r = 2;
locs = 4;

n_trials = reps * locs * l_r * n_faces * n_emos; #4 locations for face, 2 for left/right appearance

trial_mat = zeros(n_trials, 5); #1: L/R; 2: Face location; 3: Participant response; 4: Face exemplar; 5:Emotion

#Not sure if the counterbalancing is correct
emo_ind = [1 2 1 2 1 2 1 2 1 2 1 2];
face_ind = [1 1 1 2 2 2 3 3 3 4 4 4];
for i = 1:n_faces * n_emos
	trial_mat(i:n_faces*n_emos:end, 4) = face_ind(i);
	trial_mat(i:n_faces*n_emos:end, 5) = emo_ind(i);
end


#L/R
trial_mat(1:end/2, 1) = 1;
trial_mat(:, 1) +=1;

#Face location & exemplar
for i=1:4
	trial_mat(i:4:end, 2) = i;
end

trial_mat = trial_mat(randperm(n_trials), :);


# Screen object creation

#Right now we can't use this variable for a weird reason
one_deg = visangcalc(60, 1368, 30);

#All of these has to do with the screen object
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

#Necessary for rectangles
[xCenter, yCenter] = RectCenter(windowRect);

#one_deg
dist_from_center = [-480 480];
rect_pos = xCenter .+ dist_from_center;
base_rect = [0 0 480 480];

#masks = make_mondrian_masks(base_rect(3), base_rect(4), 1,1,1){1};
mask = make_mondrian_masks(base_rect(3), base_rect(4), 1,1,1){1};

for i = 1:2
	#Final positions of rectangle corners
	rects(:, i) = CenterRectOnPointd(base_rect, rect_pos(i), yCenter);

end

#Necessary for fixation
fixCrossDimPix = 10;
xCoords = repmat([-fixCrossDimPix fixCrossDimPix 0 0], [2 1]);	
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
lineWidthPix = 4;
dist_from_c = repmat(transpose(dist_from_center), [1, 4]);
xCoords = xCoords .- dist_from_c;
allCoords = [xCoords(1, :); yCoords; xCoords(2, :); yCoords];

# Key codes for linux using KbDemo
escapeKey = KbName("ESCAPE");
upper_left = KbName("f"); #position 1
upper_right = KbName("j"); # position 2
lower_left = KbName("v"); # position 3
lower_right = KbName("n"); # position 4


#Initial mask variable


#Trials start here
for trial = 1:n_trials
	#mask = ones(size(masks{1}));

	# Position and draw the image
	img_LR_ind = mod(trial_mat(trial, 1), 2) + 1; # Switches the indexes
	imgpos = trial_mat(trial, 2);

	img_cents = [rects(1, img_LR_ind) + rects(3, img_LR_ind), rects(2, img_LR_ind) + rects(4, img_LR_ind)] / 2; # X and Y averages, respectively
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
	

	img_str = strcat("./faces/", exemplar_fname{trial_mat(trial, 4)}, emo_fname{trial_mat(trial, 5)}, ".bmp");
	img = imread(img_str);
	imgTexture = Screen('MakeTexture', window, img);

	rect_mat = ones(size(img)) * 0.5;
	rectTexture = Screen('MakeTexture', window, rect_mat);

	alpha = 1;
	

	end_trial = false;
	tstart = GetSecs;
	tstart_abs = GetSecs;
	while end_trial == false
		
		[keyIsDown,secs, keyCode] = KbCheck;
		tcurrent = GetSecs;
		if abs(tcurrent - tstart) > 0.1
			tstart = GetSecs;
			mask = make_mondrian_masks(base_rect(3), base_rect(4), 1,1,1){1};
			#nmask = floor(rand*10)+1;
			#mask = masks{nmask};
			
			alpha = max(0, alpha - 0.06);
			rect_mat = SetImageAlpha(rect_mat, alpha);
			rectTexture = Screen('MakeTexture', window, rect_mat);

		end

		if abs(tcurrent - tstart_abs) > 15
			end_trial = true
		end

		maskTexture = Screen('MakeTexture', window, mask);
		Screen('DrawTexture', window, maskTexture, [], rects(:, trial_mat(trial, 1)), 0);
		
		Screen('DrawTexture', window, imgTexture, [], img_rect, 0);
		Screen('DrawTexture', window, rectTexture, [], img_rect, 0);
	
		# Draw rectangles and fixation
		Screen('DrawLines', window, allCoords(1:2, :),lineWidthPix, 1, [xCenter yCenter], 2);
		Screen('DrawLines', window, allCoords(3:end, :),lineWidthPix, 1, [xCenter yCenter], 2);
		Screen('FrameRect', window, 1, rects, lineWidthPix);
		
		#Flip
		Screen('Flip', window);
		if keyCode(escapeKey)
			end_trial = true;
			break;
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

	# Inter trial interval
	#clear mask, rect_mat, img

	Screen('DrawLines', window, allCoords(1:2, :),lineWidthPix, 0.5, [xCenter yCenter], 2);
	Screen('DrawLines', window, allCoords(3:end, :),lineWidthPix, 0.5, [xCenter yCenter], 2);
	Screen('FrameRect', window, 0.5, rects, lineWidthPix);
	Screen("Flip", window);
	WaitSecs(0.2);
end
#trial_mat
% Clear the screen
sca;
