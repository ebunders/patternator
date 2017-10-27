// import Tone from 'tone/build/Tone.js';
var Tone = require('tone/build/Tone.js');

var synth = new Tone.PolySynth(6, Tone.Synth, {
	"oscillator" : {
		"partials" : [0, 2, 3, 4],
	}
}).toMaster();

document.synth = synth


function playNote (note, duration){
	var freq = note.frequencies;
	var velo = note.velocity;
  synth.triggerAttack(freq, undefined, velo);
  setTimeout(function(){endNote(freq);}, duration);
}

function endNote(freq){
  synth.triggerRelease(freq);
}

// export {playNote};
module.exports = {'playNote': playNote};
