AE = Artificial.Everywhere
AM = Artificial.Mirage

class AM.Display extends AM.Component
  @register 'Artificial.Mirage.Display'

  constructor: (@app, options) ->
    super

    @app.services.addService @constructor, @

    @safeAreaWidth = new ReactiveField options.safeAreaWidth
    @safeAreaHeight = new ReactiveField options.safeAreaHeight

    @minScale = new ReactiveField options.minScale

    @maxDisplayWidth = new ReactiveField options.maxDisplayWidth
    @maxDisplayHeight = new ReactiveField options.maxDisplayHeight

    @minAspectRatio = new ReactiveField options.minAspectRatio
    @maxAspectRatio = new ReactiveField options.maxAspectRatio

    @scale = new ReactiveField 1
    @viewport = new ReactiveField
      bounds: new AE.Rectangle()
      safeArea: new AE.Rectangle()

  initialize: ->
    @window = @app.services.getService AM.Window

    # React to window size changes.
    Tracker.autorun =>
      scale = @minScale()
      clientBounds = @window.clientBounds()
      clientWidth = clientBounds.width()
      clientHeight = clientBounds.height()
      safeAreaWidth = @safeAreaWidth()
      safeAreaHeight = @safeAreaHeight()
      minAspectRatio = @minAspectRatio()
      maxAspectRatio = @maxAspectRatio()
      maxDisplayWidth = @maxDisplayWidth()
      maxDisplayHeight = @maxDisplayHeight()

      # Calculate new scale.
      loop
        # Test if next scale level would make the safe area go out of page bounds.
        scaledSafeAreaWidth = safeAreaWidth * (scale + 1)
        scaledSafeAreaHeight = safeAreaHeight * (scale + 1)

        break if scaledSafeAreaWidth > clientWidth or scaledSafeAreaHeight > clientHeight

        # It is safe to increase the scale.
        scale++

      scaledSafeAreaWidth = safeAreaWidth * scale
      scaledSafeAreaHeight = safeAreaHeight * scale

      @scale scale

      # Bound to maximum size.
      scaledMaxWidth = if maxDisplayWidth then Math.round maxDisplayWidth * scale else clientWidth
      scaledMaxHeight = if maxDisplayHeight then Math.round maxDisplayHeight * scale else clientHeight

      # Calculate viewport ratio, clamped to our limits.
      uncroppedViewportRatio = scaledMaxWidth / scaledMaxHeight

      viewportRatio = uncroppedViewportRatio
      viewportRatio = Math.max viewportRatio, minAspectRatio if minAspectRatio
      viewportRatio = Math.min viewportRatio, maxAspectRatio if maxAspectRatio

      # Calculate viewport size. By default it fills the full page, but make sure it doesn't exceed the viewport ratio.
      viewportSize =
        width: scaledMaxWidth
        height: scaledMaxHeight

      # If image is too tall, add crop bars on top/bottom.
      viewportSize.height = viewportSize.width / viewportRatio if uncroppedViewportRatio < viewportRatio

      # If image is too wide, add crop bars on left/right.
      viewportSize.width = viewportSize.height * viewportRatio if uncroppedViewportRatio > viewportRatio

      viewportBounds = new AE.Rectangle
        x: Math.round (clientWidth - viewportSize.width) * 0.5
        y: Math.round (clientHeight - viewportSize.height) * 0.5
        width: Math.round viewportSize.width
        height: Math.round viewportSize.height

      # Safe area is relative to viewport (it will always be contained within).
      safeArea = new AE.Rectangle
        x: Math.round (viewportSize.width - scaledSafeAreaWidth) * 0.5
        y: Math.round (viewportSize.height - scaledSafeAreaHeight) * 0.5
        width: Math.round scaledSafeAreaWidth
        height: Math.round scaledSafeAreaHeight

      if @isRendered()
        # Update crop bars.
        $('.am-display .horizontal-crop-bar').css height: viewportBounds.top()
        $('.am-display .vertical-crop-bar').css width: viewportBounds.left()

        # Update debug rectangles.
        $('.am-display .viewport-bounds').css viewportBounds.toDimensions()
        $('.am-display .viewport-bounds .safe-area').css safeArea.toDimensions()

      @viewport
        bounds: viewportBounds
        safeArea: safeArea
