// import Tone from 'tone/build/Tone.js';
var Tone = require('tone/build/Tone.js');

var synth = new Tone.PolySynth(6, Tone.Synth, {
	"oscillator" : {
		"partials" : [0, 2, 3, 4],
	}
}).toMaster();


function playNote (freq, duration){
  synth.triggerAttack(freq);
  setTimeout(function(){endNote(freq);}, duration);
}

function endNote(freq){
  synth.triggerRelease(freq);
}

// export {playNote};
module.exports = {'playNote': playNote};
