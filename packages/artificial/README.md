# Pixel Art Academy

## Artificial Engines

A Meteor game development library written in CoffeeScript.

### Artificial Base

_The app framework_

Tying all the pieces of your app together can be a hassle. Running an update and draw loop should be unified.
Services need to be shared, components integrated. Artificial Base (AB) gives you the basic framework.

- **App**: The root class from which to inherit your custom app.
- **Services**: A container for loose coupling of app components.

### Artificial Everywhere

_Useful bits and pieces_

Some static classes and routines are just useful right about everywhere in your code and don’t fall into any specific
category. The place for them is Artificial Everywhere (AE).

- **Rectangle**: A reactive rectangle data structure.

### Artificial Mirage

_Graphical user interface elements_

A great GUI is a ticket to user friendliness. Artificial Mirage provides common interface elements that you connect
into a system, specially designed to adapt to different display resolutions and aspect ratios.

- **Component**: Extension of BlazeComponent with custom functionality.
- **CSSHelper**: Helper functions for dealing with CSS.
- **Display**: Represents the display area and provides automatic pixel art scaling calculation.
- **Window**: The bounds of your browser window.
