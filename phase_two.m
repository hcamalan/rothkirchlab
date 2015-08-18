close all;
clear all;

#Randomized and counterbalanced trial matrix
reps = 1;
n_trials = reps * 2 * 5; #Happy/Angry, reward_no_reward

trial_mat = ones(n_trials, 2);
trial_mat(1:end/2, 1) = 0;
trial_mat(1:5:end, 2) = 0;
trial_mat = trial_mat(randperm(n_trials), :);
trial_mat


#No response by participant?
#I need the image files
#No fixations or mask?
#What is meant by counterbalanced?
