AE = Artificial.Everywhere
AM = Artificial.Mirage

class PixelArtAcademy extends Artificial.Base.App
  constructor: ->
    super

    @display = new Artificial.Mirage.Display @,
      safeAreaWidth: 240
      safeAreaHeight: 180
      minScale: 2
      minAspectRatio: 2/3
    @components.addComponent @display

    @landingPage = new PixelArtAcademy.LandingPage @
    @components.addComponent @landingPage

  fontSize: ->
    # 62.5% brings us to 1em = 10px, so we scale all fonts set to their pixel perfect sizes with this.
    62.5 * @display.scale()

  renderDisplay: ->
    console.log
    @display()?.renderComponent(@currentComponent()) or null
