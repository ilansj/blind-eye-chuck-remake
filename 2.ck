60.0/132.0 => float secondsPerBeat;
secondsPerBeat::second => dur beat;

beat/2 => dur quantize;
quantize - (now % quantize) => now;

fun void Pluck(int lr) {
  SqrOsc sqr => ADSR env => LPF f => NRev r => Gain busSend;
  SinOsc sin => ADSR sinEnv => busSend;
  Gain busReturn => Pan2 p => dac;

  Step s => ADSR filterEnv => blackhole;
  1 => s.next;
  filterEnv.set(1::ms, 30::ms, 0, 1::ms);

  env.set(1::ms, 80::ms, 0, 1::ms);
  0.003 => r.mix;
  sinEnv.set(1::ms, 300::ms, 0, 1::ms);

  spork ~updateFilter(8000, 500, f, filterEnv);

  0.2 => busSend.gain;
  spork ~busFX(busSend, busReturn);

  //plays the right or left pattern based on the parameter input
  //this way the oscillators and envelopes don't need to be created again in a separate function
  if (lr == 1) {
    while(true) {
      spork ~playLeft(sqr, sin, env, sinEnv, filterEnv, p);
      beat*16 => now;
    }
  } else if (lr == 2) {
    while(true) {
      spork ~playRight(sqr, sin, env, sinEnv, filterEnv, p);;
      beat*16 => now;
    }
  }
}

fun void playPluck(SqrOsc sqr, SinOsc sin, ADSR env, ADSR sinEnv, ADSR filterEnv, Pan2 p, float pitch, float pan, float gain, dur T) {
  //sets pitch, gain and pan of oscillators
  Std.mtof(pitch) => sqr.freq;
  gain/2 => sqr.gain;

  Std.mtof(pitch) => sin.freq;
  gain => sin.gain;
  pan => p.pan;

  env.keyOn();
  sinEnv.keyOn();
  filterEnv.keyOn();
  T - 0.001::second => now ;
  env.keyOff();
  sinEnv.keyOff();
  filterEnv.keyOff();
  0.001::second => now ;
}

fun void updateFilter(float high, float low, LPF f, ADSR filterEnv) {
  while (true) {
    filterEnv.last() * (high - low) + low => f.freq; //update cutoff freq once envelope is triggered
    1::samp => now;
   }
}

fun void playLeft(SqrOsc sqr, SinOsc sin, ADSR env, ADSR sinEnv, ADSR filterEnv, Pan2 p) {
  (beat/4)*3 => now; //rest at beginning of pattern
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, -0.5, 1, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, -0.5, 0.8, beat/2/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, -0.5, 0.8, beat/2/3);  
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, -0.5, 0.8, beat/2/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, -0.5, 0.8, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, -0.5, 0.8, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, -0.5, 0.8, (beat/4)*5);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, -0.5, 0.8, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/2);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/2);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/2);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/4);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/4);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/4);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, -0.5, 1, beat/2);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 1, (beat/4)*5);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, (beat/2)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 57, -0.5, 0.7, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 57, -0.5, 0.7, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 53, -0.5, 0.7, (beat/2)*3);
}

fun void playRight(SqrOsc sqr, SinOsc sin, ADSR env, ADSR sinEnv, ADSR filterEnv, Pan2 p) {
  beat/4 => now;  //rest at beginning of pattern
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, 0.5, 0.7, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, 0.5, 0.7, (beat/2)/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, 0.5, 0.7, (beat/2)/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, 0.5, 0.7, (beat/2)/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 58, 0.5, 0.7, (beat/4)*25);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 57, 0.5, 1, beat/2);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 60, 0.5, 1, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 60, 0.5, 1, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 60, 0.5, 1, beat);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 60, 0.5, 1, beat/2);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 60, 0.5, 1, beat/4);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 60, 0.5, 1, beat/4);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 60, 0.5, 1, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 65, 0.5, 1, (beat/4)*3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 65, 0.5, 1, beat/4);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 65, 0.5, 1, beat/16);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 65, 0.5, 1, (beat/16)*7);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 65, 0.5, 1, beat/4);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 63, 0.5, 1, beat/2);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 63, 0.5, 1, beat/8);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 63, 0.5, 0.7, beat/16);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 63, 0.5, 0.7, beat/16);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 63, 0.5, 0.7, beat/2/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 63, 0.5, 0.7, beat/2/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 63, 0.5, 0.7, beat/2/3);
  playPluck(sqr, sin, env, sinEnv, filterEnv, p, 62, 0.5, 1, beat/2);
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

  // for (int i; i < 16*16; i++) {
  //   15000 - 58*i => lpf.freq;
  //   20 + 2*i => hpf.freq;
  //   0.001*i => r.mix;
  //   beat/4 => now;
  // }
}

//triggers left and right patterns simultaneosly and indefinitely
spork ~Pluck(1);
spork ~Pluck(2);
while(true) {beat => now;}