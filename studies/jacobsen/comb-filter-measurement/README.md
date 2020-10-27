# Amplitude-phase measurement Octave GUI
This Octave GUI can be used to perform an amplitude-phase measurement exploiting destructive interference of sound waves at the eardrum. It is optimized for usage with the mobile hearing aid prototype.

The main objective of the psychoacoustic measurement is to find particular amplitude-phase values that could potentially lead to comb filtering when using the mobile hearing aid prototype. For more information on the theory behind comb filtering and its mitigation methods see [1]. The measurement was first used in this work.

## Adjustments to the prototype
There are a few adjustments that have to be made to the prototype prior to running the GUI and performing the measurement. The necessary files can be found on the SD-card image in the directory `home > pi > hearingaid-prototype`. The image version used in the pilot measurement was 1.2.

### White noise for masking
Comment out lines 66 and 68 in the file `commander.sh`:

```bash
thresholdnoise(){
  local STATUS="$1"
  case "$STATUS" in
    on)
#      jack_connect thresholdnoise:output_1 abhang:input_3
      jack_connect thresholdnoise:output_2 abhang:input_4
#      jack_connect thresholdnoise:output_1 abhang:input_2
      jack_connect thresholdnoise:output_2 abhang:input_1
    ;;
```

Add the following lines after line 78 in the file `start.sh`:

```bash
sleep 1
echo thresholdnoise on > commandqueue
```

In the file `thresholdnoise.c`, found under `tools > signals`, increase the amplitude from 0.01 to 0.04:

```c
#define AMPLITUDE 0.04
```

### FIR-filter
In the file `openMHA.cfg` edit line 19 as follows:

```
mha.transducers.mhachain.algos = [wavrec:record addsndfile:playback irrfilter:injector altplugs]
```

Edit lines 30 and 31:

```
mha.transducers.mhachain.injector.A = [1.0]
mha.transducers.mhachain.injector.B = [1.0]
```

## Usage
The provided file `comb_filter_measurement.m` is to be run with GNU Octave to ensure correct visualization and functionality. Beside the username, no adjustments need to be made to the GUI code to perform a measurement for the 9 center frequencies of the prototype.

The external playback of the individual pure tones should be realized with a loudspeaker and signal generator of your choice and is not directly adjusted through the GUI. The loudspeaker should be placed approximately 1 meter away from the left ear of the subject, directly facing towards it in the horizontal plane. Sound levels at the ear should be around 70 dB SPL.

Detailed instructions for the measurement setup and procedure can be found in [1].

### Strategy for finding points of total destructive interference
After the playback of a pure tone at a particular frequency and corresponding selection of that frequency in the GUI, the phase and amplitude can be adjusted through clicking in the axes window. There is some lag between clicking and the actual adjustment.

First, start with the phase keeping the amplitude constant. Move along the horizontal middle line and click through the several boxes to get a rough estimate of where a minimum in sound level is. Fine tune by still only adjusting the phase in search for the minimum.

After the phase adjustment, move alongside the vertical axis from the point of the determined minimum for adjusting the amplitude. Try to narrow in the spot where the pure tone is ideally canceled out completely. Small further adjustments for the phase might need to be necessary. Save your selection for the current frequency and repeat this process for all 9 center frequencies.

Make sure to not move head and body too much. Small turns of the head can strongly influence the perception of a minimum in sound level.

## References
[1] Jacobsen, Simon (2019) Mitigation of comb filter effects by in-situ amplitude-phase measurements and gain table manipulation with a mobile hearing aid prototype. Bachelor thesis, Carl von Ossietzky University Oldenburg.  https://oops.uni-oldenburg.de/id/eprint/4591
