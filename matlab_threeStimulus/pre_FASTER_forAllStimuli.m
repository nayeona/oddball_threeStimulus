function [epochs_raw, epochs_distr_raw, epochs_std_raw, artifactIndices_FASTER, artifactIndices_FASTER_distr, artifactIndices_FASTER_std] = ...
    pre_FASTER_forAllStimuli(epochs_raw, epochs_distr_raw, epochs_std_raw, ...
    epochs_rawInput, epochs_distr_rawInput, epochs_std_rawInput, ...
    epochs_EOG, epochs_distr_EOG, epochs_std_EOG, ...
    epochs_ECG, epochs_distr_ECG, epochs_std_ECG, ...
    parameters, handles)
            
    [~, handles.flags] = init_DefaultSettings(); % use a subfunction        
    if handles.flags.saveDebugMATs == 1
        debugMatFileName = 'tempFASTER_allStimuli.mat';
        if nargin == 0
            load('debugPath.mat')
            load(fullfile(path.debugMATs, debugMatFileName))
            close all
        else
            if handles.flags.saveDebugMATs == 1
                path = handles.path;
                save('debugPath.mat', 'path')
                save(fullfile(path.debugMATs, debugMatFileName))
            end
        end 
    end

    % get the fixed artifact indices for the raw input
    debugOn = 1; % show debug plots
    
    disp('      .. Find artifacts (Fixed EEG/EOG, Moving Average, Step)')
    
        % TARGET
        fprintf('       : TARGET')
        [NaN_indices_EEG, NaN_indices_EOG, NaN_indices_moving, NaN_indices_step, fixedIndices] = ...
            pre_artifactFASTER_fixedThresholds_ERPLAB(epochs_rawInput, epochs_EOG, epochs_ECG, debugOn, handles.parameters, handles);    

        % DISTRACTER
        fprintf('\n'); fprintf('       : DISTRACTER')
        [NaN_indices_EEG_distr, NaN_indices_EOG_distr, NaN_indices_moving_distr, NaN_indices_step_distr, fixedIndices_distr] = ...
            pre_artifactFASTER_fixedThresholds_ERPLAB(epochs_distr_rawInput, epochs_distr_EOG, epochs_distr_ECG, debugOn, handles.parameters, handles);
        
        % STANDARD
        fprintf('\n'); fprintf('       : STANDARD')
        [NaN_indices_EEG_std, NaN_indices_EOG_std, NaN_indices_moving_std, NaN_indices_step_std, fixedIndices_std] = ...
            pre_artifactFASTER_fixedThresholds_ERPLAB(epochs_std_rawInput, epochs_std_EOG, epochs_std_ECG, debugOn, handles.parameters, handles);

    % concatenate
    epochs_concan_raw = pre_concatenateEpochs(epochs_raw, handles.parameters, handles);
    epochs_concan_distr_raw = pre_concatenateEpochs(epochs_distr_raw, handles.parameters, handles);
    epochs_concan_std_raw = pre_concatenateEpochs(epochs_std_raw, handles.parameters, handles);

    % FASTER (3rd party) used with a wrapper funtion
    disp('        .. FASTER algorithm')
    [epochs_concan_FASTER, artifactIndices_FASTER] = pre_artifactFASTER_wrapper(epochs_concan_raw, fixedIndices,...
        NaN_indices_EEG, NaN_indices_EOG, NaN_indices_moving, NaN_indices_step, epochs_rawInput, handles.parameters, 'target', handles);
    
    [epochs_concan_FASTER_distr, artifactIndices_FASTER_distr] = pre_artifactFASTER_wrapper(epochs_concan_distr_raw, fixedIndices_distr,...
        NaN_indices_EEG_distr, NaN_indices_EOG_distr, NaN_indices_moving_distr, NaN_indices_step_distr, epochs_distr_rawInput, handles.parameters, 'distracter', handles);            
    
    [epochs_concan_FASTER_std, artifactIndices_FASTER_std] = pre_artifactFASTER_wrapper(epochs_concan_std_raw, fixedIndices_std,...
        NaN_indices_EEG_std, NaN_indices_EOG_std, NaN_indices_moving_std, NaN_indices_step_std, epochs_std_rawInput, handles.parameters, 'standard', handles);

    % deconcatenate back
    epochs_deconcan_FASTER = pre_deconcatenateEpochs(epochs_concan_FASTER, handles.parameters, handles);
    epochs_deconcan_FASTER_distr = pre_deconcatenateEpochs(epochs_concan_FASTER_distr, handles.parameters, handles);
    epochs_deconcan_FASTER_std = pre_deconcatenateEpochs(epochs_concan_FASTER_std, handles.parameters, handles);

    % convert the artifacted epochs to NaN vectors, and assign to 
    % different variable names so that the denoising goes
    % okay and you can debug the FASTER step easily if you need
    %{
    epochs_raw = pre_convertEpochs_to_NanVectors(epochs_deconcan_FASTER, artifactIndices_FASTER);
    epochs_distr_raw = pre_convertEpochs_to_NanVectors(epochs_deconcan_FASTER_distr, artifactIndices_FASTER_distr);
    epochs_std_raw = pre_convertEpochs_to_NanVectors(epochs_deconcan_FASTER_std, artifactIndices_FASTER_std);
    %}

    % rename to match to upcoming steps
    epochs_raw = epochs_deconcan_FASTER;
    epochs_distr_raw = epochs_deconcan_FASTER_distr;
    epochs_std_raw = epochs_deconcan_FASTER_std;
