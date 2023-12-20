60.0/132.0 => float secondsPerBeat;
secondsPerBeat::second => dur beat;

beat/2 => dur quantize;
quantize - (now % quantize) => now;


fun void openHat() {
    //reads in a wav file containing a open hat sample
    SndBuf buf => ADSR env => Gain mix => NRev r => dac;
    me.dir() + "OpenHat.wav" => buf.read;
    
    0.1 => mix.gain;
    0.01 => r.mix;
    env.set(1::ms, 400::ms, 0, 1::ms);
    
    for (int i; i < 16; i++) {
        beat/4 + 30::ms => now;
        //plays open hats with randomized lengths and gains
        //the first hat doesn't play each time since it is multiplied by a randmoized value of either 0 or 1
        playOpenHat(buf, env, Math.random2(50, 200)::ms, Math.random2f(0.4, 0.8)*Math.random2(0,1), beat/4 - 30::ms);
        playOpenHat(buf, env, Math.random2(300, 800)::ms, 1, beat/2);
    }
}

fun void playOpenHat(SndBuf buf, ADSR env, dur decay, float gain, dur T) {
    //sets buffer position towards the beginning of the sample to restart it
    200 => buf.pos;
    gain => buf.gain;
    decay => env.decayTime;

    env.keyOn();
    T => now;
}

while (true) {
    spork ~openHat();
    beat*16 => now;
}
