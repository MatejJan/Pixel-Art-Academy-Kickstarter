AE = Artificial.Everywhere
AM = Artificial.Mirage

class PixelArtAcademy.LandingPage extends AM.Component
  @register 'PixelArtAcademy.LandingPage'

  sceneWidth = 240
  middleSceneHeight = 180
  middleSceneOffsetFactor = 0.5

  constructor: (@pixelArtAcademy) ->
    super

  onCreated: ->
    super

    # Set the initializing flag for the first rendering pass, before we have time to initialize rendered elements.
    @initializingClass = new ReactiveField "initializing"

  initialize: ->
    @display = @pixelArtAcademy.services.getService AM.Display
    @display.maxDisplayWidth sceneWidth

    ### Image scaling ###

    # Provide scale to the jQuery handlers, which don't have @.
    scaleField = @display.scale

    # Preprocess all the images.
    $('.landing-page').find('img').each ->
      $image = $(@)
      $image.addClass('initializing')

      source = $image.attr('src')

      # Load a copy for measuring purposes.
      $('<img/>').attr(src: source).load ->
        loadedImage = @
        # Store size from loaded image to the original image.
        $image.data
          sourceWidth: loadedImage.width
          sourceHeight: loadedImage.height

        # Scale the original image for the first time.
        $image.css
          width: loadedImage.width * scaleField()
          height: loadedImage.height * scaleField()

        $image.removeClass('initializing')

    # Scale the images.
    @autorun (computation) =>
      scale = @display.scale()

      $('.landing-page').find('img').each ->
        $image = $(@)
        $image.css
          width: $image.data('sourceWidth') * scale
          height: $image.data('sourceHeight') * scale

    ### Parallax ###

    # Preprocess parallax elements to avoid trashing.
    parallaxElements = []
    topParallaxElements = []
    middleParallaxElements = []

    $('.landing-page *[data-depth]').each ->
      $element = $(@)

      scaleFactor = 1 - $element.data('depth')

      parallaxInfo =
        $element: $element
        scaleFactor: scaleFactor
        top: $element.position().top

      parallaxElements.push parallaxInfo

      localArray = if $element.closest('.top-section').length then topParallaxElements else middleParallaxElements
      localArray.push parallaxInfo

    @topParallaxElements = topParallaxElements
    @middleParallaxElements = middleParallaxElements

    @autorun (computation) =>
      scale = @display.scale()

      for element in middleParallaxElements
        element.$element.css top: element.top * scale

    # Cache elements.
    @$scene = $('.scene')
    @supportPageOffset = window.pageYOffset isnt undefined
    @isCSS1Compat = (document.compatMode or "") is "CSS1Compat"

    ### EVENT LOOP ###

    # Enable magnification detection.
    @autorun =>
      # Register dependency on display scaling.
      @display.scale()
      @hasResized = true

    # Enable scroll detection.
    $(window).on "scroll.#{@_id}", (event) =>
      @hasScrolled = true

    @hasScrolled = true

    # We are finished with initialization.
    @initializingClass ""

  ### HELPERS ###

  draw: (appTime) ->

    ### Resizing ###

    if @hasResized
      @hasResized = false

      # Also trigger parallax.
      @hasScrolled = true

      scale = @display.scale()
      viewport = @display.viewport()

      topSectionBounds = new AE.Rectangle
        x: 0
        y: 0
        width: viewport.bounds.width()
        height: viewport.bounds.height()

      middleSectionBounds = new AE.Rectangle
        x: 0
        y: Math.round topSectionBounds.bottom() + viewport.bounds.height() * middleSceneOffsetFactor
        width: viewport.bounds.width()
        height: middleSceneHeight * scale

      sceneBounds = new AE.Rectangle
        x: viewport.bounds.x()
        y: viewport.bounds.y()
        width: viewport.bounds.width()
        height: middleSectionBounds.bottom()

      bottomSectionBounds = new AE.Rectangle
        x: sceneBounds.x()
        y: sceneBounds.bottom()
        width: viewport.bounds.width()
        height: viewport.bounds.height()

      # Apply changes.
      $('.landing-page .scene').css sceneBounds.toDimensions()

      $('.landing-page .top-section').css topSectionBounds.toDimensions()

      topSectionRestHeight = topSectionBounds.height() * 0.5 - 60 * scale
      $('.landing-page .top-section .top, .landing-page .top-section .bottom').css
        height: topSectionRestHeight
        lineHeight: "#{topSectionRestHeight}px"

      $('.landing-page .top-section .middle').css
        top: topSectionBounds.height() * 0.5 - 60 * scale

      $('.landing-page .middle-section').css middleSectionBounds.toDimensions()

      $('.landing-page .bottom-section').css
        marginTop: bottomSectionBounds.top()
        marginBottom: viewport.bounds.top()
        minHeight: bottomSectionBounds.height()

      # Update parallax origins. They tells us at what scroll top the images are at the original setup.

      # The top scene is correct simply as the page is rendered on top.
      @topParallaxOrigin = topSectionBounds.top()

      # It should be when the middle section is exactly in the middle of the screen.
      middleScenePillarboxBarHeight = (viewport.bounds.height() - middleSectionBounds.height()) * 0.5
      @middleParallaxOrigin = middleSectionBounds.top() - middleScenePillarboxBarHeight

    ### Parallax ###

    if @hasScrolled
      @hasScrolled = false

      scrollTop = if @supportPageOffset then window.pageYOffset else if isCSS1Compat then document.documentElement.scrollTop else document.body.scrollTop
      topDelta = scrollTop - @topParallaxOrigin
      middleDelta = scrollTop - @middleParallaxOrigin

      # Move sections.
      @$scene.css transform: "translate3d(0, #{-scrollTop}px, 0)"

      # Move elements.
      for {delta, elements} in [
        {delta: topDelta, elements: @topParallaxElements}
        {delta: middleDelta, elements: @middleParallaxElements}
      ]
        for element in elements
          offset = delta * element.scaleFactor
          element.$element.css transform: "translate3d(0, #{offset}px, 0)"
