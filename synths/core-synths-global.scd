/*

AUX BASED (GLOBAL)
CORE SYNTHDEFS FOR CLEAN
(REQUIRED: GlobalCleanEffects)

	Global synth defs: these synths run in each CleanAux and are only released when it is stopped
	when you change them, to update them, hit cmd-period (i.e. stop the synths on the server) once.
	they'll come back automatically

*/

(
{
	var numChannels = ~clean.numChannels;

	/*

	Routing and Analysis

	*/

	SynthDef("clean_monitor" ++ numChannels, { |dryBus, effectBus, outBus, gate = 1|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		//var signal = XFade2.ar(wetSignal, drySignal, dry * 2 - 1);
		var signal = wetSignal + drySignal;
		var post = if(SuperClean.postBadValues) { 2 } { 0 };

		signal = Select.ar(CheckBadValues.ar(signal, post: post) > 0, [signal, DC.ar(0)]);

		signal = Limiter.ar(signal);

		// or if you like it harsher
		//signal = tanh(signal);
		// or:
		//signal = distort(signal);

		CleanPause.ar(signal, graceTime:4);

		signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(outBus, signal)
	}, [\ir, \ir, \kr, \kr]).add;


	// RMS measurement, sending back to editor
	SynthDef("clean_rms" ++ numChannels, { |gate = 1, dryBus, effectBus, rmsReplyRate, rmsPeakLag, auxIndex|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		var signal = wetSignal + drySignal;

		CleanPause.ar(signal, graceTime:4);
		EnvGen.kr(Env.asr, gate, doneAction:2);

		SendPeakRMS.kr(signal, replyRate: rmsReplyRate, peakLag: rmsPeakLag, cmdName:"/rms", replyID: auxIndex)

	}, [\kr, \ir, \ir, \kr, \kr, \kr]).add;



	/*

	Effect synths

	Each must have at least: dryBus, effectBus, gate

	dryBus and effectBus have \ir as rates (they shouldn't change at runtime)

	*/



	if(\SwitchDelay.asClass.notNil) {

		SynthDef("clean_delay" ++ numChannels, { |dryBus, effectBus, gate = 1, delaytime, delayfeedback, delaySend = 1, delayAmp = 1, lock = 0, cps = 1|
			var signal;
			var input = In.ar(dryBus, numChannels);
			var maxdelaytime = 4;

			input = input * delaySend.lag(LFNoise1.kr(1).range(0.01, 0.02)); // regulate input

			delayfeedback = delayfeedback.max(0);
			delaytime = delaytime * if(lock, reciprocal(cps), 1);
			delaytime = delaytime.clip(0, maxdelaytime); // just to be sure
			// from sc3-plugins
			signal = \SwitchDelay.asClass.ar(input, 1, 1, delaytime, delayfeedback, maxdelaytime);

			DetectSilence.ar(signal, time:1, doneAction: 1);
			// doesn't work properly. We don't really know when it's not used anymore.
			// this would have to be an explicit signal from sclang

			signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
			signal = signal * delayAmp.lag(0.01);

			CleanPause.ar(signal, graceTime:4);

			Out.ar(effectBus, signal);

		}, [\ir, \ir]).add;
	} {
		"\n\n ---- SC3-Plugins not found. This is a problem."
		"Note that without the sc3plugins we'll be using a comb delay, which will not sound the same as SwitchDelay from the sc3 plugins".postln;

		SynthDef("clean_delay" ++ numChannels, { |dryBus, effectBus, gate = 1, delaytime, delayfeedback, delayAmp = 1, lock = 0, cps = 1|
			var signal = In.ar(dryBus, numChannels);
			var maxdelaytime = 4;
			var decayTime;

			delayfeedback = delayfeedback.clip(0, 0.99);
			delaytime = delaytime * if(lock, reciprocal(cps), 1);
			delaytime = delaytime.clip(0, maxdelaytime); // just to be sure
			decayTime = log2(-60.dbamp) / log2(delayfeedback) * delaytime;
			decayTime = decayTime.clip(0, 20);

			signal = CombL.ar(signal, maxdelaytime, delaytime.lag(1), decayTime);

			signal = LeakDC.ar(signal) * delayAmp.lag(0.01) * EnvGen.kr(Env.asr, gate, doneAction:2);

			CleanPause.ar(signal, graceTime:4);

			Out.ar(effectBus, signal);
		}, [\ir, \ir]).add;
	};


	// I think this reverb was created by Jost Muxfeld and James McCartney, I don't like it
	//

	SynthDef("clean_reverb" ++ numChannels, { |dryBus, effectBus, gate = 1, rin = 0, rev = 0.1, dry = 0|
		var in, snd, loop, depth;

		in = In.ar(dryBus, numChannels).asArray.sum;

		in = in * rin.lag(LFNoise1.kr(1).range(0.01, 0.02)); // regulate input

		4.do { in = AllpassN.ar(in, 0.03, { Rand(0.005, 0.02) }.dup(numChannels), 1) };

		depth = rev.lag(0.02).linexp(0, 1, 0.01, 0.98); // change depth between 0.1 and 0.98
		loop = LocalIn.ar(numChannels) * { depth + Rand(0, 0.05) }.dup(numChannels);
		loop = OnePole.ar(loop, 0.5);  // 0-1

		loop = AllpassN.ar(loop, 0.05, { Rand(0.01, 0.05) }.dup(numChannels), 2);

		loop = DelayN.ar(loop, 0.3, [0.19, 0.26] + { Rand(-0.003, 0.003) }.dup(2));
		loop = AllpassN.ar(loop, 0.05, { Rand(0.03, 0.15) }.dup(numChannels), 2);

		loop = loop + in;
		loop = LeakDC.ar(loop);

		LocalOut.ar(loop);

		snd = loop;
		snd = snd * (1 - dry).lag(LFNoise1.kr(1).range(0.01, 0.02));

		CleanPause.ar(snd, graceTime:4);

		snd = snd * EnvGen.kr(Env.asr, gate, doneAction:2);

		Out.ar(effectBus, snd);

	}, [\ir, \ir]).add;

	// GVerb with LPF actually, but dark sounds _way_ better so, there you have it
	SynthDef("clean_dark" ++ numChannels, {
	|dryBus, effectBus, gate = 1, in, out, roomsize=250, revtime=30, damping=0.5, inputbw=0.5, spread=15, drylevel=1, earlyreflevel=0.7, taillevel=0.5, darken=1000, dark=1|
    var sig;
    sig = In.ar(dryBus, numChannels).asArray.sum;
	sig = GVerb.ar(sig, roomsize, revtime, damping, inputbw, spread, drylevel, earlyreflevel, taillevel);
    sig = LPF.ar(sig, darken.clip(20, 20000));
	sig = sig * (1 - dark - 1);
	CleanPause.ar(sig, graceTime:4);
    Out.ar(effectBus, sig);
}, [\ir, \ir]).add;


	/*// The NHHall reverb
	SynthDef("clean_nhh" ++ numChannels, {
	|dryBus, effectBus, gate = 1, in, out, rt60=1, stereo=0.5, lowFreq=200, lowRatio=0.5, hiFreq=4000, hiRatio=0.5, earlyDiffusion=0.5, lateDiffusion=0.5, modRate=0.2, modDepth=0.3, nhh=1|
    var sig;
    sig = In.ar(dryBus, numChannels).asArray.sum;
	sig = NHHall.ar(in, rt60, stereo, lowFreq, lowRatio, hiFreq, hiRatio, earlyDiffusion, lateDiffusion, modRate, modDepth);
	sig = sig * (1 - nhh - 1);
	CleanPause.ar(sig, graceTime:4);
    Out.ar(effectBus, sig);
}, [\ir, \ir]).add;*/

	//"---- core synth defs loaded ----".postln;

}.value
);
