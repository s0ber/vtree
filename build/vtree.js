(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("jquery"));
	else if(typeof define === 'function' && define.amd)
		define(["jquery"], factory);
	else if(typeof exports === 'object')
		exports["Vtree"] = factory(require("jquery"));
	else
		root["Vtree"] = factory(root["jquery"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_2__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(1);


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	var $, Configuration, DOM, Launcher, Vtree;
	
	$ = __webpack_require__(2);
	
	Configuration = __webpack_require__(3);
	
	DOM = __webpack_require__(4);
	
	Launcher = __webpack_require__(6);
	
	module.exports = Vtree = (function() {
	  function Vtree() {}
	
	  Vtree.DOM = DOM;
	
	  Vtree.initNodes = function() {
	    this._launcher().launch(this.config());
	    return this._launcher().createViewsTree();
	  };
	
	  Vtree.initNodesAsync = function() {
	    return AsyncFn.addToCallQueue((function(_this) {
	      return function() {
	        var dfd;
	        dfd = new $.Deferred();
	        AsyncFn.setImmediate(function() {
	          _this.initNodes();
	          return dfd.resolve();
	        });
	        return dfd.promise();
	      };
	    })(this));
	  };
	
	  Vtree.onNodeInit = function(callback) {
	    return this.hooks().onInit(callback);
	  };
	
	  Vtree.getInitCallbacks = function() {
	    return this.hooks().onInitCallbacks();
	  };
	
	  Vtree.onNodeUnload = function(callback) {
	    return this.hooks().onUnload(callback);
	  };
	
	  Vtree.getUnloadCallbacks = function() {
	    return this.hooks().onUnloadCallbacks();
	  };
	
	  Vtree.configure = function(options) {
	    var key, results, value;
	    results = [];
	    for (key in options) {
	      value = options[key];
	      results.push(this.config()[key] = value);
	    }
	    return results;
	  };
	
	  Vtree.config = function() {
	    return this._config != null ? this._config : this._config = new Configuration;
	  };
	
	  Vtree.hooks = function() {
	    return this._launcher().hooks();
	  };
	
	  Vtree._launcher = function() {
	    return this.__launcher != null ? this.__launcher : this.__launcher = Launcher;
	  };
	
	  return Vtree;
	
	})();
	
	window.Vtree = Vtree;


/***/ },
/* 2 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_2__;

/***/ },
/* 3 */
/***/ function(module, exports) {

	var Configuration;
	
	module.exports = Configuration = (function() {
	  function Configuration() {}
	
	  Configuration.prototype.viewSelector = '[data-view]';
	
	  Configuration.prototype.componentSelector = '[data-component]';
	
	  Configuration.prototype.selector = '[data-component], [data-view]';
	
	  Configuration.prototype.namespacePattern = /(.+)#(.+)/;
	
	  Configuration.prototype.isComponentIndex = function($el) {
	    return $el.data('component') != null;
	  };
	
	  Configuration.prototype.nodeUnderscoredName = function($el) {
	    if (this.isComponentIndex($el)) {
	      return $el.data('component');
	    } else {
	      return $el.data('view') || '';
	    }
	  };
	
	  Configuration.prototype.isStandAlone = function($el) {
	    return !this.isComponentIndex($el) && this.namespacePattern.test(this.nodeUnderscoredName($el));
	  };
	
	  Configuration.prototype.extractStandAloneNodeData = function($el) {
	    var __, namespaceName, nodeName, ref;
	    ref = this.nodeUnderscoredName($el).match(this.namespacePattern), __ = ref[0], namespaceName = ref[1], nodeName = ref[2];
	    return [namespaceName, nodeName];
	  };
	
	  Configuration.prototype.extractComponentIndexNodeData = function($el) {
	    var __, componentName, namespaceName, ref;
	    ref = this.nodeUnderscoredName($el).match(this.namespacePattern), __ = ref[0], namespaceName = ref[1], componentName = ref[2];
	    return [namespaceName, componentName];
	  };
	
	  return Configuration;

	})();


/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	var $, AsyncFn, DOM;
	
	$ = __webpack_require__(2);
	
	AsyncFn = __webpack_require__(5);
	
	module.exports = DOM = (function() {
	  function DOM() {}
	
	  DOM.html = function($el, html) {
	    $el.children().each(function(i, child) {
	      return $(child).remove();
	    });
	    $el.html(html);
	    return $el.trigger('refresh');
	  };
	
	  DOM.append = function($parentEl, $el) {
	    $parentEl.append($el);
	    return $parentEl.trigger('refresh');
	  };
	
	  DOM.prepend = function($parentEl, $el) {
	    $parentEl.prepend($el);
	    return $parentEl.trigger('refresh');
	  };
	
	  DOM.before = function($el, $inserterdEl) {
	    $el.before($inserterdEl);
	    return $el.parent().trigger('refresh');
	  };
	
	  DOM.after = function($el, $inserterdEl) {
	    $el.after($inserterdEl);
	    return $el.parent().trigger('refresh');
	  };
	
	  DOM.remove = function($el) {
	    return $el.remove();
	  };
	
	  DOM.htmlAsync = function($el, html) {
	    return AsyncFn.addToCallQueue(function() {
	      var dfd;
	      dfd = new $.Deferred();
	      AsyncFn.setImmediate(function() {
	        $el.children().each(function(i, child) {
	          return $(child).remove();
	        });
	        $el.html(html);
	        $el.trigger('refresh');
	        return dfd.resolve();
	      });
	      return dfd.promise();
	    });
	  };
	
	  DOM.appendAsync = function($parentEl, $el) {
	    return AsyncFn.addToCallQueue(function() {
	      var dfd;
	      dfd = new $.Deferred();
	      AsyncFn.setImmediate(function() {
	        $parentEl.append($el);
	        $parentEl.trigger('refresh');
	        return dfd.resolve();
	      });
	      return dfd.promise();
	    });
	  };
	
	  DOM.prependAsync = function($parentEl, $el) {
	    return AsyncFn.addToCallQueue(function() {
	      var dfd;
	      dfd = new $.Deferred();
	      AsyncFn.setImmediate(function() {
	        $parentEl.prepend($el);
	        $parentEl.trigger('refresh');
	        return dfd.resolve();
	      });
	      return dfd.promise();
	    });
	  };
	
	  DOM.beforeAsync = function($el, $inserterdEl) {
	    return AsyncFn.addToCallQueue(function() {
	      var dfd;
	      dfd = new $.Deferred();
	      AsyncFn.setImmediate(function() {
	        $el.before($inserterdEl);
	        $el.parent().trigger('refresh');
	        return dfd.resolve();
	      });
	      return dfd.promise();
	    });
	  };
	
	  DOM.afterAsync = function($el, $inserterdEl) {
	    return AsyncFn.addToCallQueue(function() {
	      var dfd;
	      dfd = new $.Deferred();
	      AsyncFn.setImmediate(function() {
	        $el.after($inserterdEl);
	        $el.parent().trigger('refresh');
	        return dfd.resolve();
	      });
	      return dfd.promise();
	    });
	  };
	
	  return DOM;

	})();


/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	!function(n,e){ true?module.exports=e(__webpack_require__(2)):"function"==typeof define&&define.amd?define(["jquery"],e):"object"==typeof exports?exports.AsyncFn=e(require("jquery")):n.AsyncFn=e(n.jquery)}(this,function(n){return function(n){function e(r){if(t[r])return t[r].exports;var o=t[r]={exports:{},id:r,loaded:!1};return n[r].call(o.exports,o,o.exports,e),o.loaded=!0,o.exports}var t={};return e.m=n,e.c=t,e.p="",e(0)}([function(n,e,t){n.exports=t(1)},function(n,e,t){var r;r=t(2),n.exports=window.AsyncFn=function(){function n(n){this.dfd=new r.Deferred,this.fn=n}return n.prototype.done=function(n){if(this.callback=n,this.isCalled)return this.callback()},n.prototype.call=function(){if(!this.isCalled)return this.fn().always(function(n){return function(){if(n.isCalled=!0,n.dfd.resolve(),n.callback)return n.callback()}}(this))},n.addToCallQueue=function(e){var t;return t=new n(e),null!=this.currentFn?this.currentFn.done(function(){return t.call()}):t.call(),this.currentFn=t},n.setImmediate=function(){var n,e,t,r;return e={},r=e,n=Math.random(),t=function(t){var r;if(t.data.toString()===n.toString())return e=e.next,r=e.func,delete e.func,r()},window.addEventListener&&window.postMessage?(window.addEventListener("message",t,!1),function(e){return r=r.next={func:e},window.postMessage(n,"*")}):function(n){return setTimeout(n,0)}}(),n}()},function(e,t){e.exports=n}])});
	//# sourceMappingURL=async_fn.min.js.map

/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	var $, Hooks, Launcher, TreeManager;
	
	$ = __webpack_require__(2);
	
	TreeManager = __webpack_require__(7);
	
	Hooks = __webpack_require__(10);
	
	module.exports = Launcher = (function() {
	  function Launcher() {}
	
	  Launcher.launch = function(config) {
	    this.initTreeManager(config);
	    this.initRemoveEvent();
	    return this.initRefreshEvent(config);
	  };
	
	  Launcher.initTreeManager = function(config) {
	    return this.treeManager = new TreeManager(config, this.hooks());
	  };
	
	  Launcher.initRemoveEvent = function() {
	    var base;
	    return (base = $.event.special).remove != null ? base.remove : base.remove = {
	      remove: function(handleObj) {
	        var e, el;
	        el = this;
	        e = {
	          type: 'remove',
	          data: handleObj.data,
	          currentTarget: el
	        };
	        return handleObj.handler(e);
	      }
	    };
	  };
	
	  Launcher.initRefreshEvent = function(config) {
	    var refreshHandler;
	    if (this.isRefreshEventInitialized) {
	      return;
	    }
	    this.isRefreshEventInitialized = true;
	    refreshHandler = (function(_this) {
	      return function(e) {
	        var $elWithNode, node, nodeId;
	        e.stopPropagation();
	        $elWithNode = $(e.currentTarget).closest(config.selector);
	        nodeId = $elWithNode.data('vtree-node-id');
	        while ($elWithNode.length && !nodeId) {
	          $elWithNode = $elWithNode.parent().closest(config.selector);
	          nodeId = $elWithNode.data('vtree-node-id');
	        }
	        if (!nodeId) {
	          return;
	        }
	        node = _this.treeManager.nodesCache.getById(nodeId);
	        return _this.treeManager.refresh(node);
	      };
	    })(this);
	    $('body').on('refresh', refreshHandler);
	    return $('body').on('refresh', '*', refreshHandler);
	  };
	
	  Launcher.createViewsTree = function() {
	    return this.treeManager.createTree();
	  };
	
	  Launcher.hooks = function() {
	    if (this._hooks != null) {
	      return this._hooks;
	    }
	    return this._hooks != null ? this._hooks : this._hooks = new Hooks;
	  };
	
	  return Launcher;

	})();


/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	var $, Hooks, Node, NodeWrapper, NodesCache, TreeManager;
	
	$ = __webpack_require__(2);
	
	NodesCache = __webpack_require__(8);
	
	Node = __webpack_require__(9);
	
	NodeWrapper = __webpack_require__(11);
	
	Hooks = __webpack_require__(10);
	
	module.exports = TreeManager = (function() {
	  function TreeManager(config, launcherHooks) {
	    this.config = config;
	    this.launcherHooks = launcherHooks;
	    if (this.config == null) {
	      throw new Error('Config is required');
	    }
	    if (this.launcherHooks == null) {
	      throw new Error('Launcher hooks are required');
	    }
	    this.initNodeHooks();
	    this.initialNodes = [];
	    this.nodesCache = new NodesCache();
	  }
	
	  TreeManager.prototype.initNodeHooks = function() {
	    this.hooks = new Hooks;
	    this.hooks.onInit(this.addNodeIdToElData);
	    this.hooks.onInit((function(_this) {
	      return function(node) {
	        return _this.addRemoveEventHandlerToEl(node);
	      };
	    })(this));
	    this.hooks.onActivation((function(_this) {
	      return function(node) {
	        return _this.addNodeWrapper(node);
	      };
	    })(this));
	    this.hooks.onUnload(this.unloadNode);
	    return this.hooks.onUnload(this.deleteNodeWrapper);
	  };
	
	  TreeManager.prototype.createTree = function() {
	    this.setInitialNodes();
	    this.setParentsForInitialNodes();
	    this.setChildrenForInitialNodes();
	    return this.activateInitialNodes();
	  };
	
	  TreeManager.prototype.setInitialNodes = function() {
	    var $els, i, j, node, ref, results;
	    $els = $(this.config.selector);
	    this.initialNodes = [];
	    results = [];
	    for (i = j = 0, ref = $els.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
	      node = new Node($els.eq(i), this.hooks);
	      this.nodesCache.add(node);
	      results.push(this.initialNodes.push(node));
	    }
	    return results;
	  };
	
	  TreeManager.prototype.setParentsForInitialNodes = function() {
	    return this.setParentsForNodes(this.initialNodes);
	  };
	
	  TreeManager.prototype.setChildrenForInitialNodes = function() {
	    return this.setChildrenForNodes(this.initialNodes);
	  };
	
	  TreeManager.prototype.setParentsForNodes = function(nodes) {
	    var $parentEl, j, len, node, nodeId, results;
	    results = [];
	    for (j = 0, len = nodes.length; j < len; j++) {
	      node = nodes[j];
	      $parentEl = node.$el.parent().closest(this.config.selector);
	      if ($parentEl.length === 0) {
	        results.push(this.nodesCache.addAsRoot(node));
	      } else {
	        nodeId = $parentEl.data('vtree-node-id');
	        results.push(node.parent = this.nodesCache.getById(nodeId));
	      }
	    }
	    return results;
	  };
	
	  TreeManager.prototype.setChildrenForNodes = function(nodes) {
	    var i, j, node, ref, ref1, results;
	    if (!nodes.length) {
	      return;
	    }
	    results = [];
	    for (i = j = ref = nodes.length - 1; ref <= 0 ? j <= 0 : j >= 0; i = ref <= 0 ? ++j : --j) {
	      node = nodes[i];
	      results.push((ref1 = node.parent) != null ? ref1.prependChild(node) : void 0);
	    }
	    return results;
	  };
	
	  TreeManager.prototype.activateInitialNodes = function() {
	    return this.activateRootNodes(this.initialNodes);
	  };
	
	  TreeManager.prototype.activateRootNodes = function(nodes) {
	    var j, len, node, results, rootNodes;
	    rootNodes = this.nodesCache.showRootNodes();
	    results = [];
	    for (j = 0, len = rootNodes.length; j < len; j++) {
	      node = rootNodes[j];
	      results.push(this.activateNode(node));
	    }
	    return results;
	  };
	
	  TreeManager.prototype.activateNode = function(node) {
	    var childNode, j, len, ref, results;
	    node.activate();
	    ref = node.children;
	    results = [];
	    for (j = 0, len = ref.length; j < len; j++) {
	      childNode = ref[j];
	      results.push(this.activateNode(childNode));
	    }
	    return results;
	  };
	
	  TreeManager.prototype.removeNode = function(node) {
	    if (node.isRemoved()) {
	      return;
	    }
	    if (node.parent) {
	      node.parent.removeChild(node);
	    }
	    this.removeChildNodes(node);
	    node.remove();
	    return this.nodesCache.removeById(node.id);
	  };
	
	  TreeManager.prototype.removeChildNodes = function(node) {
	    var childNode, j, len, ref, results;
	    ref = node.children;
	    results = [];
	    for (j = 0, len = ref.length; j < len; j++) {
	      childNode = ref[j];
	      this.removeChildNodes(childNode);
	      childNode.remove();
	      results.push(this.nodesCache.removeById(childNode.id));
	    }
	    return results;
	  };
	
	  TreeManager.prototype.refresh = function(refreshedNode) {
	    var $el, $els, i, j, k, len, newNodes, node, nodeId, ref;
	    $els = refreshedNode.$el.find(this.config.selector);
	    newNodes = [refreshedNode];
	    for (i = j = 0, ref = $els.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
	      $el = $els.eq(i);
	      if (nodeId = $el.data('vtree-node-id')) {
	        node = this.nodesCache.getById(nodeId);
	      } else {
	        node = new Node($el, this.hooks);
	        this.nodesCache.add(node);
	      }
	      newNodes.push(node);
	    }
	    for (k = 0, len = newNodes.length; k < len; k++) {
	      node = newNodes[k];
	      node.children.length = 0;
	    }
	    this.setParentsForNodes(newNodes);
	    this.setChildrenForNodes(newNodes);
	    return this.activateNode(refreshedNode);
	  };
	
	  TreeManager.prototype.addNodeIdToElData = function(node) {
	    return node.$el.data('vtree-node-id', node.id);
	  };
	
	  TreeManager.prototype.addRemoveEventHandlerToEl = function(node) {
	    return node.$el.on('remove', (function(_this) {
	      return function() {
	        return _this.removeNode(node);
	      };
	    })(this));
	  };
	
	  TreeManager.prototype.addNodeWrapper = function(node) {
	    return node.nodeWrapper = new NodeWrapper(node, this.config, this.launcherHooks);
	  };
	
	  TreeManager.prototype.unloadNode = function(node) {
	    var ref;
	    return (ref = node.nodeWrapper) != null ? typeof ref.unload === "function" ? ref.unload() : void 0 : void 0;
	  };
	
	  TreeManager.prototype.deleteNodeWrapper = function(node) {
	    return delete node.nodeWrapper;
	  };
	
	  return TreeManager;

	})();


/***/ },
/* 8 */
/***/ function(module, exports) {

	var VtreeNodesCache;
	
	module.exports = VtreeNodesCache = (function() {
	  function VtreeNodesCache() {
	    this.nodes = {};
	    this.rootNodes = [];
	  }
	
	  VtreeNodesCache.prototype.show = function() {
	    return this.nodes;
	  };
	
	  VtreeNodesCache.prototype.showRootNodes = function() {
	    return this.rootNodes;
	  };
	
	  VtreeNodesCache.prototype.add = function(node) {
	    return this.nodes[node.id] = node;
	  };
	
	  VtreeNodesCache.prototype.addAsRoot = function(node) {
	    if (this.nodes[node.id] == null) {
	      throw new Error('Trying to add node as root, but node is not cached previously');
	    }
	    return this.rootNodes.push(node);
	  };
	
	  VtreeNodesCache.prototype.getById = function(id) {
	    return this.nodes[id];
	  };
	
	  VtreeNodesCache.prototype.removeById = function(id) {
	    var nodeIndex;
	    if ((nodeIndex = this.rootNodes.indexOf(this.nodes[id])) !== -1) {
	      this.rootNodes.splice(nodeIndex, 1);
	    }
	    return delete this.nodes[id];
	  };
	
	  VtreeNodesCache.prototype.clear = function() {
	    this.nodes = {};
	    return this.rootNodes = [];
	  };
	
	  return VtreeNodesCache;

	})();


/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	var Hooks, Node;
	
	Hooks = __webpack_require__(10);
	
	module.exports = Node = (function() {
	  var nodeId;
	
	  nodeId = 1;
	
	  function Node($el, hooks) {
	    this.$el = $el;
	    this.hooks = hooks || new Hooks();
	    this.el = this.$el[0];
	    this.id = "nodeId" + nodeId;
	    this.parent = null;
	    this.children = [];
	    nodeId++;
	    this.init();
	  }
	
	  Node.prototype.setParent = function(node) {
	    return this.parent = node;
	  };
	
	  Node.prototype.prependChild = function(node) {
	    return this.children.unshift(node);
	  };
	
	  Node.prototype.appendChild = function(node) {
	    return this.children.push(node);
	  };
	
	  Node.prototype.removeChild = function(node) {
	    var nodeIndex;
	    if ((nodeIndex = this.children.indexOf(node)) === -1) {
	      return;
	    }
	    return this.children.splice(nodeIndex, 1);
	  };
	
	  Node.prototype.init = function() {
	    return this.hooks.init(this);
	  };
	
	  Node.prototype.activate = function() {
	    if (this.isActivated()) {
	      return;
	    }
	    this.setAsActivated();
	    return this.hooks.activate(this);
	  };
	
	  Node.prototype.remove = function() {
	    if (this.isRemoved()) {
	      return;
	    }
	    this.setAsRemoved();
	    if (this.isActivated()) {
	      return this.unload();
	    }
	  };
	
	  Node.prototype.unload = function() {
	    this.hooks.unload(this);
	    return this.setAsNotActivated();
	  };
	
	  Node.prototype.setAsActivated = function() {
	    return this._isActivated = true;
	  };
	
	  Node.prototype.setAsNotActivated = function() {
	    return this._isActivated = false;
	  };
	
	  Node.prototype.isActivated = function() {
	    return this._isActivated != null ? this._isActivated : this._isActivated = false;
	  };
	
	  Node.prototype.setAsRemoved = function() {
	    return this._isRemoved = true;
	  };
	
	  Node.prototype.isRemoved = function() {
	    return this._isRemoved != null ? this._isRemoved : this._isRemoved = false;
	  };
	
	  return Node;

	})();


/***/ },
/* 10 */
/***/ function(module, exports) {

	var Hooks,
	  slice = [].slice;
	
	module.exports = Hooks = (function() {
	  function Hooks() {}
	
	  Hooks.prototype.onInit = function(callback) {
	    return this.onInitCallbacks().push(callback);
	  };
	
	  Hooks.prototype.onInitCallbacks = function() {
	    return this._onInitCallbacks != null ? this._onInitCallbacks : this._onInitCallbacks = [];
	  };
	
	  Hooks.prototype.init = function() {
	    var args, callback, i, len, ref, results;
	    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
	    ref = this.onInitCallbacks();
	    results = [];
	    for (i = 0, len = ref.length; i < len; i++) {
	      callback = ref[i];
	      results.push(callback.apply(null, args));
	    }
	    return results;
	  };
	
	  Hooks.prototype.onActivation = function(callback) {
	    return this.onActivationCallbacks().push(callback);
	  };
	
	  Hooks.prototype.onActivationCallbacks = function() {
	    return this._onActivationCallbacks != null ? this._onActivationCallbacks : this._onActivationCallbacks = [];
	  };
	
	  Hooks.prototype.activate = function() {
	    var args, callback, i, len, ref, results;
	    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
	    ref = this.onActivationCallbacks();
	    results = [];
	    for (i = 0, len = ref.length; i < len; i++) {
	      callback = ref[i];
	      results.push(callback.apply(null, args));
	    }
	    return results;
	  };
	
	  Hooks.prototype.onUnload = function(callback) {
	    return this.onUnloadCallbacks().push(callback);
	  };
	
	  Hooks.prototype.onUnloadCallbacks = function() {
	    return this._onUnloadCallbacks != null ? this._onUnloadCallbacks : this._onUnloadCallbacks = [];
	  };
	
	  Hooks.prototype.unload = function() {
	    var args, callback, i, len, ref, results;
	    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
	    ref = this.onUnloadCallbacks();
	    results = [];
	    for (i = 0, len = ref.length; i < len; i++) {
	      callback = ref[i];
	      results.push(callback.apply(null, args));
	    }
	    return results;
	  };
	
	  Hooks.prototype._reset = function() {
	    this._onInitCallbacks = [];
	    this._onActivationCallbacks = [];
	    return this._onUnloadCallbacks = [];
	  };
	
	  return Hooks;

	})();


/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	var $, NodeData, NodeWrapper;
	
	$ = __webpack_require__(2);
	
	NodeData = __webpack_require__(12);
	
	module.exports = NodeWrapper = (function() {
	  var SECRET_KEY, componentId;
	
	  componentId = 0;
	
	  SECRET_KEY = 'semarf';
	
	  function NodeWrapper(node, config, launcherHooks) {
	    this.node = node;
	    this.config = config;
	    this.launcherHooks = launcherHooks;
	    if (this.config == null) {
	      throw new Error('Config is required');
	    }
	    if (this.launcherHooks == null) {
	      throw new Error('Launcher hooks are required');
	    }
	    this.$el = this.node.$el;
	    this.el = this.node.el;
	    if (this.isComponentIndex()) {
	      componentId++;
	    }
	    this.identifyNodeAttributes();
	    this.initNodeDataObject();
	  }
	
	  NodeWrapper.prototype.identifyNodeAttributes = function() {
	    var ref;
	    if (this.isStandAlone()) {
	      return ref = this.config.extractStandAloneNodeData(this.$el), this.namespaceName = ref[0], this.nodeName = ref[1], ref;
	    } else {
	      this.namespaceName = this.component().namespace;
	      return this.nodeName = this.isComponentIndex() ? 'index' : this.nodeUnderscoredName();
	    }
	  };
	
	  NodeWrapper.prototype.initNodeDataObject = function() {
	    var ref;
	    this.nodeData = this.initNodeData();
	    return (ref = this._hooks()) != null ? typeof ref.init === "function" ? ref.init(this.nodeData) : void 0 : void 0;
	  };
	
	  NodeWrapper.prototype.initNodeData = function() {
	    var componentName, componentNameUnderscored, namespaceName, namespaceNameUnderscored, ref, ref1;
	    namespaceNameUnderscored = this.namespaceName;
	    namespaceName = this._camelize(this.namespaceName);
	    if (this.isStandAlone()) {
	      componentNameUnderscored = null;
	      componentName = null;
	    } else {
	      componentNameUnderscored = this.component().name;
	      componentName = this._camelize(componentNameUnderscored);
	    }
	    return new NodeData({
	      el: this.el,
	      $el: this.$el,
	      isStandAlone: this.isStandAlone(),
	      isComponentIndex: this.isComponentIndex(),
	      isComponentPart: !this.isStandAlone(),
	      componentId: this.isStandAlone() ? null : this.component().id,
	      componentIndexNode: ((ref = this.componentIndexNode()) != null ? (ref1 = ref.nodeWrapper) != null ? ref1.nodeData : void 0 : void 0) || null,
	      nodeName: this._camelize(this.nodeName),
	      nodeNameUnderscored: this.nodeName,
	      componentName: componentName,
	      componentNameUnderscored: componentNameUnderscored,
	      namespaceName: namespaceName,
	      namespaceNameUnderscored: namespaceNameUnderscored
	    });
	  };
	
	  NodeWrapper.prototype.unload = function() {
	    var ref;
	    if ((ref = this._hooks()) != null) {
	      if (typeof ref.unload === "function") {
	        ref.unload(this.nodeData);
	      }
	    }
	    delete this.nodeData;
	    return delete this.node;
	  };
	
	  NodeWrapper.prototype.isStandAlone = function() {
	    return this._isStandAlone != null ? this._isStandAlone : this._isStandAlone = this.config.isStandAlone(this.$el);
	  };
	
	  NodeWrapper.prototype.component = function() {
	    var componentName, namespaceName, ref;
	    return this._component != null ? this._component : this._component = this.isComponentIndex() ? ((ref = this.config.extractComponentIndexNodeData(this.$el), namespaceName = ref[0], componentName = ref[1], ref), {
	      namespace: namespaceName,
	      name: componentName,
	      id: componentId,
	      node: this.node
	    }) : this.node.parent != null ? this.node.parent.nodeWrapper.component() : {
	      namespace: SECRET_KEY,
	      name: SECRET_KEY,
	      id: 0,
	      node: this.node
	    };
	  };
	
	  NodeWrapper.prototype.componentIndexNode = function() {
	    return this._componentIndexNode != null ? this._componentIndexNode : this._componentIndexNode = this.isStandAlone() || this.isComponentIndex() ? null : this.component().node;
	  };
	
	  NodeWrapper.prototype.isComponentIndex = function() {
	    return this._isComponentIndex != null ? this._isComponentIndex : this._isComponentIndex = this.config.isComponentIndex(this.$el);
	  };
	
	  NodeWrapper.prototype.nodeUnderscoredName = function() {
	    return this._nodeUnderscoredName != null ? this._nodeUnderscoredName : this._nodeUnderscoredName = this.config.nodeUnderscoredName(this.$el);
	  };
	
	  NodeWrapper.prototype._hooks = function() {
	    return this.launcherHooks;
	  };
	
	  NodeWrapper.prototype._camelize = function(string) {
	    return string.replace(/(?:^|[-_])(\w)/g, function(_, c) {
	      if (c) {
	        return c.toUpperCase();
	      } else {
	        return '';
	      }
	    });
	  };
	
	  return NodeWrapper;

	})();


/***/ },
/* 12 */
/***/ function(module, exports) {

	var NodeData;
	
	module.exports = NodeData = (function() {
	  NodeData.prototype.el = null;
	
	  NodeData.prototype.$el = null;
	
	  NodeData.prototype.isComponentIndex = null;
	
	  NodeData.prototype.isComponentPart = null;
	
	  NodeData.prototype.isStandAlone = null;
	
	  NodeData.prototype.componentId = null;
	
	  NodeData.prototype.componentIndexNode = null;
	
	  NodeData.prototype.nodeName = null;
	
	  NodeData.prototype.componentName = null;
	
	  NodeData.prototype.namespaceName = null;
	
	  NodeData.prototype.nodeNameUnderscored = null;
	
	  NodeData.prototype.componentNameUnderscored = null;
	
	  NodeData.prototype.namespaceNameUnderscored = null;
	
	  function NodeData(options) {
	    var key, value;
	    for (key in options) {
	      value = options[key];
	      this[key] = value;
	    }
	    this.data = {};
	  }
	
	  NodeData.prototype.setData = function(name, value) {
	    return this.data[name] = value;
	  };
	
	  NodeData.prototype.getData = function(name) {
	    return this.data[name];
	  };
	
	  return NodeData;

	})();


/***/ }
/******/ ])
});
;