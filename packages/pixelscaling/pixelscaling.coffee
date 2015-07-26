AE = Artificial.Everywhere
AM = Artificial.Mirage

class PixelArtAcademy.PixelScaling extends AM.Component
  @register 'PixelArtAcademy.PixelScaling'

  initialize: =>
    @canvas = $('.pixel-scaling .canvas')[0]
    @context = @canvas.getContext '2d'

    @content = content = {}

    $('<img/>').attr(src: '/pixelscaling/indy.png').load ->
      content.indy = @

    $('<img/>').attr(src: '/pixelscaling/room.png').load ->
      content.room = @

  draw: (appTime) =>
    @context.clearRect 0, 0, @canvas.width, @canvas.height

    if @content.indy and @content.room
      indy = @content.indy
      width = 44
      height = indy.height
      frames = 6
      fps = 8

      frame = Math.round(appTime.totalAppTime * fps) % frames

      room = @content.room

      offset = 50 #+ appTime.totalAppTime
      floor = 70

      spacing = 150


      @context.drawImage room, 0, 0
      @context.drawImage room, 0, spacing

      for scale in [1, 0.99, 0.9, 0.8, 0.7, 0.6, 0.5]
        #scale *= Math.pow 0.99, appTime.totalAppTime if scale < 1

        @context.imageSmoothingEnabled = true
        @context.drawImage indy, frame * width, 0, width, height, offset, height * (1 - scale * 0.5) + floor, width * scale, height * scale

        @context.imageSmoothingEnabled = false
        @context.drawImage indy, frame * width, 0, width, height, offset, height * (1 - scale * 0.5) + floor + spacing, width * scale, height * scale

        offset += width * 0.5 * scale + 10
