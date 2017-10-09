// pull in desired CSS/SASS files
require( './styles/main.scss' );
snd = require('../js/sound.js');

// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ) );
console.log("app:", app);

app.ports.playNote.subscribe(function(freq){
  snd.playNote(freq, 200);
});
