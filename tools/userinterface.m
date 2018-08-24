function userinterface()

  [status, VERSION] = system('cd "$HOME/hearingaid-prototype" && git describe --abbrev=4');

  if status ~= 0
    VERSION = 'unknown';
  end

  if exist('../fittings/individual/status.mat','file');
    individualization = load('../fittings/individual/status.mat')
    freqs = individualization.freqs;
    thresholds_left = individualization.thresholds_left;
    thresholds_right = individualization.thresholds_right;
    fitting(freqs, thresholds_left, thresholds_right, 'initial');
  else
    freqs = [];
    thresholds_left = [];
    thresholds_right = [];
  end
  
  text2speech(sprintf('This is hearing aid prototype version %s!',VERSION));

  while true
    switch gamepad_event()
      case 'A pressed'
        if ~isempty(freqs)
          fitting(freqs, thresholds_left, thresholds_right, 'offset');
        else
          defaultfitting('A');
        end
        
      case 'B pressed'
        if ~isempty(freqs)
          fitting(freqs, thresholds_left, thresholds_right, 'marginfactor');
        else
          defaultfitting('B');
        end
        
      case 'X pressed'
        if ~isempty(freqs)
          fitting(freqs, thresholds_left, thresholds_right, 'rolloff');
        else
          defaultfitting('X');
        end
        
      case 'Y pressed'
        text2speech("Recording 10 seconds");
        record('10');
        
      case 'START pressed'
        validanswer = 0;
        while validanswer == 0
          text2speech "Power off! A) Confirm, B) Cancel.";        
          switch gamepad_event();
            case 'A pressed'
              validanswer = 1;
              text2speech "Confirmed!";
              pause(2);        
              system "sudo poweroff";
            case 'B pressed'
              validanswer = 1;
              text2speech "Cancelled!";        
          end
        end
      
      case 'SELECT pressed'
        text2speech "Mute!";
        mhacontrol "mha.transducers.mhachain.altplugs.select = (none)";
        
      case 'VERTICAL max'
        text2speech "Amplification on!";
        mhacontrol "mha.transducers.mhachain.altplugs.select = dynamiccompression";
        
      case 'VERTICAL min'
        text2speech "Amplification off!";
        mhacontrol "mha.transducers.mhachain.altplugs.select = identity";
        
      case 'HORIZONTAL max'
        text2speech "Noise on!";
        thresholdnoise "on"; 
        
      case 'HORIZONTAL min'
        text2speech "Noise off!";
        thresholdnoise "off"; 
        
      case 'RT pressed'
        text2speech "Measure feedback!";
        pause(1);
        feedback "3";

      case 'LT pressed'
        while true
          text2speech "Individualization menu: A) Fitting, X) Reset, Y) Test sound, B) Return.";    
          switch gamepad_event()
            case 'A pressed'
              while ~strcmp(gamepad_event(),'START pressed')
                text2speech "Measure hearing thresholds: A) Tone, X) No tone, B) Abort. Press Start button!";
              end  
              mhacontrol "mha.transducers.mhachain.altplugs.select = identitiy";
              freqs = [500 1000 2000 4000];
              thresholds_left = measure_thresholds(freqs, 'l')
              thresholds_right = measure_thresholds(freqs, 'r')
              mhacontrol "mha.transducers.mhachain.altplugs.select = dynamiccompression";
              if any(isnan(thresholds_left)) || any(isnan(thresholds_right))
                text2speech "Fitting failed!"
                freqs = [];
              else
                mkdir('../fittings/individual');
                save('../fittings/individual/status.mat','freqs','thresholds_left','thresholds_right');
                fitting(freqs, thresholds_left, thresholds_right, 'initial');
                while ~strcmp(gamepad_event(),'START pressed')
                  text2speech(['Your thresholds on the left are: ',sprintf('%.0f ',thresholds_left),', and your thresholds on the left are: ',sprintf('%.0f ',thresholds_right),'. Press Start button!']);
                end
              end
            case 'X pressed'
              validanswer = 0;
              while validanswer == 0
                text2speech "Reset individualization! A) Confirm, B) Cancel.";        
                switch gamepad_event();
                  case 'A pressed'
                    validanswer = 1;
                    text2speech "Confirmed!";
                    pause(2);        
                    unlink('../fittings/individual/status.mat');
                    freqs = [];
                    thresholds_left = [];
                    thresholds_right = [];
                    defaultfitting('A');
                  case 'B pressed'
                    validanswer = 1;
                    text2speech "Cancelled!";
                    pause(1);
                end
              end
            case 'B pressed'
              text2speech "Main menu!";
              break
            case 'Y pressed'
              while ~strcmp(gamepad_event(),'START pressed')
                text2speech "Caution: Will start test sound. Press Start button!";
              end
              filename = '../recordings/testsound.wav';
              playwavfile(filename, 'b', 'MHA', 0);
          end
        end     
      case ''
    end
  end
end

function defaultfitting(button)
  % Look for individual gaintables and fall back to default gaintables 
  gaintablefile = dir(['../fittings/default/' button '_*.cfg']);
  if ~isempty(gaintablefile)
    [~, dateidx] = sort(gaintablefile.datenum);
    gaintablefile = gaintablefile(dateidx(end)).name;
    descriptionidx = strfind(gaintablefile,'_');
    description = strrep(gaintablefile(1+descriptionidx:end-4),'-',' ');
    text2speech(description);
    mhacontrol(['mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc?read:fittings/default/' gaintablefile]);
  end
end

function fitting(freqs, thresholds_left, thresholds_right, action)
  persistent state;
  
  offsets = [-10 0 10];
  marginfactors = [0 0.33 0.66];
  rolloffs = 1+[1/8 1/4 1/2];
  
  switch action
    case 'offset'
      state.offset = state.offset + 1;
      if state.offset > length(offsets)
        state.offset = 1;
      end
    case 'marginfactor'
      state.marginfactor = state.marginfactor + 1;
      if state.marginfactor > length(marginfactors)
        state.marginfactor = 1;
      end
    case 'rolloff'
      state.rolloff = state.rolloff + 1;
      if state.rolloff > length(rolloffs)
        state.rolloff = 1;
      end  
    case 'initial'
      state.offset = 2;
      state.marginfactor = 2;
      state.rolloff = 2;
  end
  offset = offsets(state.offset)
  marginfactor = marginfactors(state.marginfactor)
  rolloff = rolloffs(state.rolloff)
  [gt_data, gt_freqs, gt_levels] = prescription_minimalistic(freqs, thresholds_left, thresholds_right, offset, marginfactor, rolloff);
  writegaintable('/dev/shm/tmp_gaintable.cfg', gt_data);
  mhacontrol(['mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc?read:/dev/shm/tmp_gaintable.cfg']);
end

function text2speech(message)
  system(['echo text2speech "',message,'" > ~/hearingaid-prototype/commandqueue']);
end

function mhacontrol(command)
  system(['echo mhacontrol "',command,'" > ~/hearingaid-prototype/commandqueue']);
end

function mhaplay(filename, mode, level, loop)
  system(['echo mhaplay "',filename,'" "',mode,'" "',level,'" "',loop,'" > ~/hearingaid-prototype/commandqueue']);
end

function thresholdnoise(status)
  system(['echo thresholdnoise "',status,'" > ~/hearingaid-prototype/commandqueue']);
end

function feedback(duration)
  system(['echo feedback "',duration,'" > ~/hearingaid-prototype/commandqueue']);
end

function record(duration)
  system(['echo record "',duration,'" > ~/hearingaid-prototype/commandqueue']);
end
