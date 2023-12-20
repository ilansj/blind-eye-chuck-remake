60.0/132.0 => float secondsPerBeat;
secondsPerBeat::second => dur beat;

beat/2 => dur quantize;
quantize - (now % quantize) => now;

fun void Melody() {
  SqrOsc sqr => ADSR env => LPF f => NRev r => Gain busSend;
  Gain busReturn => dac;
  Step s => ADSR pitchEnv => blackhole;
  pitchEnv.set(1::ms, 300::ms, 0, 1::ms);
  1 => s.next;

  env.set(1::ms, 80::ms, 0.3, 500::ms);
  0.09 => r.mix;
  500 => f.freq;

  0.25 => busSend.gain;
  spork ~busFX(busSend, busReturn);

  //sporks the function that creats the dive effect on each note
  spork ~updatePitch(sqr, pitchEnv);

  while (true) {
    playMelody(sqr, env, pitchEnv, 63, 0.5, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 63, 0.5, (beat/4)*5);
    playMelody(sqr, env, pitchEnv, 70, 1, beat);
    playMelody(sqr, env, pitchEnv, 74, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 70, 1, beat/2);
    playMelody(sqr, env, pitchEnv, 69, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 69, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 69, 1, beat/2);
    playMelody(sqr, env, pitchEnv, 67, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 67, 1, beat/2);
    playMelody(sqr, env, pitchEnv, 74, 1, beat/4);
    playMelody(sqr, env, pitchEnv, 67, 1, beat/2);
    playMelody(sqr, env, pitchEnv, 69, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 70, 1, beat);
    playMelody(sqr, env, pitchEnv, 70, 1, beat);
    playMelody(sqr, env, pitchEnv, 74, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 65, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 65, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 65, 1, (beat/4)*3);
    playMelody(sqr, env, pitchEnv, 65, 0.5, beat/4);
    playMelody(sqr, env, pitchEnv, 63, 0.5, beat/4);
    playMelody(sqr, env, pitchEnv, 75, 1, beat/2);
    playMelody(sqr, env, pitchEnv, 63, 0.5, beat/4);
    playMelody(sqr, env, pitchEnv, 74, 1, (beat/4)*3);
  }
}

fun void playMelody(SqrOsc sqr, ADSR env, ADSR pitchEnv, float pitch, float gain, dur T) {
  Std.mtof(pitch) => sqr.freq;
  gain => sqr.gain;
  env.keyOn();
  pitchEnv.keyOn();
  T - 1::ms => now;
  env.keyOff();
  pitchEnv.keyOff();
  1::ms => now;
}

fun void updatePitch(SqrOsc sqr, ADSR pitchEnv) {
  //updates pitch at sample rate when pitch envelope is triggered
  while (true) {
    sqr.freq() - pitchEnv.last()*0.001 => sqr.freq;
    1::samp => now;
  }
}

fun void busFX(Gain busSend, Gain busReturn) {
  busSend => busReturn;
  while(true) {beat => now;}
  //COMMENT OUT EVERYTHING BELOW, THEN UNCOMMENT LINE ABOVE TO BYPASS FX INDEFINITELY

  // for (int i; i < 4; i++) {
  //   beat*4 => now;
  // }

  // busSend =< busReturn;
  // busSend => LPF lpf => HPF hpf => PRCRev r => busReturn;

  // for (int i; i < 16*12; i++) {
  // //multipliers calculated to create desired sweeps
  //   5000 - 10*i => lpf.freq;
  //   30 + 2*i => hpf.freq;
  //   0.005*i => r.mix;
  //   busSend.gain() - 0.000015*i => busSend.gain;
  //   beat/4 => now;
  // }
}

spork ~Melody();
while(true) {beat => now;}
