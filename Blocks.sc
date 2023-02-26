Blocks {

	var server;
	var bufs;
	var oscs;
	var <syns;
	var win;
	var <boxes;
	*new {
		arg argServer;
		^super.new.init(argServer);
	}

	init {
		arg argServer;

		boxes=List.new();
		server=argServer;

		// initialize variables
		bufs = Dictionary.new();
		syns = Dictionary.new();
		oscs = Dictionary.new();

		SynthDef("ducks",{
			arg freq=220,amp=0.0,attack=0.1,release=1,t_trig=0;
			var snd, bassfreq;
			var hz = freq;
			var note=hz.cpsmidi;
			freq = [note-LFNoise2.kr(1/4).range(0.05,0.1),note+LFNoise2.kr(1/4).range(0.05,0.1)].midicps;
			bassfreq = freq/2;
			snd = Pulse.ar(freq,SinOsc.kr([0.3,0.2]).range(0.3,0.7));
			snd = snd + Pulse.ar(freq*2.001,LFNoise1.ar(1/3).range(0.01,0.05),0.2);
			snd = snd + SinOsc.ar(bassfreq,0,1);
			snd = LeakDC.ar(snd);
			snd = snd.fold(-0.5,0.9);
			snd = LockhartWavefolder.ar(snd[0] * LFNoise1.kr(1/4).range(1,10), 4) + ((LockhartWavefolder.ar(snd[1] * LFNoise1.kr(1/4).range(1,10), 4)) * [-1,1]);
			snd = RLPF.ar(snd, LinExp.kr(LFNoise2.kr(1/4).range(0.01,1),0.01,1,200,4000),LFNoise2.kr(1/4).range(0.1,1));

			snd = AnalogVintageDistortion.ar(snd,0,1,0.1,0.1);
			snd = LeakDC.ar(snd);
			snd = snd.tanh * 0.8;
			snd = [LPF.ar(snd[0],
				LinExp.kr(LFNoise2.kr(1/4).range(0.01,1),0.01,1,2000,10000)),
			LPF.ar(snd[1],LinExp.kr(LFNoise2.kr(1/4).range(0.01,1),0.01,1,2000,10000))];

			snd = snd * SelectX.ar(MouseX.kr(),[DC.ar(1),SinOsc.ar(MouseX.kr(0.1,12)).range(0,1.5)]);
			snd=snd*amp/10;
			Out.ar(0,snd*EnvGen.ar(Env.perc(attack,release),t_trig)*amp);
		}).send(server);
		SynthDef("test",{
			arg freq=220,amp=0.0,attack=0.1,release=1,t_trig=0;
			var snd;
			snd = SinOsc.ar([freq-2,freq+2])/5;

			Out.ar(0,snd*EnvGen.ar(Env.perc(attack,release),t_trig)*amp);
		}).send(server);

		server.sync;
		syns.put("main",Synth.head(server,"test",[\amp,0]));
	}

	gui {
		arg height=800,width=800;
		var paramNames =["volume","attack","release"];
		var specs=[
			[0.0,1.0].asSpec,
			[0.0,2.0].asSpec,
			[0.0,3.0].asSpec,
		];
		var params = Dictionary.new();
		var defaultValues=[];
		var elements=[];
		var sliders = [];
		var palette = [
			Color.newHex("F5F5DC"),
			Color.newHex("B5D5C5"),
			Color.newHex("B08BBB"),
			Color.newHex("ECA869"),
			Color.newHex("579BB1"),
		];

		win=Window("bridges", Rect(200 , 450, width, height));
		win.view.decorator = FlowLayout(win.view.bounds);
		// Populate param dict
		paramNames.do{|pName,i|
			var spec=specs[i];

			// Slider
			var slider = Slider.new()
			.orientation_(\horizontal)
			.background_(Color.gray(0.8,0.1))
			.action_({|obj|
				var sliderVal = obj.value;
				var mappedVal = spec.map(sliderVal);
				valueBox.value = mappedVal;
				[pName,mappedVal].postln;
			});

			// Label
			var label = StaticText.new
			.string_(pName);

			// Value box
			var valueBox = NumberBox.new().background_(Color.gray(0.8,0.1));

			// Slider Layout
			var sliderLayout = HLayout([label, s: 1], [slider, s: 6], [valueBox, s:1]);

			sliders = sliders.add(slider);
			//			elements = elements.add(sliderLayout);
		};
		2.do({ arg i;
			var box = MultiSliderView.new()
			.action_({|obj|
				obj.value;
			})
			.background_(Color.rand)
			.readOnly_(false)
			.elasticMode_(1).gap_(0)
			.drawLines_(true)
			.showIndex_(true)
			.isFilled_(true)
			.background_(palette[i+1])
			.fillColor_(palette[0])
			.strokeColor_(palette[0])
			.size_(8);
			elements=elements.add([box,s:1]);
			boxes=boxes.add(box);
		});
		1.do({ arg i;
			var box = MultiSliderView.new()
			.action_({|obj|
				// [obj.index,obj.value].postln;
			})
			.background_(Color.rand)
			.readOnly_(true)
			.elasticMode_(1).gap_(0)
			.showIndex_(true)
			.isFilled_(true)
			.fillColor_(palette[0])
			.drawLines_(false)
			.strokeColor_(palette[0])
			.background_(palette[i+3])
			.size_(56);
			elements=elements.add([box,s:0.75]);
			boxes=boxes.add(box);
		});

		1.do({ arg i;
			var box = MultiSliderView.new()
			.readOnly_(false)
			.elasticMode_(1).gap_(0)
			.showIndex_(true)
			.isFilled_(true)
			.fillColor_(palette[0])
			.drawLines_(false)
			.strokeColor_(palette[0])
			.background_(palette[i+4])
			.size_(7);
			// speed amp attack release key probability reverb
			elements=elements.add([box,s:0.75]);
			boxes=boxes.add(box);
		});
		win.layout = VLayout(*elements);
		win.view.background_(palette[0]);
		win.front;

		// defaults
		sliders[0].valueAction = 0.5;
		sliders[1].valueAction = 0.1;
		sliders[2].valueAction = 1;
		defaultValues=Array.fill(boxes[3].value.size,{
			rrand(0,100)/100
		});
		defaultValues[0]=0.2;
		defaultValues[1]=0.5;
		defaultValues[4]=0.5;
		defaultValues[5]=1.0;
		boxes[3].valueAction = defaultValues;

		AppClock.play(Routine({
			var scaleType = Scale.dorian;
			var scale=[];
			var total=0;
			var lasts=[[],[]];
			1.wait;
			4.do({ arg i;
				scale=scale++(scaleType.degrees+(12*i)+36);
			});
			inf.do({ arg beat;
				var note=0;
				var val=0;
				var vals;
				var steps=[List.new(),List.new()];
				var waitTime=boxes[3].value[0].linlin(0,1,0.05,1);
				var amp=boxes[3].value[1];
				var attack=waitTime*boxes[3].value[2]+0.05;
				var release=waitTime*boxes[3].value[3]*10+0.05;
				var key=((boxes[3].value[4]-0.5)*24).asInteger;
				var probability=boxes[3].value[5];
				boxes[0].value.size.do({ arg i;
					2.do({ arg j;
						if (boxes[j].value[i]>0,{
							steps[j].add(i);
						});
					});
				});
				2.do({ arg i;
					if (steps[i].size>0,{
						boxes[i].index_(steps[i][beat.mod(steps[i].size)]);
					});
				});
				2.do({ arg i;
					if (i>0,{
						if (boxes[i].value[boxes[i].index]>0,{
							val = val + boxes[i].value[boxes[i].index]-0.5;
						});
					},{
						val = val + boxes[i].value[boxes[i].index];
					});
				});
				if (steps[0].size.asInteger>0,{
					var changed=false;
					2.do({ arg i;
						if (lasts[i]==boxes[i].value,{},{
							changed = true;
							lasts[i]=boxes[i].value;
						});
					});
					if (changed,{
						total = steps[0].size;
						if (steps[1].size>0,{
							total = total.lcm(steps[1].size);
						});
						vals=boxes[2].value;
						boxes[2].size.do({arg i;
							vals[i]=0;
						});
						total.do({arg j;
							var v = 0;
							2.do({ arg i;
								var k = j.mod(steps[i].size);
								if (steps[i].size>0,{
									if (i>0,{
										if (boxes[i].value[steps[i][k]]>0,{
											v = v + boxes[i].value[steps[i][k]]-0.5;
										});
									},{
										v = v + boxes[i].value[steps[i][k]];
									});

								});
							});
							vals[j] = v;
						});
						boxes[2].valueAction = vals;
						boxes[2].size(total);
					});
					boxes[2].index_(beat.mod(total));
					note=scale[(boxes[2].value[boxes[2].index]*scale.size).clip(0,scale.size-1)];
					note = note + key;
					if (rrand(0,100)/100<probability,{
						syns.at("main").postln;
						syns.at("main").set(
							\freq,note.midicps,
							\amp,amp,
							\attack,attack,
							\release,release,
							\t_trig,1,
						);
					});
				});
				waitTime.wait;
			})
		}));
	}

	refresh{
		win.refresh;
	}
	free {
		oscs.keysValuesDo({ arg k, val;
			val.free;
		});
		bufs.keysValuesDo({ arg k, val;
			val.free;
		});
		syns.keysValuesDo({ arg k, val;
			val.free;
		});
	}
}