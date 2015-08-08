AE = Artificial.Everywhere
AM = Artificial.Mirage

class PixelArtAcademy.LandingPage extends AM.Component
  @register 'PixelArtAcademy.LandingPage'

  sceneWidth = 360
  middleSceneHeight = 180
  middleSceneOffsetFactor = 0.5

  coatOfArmsHeight = 103
  coatOfArmsRealHeight = 180
  coatOfArmsOffset = 5

  bottomSectionHeight = 150

  # Run the intro animation.
  intro = false

  coatOfArmsOffset = -2 if intro

  constructor: (@pixelArtAcademy) ->
    super

  onCreated: ->
    super

    # Set the initializing flag for the first rendering pass, before we have time to initialize rendered elements.
    @initializingClass = new ReactiveField "initializing"

  onRendered: ->
    super

    # Since focusing moves scroll position in Safari, let's focus right here and scroll to top.
    @focusPrompt()
    $('html').scrollTop(0)

    @display = @pixelArtAcademy.services.getService AM.Display
    @display.maxDisplayWidth sceneWidth

    ### Parallax ###

    # Preprocess parallax elements to avoid trashing.
    parallaxElements = []
    topParallaxElements = []
    middleParallaxElements = []

    sceneItems =
      coatOfArms: []

    $('.landing-page *[data-depth]').each ->
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

      localArray = if $element.closest('.top-section').length then topParallaxElements else middleParallaxElements
      localArray.push parallaxInfo

      sceneItems.quadrocopter = parallaxInfo if $element.hasClass('quadrocopter')
      sceneItems.airshipFar = parallaxInfo if $element.hasClass('airship-far')
      sceneItems.airshipNear = parallaxInfo if $element.hasClass('airship-near')
      sceneItems.frigates1 = parallaxInfo if $element.hasClass('frigates-1')
      sceneItems.frigates2 = parallaxInfo if $element.hasClass('frigates-2')
      sceneItems.frigates3 = parallaxInfo if $element.hasClass('frigates-3')
      sceneItems.frigates4 = parallaxInfo if $element.hasClass('frigates-4')
      sceneItems.coatOfArms.push parallaxInfo if $element.hasClass('coat-of-arms')

    @sceneItems = sceneItems

    @topParallaxElements = topParallaxElements
    @middleParallaxElements = middleParallaxElements

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
        scale = scaleField()

        css =
          width: loadedImage.width * scale
          height: loadedImage.height * scale

        for property in ['left', 'top', 'bottom', 'right']
          css[property] = data[property] * scale if data[property]

        $image.css css

        $image.removeClass('initializing')

    # Reposition parallax elements.
    @autorun (computation) =>
      scale = @display.scale()

      for element in parallaxElements
        css = {}

        for property in ['left', 'top', 'bottom', 'right']
          css[property] = element[property] * scale if element[property]

        element.$element.css css

    # Scale the images.
    @autorun (computation) =>
      scale = @display.scale()

      $('.landing-page').find('img').each ->
        $image = $(@)

        css =
          width: $image.data('sourceWidth') * scale
          height: $image.data('sourceHeight') * scale

        for property in ['left', 'top', 'bottom', 'right']
          value = $image.data(property)
          css[property] = value * scale if value

        $image.css css

    # Cache elements.
    @$paralaxSections = $('.landing-page .parallax-section')
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

    @airshipsMoving = false
    @airshipsMovingTimeStart = 0

    if intro
      $('.landing-page .top-section .top').css(opacity: 0)
      $('.landing-page .top-section .middle').css(opacity: 0)
      $('.landing-page .top-section .bottom').hide()

      $('.landing-page .bottom-section .text-adventure').hide()

      $('.landing-page .intro-section').show()

      @introMusic = $('.landing-page .intro-section .music')[0]

    # Start intro after a couple seconds.
      Meteor.setTimeout =>
        @introMusic.play()

        Meteor.setTimeout =>
          @animateIntro()
        , 2000

      , 1000

    ### Reflection ###

    ### Handled by a gif instead - use only when re-rendering

    $reflection = $('.landing-page .reflection')
    reflectionImageUrl = '/landingpage/retropolis/reflection.png'
    @drawReflection = createReflection reflectionImageUrl, $reflection,
      speed: 0.3
      scale: 0.5
      waves: 20

    reflectionSize = {}

    scaleReflectionCanvas = =>
      scale = @display.scale()

      $source = $('.landing-page .reflection .source')

      $canvas = $('.landing-page .reflection canvas')
      $canvas.css
        width: reflectionSize.width * scale
        # Reflection canvas is double in size.
        height: reflectionSize.height * scale * 2

    # Load a copy for measuring purposes.
    $('<img/>').attr(src: reflectionImageUrl).load ->
      loadedImage = @

      reflectionSize =
        width: loadedImage.width
        height: loadedImage.height

      scaleReflectionCanvas()

    # Scale reflection canvas.
    @autorun (computation) =>
      scaleReflectionCanvas()

    ###

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

  animateIntro: ->
    $('html').velocity 'scroll',
      duration: 20000
      easing: 'ease-out'
      offset: $('.landing-page .top-section').offset().top - @display.viewport().viewportBounds.y()

    $('.landing-page .top-section .middle').velocity
      opacity: 1
    ,
      delay: 21000
      duration: 2000
      easing: 'ease-in-out'
      complete: =>
        $('.landing-page .top-section .top').velocity
          opacity: 1
        ,
          duration: 2000
          delay: 2000
          easing: 'ease-in-out'

    $('.landing-page .intro-section .retronator-presents').velocity
      opacity: 1
    ,
      duration: 2000
      delay: 800
      easing: 'ease-in-out'

    .velocity
      opacity: 0
    ,
      duration: 2000
      delay: 1300
      easing: 'ease-in-out'
      complete: =>
        $('.landing-page .intro-section .game-by').velocity
          opacity: 1
        ,
          duration: 2000
          easing: 'ease-in-out'

        .velocity
          opacity: 0
        ,
          duration: 2000
          delay: 1850
          easing: 'ease-in-out'
          complete: =>
            $('.landing-page .intro-section .music-by').velocity
              opacity: 1
            ,
              duration: 2000
              easing: 'ease-in-out'

            .velocity
              opacity: 0
            ,
              duration: 4000
              delay: 2000
              easing: 'ease-in-out'


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

    scale = @display.scale()

    if @hasResized
      @hasResized = false

      # Also trigger parallax.
      @hasScrolled = true

      viewport = @display.viewport()

      topSectionBounds = new AE.Rectangle
        x: viewport.viewportBounds.x() + viewport.safeArea.x()
        y: viewport.viewportBounds.y()
        width: viewport.safeArea.width()
        height: viewport.viewportBounds.height()

      # Middle section is absolute inside the scene.
      middleSectionBounds = new AE.Rectangle
        x: 0
        y: viewport.viewportBounds.height() * (1 + middleSceneOffsetFactor)
        width: viewport.maxBounds.width()
        height: middleSceneHeight * scale

      # Scene is the part with sky background.
      sceneBounds = new AE.Rectangle
        x: viewport.maxBounds.x()
        y: viewport.viewportBounds.y()
        width: viewport.maxBounds.width()
        height: middleSectionBounds.bottom()

      if intro
        # Place the intro section to the top.
        $('.landing-page .intro-section').css topSectionBounds.toDimensions()

        # Move the title section over the middle.
        topSectionBounds.y middleSectionBounds.y() - (topSectionBounds.height() - middleSectionBounds.height()) * 0.5 + sceneBounds.y()

      bottomSectionBounds = new AE.Rectangle
        x: viewport.viewportBounds.x() + viewport.safeArea.x()
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
        top: topSectionBounds.height() * 0.5 - coatOfArmsRealHeight * 0.5 * scale + coatOfArmsOffset * scale

      $('.landing-page .middle-section').css middleSectionBounds.toDimensions()
      $('.landing-page .bottom-section').css bottomSectionBounds.toDimensions()

      $('.landing-page').css
        height: bottomSectionBounds.bottom() + viewport.viewportBounds.y()

      # Update trigger sections.
      @textAdventureShowScrollTop = bottomSectionBounds.top() - viewport.viewportBounds.bottom()

      # Update parallax origins. They tells us at what scroll top the images are at the original setup.

      # The top scene is correct simply as the page is rendered on top.
      @topParallaxOrigin = 0

      # It should be when the middle section is exactly in the middle of the screen.
      middleScenePillarboxBarHeight = (viewport.viewportBounds.height() - middleSectionBounds.height()) * 0.5
      @middleParallaxOrigin = middleSectionBounds.top() - middleScenePillarboxBarHeight

      if intro
        @topParallaxOrigin = @middleParallaxOrigin

    if @hasScrolled
      @hasScrolled = false

      scrollLeft = if @supportPageOffset then window.pageXOffset else if isCSS1Compat then document.documentElement.scrollLeft else document.body.scrollLeft
      scrollTop = if @supportPageOffset then window.pageYOffset else if isCSS1Compat then document.documentElement.scrollTop else document.body.scrollTop
      @topScrollDelta = scrollTop - @topParallaxOrigin
      @middleScrollDelta = scrollTop - @middleParallaxOrigin

      @showTextAdventure() if not @textAdventureLinesShown and scrollTop >= @textAdventureShowScrollTop

      unless @airshipsMoving
        @airshipsMovingTimeStart = appTime.totalAppTime
        @airshipsMoving = true if scrollTop > 0

      # Move sections.
      @$paralaxSections.css transform: "translate3d(#{-scrollLeft}px, #{-scrollTop}px, 0)"

      # Move elements.
      for element in @middleParallaxElements
        offset = @middleScrollDelta * element.scaleFactor
        element.$element.css transform: "translate3d(0, #{offset}px, 0)"

      for element in @topParallaxElements
        offset = @topScrollDelta * element.scaleFactor
        element.$element.css transform: "translate3d(0, #{offset}px, 0)"

    if intro
      for element in @sceneItems.coatOfArms
        tilt = Math.sin(appTime.totalAppTime + 2) * 10 * scale
        offset = (@topScrollDelta + tilt) * element.scaleFactor + 0.6 * tilt
        element.$element.css transform: "translate3d(0, #{offset}px, 0)"

    x = Math.sin(appTime.totalAppTime / 2) * 5 * scale
    y = @middleScrollDelta * @sceneItems.quadrocopter.scaleFactor + Math.sin(appTime.totalAppTime) * 3 * scale
    @sceneItems.quadrocopter.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = (appTime.totalAppTime - @airshipsMovingTimeStart) * scale
    y = @middleScrollDelta * @sceneItems.airshipFar.scaleFactor
    @sceneItems.airshipFar.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = (appTime.totalAppTime - @airshipsMovingTimeStart) * scale * 5 - 100 * scale
    y = @middleScrollDelta * @sceneItems.airshipNear.scaleFactor
    @sceneItems.airshipNear.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = Math.sin(appTime.totalAppTime / 5) * scale
    y = @middleScrollDelta * @sceneItems.frigates1.scaleFactor + Math.sin(appTime.totalAppTime / 2) * 2 * scale
    @sceneItems.frigates1.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = Math.sin(appTime.totalAppTime / 5 + 1) * scale * 2
    y = @middleScrollDelta * @sceneItems.frigates2.scaleFactor + Math.sin(appTime.totalAppTime / 2 + 4) * scale
    @sceneItems.frigates2.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = Math.sin(appTime.totalAppTime / 5 + 2) * 2 * scale
    y = @middleScrollDelta * @sceneItems.frigates3.scaleFactor + Math.sin(appTime.totalAppTime / 2 + 5) * 2 * scale
    @sceneItems.frigates3.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = Math.sin(appTime.totalAppTime / 5 + 3) * 2 * scale
    y = @middleScrollDelta * @sceneItems.frigates4.scaleFactor + Math.sin(appTime.totalAppTime / 2 + 6) * 3 * scale
    @sceneItems.frigates4.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"
