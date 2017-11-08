// pull in desired CSS/SASS files
require('./styles/main.scss')
var melody = require('../js/melody.js')
var control = require('../js/control.js')

// inject bundled Elm app into div#main
var Elm = require('../elm/Main')
var app = Elm.Main.embed(document.getElementById('main'))

app.ports.playNote.subscribe(function (note) {
  melody.playNote(note, 200)
})

app.ports.melodyWaveform.subscribe(function (waveform) {
  melody.melodyWaveform(waveform)
})

app.ports.melodyInitKnob.subscribe(function (knobModel) {
  control.initKnob(knobModel, function (id, value) {
    app.ports.melodyUpdateKnob.send(
      {'id': id, 'value': Math.floor(value)})
  })
})
