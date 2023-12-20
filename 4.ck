60.0/132.0 => float secondsPerBeat;
secondsPerBeat::second => dur beat;

beat/2 => dur quantize;
quantize - (now % quantize) => now;

fun void Kick() {
    //creates kick with a sine wave through a pitch envelope and filtered noise
    SinOsc k => ADSR env => dac;
    Noise n => ADSR noiseEnv => ResonZ f => dac;
    Step s => ADSR pitchEnv => blackhole;
    
    env.set(1::ms, 120::ms, 0, 1::ms);

    noiseEnv.set(1::ms, 50::ms, 0, 1::ms);
    0.1 => n.gain;
    240 => f.freq;
    1 => f.Q;

    pitchEnv.set(1::ms, 160::ms, 0, 1::ms);
    1 => s.next;

    spork ~updatePitch(k, pitchEnv);

    for (int i; i < 16; i++) {
        playKick(k, env, n, noiseEnv, pitchEnv, 210, 0.45, beat);
    }
}

fun void playKick(SinOsc k, ADSR env, Noise n, ADSR noiseEnv, ADSR pitchEnv, float pitch, float gain, dur T) {
    pitch => k.freq;
    gain => k.gain;
    env.keyOn();
    noiseEnv.keyOn();
    pitchEnv.keyOn();
    T - 1::ms => now;
    pitchEnv.keyOff();
    env.keyOff();
    noiseEnv.keyOff();
    1::ms => now;
}

fun void updatePitch(SinOsc k, ADSR pitchEnv) {
  while (true) {
    k.freq() - pitchEnv.last()*0.05 => k.freq;
    1::samp => now;
  }
}
/*------------------------------------------------------------------------------------*/

fun void SubBass() {
  //creates sub bass with a sine wave
  SinOsc sb => ADSR env => dac;
  env.set(1::ms, 500::ms, 0, 300::ms);

    for (int i; i < 2; i++) {
      for (int j; j < 4; j++) {
        playSubBass(sb, env, 31, 0.02, beat);
      }
      for (int j; j < 4; j++) {
        playSubBass(sb, env, 34, 0.02, beat);
      }
    }
}

fun void playSubBass(SinOsc sb, ADSR env, float pitch, float gain, dur T) {
    Std.mtof(pitch) => sb.freq;
    gain => sb.gain;
    env.keyOn();
    T - 1::ms => now;
    env.keyOff();
    1::ms => now;
}
/*------------------------------------------------------------------------------------*/

fun void HiHat() {
  //creates a hihat with noise through a high Q filter
  Noise h => ADSR env => LPF lpf => HPF hpf => dac;
  env.set(1::ms, 45::ms, 0, 1::ms);
  5000 => hpf.freq;
  2 => lpf.Q;

  for (int i; i < 4; i++) {
    beat/2 => now;
    playHiHat(h, env, lpf, 0.25, 7000, beat/2);
    beat/2 => now;
    playHiHat(h, env, lpf, 0.25, 7000, beat/2 - beat/4 + 30::ms);
    playHiHat(h, env, lpf, 0.1, 6000, beat/4 - 30::ms);
    beat/2 => now;
    playHiHat(h, env, lpf, 0.25, 7000, beat/2);
    beat/2 => now;
    playHiHat(h, env, lpf, 0.25, 7000, beat/2);
  }

}

fun void playHiHat(Noise h, ADSR env, LPF lpf, float gain, float pitch, dur T) {
  pitch => lpf.freq;
  gain => h.gain;
  env.keyOn();
  T - 1::ms => now;
  env.keyOff();
  1::ms => now;
}
/*------------------------------------------------------------------------------------*/

fun void Snare() {
  //creates a snare with noise through a filter envelope
  Noise h => ADSR env => LPF lpf => HPF hpf => dac;
  Step s => ADSR filterEnv => blackhole;

  1 => s.next;

  env.set(1::ms, 35::ms, 0, 1::ms);

  filterEnv.set(1::ms, 25::ms, 0, 1::ms);
  300 => hpf.freq;
  1 => lpf.Q;


  spork ~updateFilter(1500, 500, lpf, filterEnv);

  for (int i; i < 8; i++) {
    beat => now;
    spork ~playSnare(h, env, filterEnv, 1.2, beat);
    beat => now;
  }

}

fun void updateFilter(float high, float low, LPF f, ADSR filterEnv) {
  while (true) {
    filterEnv.last() * (high - low) + low => f.freq; //update cutoff freq once envelope is triggered
    1::samp => now;
   }
}

fun void playSnare(Noise h, ADSR env, ADSR filterEnv, float gain, dur T) {
  Noise fuzz => ADSR fuzzEnv => ResonZ fuzzFilter => dac;
  fuzzEnv.set(1::ms, 40::ms, 0, 1::ms);
  gain/5 => fuzz.gain;
  2000 => fuzzFilter.freq;


  gain => h.gain;
  env.keyOn();
  fuzzEnv.keyOn();
  filterEnv.keyOn();
  T - 1::ms => now;
  env.keyOff();
  fuzzEnv.keyOff();
  filterEnv.keyOff();
  1::ms => now;
}
/*------------------------------------------------------------------------------------*/
while (true) {
  spork ~Kick();
  spork ~SubBass();
  spork ~HiHat();
  spork ~Snare();
  beat*16 => now;
}