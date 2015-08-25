close all;
clear all;
sca;

# Order of the script

# Trials
#

%Creation of trial matrix, participant logging

%Uncomment after all is done
%participant_id = input("Enter initials: ", "s")

#Randomized and counterbalanced trial matrix
reps = 1;
n_trials = reps * 2 * 4; #4 locations for face, 2 for left/right appearance 
trial_mat = zeros(n_trials, 4); #1: L/R; 2: Face location; 3: Participant response; 4: Correct
#L/R
trial_mat(1:end/2, 1) = 1;
trial_mat(:, 1) +=1

#Face location
for i=1:4
	trial_mat(i:4:end, 2) = i;
end

trial_mat = trial_mat(randperm(n_trials), :);
loc_map = ["f", "j", "v", "n"]; #correspond to locations 1,2,3,4 above
 

# Screen object creation

#Right now we can't use this variable for a weird reason
one_deg = visangcalc(60, 1368, 30);
10*one_deg
#All of these has to do with the screen object
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'SuppressAllWarnings', 1);
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 1);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

#Necessary for rectangles
[xCenter, yCenter] = RectCenter(windowRect);
dist_from_center = [-400, 400];
rect_pos = xCenter .+ dist_from_center;
base_rect = [0 0 400 400];

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
escapeKey = KbName(10);
upper_left = KbName(42); #position 1
upper_right = KbName(45); # position 2
lower_left = KbName(56); # position 3
lower_right = KbName(58); # position 4

# Let's make a mock photo for now
mock_texture = rand(base_rect(3)/2);
imgTexture = Screen('MakeTexture', window, mock_texture);
	

#Trials start here
for trial = 1:n_trials


	
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
	
%{
	Screen('DrawTexture', window, imgTexture, [], img_rect, 0);

	# Make and draw mask
	mask = make_mondrian_masks(base_rect(3), base_rect(4), 1,1,1){1};
	maskTexture = Screen('MakeTexture', window, mask);
	Screen('DrawTexture', window, maskTexture, [], rects(:, trial_mat(trial, 1)), 0);

	# Draw rectangles and fixation
	Screen('DrawLines', window, allCoords(1:2, :),lineWidthPix, 0.5, [xCenter yCenter], 2);
	Screen('DrawLines', window, allCoords(3:end, :),lineWidthPix, 0.5, [xCenter yCenter], 2);
	Screen('FrameRect', window, 0.5, rects, lineWidthPix);
	#Flip
	Screen('Flip', window);
%}

	
	for i = 1:10
		Screen('DrawTexture', window, imgTexture, [], img_rect, 0);

		# Make and draw mask
		mask = make_mondrian_masks(base_rect(3), base_rect(4), 1,1,1){1};
		maskTexture = Screen('MakeTexture', window, mask);
		Screen('DrawTexture', window, maskTexture, [], rects(:, trial_mat(trial, 1)), 0);

		# Draw rectangles and fixation
		Screen('DrawLines', window, allCoords(1:2, :),lineWidthPix, 0.5, [xCenter yCenter], 2);
		Screen('DrawLines', window, allCoords(3:end, :),lineWidthPix, 0.5, [xCenter yCenter], 2);
		Screen('FrameRect', window, 0.5, rects, lineWidthPix);

		#Flip
		Screen('Flip', window);
		WaitSecs(0.05)
	end	
	KbStrokeWait
	#Not working
	%{
	resp = false;
	tstart = GetSecs;

	while true

		[keyIsDown,secs, keyCode] = KbCheck;
		switch keyCode
			case escapeKey
				break;
				break;
				ShowCursor;				
				sca;
			case upper_left
				trial_mat(trial, 3) = 1
				break;
			case upper_right
				trial_mat(trial, 3) = 2
				break;
			case lower_left
				trial_mat(trial, 3) = 3
				break;
			case lower_right
				trial_mat(trial, 3) = 4
				break;
		end		
		tend = GetSecs;
		if tend - tstart > 5
			break;
		end
	
	end
	%}
	# Inter trial interval

	Screen('DrawLines', window, allCoords(1:2, :),lineWidthPix, 0.5, [xCenter yCenter], 2);
	Screen('DrawLines', window, allCoords(3:end, :),lineWidthPix, 0.5, [xCenter yCenter], 2);
	Screen('FrameRect', window, 0.5, rects, lineWidthPix);
	Screen("Flip", window);
	WaitSecs(0.2);
end

#Record responses
trial_mat(:, 4) = abs(abs(trial_mat(:, 2) - trial_mat(:, 3)) - 1)

% Clear the screen
sca;
