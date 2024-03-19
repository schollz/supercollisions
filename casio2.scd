(
{

		arg freq=220, amp=0.5,gate=1;
		var y,z;
		var freqBase=freq;
		var freqRes=freq*1.5;
		var sr=SampleRate.ir;
	    var samplesPeriod = sr / freqBase;
	    var samplesPeriodRes = sr / freqRes;
		var baseFreqCounter=Phasor.ar(0,1,0,samplesPeriod);
		var resFreqCounter=Phasor.ar(baseFreqCounter<1,1,0,samplesPeriod);
		var sineWaveReadout=((2*pi*resFreqCounter/(samplesPeriodRes))+(1.5*pi)).sin+1;
		var invertedBaseFreq=(samplesPeriod-baseFreqCounter)/samplesPeriod;
	[baseFreqCounter,resFreqCounter,sineWaveReadout,invertedBaseFreq,sineWaveReadout*invertedBaseFreq-1]
}.plot(1.2/220)
)