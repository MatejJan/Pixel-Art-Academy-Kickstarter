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
      actualBounds: new AE.Rectangle()
      maxBounds: new AE.Rectangle()
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

      # Bound to actual window size.
      scaledWidth = Math.min scaledMaxWidth, clientWidth
      scaledHeight = Math.min scaledMaxHeight, clientHeight

      # But make sure safe area is in.
      scaledWidth = Math.max scaledWidth, scaledSafeAreaWidth
      scaledHeight = Math.max scaledHeight, scaledSafeAreaHeight

      safeClientWidth = Math.max clientWidth, scaledSafeAreaWidth
      safeClientHeight = Math.max clientHeight, scaledSafeAreaHeight

      # Calculate viewport ratio, clamped to our limits.
      uncroppedViewportRatio = scaledWidth / scaledHeight

      viewportRatio = uncroppedViewportRatio
      viewportRatio = Math.max viewportRatio, minAspectRatio if minAspectRatio
      viewportRatio = Math.min viewportRatio, maxAspectRatio if maxAspectRatio

      # Calculate viewport size. By default it fills the full page, but make sure it doesn't exceed the viewport ratio.
      actualViewportSize =
        width: scaledWidth
        height: scaledHeight

      maxViewportSize =
        width: scaledMaxWidth
        height: scaledMaxHeight

      # If image is too tall, add crop bars on top/bottom.
      actualViewportSize.height = actualViewportSize.width / viewportRatio if uncroppedViewportRatio < viewportRatio

      # If image is too wide, add crop bars on left/right.
      actualViewportSize.width = actualViewportSize.height * viewportRatio if uncroppedViewportRatio > viewportRatio

      actualViewportBounds = new AE.Rectangle
        x: Math.round (safeClientWidth - actualViewportSize.width) * 0.5
        y: Math.round (safeClientHeight - actualViewportSize.height) * 0.5
        width: Math.round actualViewportSize.width
        height: Math.round actualViewportSize.height

      maxViewportBounds = new AE.Rectangle
        x: Math.round (safeClientWidth - maxViewportSize.width) * 0.5
        y: Math.round (safeClientHeight - maxViewportSize.height) * 0.5
        width: Math.round maxViewportSize.width
        height: Math.round maxViewportSize.height

      # Safe area is relative to actual viewport (it will always be contained within).
      safeArea = new AE.Rectangle
        x: Math.round (actualViewportSize.width - scaledSafeAreaWidth) * 0.5
        y: Math.round (actualViewportSize.height - scaledSafeAreaHeight) * 0.5
        width: Math.round scaledSafeAreaWidth
        height: Math.round scaledSafeAreaHeight

      if @isRendered()
        # Update crop bars.
        $('.am-display .horizontal-crop-bar').css height: actualViewportBounds.top()
        $('.am-display .vertical-crop-bar').css width: actualViewportBounds.left()

        # Update debug rectangles.
        $('.am-display .viewport-bounds').css actualViewportBounds.toDimensions()
        $('.am-display .viewport-bounds .safe-area').css safeArea.toDimensions()

      @viewport
        actualBounds: actualViewportBounds
        maxBounds: maxViewportBounds
        safeArea: safeArea
