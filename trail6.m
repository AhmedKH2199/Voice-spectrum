function VoiceSpectrumAnalyzer 
    % Create the main figure window and components
    fig = figure('Name', 'Voice Spectrum Analyzer', 'NumberTitle', 'off', 'Position', [200, 200, 900, 600], 'Color', [0.95, 0.95, 0.95]);
    startButton = uicontrol('Style', 'pushbutton', 'String', 'Start Recording', 'Position', [20, 20, 120, 30], 'Callback', @startRecording, 'BackgroundColor', [0.1, 0.7, 0.1], 'ForegroundColor', 'white');
    stopButton = uicontrol('Style', 'pushbutton', 'String', 'Stop Recording', 'Position', [160, 20, 120, 30], 'Callback', @stopRecording, 'BackgroundColor', [0.9, 0.1, 0.1], 'ForegroundColor', 'white');
    timeEdit = uicontrol('Style', 'edit', 'String', '5', 'Position', [300, 20, 60, 30], 'Callback', @updateMaxTime);
    uicontrol('Style', 'text', 'String', 'S', 'Position', [360, 20, 30, 15], 'HorizontalAlignment', 'left', 'BackgroundColor', [0.95, 0.95, 0.95]);
    frequencyEdit = uicontrol('Style', 'edit', 'String', '1500', 'Position', [390, 20, 60, 30], 'Callback', @updateFrequency);
    timeScaleSlider = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 10, 'Value', 1, 'SliderStep', [0.1 0.1],...
        'Position', [470, 20, 200, 20], 'Callback', @updateScales);
    verticalScaleSlider = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 10, 'Value', 1, 'SliderStep', [0.1 0.1],...
        'Position', [690, 20, 200, 20], 'Callback', @updateScales);

    % Create axes for displaying the graphs
    timeAx = subplot(2, 2, 1);
    amplitudeAx = subplot(2, 2, 2);
    frequencyAx = subplot(2, 2, 4);
    energyAx = subplot(2, 2, 3);

    % Customize appearance
    set(fig, 'DefaultAxesColor', [0.8, 0.8, 0.8]);
    set([timeAx, amplitudeAx, frequencyAx, energyAx], 'Box', 'on', 'GridColor', [0.7, 0.7, 0.7]);

    % Initialize recording variables
    recording = false;
    Fs = str2double(get(frequencyEdit, 'String'));
    maxTime = str2double(get(timeEdit, 'String'));

    % Initialize audio recorder
    recorder = audiorecorder(Fs, 16, 1);

    % Store the original axis limits
    originalXLim = get(timeAx, 'XLim');
    originalYLim = get(timeAx, 'YLim');

    % Set titles at the beginning
    set(timeAx, 'XLim', [0 maxTime]);
    set(timeAx, 'YLim', [-1 1]);
    title(timeAx, 'Time Domain', 'Color', [0.1, 0.1, 0.1]);

    set(amplitudeAx, 'XLim', [0 Fs/2]);
    set(amplitudeAx, 'YLim', [0 1]);
    title(amplitudeAx, 'Amplitude Spectrum', 'Color', [0.1, 0.1, 0.1]);

    set(frequencyAx,'XLim', [0 Fs/2]);
    set(frequencyAx, 'YLim', [-pi pi]);
    title(frequencyAx, 'Frequency Spectrum', 'Color', [0.1, 0.1, 0.1]);

    set(energyAx, 'XLim', [0 Fs/2]);
    set(energyAx, 'YLim', [0 1]);
    title(energyAx, 'Frequency with Energy', 'Color', [0.1, 0.1, 0.1]);

    % Callback function for the start button
    function startRecording(~, ~)
        if ~recording
            % Start recording
            recording = true;
            set(startButton, 'String', 'Recording...');
            set(stopButton, 'Enable', 'on');
            set(timeEdit, 'Enable', 'off');
            set(frequencyEdit, 'Enable', 'off');
            record(recorder, maxTime);

            % Update the stored original axis limits
            originalXLim = get(timeAx, 'XLim');
            originalYLim = get(timeAx, 'YLim');
        end
    end

    % Callback function for the stop button
    function stopRecording(~, ~)
        if recording
            % Stop recording
            recording = false;
            set(stopButton, 'Enable', 'off');
            set(startButton, 'String', 'Start Recording');
            set(timeEdit, 'Enable', 'on');
            set(frequencyEdit, 'Enable', 'on');
            stop(recorder);
            audioData = getaudiodata(recorder);

            % Perform FFT
            L = length(audioData);
            Y = abs(fft(audioData));
            f = Fs*(0:(L/2))/L;

            % Plot time domain
            t = (0:L-1)/Fs;
            plot(timeAx, t, audioData, 'LineWidth', 1.5, 'Color', [0.1, 0.4, 0.7]);
            title(timeAx, 'Time Domain', 'Color', [0.1, 0.1, 0.1]);
            xlabel(timeAx, 'Time (s)', 'Color', [0.1, 0.1, 0.1]);
            ylabel(timeAx, 'Amplitude', 'Color', [0.1, 0.1, 0.1]);
            set(timeAx, 'XLim', [0 max(t)*get(timeScaleSlider, 'Value')]);
            set(timeAx, 'YLim', [-1 1]*get(verticalScaleSlider, 'Value'));
            grid(timeAx, 'on');

            % Plot amplitude spectrum
            plot(amplitudeAx, f, Y(1:L/2+1), 'LineWidth', 1.5, 'Color', [0.1, 0.4, 0.7]);
            title(amplitudeAx, 'Amplitude Spectrum', 'Color', [0.1, 0.1, 0.1]);
            xlabel(amplitudeAx, 'Frequency (Hz)', 'Color', [0.1, 0.1, 0.1]);
            ylabel(amplitudeAx, 'Magnitude', 'Color', [0.1, 0.1, 0.1]);
            set(amplitudeAx, 'XLim', [0 Fs/2]);
            set(amplitudeAx, 'YLim', [0 max(Y)*get(verticalScaleSlider, 'Value')]);
            grid(amplitudeAx, 'on');

            % Plot frequency spectrum
            phase = angle(fft(audioData));
            plot(frequencyAx, f, phase(1:L/2+1), 'LineWidth', 1.5, 'Color', [0.1, 0.4, 0.7]);
            title(frequencyAx, 'Frequency Spectrum', 'Color', [0.1, 0.1, 0.1]);
            xlabel(frequencyAx, 'Frequency (Hz)', 'Color', [0.1, 0.1, 0.1]);
            ylabel(frequencyAx, 'Phase', 'Color', [0.1, 0.1, 0.1]);
            set(frequencyAx,'XLim', [0 Fs/2]);
            set(frequencyAx, 'YLim', [-pi pi]*get(verticalScaleSlider, 'Value'));
            grid(frequencyAx, 'on');

            % Plot frequency with energy
            energy = Y(1:L/2+1).^2;
            plot(energyAx, f, energy, 'LineWidth', 1.5, 'Color', [0.1, 0.4, 0.7]);
            title(energyAx, 'Frequency with Energy', 'Color', [0.1, 0.1, 0.1]);
            xlabel(energyAx, 'Frequency (Hz)', 'Color', [0.1, 0.1, 0.1]);
            ylabel(energyAx, 'Energy', 'Color', [0.1, 0.1, 0.1]);
            set(energyAx, 'XLim', [0 Fs/2]);
            set(energyAx, 'YLim', [0 max(energy)*get(verticalScaleSlider, 'Value')]);
            grid(energyAx, 'on');
        end
    end

    % Callback function for updating the maximum recording time
    function updateMaxTime(~, ~)
        maxTime = str2double(get(timeEdit, 'String'));
        % Update the title of the time domain graph
        title(timeAx, 'Time Domain', 'Color', [0.1, 0.1, 0.1]);
    end

    % Callback function for updating the recording frequency
    function updateFrequency(~, ~)
        Fs = str2double(get(frequencyEdit, 'String'));
        recorder = audiorecorder(Fs, 16, 1);
    end

    % Callback function for updating the scales
    function updateScales(~, ~)
        % Get the current values of both sliders
        timeScale = get(timeScaleSlider, 'Value');
        verticalScale = get(verticalScaleSlider, 'Value');

        % Update the scales of all axes
        updateScale(timeAx, timeScale, verticalScale);
        updateScale(amplitudeAx, timeScale, verticalScale);
        updateScale(frequencyAx, timeScale, verticalScale);
        updateScale(energyAx, timeScale, verticalScale);
    end

    % Helper function to update the scales of an axis
    function updateScale(ax, timeScale, verticalScale)
        xlim(ax, originalXLim * timeScale);
        ylim(ax, originalYLim * verticalScale);
    end
end
