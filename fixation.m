% Clear the workspace
close all;
clear all;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
#Screen('Preference', 'SuppressAllWarnings', 1);


screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens)

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 1);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);



fixCrossDimPix = 10;
dist_from_center = [-200, 200];
xC = [-fixCrossDimPix fixCrossDimPix 0 0];	
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];

% Set the line width for our fixation cross
lineWidthPix = 4;

base_rect = [0 0 200 200];
#dist_from_center = 200
rect_pos = xCenter .+ dist_from_center;




for i = 1:2
	xCoords = xC - dist_from_center(i);
	allCoords = [xCoords; yCoords];
	rects(:, i) = CenterRectOnPointd(base_rect, rect_pos(i), yCenter);


	Screen('DrawLines', window, allCoords,...
	    lineWidthPix, 0.5, [xCenter yCenter], 2);

end
Screen('FrameRect', window, 0.5, rects, 6);

% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;
