// an example of using the sampler, looks for samples in a folder called mmd
(
Pdef(0,
	Pseed(Pn(999,1),
		Psync(
			Pbind(*[
				type: \cln,
				snd: \mmd,
				num: Pwhite(0,23),
				dur: Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
				rel: Pstutter(Pwhite(1,8),Pseq([1/16,1/17,1/18,1/19,1/20,1/21,1/22,1/8,2],inf))*Pexprand(0.1,10.0),
				amp: Pexprand(1.0,8.0),
				pan: Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
				lpf: Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
				spd: Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
				shp: Pwhite(0.0,1.0).trace,
				dla: 0.001,
				dlf: 0.94,
				dlt: 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
				rin: Pwrand([0,0.05],[9,1].normalizeSum,inf),
				rev: 0.97,
				dry: Pstutter(Pwhite(1,9),Pwrand([0.25,1],[3,1].normalizeSum,inf)),
				hpf: 40,
			]),1,15,
		)
	)
).play(quant:1);
);

// an example using fmx which is the built in four operator FM synthesizer
(
Pdef(0,
	Pseed(4,
		Pbind(*[
			type: \cln,
			snd: \fmx,
			rps: Pexprand(9,99),
			hr1: Pstutter(Pkey(\rps)-Pwhite(0,7),Pshuf((1..4),inf)),
			hr2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
			hr3: Pstutter(Pkey(\rps)-Pwhite(0,7),Pshuf((1..4),inf)),
			hr4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
			fdb: Pexprand(0.0001,100.0),
			mi2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			mi3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			mi4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			amp: Pexprand(0.25,0.75),
			en1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pexprand(0.0001,0.555)),
			en2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pexprand(0.2,0.666)),
			en3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pexprand(0.3,0.777)),
			en4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pkey(\en3)*Pexprand(0.4,0.888)),
			cu1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			dur: Pstutter(Pkey(\rps)+Pwhite(2,9),2/Pbrown(5,19,Pwhite(1,3),inf)),
			legato: Pkey(\dur)*Pexprand(16,64),
			freq: (Pstutter(Pexprand(4,32),10*Pexprand(1,5).round)
				*Pstutter(Pexprand(1,64),Pexprand(1,5)).round
				*Pstutter(Pkey(\rps),Pexprand(1,7).round)),
			dark: Pseg(Pexprand(0.25,1.0),Pexprand(8.0,64.0),\welch,inf),
			pan: Pbrown(0.0,1.0,Pstutter(Pwhite(1,3),Pwhite(0.01,0.1))).trace,
			atk: Pexprand(0.01,4.0),
			hld: Pkey(\dur)*2,
			rel: Pkey(\dur)*2,
			crv: 5,
			sustain: Pexprand(2.5,5.0),
		])
	)
).play(quant:1);
);

// an example using add which is the built in additive synthesizer
(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \add,
		amp: Pseg(Pexprand(0.4,0.7),Pexprand(0.4,4.0),\exp, inf),
		freq: Pfunc{
			var x = 40 * (1..7).choose * rrand(1,250).geom(1,30/29);
			x.reject{|i| i > 20000 }
		}.trace,
		dur: Pstutter(Pexprand(5,11),Pexprand(1,3).round/Pexprand(5,15).round),
		ada: Pexprand(0.00000000000000000000000000000000000000000000001,10.1),
		adr: Pkey(\dur)+(Pexprand(0.000001,10.0)),
		hpf: Pseg(Pexprand(40,4000),Pexprand(0.001,10.0),\exp, inf),
		adc: Pexprand(-8.0,-0.0001),
		slw: Pexprand(0.00001,10.0),
		pan: Pseg(Pwhite(0.1,0.9),Pwhite(1.0,10.0),\exp,inf),
		legato: Pexprand(0.25,1.25),
		sustain: Pexprand(0.25,1.25),
		stretch: Pseg(Pexprand(0.75,1.25),Pexprand(0.5,8.0),\exp, inf),
	])
).play(quant: 1);
)

