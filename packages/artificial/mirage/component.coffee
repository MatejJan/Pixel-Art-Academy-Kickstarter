AM = Artificial.Mirage

class AM.Component extends BlazeComponent
  # Modified firstNode and lastNode helpers that skip over text nodes. Useful if the component doesn't have
  # persistent first and last nodes, since the original helpers will point to surrounding text elements.
  firstElementNode: ->
    firstNode = @firstNode()

    # Not using nextElementSibling because it is not yet widely supported on text nodes.
    while firstNode and firstNode.nodeType isnt Node.ELEMENT_NODE
      firstNode = firstNode.nextSibling

    firstNode

  lastElementNode: ->
    lastNode = @lastNode()

    # Not using previousElementSibling because it is not yet widely supported on text nodes.
    while lastNode and lastNode.nodeType isnt Node.ELEMENT_NODE
      lastNode = lastNode.previousSibling

    lastNode

  # Returns a jQuery object with all the top-level nodes within the component, ignoring possible initial and last
  # non-element nodes.
  $children: ->
    return $() unless @isRendered()

    firstNode = @firstElementNode()
    lastNode = @lastElementNode()

    if firstNode is lastNode
      $(firstNode)
    else
      $(firstNode).nextUntil(lastNode).addBack().add(lastNode)

  # Returns a jQuery object with all the nodes that are part of this widget, but not child widgets.
  $widgetNodes: ->
    return $() unless @isRendered()

    $children = @$children()

    # All immediate children nodes belong to the widget.
    $widgetNodes = $($children)

    # Search descendant nodes until hitting the ones with the data-id is set (indicating a root of a child widget).
    search = ($children) ->
      $children.each ->
        $node = $(@)
        unless $node.data('id')
          $widgetNodes = $widgetNodes.add($node)
          search $node.children()

    $children.each ->
      search $(@).children()

    $widgetNodes

  isDescendantOf: (component) ->
    current = @

    while current.componentParent()
      current = current.componentParent()
      return true if current is component

    return false

  componentChildrenOfType: (constructor) ->
    @componentChildrenWith (child) ->
      child instanceof constructor

  # Returns the widget component (UIComponent that is also a Widget), potentially skipping any non-widget components
  # that might be between the UIComponent of the current context and the widget UIComponents. This is to support
  # getting the widget component when we're in a helper/handler inside a child UIComponent that the widget might be
  # using in its template.
  widgetComponent: ->
    widgetComponent = @
    while widgetComponent and widgetComponent not instanceof Widget
      widgetComponent = widgetComponent.componentParent()
    widgetComponent

  # Returns the parent widget component of the current widget component, i.e. the
  # parent Widget of the current Widget, both of the Widgets being rendered UIComponents.
  widgetComponentParent: ->
    @widgetComponent().componentParent()?.widgetComponent()

  # Returns an array of children widget components of the provided widget component,
  # i.e. the children Widgets of the current Widget (all of which are rendered UIComponents).
  @widgetComponentChildren: (widgetComponent) ->
    # We perform a breadth first search on the component children tree, starting at the children of the
    # widget component node and searching for widget components (while skipping over non-widget components).
    searchFringe = widgetComponent.componentChildren()
    childWidgetComponents = []

    while searchFringe.length
      component = searchFringe.shift()
      if component instanceof Widget
        childWidgetComponents.push component
      else
        searchFringe = searchFringe.concat component.componentChildren()

    childWidgetComponents

  # Returns an array of children widget components of the current widget component,
  # i.e. the children Widgets of the current Widget (all of which are rendered UIComponents).
  widgetComponentChildren: ->
    @constructor.widgetComponentChildren @widgetComponent()

  # Converts a style object to a css string. Useful in templates
  # when you need just the string and not a style attribute.
  css: (styleObject) ->
    AM.CSSHelper.objectToString styleObject

  # Converts a style object to a css attribute. Useful in templates as a helper to construct the style attribute.
  style: (styleObject) ->
    style: AM.CSSHelper.objectToString styleObject

  # Converts an array of style classes into a class attribute. It doesn't return anything
  # if the array is empty (or null) so that class attribute is not unnecessarily created.
  class: (styleClassesArray) ->
    if styleClassesArray?.length
      class: styleClassesArray.join ' '

  # Renders the component into the parent component.
  render: ->
    console.log "RENDER?"
    @renderComponent(@currentComponent()) or null
