# Patternator


A very simple sequencer

##Functional
[X] grid: 16 x 12
[X] kolom 1, 5, 9 & 13 ander kleurtje
[X] cellen aanklikbaar
[X] run! (highlight row)
[X] controls: stop/start & rewind Icons with http://fontawesome.io/
[X] controls: bpm instellen
[ ] muziek (instrument)
[ ] volume: drie stappen (accent)  
[ ] meerdere patterns
[ ] drum of melodie pattern
[ ] song arranger
[ ] instrument (voice) editor
[ ] different time signatures (1/4, 1/8, triplet versions)

##Technical
[X] use elm Matrix as a model:  http://package.elm-lang.org/packages/jreut/elm-grid/latest/Grid
[X] Nice clean transformation from data grid to view grid.

https://tonejs.github.io/


Questions:
It seems that 'subscriptions' is called after each event. This means that the
timer is reset after each event. This becomes apparent when you rapidly press
controls like bpm up.
I tried to restrict the return of the time subscription to the update event for
the tick, but it turns out that if you do not return the time subscription in
consequence of another update, the timer stops.
