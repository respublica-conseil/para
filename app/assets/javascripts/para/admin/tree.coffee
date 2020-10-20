class Para.ResourceTree
  constructor: (@$el) ->
    @initializeTree()

  initializeTree: ->
    @orderUrl = @$el.data('url')
    @maxDepth = parseInt @$el.data('max-depth')

    # Each is needed here as the sortable jQuery plugin doesn't loop over each found node
    # but initializes the tree on the first found element.
    $(".tree").each(@initializeSubTree)

  initializeSubTree: (_i, el) =>
    $(el).sortable(
      group: "tree"
      handle: ".handle"
      draggable: ".node"
      fallbackOnBody: true
      swapThreshold: 0.65
      animation: 150
      onSort: @handleOrderUpdated
      onMove: @isMovementValid
    )

  # Note : This method is called often (many times per second while we're dragging) and
  # takes quite some processing.
  isMovementValid: (e) =>
    $movedNode = $(e.dragged)
    $target = $(e.related)

    # Calculate the deepness of the moved and target nodes
    movedNodeDeepness = $movedNode.parents(".node").length - 1
    # If the target is a node, the moved node root deepness is gonna be the same as the
    # the target one, else the tree's parent node is counted also
    targetDeepness = $target.parents(".node").length - 1

    # Find the deepest node in the subtree of the moved node
    $movedNodeSubtrees = $movedNode.find(".tree")
    movedNodeTreeDeepness = 0

    # The movedNodeTreeDeepness is the maximum deepness of a child node of the current
    # moved node, relative to the moved node
    $movedNodeSubtrees.each (i, el) =>
      subtreeDeepness = $(el).parents(".node").length - 1
      subtreeRelativeDeepness = subtreeDeepness - movedNodeDeepness
      movedNodeTreeDeepness = Math.max(movedNodeTreeDeepness, subtreeRelativeDeepness)

    # Calculate the final subtree deepness once we move the whole moved node subtree to
    # its target position
    finalSubtreeDeepnessAfterMove = movedNodeTreeDeepness + targetDeepness

    # We finally validate the move only if the final subtree deepness is lower than the
    # maximum allowed depth
    finalSubtreeDeepnessAfterMove <= @maxDepth

  handleOrderUpdated: (e) =>

    # Get all involved tree leaves that may include a subtree
    treeLeaves = [$(e.target), $(e.from), $(e.item).find('.tree')]

    # Update their placeholder display wether they can be a drop target or not
    @handlePlaceholder($el) for $el in treeLeaves
    # Save the tree structure on the server
    @updateOrder()

  # This method checks wether a given tree leaf can be a drop target, depending
  # on wether it's located at the maximum allowed depth for the tree or not, and adds or
  # remove a the visual placeholder to indicate its droppable state.
  #
  handlePlaceholder: ($el) ->
    $placeholder = $el.find("> .placeholder")
    parentsCount = $el.parents('.node').length - 1
    hasChildren = $el.find('> .node').length

    if parentsCount >= @maxDepth or hasChildren
      $placeholder.hide()
      $el.children(".tree").each (index, el) => @handlePlaceholder($(el))
    else
      $placeholder.show()

  updateOrder: ->
    Para.ajax(
      url: @orderUrl
      method: 'patch'
      data: { resources: @buildOrderedData() }
      success: @orderUpdated
    )

  buildOrderedData: ->
    data = {}
    $(".node").each (index) ->
      $this = $(this)
      data[index] = {
        id: $this.data("id"),
        position: index,
        parent_id: $this.parents(".node:first").data("id")
      }
    data

  orderUpdated: =>
    # TODO: Add flash message to display ordering success

$(document).on 'page:change turbolinks:load', ->
  $('.root-tree').each (i, el) ->
    new Para.ResourceTree($(el))
