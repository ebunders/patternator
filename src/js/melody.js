// import Tone from 'tone/build/Tone.js';
var Tone = require('tone/build/Tone.js')
var $ = require('jquery')
// var _ = require('underscore')

var synth = new Tone.PolySynth(6, Tone.Synth, {
  'oscillator': {
    'type': 'square'
  },
  'envelope': {
    'attack': 0.0,
    'release': 0.0
  }
}).toMaster()

document.synth = synth

function playNote (note, duration) {
  var freq = note.frequencies
  var velo = note.velocity
  synth.triggerAttack(freq, undefined, velo)
  setTimeout(function () { endNote(freq) }, duration)
}

function endNote (freq) {
  synth.triggerRelease(freq)
}

function setWaveform (waveform) {
  synth.set('oscillator.type', waveform)
}

function updateEnvelope (field, value) {
  var o = {}
  o[field] = value
  synth.set('envelope', $.extend({}, synth.get('envelope'), o))
}

function curry1 (fun, arg1) {
  return function (arg2) { fun(arg1, arg2) }
}

// export {playNote};
module.exports = {
  'playNote': playNote,
  'setWaveform': setWaveform,
  'updateAttack': curry1(updateEnvelope, 'attack'),
  'updateRelease': curry1(updateEnvelope, 'release')}
