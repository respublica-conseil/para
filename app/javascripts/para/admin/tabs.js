  // Tabs hash management adapted from SO answer :
  //   http://stackoverflow.com/a/21443271/685925

var ref,
  boundMethodCheck = function(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new Error('Bound instance method accessed before binding'); } };

ref = Para.Tabs = (function() {
  class Tabs extends Vertebra.View {
    initialize(options = {}) {
      this.onTabShown = this.onTabShown.bind(this);
      
      this.$anchorInput = options.$anchorInput;
      this.showActiveTab();
      this.refreshTabsErrors();
      return this.initializeAffix();
    }

    showActiveTab() {
      var hash, ref1;
      if ((hash = location.hash || ((ref1 = this.$anchorInput) != null ? ref1.val() : void 0))) {
        return this.findTab(hash).tab('show');
      }
    }

    onTabShown(e) {
      var $tab, tabHash;
      boundMethodCheck(this, ref);
      $tab = $(e.target);
      if (!$tab.closest('[data-form-tabs]').is('[data-top-level-tabs]')) {
        return;
      }
      tabHash = $tab.attr('href');
      history.pushState(null, null, tabHash);
      return this.updateAnchorInput();
    }

    updateAnchorInput() {
      if (this.$anchorInput.length) {
        return this.$anchorInput.val(location.hash);
      }
    }

    refreshTabsErrors() {
      return this.$('[data-toggle="tab"]').each((i, tab) => {
        return this.refreshTabErrors($(tab));
      });
    }

    refreshTabErrors($tab) {
      var $panel;
      $panel = this.$($tab.attr('href'));
      if ($panel.find('.has-error').length) {
        return $tab.addClass('has-error');
      }
    }

    
    initializeAffix() {
      var headerHeight, offsetTop, sidebarWidth;
      if (!(this.$nav = this.$('[data-affix-header="tabs"]')).length) {
        return;
      }
      headerHeight = $('[data-header]').outerHeight();
      offsetTop = this.$nav.offset().top - headerHeight;
      sidebarWidth = $('[data-admin-left-sidebar]').outerWidth();
      this.$nav.affix({
        offset: {
          top: offsetTop
        }
      }).css({
        top: headerHeight,
        left: sidebarWidth
      });
      // Fix parent wrapper height to maintain the same scroll position when the
      // nav tabs are fixed to top
      return this.$nav.closest('[data-nav-tabs-wrapper]').height(this.$nav.outerHeight());
    }

    onFormInputUpdate(e) {
      var $tab;
      $tab = this.findTab($(e.currentTarget).attr('id'));
      return this.refreshTabErrors($tab);
    }

    findTab(id) {
      if (!(id.indexOf('#') >= 0)) {
        id = `#${id}`;
      }
      return this.$('a[href="' + id + '"]');
    }

  };

  Tabs.prototype.events = {
    'shown.bs.tab a[data-toggle="tab"]': 'onTabShown',
    'change .tab-pane': 'onFormInputUpdate'
  };

  return Tabs;

}).call(this);

$(document).on('turbo:load turbo:frame-load', function() {
  return $('[data-form-tabs]').each(function(i, el) {
    return new Para.Tabs({
      el: el,
      $anchorInput: $('[data-current-anchor]')
    });
  });
});
