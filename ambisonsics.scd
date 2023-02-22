// ------------------------------------------------------------
// boot server
(
s.waitForBoot({
	~checkMyServerOutputs = { arg server, decoder;
		server.serverRunning.if({
			(decoder.numOutputs > server.options.numOutputBusChannels).if({
				"Number of Server output bus channels is less than number required by Decoder!".warn;
				"Server Outputs: %\n".postf(server.options.numOutputBusChannels);
				"Decoder Outputs: %\n\n".postf(decoder.numOutputs);
				"Update number of Server outputs as illustrated here: ".post;
				"http://doc.sccode.org/Classes/ServerOptions.html#examples".postln;
			}, {
				"Server has an adequate number of output bus channels for use with this Decoder!".postln;
			})
		})
	};
	// ~decoder = FoaDecoderMatrix.newStereo((131/2).degrad, 0.5); // Cardioids at 131 deg
	// ~decoder = FoaDecoderKernel.newUHJ;                         // UHJ (kernel)
	~decoder = FoaDecoderKernel.newSpherical;                   // synthetic binaural (kernel)
	// ~decoder = FoaDecoderKernel.newCIPIC;                       // KEMAR binaural (kernel)

	~renderDecode = { arg in, decoder;
		var kind;
		var fl, bl, br, fr;
		var fc, lo;
		var sl, sr;
		var flu, blu, bru, fru;
		var fld, bld, brd, frd;
		var slu, sru, sld, srd;


		kind = decoder.kind;

		case
		{ decoder.numChannels == 2 }
		{
			// decode to stereo (or binaural)
			FoaDecode.ar(in, decoder)
		}
		{ kind == 'quad' }
		{
			// decode (to quad)
			#fl, bl, br, fr = FoaDecode.ar(in, decoder);

			// reorder output to match speaker arrangement
			[fl, fr, bl, br]
		}
		{ kind == '5.0' }
		{
			// decode (to 5.0)
			#fc, fl, bl, br, fr = FoaDecode.ar(in, decoder);
			lo = Silent.ar;

			// reorder output to match speaker arrangement
			[fl, fr, fc, lo, bl, br]
		}
		{ kind == 'panto' }
		{
			// decode (to hex)
			#fl, sl, bl, br, sr, fr = FoaDecode.ar(in, decoder);

			// reorder output to match speaker arrangement
			[fl, fr, sl, sr, bl, br]
		}
		{ kind == 'peri' }
		{
			// decode (to cube)
			#flu, blu, bru, fru, fld, bld, brd, frd = FoaDecode.ar(in, decoder);

			// reorder output to match speaker arrangement
			[flu, fru, blu, bru, fld, frd, bld, brd]
		}
		{ kind == 'diametric' }
		{
			// decode (to bi-rectangle)
			#fl, fr, slu, sru, br, bl, srd, sld = FoaDecode.ar(in, decoder);

			// reorder output to match speaker arrangement
			[fl, fr, bl, br, slu, sru, sld, srd]
		};
	};
});
)
