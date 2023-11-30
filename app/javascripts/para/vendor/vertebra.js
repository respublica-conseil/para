var _now, delegateEventSplitter, lastUniqueId, uniqueId;

// Global Vertebra namespace
window.Vertebra = {};

// Allows assigning unique ids to views
lastUniqueId = 0;

uniqueId = function(prefix) {
  return [prefix, ++lastUniqueId].join('-');
};

// Regex to split delegated events string
delegateEventSplitter = /^(\S+)\s*(.*)$/;

window.camelize = function(str) {
  return str.replace(/(^|[-_])(.)/g, function(match) {
    return match.toUpperCase();
  }).replace(/[-_]/g, '');
};

window.trim = function(str) {
  return str.replace(/^\s+|\s+$/g, '');
};

window.isFunction = function(obj) {
  return !!(obj && obj.constructor && obj.call && obj.apply);
};

_now = Date.now || function() {
  return new Date().getTime();
};

// Throttle function borrowed from underscore.js
window.throttle = function(func, wait, options) {
  var later, previous;
  previous = 0;
  if (options == null) {
    options = {};
  }
  later = function() {
    var args, context, result, timeout;
    previous = options.leading === false ? 0 : _now();
    timeout = null;
    result = func.apply(context, args);
    if (!timeout) {
      context = args = null;
    }
  };
  return function() {
    var args, context, now, remaining, result, timeout;
    now = _now();
    if (!previous && options.leading === false) {
      previous = now;
    }
    remaining = wait - (now - previous);
    context = this;
    args = arguments;
    if (remaining <= 0 || remaining > wait) {
      if (timeout) {
        clearTimeout(timeout);
        timeout = null;
      }
      previous = now;
      result = func.apply(context, args);
      if (!timeout) {
        context = args = null;
      }
    } else if (!timeout && options.trailing !== false) {
      timeout = setTimeout(later, remaining);
    }
    return result;
  };
};

// Minimalist Backbon.View with support for view element, this.$ and delegated
// events on initialization.

// Only depends on jQuery, and not underscore.js
window.Vertebra.View = class View {
  $(selector) {
    return this.$el.find(selector);
  }

  constructor(options) {
    var ref;
    if (options.el) {
      this.setElement(options.el);
    }
    this._eventListeners = {};
    this._listeningTo = {};
    this.cid = uniqueId('view');
    if ((ref = this.initialize) != null) {
      ref.apply(this, arguments);
    }
  }

  setElement(el) {
    this.$el = el instanceof $ ? el : $(el);
    this.el = this.$el[0];
    return this.delegateEvents();
  }

  delegateEvents() {
    var events, key, match, method, results;
    this._undelegateEvents();
    if (!this.events) {
      return;
    }
    events = isFunction(this.events) ? this.events() : this.events;
    results = [];
    for (key in events) {
      method = events[key];
      method = this[method];
      if (!method) {
        continue;
      }
      match = key.match(delegateEventSplitter);
      results.push(this.delegate(match[1], match[2], $.proxy(method, this)));
    }
    return results;
  }

  delegate(eventName, selector, listener) {
    var ref;
    return (ref = this.$el) != null ? ref.on(eventName + '.delegateEvents' + this.cid, selector, listener) : void 0;
  }

  _undelegateEvents() {
    var ref;
    return (ref = this.$el) != null ? ref.off('.delegateEvents' + this.cid) : void 0;
  }

  listenTo(object, eventName, listener) {
    var base, base1, name;
    if ((base = this._listeningTo)[name = object.cid] == null) {
      base[name] = {};
    }
    if ((base1 = this._listeningTo[object.cid])[eventName] == null) {
      base1[eventName] = [];
    }
    this._listeningTo[object.cid][eventName].push(listener);
    return object.on(eventName, (() => {
      return listener.apply(this, arguments);
    }));
  }

  on(eventName, listener) {
    var base;
    if ((base = this._eventListeners)[eventName] == null) {
      base[eventName] = [];
    }
    return this._eventListeners[eventName].push(listener);
  }

  off(eventName, listener) {
    var index, listeners, results;
    if (!(listeners = this._eventListeners[eventName])) {
      return;
    }
    if (listener) {
      results = [];
      for (index in listeners) {
        if (listeners[index] === listener) {
          results.push(listeners.splice(index, 1));
        }
      }
      return results;
    } else {
      return this._eventListeners[eventName] = [];
    }
  }

  trigger(eventName, ...args) {
    var i, len, listener, listeners, results;
    if ((listeners = this._eventListeners[eventName])) {
      results = [];
      for (i = 0, len = listeners.length; i < len; i++) {
        listener = listeners[i];
        results.push(listener.apply(this, args));
      }
      return results;
    }
  }

  stopListeningTo(object, eventName, listener) {
    var i, len, listeners, listenersHash, results;
    if ((listenersHash = this._listeningTo[object.cid]) && (listeners = listenersHash[eventName])) {
      results = [];
      for (i = 0, len = listeners.length; i < len; i++) {
        listener = listeners[i];
        results.push(object.off(eventName, listener));
      }
      return results;
    }
  }

  stopListening() {
    var eventName, events, listeners, object, ref, results;
    if (!this._listeningTo) {
      return;
    }
    ref = this._listeningTo;
    results = [];
    for (object in ref) {
      events = ref[object];
      results.push((function() {
        var results1;
        results1 = [];
        for (eventName in events) {
          listeners = events[eventName];
          results1.push(this.stopListeningTo(object, eventName, listener));
        }
        return results1;
      }).call(this));
    }
    return results;
  }

  destroy() {
    return this.stopListening();
  }

};