// an example using sin, saw and sqr which are the built in basic waveform synthesizers
(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: Pxrand([\sin,\saw,\sqr,\rest],inf),
		dur: 1/Pstutter(Pwhite(5,11),Pwhite(5,11),inf),
		sustain: Pstutter(Pwhite(5,11),Pwhite(3.0,9.0),inf),
		atk: Pstutter(Pwhite(5,11),Pexprand(0.001,1.0),inf),
		hld: Pstutter(Pwhite(5,11),Pwhite(3.0,5.0),inf),
		rel: Pstutter(Pwhite(5,11),Pwhite(5.0,11.0),inf),
		crv: -8,
		num: Pstutter(Pwhite(5,11),Pxrand((-24,Pstutter(Pwhite(1,100),Prand([-9,-10],inf))..24),inf)),
		amp: Pseg(Pexprand(0.4,0.8),Pexprand(0.25,4.0),\exp,inf),
		pan: Pwhite(0.0,1.0),
		wid: Pwhite(0.0,1.0),
		iph: Pexprand(0.0001,1.0),
		lpf: Pexprand(20,20000),
		stretch: Pseg([7,1/6,7],16,\exp,inf).trace,
		])
).play(quant: 1);
)

// an example using drm which is a built in drum synthesizer
(
Pdef(0,
	Pbind(*[
		type: Pwrand([\cln,\rest],[6,1].normalizeSum,inf),
		snd: \drm,
		dur: 1/Pwrand([4.75,9.5],[3,8].normalizeSum,inf),
		tun: Pstutter(Pexprand(1,8),Pexprand(0.0001,0.25)).trace,
		fdb: Pexprand(0.00001,2000.0),
		dst: Pwhite(0.0,1.0),
		shp: Pwhite(0.0,1.0),
		tri: Pwhite(0.0,1.0),
		amp: Pexprand(0.5,2.0),
		sustain: Pexprand(0.1,2.0),
		rel: Pexprand(Pkey(\dur)/(4/3),Pkey(\dur)*64),
		crv: Pwhite(-8.0,-0.00001),
		pan: Pseq([0.5,0.75,1.0,0.75,0.5,0.25,0.0,0.25],inf),
		lpf: 20000-Pexprand(2000,20000),
		legato: Pwrand([Pkey(\dur)*1.5,Pkey(\dur)*16],[1,2].normalizeSum,inf),
	])
).play(quant:1);
)

( // an example using kps which is a Karplus-Strong physical modeling of a vibrating string
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \kps,
		amp: Pexprand(0.5,1.0),
		freq: 32*Prand([1,2,4,8,16],inf)*(1,3..11),
		dur: 1/Pstutter(Pwhite(5,11),Pwhite(5,11)),
		sustain: Pexprand(0.5,4.0),
		hpf: Pexprand(20,20000),
		lpf: (20000-Pexprand(20,20000)).trace,
		pan: Pwhite(0.0,1.0),
		])
).play(quant:1);
)

( // an example using hat which is a tunable noise source and a filter
Pdef(0,
	Pbind(*[
		type: Pwrand([\cln,\rest],[12,1].normalizeSum,inf),
		snd: \hat,
        amp: Pwrand([0.75,1.5],[12,1].normalizeSum,inf),
        sustain: Pwrand([1/11,2],[27,1].normalizeSum,inf),
        dur: 1/Pwrand([8,4],[12,1].normalizeSum,inf),
        bnd: (3-Pexprand(1.0,3.0)-1),
        num: Pwrand([-2,4],[12,1].normalizeSum,inf),
        dst: Pwrand([0,1],[12,1].normalizeSum,inf),
        shp: Pseg([0.0,0.8,0.0],Pexprand(4.0,12),\sine,inf),
		tri: Pseg([0.0,0.0,9.0],Pexprand(4.0,12),\sine,inf),
        lpf: Pseg([20000,400,20000],Pexprand(4.0,18),\sine,inf),
        pan: Pseg([0.5,0,1,0.5],Pexprand(4.0,12),\sine,inf),
        dla: Pseg([0.0,1/20,0.0],Pexprand(8.0,36),\sine,inf),
        dlf: 0.94,
        dlt: (2/Pstutter(Pn(Pgeom(1,2,3),inf),Pn(Pgeom(1,2,11),inf))).trace,
        stretch: 0.7,
    ])
).play(quant:1);
)