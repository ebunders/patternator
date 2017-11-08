# Patternator

A very simple pattern based sequencer. This is mainly an Elm learning project, but the goal is to have three channels:
* base (monophonic)
* melody (polyphonic)
* drum

Each channel has 9 patterns to choose from (easy copying will be supported). The instruments will have some controls, like:
* filter settings
* attack-decay
* effects?

When all this is done, and I'm still in the mood, we could start thinking about a song builder, and perhaps some automation.

The audio engine to back all this goodness is [Tone.js](https://tonejs.github.io/)

## How to run?
After cloning the repo:
```
npm install
elm package install
npm start
```

## How to run the unit tests?
First you have to install elm test (if you don't have it yet)
```
sudo npm install -g elm-test
```
Then you can just run
```elm test```
at the project root.

Feature implementation list:

## Functional
- [x] grid: 16 x 12
- [x] columns 1, 5, 9 & 13 different color
- [x] clickable cells
- [x] run! (highlight row)
- [x] controls: stop/start & rewind Icons with http://fontawesome.io/
- [x] controls: set the bmp
- [x] selected cells are creating sound
- [x] volume: three steps (accent)
- [ ] keyboard support (space- play/stop, rewind)
- [ ] controls: stutter: loop on note while pressed, continue at the 'would have been' point after release (so the beat is not broken)
- [ ] multiple patterns with switcher, switchover at the start of the next loop
- [ ] three channels: drum + bass + chords
- [ ] channel instrument (voice) editor with https://github.com/aterrien/jQuery-Kontrol ()
- [ ] different time signatures (1/4, 1/8, triplet versions)
- [ ] swing
- [ ] glide, join notes
- [ ] song arranger (svg?)

## Technical
- [x] use elm Matrix as a model:  http://package.elm-lang.org/packages/jreut/elm-grid/latest/Grid
- [x] Nice clean transformation from data grid to view grid.
