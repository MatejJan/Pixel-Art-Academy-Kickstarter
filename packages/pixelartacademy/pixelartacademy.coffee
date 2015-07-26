AE = Artificial.Everywhere
AM = Artificial.Mirage

class PixelArtAcademy extends Artificial.Base.App
  constructor: ->
    super

    recording = true

    if recording
      @display = new Artificial.Mirage.Display @,
        safeAreaWidth: 240
        safeAreaHeight: 180
        minScale: 2
        minAspectRatio: 16/9
        maxAspectRatio: 16/9
        maxClientWidth: 1280
        maxClientHeight: 720

    else
      @display = new Artificial.Mirage.Display @,
        safeAreaWidth: 240
        safeAreaHeight: 180
        minScale: 2
        minAspectRatio: 2/3

    @components.addComponent @display

    #@landingPage = new PixelArtAcademy.LandingPage @
    #@components.addComponent @landingPage

    @pixelScaling = new PixelArtAcademy.PixelScaling @
    @components.addComponent @pixelScaling

  fontSize: ->
    # 62.5% brings us to 1em = 10px, so we scale all fonts set to their pixel perfect sizes with this.
    62.5 * @display.scale()
