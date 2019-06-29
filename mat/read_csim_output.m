clearvars;

% read in simulation data
fname = "../hls/data/out.dat";
fp = fopen(fname);
data = fread(fp, 'float32');
fclose(fp);

% TODO: Have data file contain these parameters and parse out

% Simulation parameters, oversampled PFB parameters, and second stage FFT parameters
windows = 833;
M = 32;                  % Transform size (i.e., polyphase branches, Nfft_coarse)
D = 24;                  % Decimation rate (D < M)
P = 8;                   % Polyphase taps per branch

Nfft_coarse = M;         % Transform size for 1st stage PFB (number of channels from 1st stage)
Nfft_fine = 512;         % Transform size for 2nd stage FFT (number of channels formed per coarse 1st stage channel)

fs = 10e3;               % signal sampling rate (Hz)
fs_os = fs/D;            % Sample rate of each output of the oversampled PFB (Hz)

L_fine = D*Nfft_fine;           % total number of channels in the fine 'zoom' spectrum after discarding channels
                                % The critically sampled PFB would have M*Nfft_fine channels (or Nfft_coarse*Nfft_fine)
                                % note:
                                % fbins_fine = hscount * (2*M)
                                % and
                                % fbins_fine = (Nfft_fine-2*hsov)*M
                                % all of these identities
                                        
hsov = (M-D)*Nfft_fine/(2*M);     % half-sided overlap; Number of overlapped channels for two adjacent channels;
                                  % Also thought of as the number of discarded channels.
                                        
hs_count = D*Nfft_fine/(2*M);     % half-sided channel count; Number of channels preserved from bin center extending
                                  % to the edge of one channel

fine_channel_count = hs_count*2;  % number of fine channels remaning after discarding channels
                                  % note:
                                  % channel_count = Nfft_fine - 2*hsov
 
fbins_coarse = 0:M-1;                     % 1st stage coarse bins
faxis_coarse = fbins_coarse*fs/M;         % 1st stage coarse frequency axis

fshift_fine = -(Nfft_fine/2-hsov+1);
fbins_fine = (0:L_fine-1) + fshift_fine;  % 2nd stage fine bins
faxis_fine = fbins_fine*fs_os/Nfft_fine;  % 2nd stage fine frequency axis

% reformat data read in from file
X = reshape(data, [2, M*windows]);
X_cx = X(1,:) + 1j*X(2,:);
os_pfb_output = reshape(X_cx, [M, windows]);

% 2nd stage FFT for fine frequency channels
offset = P; % Wait for P output frames for valid output from first stage (filter wind up)
fine_output_tmp = fftshift(fft(os_pfb_output(:, offset:Nfft_fine+offset-1), Nfft_fine, 2), 2)/Nfft_fine;

% discard redundant channels from 1st stage oversampled PFB
fine_output = fine_output_tmp(:, hsov:end-hsov-1);

% produce full 2nd stage spectrum by concatenating the remaning channels
fine_output = reshape(fine_output.', [1, L_fine]);

% Plots
% Show spectrum for output of the first stage
figure(1);
subplot(121);
plot(faxis_coarse, 20*log10(abs(os_pfb_output(:,offset)))); grid on;
title('Snapshot of 1st Stage Output Spectrum'); xlabel('Frequency(Hz)'); ylabel('Power (arb. units dB)');
subplot(122);
plot(faxis_coarse, 20*log10(mean(abs(os_pfb_output(:,offset:end)),2))); grid on;
title('Average 1st Stage Output Spectrum'); xlabel('Frequency (Hz)');

% subplots for each fine section of a coarse pfb channel
figure(2);
for m = 1:M
    subplot(4,8,m);
    % map to correct oversampled bin numbers. Since we are oversampled and
    % using a filter with a wider passband we no longer have a linear
    % frequency axis and we need to overlap the bins/frequency between
    % adjacent channels.
    % This is because 
    % Note this also represnets the real world bin/frequency prior to
    % discarding the reduandant channels.
    subbins = ((m-1)*Nfft_fine:((m-1)*Nfft_fine+Nfft_fine-1)) - (Nfft_fine/2) - (m-1)*hsov*2;
    faxis_subband = subbins*fs_os/Nfft_fine;
    plot(faxis_subband, 20*log10(abs(fine_output_tmp(m,:)))); grid on;
    xlim([min(faxis_subband), max(faxis_subband)]); ylim([-60, 20]);
    title(['Coarse Channel ', int2str(m)]);
    if (m > 24)
        xlabel('Frequency (Hz)');
    end
    if ~mod(m-1,8)
        ylabel('Power');
    end
end

% plot 2nd stage output
figure(3);
plot(faxis_fine, 20*log10(abs(fine_output))); grid on; 
title('2nd Stage Fine Spectrum'); xlabel('Frequency (Hz)'); ylabel('Power (arb. units dB)');
xlim([min(faxis_fine), max(faxis_fine)]);
