/*
 *  Lake.js by Reece Selwood (Alligatr). http://alligatr.co.uk/lake.js/
 *
 *  Modified for Pixel Art Academy.
 */
createReflection = function(imageUrl, $parent, options) {
	var settings = $.extend({
		'speed':    1,
		'scale':    1,
		'waves':    10,
		'image':    false
	}, options);

	var waves = settings['waves'];
	var speed = settings['speed']/4;
	var scale = settings['scale']/2;

	var ca = document.createElement('canvas');
	var exportCa = document.createElement('canvas');
	var c = ca.getContext('2d');
	var exportC = ca.getContext('2d');

	var img_loaded = false;

	var gif = null;

	$parent.append(ca);

	var w, h, dw, dh;

	var offset = 0;
	var frame = 0;
	var max_frames = 0;
	var frames = [];

	$('<img/>').attr({src: imageUrl}).load(function() {
		c.save();

		c.canvas.width  = this.width;
		c.canvas.height = this.height*2;
		exportC.canvas.width  = this.width;
		exportC.canvas.height = this.height*2;

		gif = new GIFEncoder();
		gif.setRepeat(0); //0  -> loop forever
		//1+ -> loop n times then stop
		gif.setDelay(50); //go to next frame every n milliseconds
		gif.setTransparent(0xa6e2fe);
		gif.start();

		c.drawImage(this, 0,  0);

		c.scale(1, -1);
		c.drawImage(this, 0,  -this.height*2);

		img_loaded = true;

		c.restore();

		w = c.canvas.width;
		h = c.canvas.height;
		dw = w;
		dh = h/2;

		var id = c.getImageData(0, h/2, w, h).data;
		var end = false;

		// precalc frames
		// image displacement
		c.save();
		while (!end) {
			// var odd = c.createImageData(dw, dh);
			var odd = c.getImageData(0, h/2, w, h);
			var od = odd.data;
			// var pixel = (w*4) * 5;
			var pixel = 0;
			for (var y = 0; y < dh; y++) {
				for (var x = 0; x < dw; x++) {
					// var displacement = (scale * dd[pixel]) | 0;
					var displacement = (scale * 10 * (Math.sin((dh/(y/waves)) + (-offset)))) | 0;
					var j = ((displacement + y) * w + x + displacement)*4;

					// horizon flickering fix
					if (j < 0) {
						j = 0;
					}

					// edge wrapping fix
					/*var m = j % (w*4);
					var n = scale * 10 * (y/waves);
					if (m < n || m > (w*4)-n) {
						var sign = y < w/2 ? 1 : -1;
						od[pixel]   = od[pixel + 4 * sign];
						od[++pixel] = od[pixel + 4 * sign];
						od[++pixel] = od[pixel + 4 * sign];
						od[++pixel] = od[pixel + 4 * sign];
						++pixel;
						continue;
					}*/

					if (id[j+3] != 0) {
						od[pixel]   = id[j];
						od[++pixel] = id[++j];
						od[++pixel] = id[++j];
						od[++pixel] = id[++j];
						++pixel;
					} else {
						od[pixel]   = od[pixel - w*4];
						od[++pixel] = od[pixel - w*4];
						od[++pixel] = od[pixel - w*4];
						od[++pixel] = od[pixel - w*4];
						++pixel;
						// pixel += 4;
					}
				}
			}

			if (offset > speed * (6/speed)) {
				offset = 0;
				max_frames = frame - 1;
				// frames.pop();
				frame = 0;
				end = true;
			} else {
				offset += speed;
				frame++;
			}
			frames.push(odd);

			exportC.putImageData(odd, 0, 0);
			var img = exportC.canvas.toDataURL("image/png");

			$frame=$('<img src="'+img+'"/>');

			gif.addFrame(exportC);

		}
		c.restore();
		if (!settings.image) {
			c.height = c.height/2;
		}

		gif.finish();
		var binary_gif = gif.stream().getData() //notice this is different from the as3gif package!
		var data_url = 'data:image/gif;base64,'+ btoa(binary_gif);
		document.write('<img src="'+data_url+'"/>');

	});

	var time = 0;
	var fps = 15;
	var frameTime = 1.0/fps;

	var draw = function(dt) {
		time += dt;
		while (time>frameTime) {
			time -= frameTime;
			if (frame < max_frames) {
				frame++;
			} else {
				frame = 0;
			}
		}

		if (img_loaded) {
			if (!settings.image) {
				c.putImageData(frames[frame], 0, 0);
			} else {
				c.putImageData(frames[frame], 0, h/2);
			}
		}
	};

	return draw;
};
