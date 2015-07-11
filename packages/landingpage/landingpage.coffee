AE = Artificial.Everywhere
AM = Artificial.Mirage

class PixelArtAcademy.LandingPage extends AM.Component
  @register 'PixelArtAcademy.LandingPage'

  sceneWidth = 240
  middleSceneHeight = 180
  middleSceneOffsetFactor = 0.5

  coatOfArmsHeight = 103
  coatOfArmsOffset = 85

  bottomSectionHeight = 150

  constructor: (@pixelArtAcademy) ->
    super

  onCreated: ->
    super

    # Set the initializing flag for the first rendering pass, before we have time to initialize rendered elements.
    @initializingClass = new ReactiveField "initializing"

  initialize: ->
    # Since focusing moves scroll position in Safari, let's focus right here and scroll to top.
    @focusPrompt()
    $('html').scrollTop(0)

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
    @$paralaxSections = $('.landing-page .scene').add('.landing-page .bottom-section')
    @supportPageOffset = window.pageYOffset isnt undefined
    @isCSS1Compat = (document.compatMode or "") is "CSS1Compat"

    # Enable magnification detection.
    @autorun =>
      # Register dependency on display scaling and viewport size.
      @display.scale()
      @display.viewport()
      @hasResized = true

    # Enable scroll detection.
    $(window).scroll (event) =>
      @hasScrolled = true

    @hasScrolled = true

    ### Animation ###

    @$textAdventureLines = $('.landing-page .text-adventure .line')
    @$textAdventureLines.css
      opacity: 0

    @textAdventureShown = false
    @kickstarterAnnouncementShown = false

    # We are finished with initialization.
    @initializingClass ""

  showTextAdventure: ->
    return if @textAdventureShown

    @$textAdventureLines.each (index) ->
      $(this).velocity
        opacity: 1
      ,
        duration: 2500
        delay: index * 350
        easing: 'ease-in-out'

    @textAdventureShown = true

  showKickstarterAnnouncement: ->
    return if @kickstarterAnnouncementShown

    $('.landing-page .text-adventure').velocity
      opacity: 0
    ,
      duration: 2000
      easing: 'ease-in-out'
      complete: =>
        $('.landing-page .text-adventure').hide()
        $('.landing-page .eager-to-start').show()

        $('.landing-page .eager-to-start .part-1').velocity
          opacity: 1
        ,
          duration: 2000
          easing: 'ease-in-out'

        $('.landing-page .eager-to-start .part-2').velocity
          opacity: 1
        ,
          duration: 2000
          delay: 2000
          easing: 'ease-in-out'
          complete: =>
            $('.landing-page .eager-to-start').velocity
              opacity: 0
            ,
              duration: 2000
              delay: 500
              easing: 'ease-in-out'
              complete: =>
                $('.landing-page .eager-to-start').hide()
                $('.landing-page .kickstarter').show().velocity
                  opacity: 1
                ,
                  duration: 1000
                  easing: 'ease-in-out'

    @kickstarterAnnouncementShown = true

  events: ->
    super.concat
      'mouseenter .action': @onMouseEnterAction
      'mouseleave .action': @onMouseLeaveAction
      'click .action': @onClickAction
      'click .prompt-area': @onClickPromptArea
      'change .prompt': @onChangePrompt
      'focus .mailing-list .input': @onFocusMailingList
      'blur .mailing-list .input': @onBlurMailingList

  onMouseEnterAction: (event) ->
    return if @hoverOnAction
    @hoverOnAction = true

    $prompt = $('.text-adventure .prompt')
    @promptOldText = $prompt.val() or ""
    @promptWasFocused = $prompt.is(":focus")
    $prompt.blur().val($(event.target).data('action'))

  onMouseLeaveAction: (event) ->
    return unless @hoverOnAction

    $prompt = $('.text-adventure .prompt')
    $prompt.val(@promptOldText)
    $prompt.focus() if @promptWasFocused

    @hoverOnAction = false

  onClickAction: (event) ->
    @prepareForKickstarterAnnouncement()

  prepareForKickstarterAnnouncement: ->
    # Scroll down and show kickstarter animation.
    ###
    $('html').velocity 'scroll',
      easing: 'ease-in-out'
      duration: 1000
      offset: $('html').height() - $(window).height()
      mobileHA: false
    ###
    @showKickstarterAnnouncement()

  onClickPromptArea: (event) ->
    @focusPrompt()

  focusPrompt: ->
    $('.text-adventure .prompt').focus()

  onChangePrompt: (event) ->
    # Don't react when hovering is changing the input.
    return if @hoverOnAction

    $('.text-adventure .prompt').blur()
    @prepareForKickstarterAnnouncement()

  onFocusMailingList: ->
    @skipDraw = true

  onBlurMailingList: ->
    @skipDraw = false

  draw: (appTime) ->
    # Prevent trouble on mobile.
    return if @skipDraw

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
        x: viewport.bounds.x() + viewport.safeArea.left()
        y: sceneBounds.bottom()
        width: viewport.safeArea.width()
        height: bottomSectionHeight * scale

      # Apply changes.
      $('.landing-page .scene').css sceneBounds.toDimensions()

      $('.landing-page .top-section').css topSectionBounds.toDimensions()

      topSectionRestHeight = topSectionBounds.height() * 0.5 - coatOfArmsHeight * 0.5 * scale
      $('.landing-page .top-section .top, .landing-page .top-section .bottom').css
        height: topSectionRestHeight
        lineHeight: "#{topSectionRestHeight}px"

      $('.landing-page .top-section .middle').css
        top: topSectionBounds.height() * 0.5 - coatOfArmsOffset * scale

      $('.landing-page .middle-section').css middleSectionBounds.toDimensions()
      $('.landing-page .bottom-section').css bottomSectionBounds.toDimensions()

      $('.landing-page').css
        height: bottomSectionBounds.bottom() + viewport.bounds.y()

      # Update trigger sections.
      @textAdventureShowScrollTop = bottomSectionBounds.top() - viewport.bounds.bottom()

      # Update parallax origins. They tells us at what scroll top the images are at the original setup.

      # The top scene is correct simply as the page is rendered on top.
      @topParallaxOrigin = topSectionBounds.top()

      # It should be when the middle section is exactly in the middle of the screen.
      middleScenePillarboxBarHeight = (viewport.bounds.height() - middleSectionBounds.height()) * 0.5
      @middleParallaxOrigin = middleSectionBounds.top() - middleScenePillarboxBarHeight

    if @hasScrolled
      @hasScrolled = false

      scrollTop = if @supportPageOffset then window.pageYOffset else if isCSS1Compat then document.documentElement.scrollTop else document.body.scrollTop
      topDelta = scrollTop - @topParallaxOrigin
      middleDelta = scrollTop - @middleParallaxOrigin

      @showTextAdventure() if not @textAdventureLinesShown and scrollTop >= @textAdventureShowScrollTop

      # Move sections.
      @$paralaxSections.css transform: "translate3d(0, #{-scrollTop}px, 0)"

      # Move elements.
      for {delta, elements} in [
        {delta: topDelta, elements: @topParallaxElements}
        {delta: middleDelta, elements: @middleParallaxElements}
      ]
        for element in elements
          offset = delta * element.scaleFactor
          element.$element.css transform: "translate3d(0, #{offset}px, 0)"
