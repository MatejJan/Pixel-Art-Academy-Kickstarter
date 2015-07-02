Template.body.onCreated ->
  @pixelArtAcademy = new PixelArtAcademy()

Template.body.onRendered ->
  @pixelArtAcademy.run()

Template.body.onDestroyed ->
  @pixelArtAcademy.endRun()

Template.body.helpers
  pixelArtAcademy: ->
    Template.instance().pixelArtAcademy
