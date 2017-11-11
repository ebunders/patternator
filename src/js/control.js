var $ = require('jquery')
require('jquery-knob')
var _ = require('underscore')
// https://www.npmjs.com/package/jquery-knob

console.log('Module control loading...')
console.log('test: ' + JSON.stringify($('.control').get()))
var elements = $('.control')
var ids = _.chain(elements)
  .map(function (el) { return {'id': $($(el).attr('id'))} })
console.log('ids:' + ids)

function createButton (minval, maxval, step, id, callback) {
  $('#' + id).dial({
    'min': minval,
    'max': maxval,
    'step': step,
    'width': 70,
    'height': 80,
    'change': curryCallback(id, callback) })
}

function curryCallback (id, callback) {
  return function (value) {
    callback(id, value)
  }
}

function initKnob (knobModel, callback) {
  createButton(knobModel.minValue, knobModel.maxValue, 0.01, knobModel.id, callback)
}

module.exports = {
  'createButton': createButton,
  'initKnob': initKnob

}
