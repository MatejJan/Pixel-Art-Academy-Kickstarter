AE = Artificial.Everywhere
AM = Artificial.Mirage

class PixelArtAcademy.PressPage extends AM.Component
  @register 'PixelArtAcademy.PressPage'

  sceneWidth = 360
  sceneScale = 2
  middleSceneHeight = 180
  middleSceneOffsetFactor = 0.5

  coatOfArmsHeight = 103
  coatOfArmsRealHeight = 180
  coatOfArmsOffset = 5

  bottomSectionHeight = 150

  constructor: (@pixelArtAcademy) ->
    super

  onCreated: ->
    super

    # Set the initializing flag for the first rendering pass, before we have time to initialize rendered elements.
    @initializingClass = new ReactiveField "initializing"

  onRendered: ->
    $('html').scrollTop(0)

    @display = @pixelArtAcademy.services.getService AM.Display
    @display.maxDisplayWidth sceneWidth

    ### Parallax ###

    # Preprocess parallax elements to avoid trashing.
    parallaxElements = []
    sceneItems = {}

    $('.press-page *[data-depth]').each ->
      $element = $(@)

      scaleFactor = 1 - $element.data('depth')

      parallaxInfo =
        $element: $element
        scaleFactor: scaleFactor
        left: $element.positionCss('left')
        right: $element.positionCss('right')
        top: $element.positionCss('top')
        bottom: $element.positionCss('bottom')

      for property in ['left', 'top', 'bottom', 'right']
        parallaxInfo[property] = if parallaxInfo[property] is 'auto' then null else parseInt(parallaxInfo[property])

      parallaxElements.push parallaxInfo

      sceneItems.quadrocopter = parallaxInfo if $element.hasClass('quadrocopter')
      sceneItems.airshipFar = parallaxInfo if $element.hasClass('airship-far')
      sceneItems.airshipNear = parallaxInfo if $element.hasClass('airship-near')
      sceneItems.frigates1 = parallaxInfo if $element.hasClass('frigates-1')
      sceneItems.frigates2 = parallaxInfo if $element.hasClass('frigates-2')
      sceneItems.frigates3 = parallaxInfo if $element.hasClass('frigates-3')
      sceneItems.frigates4 = parallaxInfo if $element.hasClass('frigates-4')

    @sceneItems = sceneItems

    ### Image scaling ###

    # Preprocess all the images.
    $('.press-page .scene').find('img').each ->
      $image = $(@)
      $image.addClass('initializing')

      source = $image.attr('src')

      # Load a copy for measuring purposes.
      $('<img/>').attr(src: source).load ->
        loadedImage = @
        # Store size from loaded image to the original image.
        data =
          sourceWidth: loadedImage.width
          sourceHeight: loadedImage.height
          left: $image.positionCss('left')
          right: $image.positionCss('right')
          top: $image.positionCss('top')
          bottom: $image.positionCss('bottom')

        for property in ['left', 'top', 'bottom', 'right']
          data[property] = if data[property] is 'auto' then null else parseInt(data[property])

        $image.data data

        # Scale the original image for the first time.
        scale = sceneScale

        css =
          width: loadedImage.width * scale
          height: loadedImage.height * scale

        for property in ['left', 'top', 'bottom', 'right']
          css[property] = data[property] * scale if data[property]

        $image.css css

        $image.removeClass('initializing')

    # Reposition parallax elements.
    @autorun (computation) =>
      scale = sceneScale

      for element in parallaxElements
        css = {}

        for property in ['left', 'top', 'bottom', 'right']
          css[property] = element[property] * scale if element[property]

          spread = 300
          offset = -spread * element.scaleFactor + spread
          css.transform = "translate3d(0, #{offset}px, 0)"

        element.$element.css css

    # Scale the images.
    @autorun (computation) =>
      scale = sceneScale

      $('.press-page').find('img').each ->
        $image = $(@)

        css =
          width: $image.data('sourceWidth') * scale
          height: $image.data('sourceHeight') * scale

        for property in ['left', 'top', 'bottom', 'right']
          value = $image.data(property)
          css[property] = value * scale if value

        $image.css css

    @initializingClass ""
