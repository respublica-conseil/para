Para.ResourceTree = class ResourceTree {
  constructor($el1) {
    this.initializeSubTree = this.initializeSubTree.bind(this);
    // Note : This method is called often (many times per second while we're dragging) and
    // takes quite some processing.
    this.isMovementValid = this.isMovementValid.bind(this);
    this.handleOrderUpdated = this.handleOrderUpdated.bind(this);
    this.orderUpdated = this.orderUpdated.bind(this);
    this.$el = $el1;
    this.initializeTree();
  }

  initializeTree() {
    this.orderUrl = this.$el.data('url');
    this.maxDepth = parseInt(this.$el.data('max-depth'));
    // Each is needed here as the sortable jQuery plugin doesn't loop over each found node
    // but initializes the tree on the first found element.
    return $(".tree").each(this.initializeSubTree);
  }

  initializeSubTree(_i, el) {
    return $(el).sortable({
      group: "tree",
      handle: ".handle",
      draggable: ".node",
      fallbackOnBody: true,
      swapThreshold: 0.65,
      animation: 150,
      onSort: this.handleOrderUpdated,
      onMove: this.isMovementValid
    });
  }

  isMovementValid(e) {
    var $movedNode, $movedNodeSubtrees, $target, finalSubtreeDeepnessAfterMove, movedNodeDeepness, movedNodeTreeDeepness, targetDeepness;
    $movedNode = $(e.dragged);
    $target = $(e.related);
    // Calculate the deepness of the moved and target nodes
    movedNodeDeepness = $movedNode.parents(".node").length - 1;
    // If the target is a node, the moved node root deepness is gonna be the same as the
    // the target one, else the tree's parent node is counted also
    targetDeepness = $target.parents(".node").length - 1;
    // Find the deepest node in the subtree of the moved node
    $movedNodeSubtrees = $movedNode.find(".tree");
    movedNodeTreeDeepness = 0;
    // The movedNodeTreeDeepness is the maximum deepness of a child node of the current
    // moved node, relative to the moved node
    $movedNodeSubtrees.each((i, el) => {
      var subtreeDeepness, subtreeRelativeDeepness;
      subtreeDeepness = $(el).parents(".node").length - 1;
      subtreeRelativeDeepness = subtreeDeepness - movedNodeDeepness;
      return movedNodeTreeDeepness = Math.max(movedNodeTreeDeepness, subtreeRelativeDeepness);
    });
    // Calculate the final subtree deepness once we move the whole moved node subtree to
    // its target position
    finalSubtreeDeepnessAfterMove = movedNodeTreeDeepness + targetDeepness;
    // We finally validate the move only if the final subtree deepness is lower than the
    // maximum allowed depth
    return finalSubtreeDeepnessAfterMove <= this.maxDepth;
  }

  handleOrderUpdated(e) {
    var $el, j, len, treeLeaves;
    // Get all involved tree leaves that may include a subtree
    treeLeaves = [$(e.target), $(e.from), $(e.item).find('.tree')];
    for (j = 0, len = treeLeaves.length; j < len; j++) {
      $el = treeLeaves[j];
      // Update their placeholder display wether they can be a drop target or not
      this.handlePlaceholder($el);
    }
    // Save the tree structure on the server
    return this.updateOrder();
  }

  // This method checks wether a given tree leaf can be a drop target, depending
  // on wether it's located at the maximum allowed depth for the tree or not, and adds or
  // remove a the visual placeholder to indicate its droppable state.

  handlePlaceholder($el) {
    var $placeholder, hasChildren, parentsCount;
    $placeholder = $el.find("> .placeholder");
    parentsCount = $el.parents('.node').length - 1;
    hasChildren = $el.find('> .node').length;
    if (parentsCount >= this.maxDepth || hasChildren) {
      $placeholder.hide();
      return $el.children(".tree").each((index, el) => {
        return this.handlePlaceholder($(el));
      });
    } else {
      return $placeholder.show();
    }
  }

  updateOrder() {
    return Para.ajax({
      url: this.orderUrl,
      method: 'patch',
      data: {
        resources: this.buildOrderedData()
      },
      success: this.orderUpdated
    });
  }

  buildOrderedData() {
    var data;
    data = {};
    $(".node").each(function(index) {
      var $this;
      $this = $(this);
      return data[index] = {
        id: $this.data("id"),
        position: index,
        parent_id: $this.parents(".node:first").data("id")
      };
    });
    return data;
  }

  orderUpdated() {}

};

// TODO: Add flash message to display ordering success
$(document).on('turbo:load turbo:frame-load', function() {
  return $('.root-tree').each(function(i, el) {
    return new Para.ResourceTree($(el));
  });
});
