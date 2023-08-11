(
s.waitForBoot({
		var win = Window.new("ube",Rect(100,500,width,height)).front;
		w=win;
	AppClock.sched(0,{
		w.view.background_(Color.new255(236,242,255));
		w.drawFunc = {
			var num=1;
			var x,availableHeight,h;
			windata.do{ arg v;
				if (v.notNil,{
					num=num+1;
				});
			};
			x=(w.bounds.width-(2*padding));
			availableHeight=((w.bounds.height-(padding*2))/num);
			h=(availableHeight-spacing);
			if (recording,{
				debounce=10;
			});
			if (lastWidth!=w.bounds.width,{
				debounce=10;
			});
			if (lastHeight!=w.bounds.height,{
				debounce=10;
			});
			if (lastNum!=num,{
				debounce=10;
			});
			lastNum=num;
			lastHeight=w.bounds.height;
			lastWidth=w.bounds.width;
			if (debounce==1,{
				var tapeid=nil;
				debounce=0;
				if (windata.size>0,{
					tapeid="tape"++windata[0][0].asInteger;
					tapeid=tapeid.asString;
				});
				if (tapeid.notNil,{
					tapeid="tape1";
					if (a.notNil,{
						a.close;
					});
					a = SoundFileView.new(w, Rect(padding,padding, x, h));
					bufs.at(tapeid).loadToFloatArray(0, -1, {|floatArray|
						AppClock.sched(0,{
							a.setData(floatArray*1.5,4096,0,1,bufs.at(tapeid).sampleRate);
							a.refresh;
						});
					});
					a.gridOn = false;
					a.timeCursorOn = false;
					a.drawsCenterLine  = false;
					a.drawsBoundingLines = false;
					a.peakColor=Color.new255(99,89,133,150);
					a.rmsColor=Color.new255(99,89,133,60);
					a.background_(Color.new255(236,242,255,0));
				});

			},{
				if (debounce>0,{
					debounce=debounce-1;
				});
			});
			windata.do{ arg v,j;
				var i=j+1;
				if (v.notNil,{
					var y=padding+(i*availableHeight);
					var posStart=v[1];
					var posEnd=v[2];
					var posWidth=(v[2]-v[1]);
					var pos=v[3];
					var volume=v[4];
					var pan=v[5];
					var volume01=volume.ampdb.linlin(-96,12,0,1)+0.001;
					var cc=Color.new255(99,89,133,255*volume01);
					// var cc=Color.new255(96,150,180,255*volume01);

					// draw waveform area
					Pen.color = cc;
					Pen.addRect(
						Rect.new(posStart*x+(padding),y,posWidth*x, h)
					);
					Pen.perform(\fill);

					// draw playhead
					Pen.color = Color.white(0.5,0.5);
					Pen.addRect(
						Rect(pos*x+(padding)-2, y, 4, h)
					);
					Pen.perform(\fill);

					// draw pan symbol
					Pen.color = cc;
					Pen.addRect(
						Rect(pan*x+(padding)-8,y,16,h)
					);
					Pen.perform(\fill);

				});
			}
		};
	});

	AppClock.sched(0,{
		if (w.notNil,{
			if (w.isClosed.not,{
				w.refresh;
			});
		});
		0.04
	});
});
)