//calculates the duration of each beat
60.0/132.0 => float secondsPerBeat;
secondsPerBeat::second => dur beat;

//quantizes to the grid
beat/2 => dur quantize;
quantize - (now % quantize) => now;

fun void PluckBass() {
  //creates arrays of oscilators, envelopes, and filters so that multiple can be played at once
  SqrOsc sqr[3] => ADSR env[3] => LPF f[3] => HPF hpf[3] => Gain busSend; //sends everything to the FX 'bus'
  Gain busReturn => dac;  //sends the return from the FX 'bus' to the dac
  //sends a step into an ADSR to the blackhole
  Step s => ADSR filterEnv => blackhole;
  1 => s.next; //set to 1 so ADSR values are only multiplied by 1
  filterEnv.set(1::ms, 50::ms, 0, 1::ms);

  //sets the values for each envelope and filter in their respective arrays
  for (int i; i < 3; i++) {
    env[i].set(1::ms, 500::ms, 0, 10::ms);
    50 => hpf[i].freq;
    spork ~updateFilter(4000, 50, f[i], filterEnv); //sporks function to update the filter of each oscilator
  }

  //sets the gain going into the FX 'bus' then sporks the function updating those FX
  0.15 => busSend.gain;
  spork ~busFX(busSend, busReturn);

  //plays the pattern indefinitely
  while(true) {
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, beat/4);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, beat/2);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, beat/2);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 43, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, beat/4);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, beat/2);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, (beat/4)*3);
    detunePlayPluckBass(sqr, env, filterEnv, 46, 1, beat/2);
  }

}

fun void playPluckBass(SqrOsc sqr, ADSR env, ADSR filterEnv, float pitch, float gain, dur T) {
  pitch => sqr.freq;
  gain => sqr.gain;

  env.keyOn();
  filterEnv.keyOn();
  T - 0.01::second => now;
  //triggers key off slightly before the end of the notes duration to prevent pops and clicks
  env.keyOff();
  filterEnv.keyOff();
  0.01::second => now;
}

fun void detunePlayPluckBass(SqrOsc sqr[], ADSR env[], ADSR filterEnv, float midiPitch, float gain, dur T) {
  //converts MIDI value into pitch when sporking the play function
  spork ~playPluckBass(sqr[0], env[0], filterEnv, Std.mtof(midiPitch), gain, T);
  //detunes note up and down with reduced gain, creating a unison effect
  spork ~playPluckBass(sqr[1], env[1], filterEnv, Std.mtof(midiPitch)-0.3, gain/4, T);
  spork ~playPluckBass(sqr[2], env[2], filterEnv, Std.mtof(midiPitch)+0.3, gain/4, T);
  T => now;
}

fun void updateFilter(float high, float low, LPF f, ADSR filterEnv) {
  //update cutoff freq at sample rate once finter envelope is triggered
  while (true) {
    filterEnv.last() * (high - low) + low => f.freq;
    1::samp => now;
   }
}

fun void busFX(Gain busSend, Gain busReturn) {
  //sends signal directly to the return with no FX for the first 8 bars
  busSend => busReturn;
  //while(true) {beat => now;}
  //COMMENT OUT EVERYTHING BELOW, THEN UNCOMMENT LINE ABOVE TO BYPASS FX INDEFINITELY

  for (int i; i < 8; i++) {
    beat*4 => now;
  }

  //sends signal to FX then triggers a for-loop that adjusts them gradually creating a sweep
  busSend =< busReturn;
  busSend => LPF lpf => HPF hpf => PRCRev r => busReturn;

  for (int i; i < 16*16; i++) {
    15000 - 58*i => lpf.freq;
    20 + 2*i => hpf.freq;
    0.001*i => r.mix;
    beat/4 => now;
  }
  //unchucks the send signal to the FX, then sends it directly to the return (bypassing the FX)
  busSend =< lpf;
  busSend => busReturn;
}

//triggers the main function indefinitely
spork~PluckBass();
while(true) {beat => now;}