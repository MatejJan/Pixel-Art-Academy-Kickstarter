AE = Artificial.Everywhere
AM = Artificial.Mirage

class PixelArtAcademy extends Artificial.Base.App
  constructor: ->
    super

    recording = false

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

    @components.add @display

    @landingPage = new PixelArtAcademy.LandingPage @
    @pressPage = new PixelArtAcademy.PressPage @

    #@pixelScaling = new PixelArtAcademy.PixelScaling @
    #@components.addComponent @pixelScaling

    app = @

    Router.route '/',
      onStop: ->
        console.log "Leaving landing page"
        app.components.remove app.landingPage

      action: ->
        console.log "Landing page action"
        app.components.add app.landingPage
        @render null

    Router.route '/press',
      onStop: ->
        console.log "Leaving press page"
        app.components.remove app.pressPage

      action: ->
        console.log "Press page action"
        app.components.add app.pressPage
        @render null

  fontSize: ->
    # 62.5% brings us to 1em = 10px, so we scale all fonts set to their pixel perfect sizes with this.
    62.5 * @display.scale()
