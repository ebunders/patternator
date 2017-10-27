// import Tone from 'tone/build/Tone.js';
var Tone = require('tone/build/Tone.js');

var synth = new Tone.PolySynth(6, Tone.Synth, {
	"oscillator" : {
		"partials" : [0, 2, 3, 4],
	}
}).toMaster();

document.synt = synth


function playNote (note, duration){
	console.log(JSON.stringify(note))
	var freq = note.frequencies;
	var velo = note.velocity;
	console.log("playing notes: " + freq + " with velocity " + velo)
  synth.triggerAttack(freq, undefined, velo);
  setTimeout(function(){endNote(freq);}, duration);
}

function endNote(freq){
  synth.triggerRelease(freq);
}

// export {playNote};
module.exports = {'playNote': playNote};
