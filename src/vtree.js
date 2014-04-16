(function() {
  var modules;

  modules = {};

  window.modula = {
    "export": function(name, exports) {
      return modules[name] = exports;
    },
    require: function(name) {
      var Module;
      Module = modules[name];
      if (Module) {
        return Module;
      } else {
        throw "Module '" + name + "' not found.";
      }
    }
  };

}).call(this);

(function() {
  var Configuration;

  Configuration = (function() {
    function Configuration() {}

    Configuration.prototype.viewSelector = '[data-view]';

    Configuration.prototype.appPelector = '[data-app]';

    Configuration.prototype.selector = '[data-app], [data-view]';

    Configuration.prototype.componentPattern = /(.+)#(.+)/;

    Configuration.prototype.isLayout = function($el) {
      return $el.data('app') != null;
    };

    Configuration.prototype.layoutUnderscoredName = function($el) {
      return $el.data('app');
    };

    Configuration.prototype.nodeUnderscoredName = function($el) {
      if (this.isLayout($el)) {
        return 'layout';
      } else {
        return $el.data('view') || '';
      }
    };

    Configuration.prototype.hasComponent = function($el) {
      return this.componentPattern.test(this.nodeUnderscoredName($el));
    };

    Configuration.prototype.extractComponentData = function($el) {
      var componentName, viewName, __, _ref;
      _ref = this.nodeUnderscoredName($el).match(this.componentPattern), __ = _ref[0], componentName = _ref[1], viewName = _ref[2];
      return [componentName, viewName];
    };

    return Configuration;

  })();

  modula["export"]('vtree/configuration', Configuration);

}).call(this);

(function() {
  var Configuration, Vtree;

  Configuration = modula.require('vtree/configuration');

  Vtree = (function() {
    function Vtree() {}

    Vtree.initNodes = function() {
      this._launcher().launch();
      return this._launcher().createViewsTree();
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
      return _.extend(this.config(), options);
    };

    Vtree.config = function() {
      return this._config = new Configuration;
    };

    Vtree.hooks = function() {
      var Hooks;
      if (this._hooks != null) {
        return this._hooks;
      }
      Hooks = modula.require('vtree/hooks');
      return this._hooks != null ? this._hooks : this._hooks = new Hooks;
    };

    Vtree._launcher = function() {
      return this.__launcher != null ? this.__launcher : this.__launcher = modula.require('vtree/launcher');
    };

    return Vtree;

  })();

  modula["export"]('vtree', Vtree);

  window.Vtree = Vtree;

}).call(this);

(function() {
  var Hooks,
    __slice = [].slice;

  Hooks = (function() {
    function Hooks() {}

    Hooks.prototype.onInit = function(callback) {
      return this.onInitCallbacks().push(callback);
    };

    Hooks.prototype.onInitCallbacks = function() {
      return this._onInitCallbacks || (this._onInitCallbacks = []);
    };

    Hooks.prototype.init = function() {
      var args, callback, _i, _len, _ref, _results;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this.onInitCallbacks();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback.apply(null, args));
      }
      return _results;
    };

    Hooks.prototype.onActivation = function(callback) {
      return this.onActivationCallbacks().push(callback);
    };

    Hooks.prototype.onActivationCallbacks = function() {
      return this._onActivationCallbacks || (this._onActivationCallbacks = []);
    };

    Hooks.prototype.activate = function() {
      var args, callback, _i, _len, _ref, _results;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this.onActivationCallbacks();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback.apply(null, args));
      }
      return _results;
    };

    Hooks.prototype.onUnload = function(callback) {
      return this.onUnloadCallbacks().push(callback);
    };

    Hooks.prototype.onUnloadCallbacks = function() {
      return this._onUnloadCallbacks || (this._onUnloadCallbacks = []);
    };

    Hooks.prototype.unload = function() {
      var args, callback, _i, _len, _ref, _results;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this.onUnloadCallbacks();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback.apply(null, args));
      }
      return _results;
    };

    return Hooks;

  })();

  modula["export"]('vtree/hooks', Hooks);

}).call(this);

(function() {
  var VtreeNodesCache;

  VtreeNodesCache = (function() {
    function VtreeNodesCache(nodes, rootNodes) {
      this.nodes = nodes != null ? nodes : {};
      this.rootNodes = rootNodes != null ? rootNodes : [];
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
      return this.rootNodes.push(node);
    };

    VtreeNodesCache.prototype.getById = function(id) {
      return this.nodes[id];
    };

    VtreeNodesCache.prototype.removeById = function(id) {
      delete this.nodes[id];
      return this.rootNodes = _.reject(this.rootNodes, function(node) {
        return node.id === id;
      });
    };

    VtreeNodesCache.prototype.clear = function() {
      this.nodes = {};
      return this.rootNodes = [];
    };

    return VtreeNodesCache;

  })();

  modula["export"]('vtree/vtree_nodes_cache', VtreeNodesCache);

}).call(this);

(function() {
  var Hooks, Node;

  Hooks = modula.require('vtree/hooks');

  Node = (function() {
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

    Node.prototype.setChildren = function(nodes) {
      return this.children = _.filter(nodes, (function(_this) {
        return function(node) {
          return node.parent && node.parent.el === _this.el;
        };
      })(this));
    };

    Node.prototype.removeChild = function(node) {
      if (_.indexOf(this.children, node) === -1) {
        return;
      }
      return this.children = _.reject(this.children, function(childNode) {
        return childNode === node;
      });
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
      return this._isActivated || (this._isActivated = false);
    };

    Node.prototype.setAsRemoved = function() {
      return this._isRemoved = true;
    };

    Node.prototype.isRemoved = function() {
      return this._isRemoved || (this._isRemoved = false);
    };

    return Node;

  })();

  modula["export"]('vtree/node', Node);

}).call(this);

(function() {
  var NodeData;

  NodeData = (function() {
    NodeData.prototype.el = null;

    NodeData.prototype.$el = null;

    NodeData.prototype.isApplicationLayout = null;

    NodeData.prototype.isApplicationPart = null;

    NodeData.prototype.isComponentPart = null;

    NodeData.prototype.applicationId = null;

    NodeData.prototype.nodeName = null;

    NodeData.prototype.applicationName = null;

    NodeData.prototype.componentName = null;

    NodeData.prototype.nodeNameUnderscored = null;

    NodeData.prototype.applicationNameUnderscored = null;

    NodeData.prototype.componentNameUnderscored = null;

    function NodeData(options) {
      _.extend(this, options);
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

  modula["export"]('vtree/node_data', NodeData);

}).call(this);

(function() {
  var NodeData, NodeWrapper, Vtree;

  Vtree = modula.require('vtree');

  NodeData = modula.require('vtree/node_data');

  NodeWrapper = (function() {
    var COMPONENT_PATTERN, SECRET_KEY, layoutId;

    layoutId = 0;

    COMPONENT_PATTERN = /(.+)#(.+)/;

    SECRET_KEY = 'semarf';

    function NodeWrapper(node) {
      this.node = node;
      this.$el = this.node.$el;
      this.el = this.node.el;
      if (this.isLayout()) {
        layoutId++;
      }
      this.identifyNodeAttributes();
      this.initNodeDataObject();
    }

    NodeWrapper.prototype.identifyNodeAttributes = function() {
      var _ref;
      this.layoutName = this.layout().name;
      this.layoutId = this.layout().id;
      if (this.hasComponent()) {
        return _ref = Vtree.config().extractComponentData(this.$el), this.componentName = _ref[0], this.nodeName = _ref[1], _ref;
      } else {
        this.componentName = this.layoutName;
        return this.nodeName = this.nodeUnderscoredName();
      }
    };

    NodeWrapper.prototype.initNodeDataObject = function() {
      var _ref;
      this.nodeData = this.initNodeData();
      return (_ref = this._hooks()) != null ? typeof _ref.init === "function" ? _ref.init(this.nodeData) : void 0 : void 0;
    };

    NodeWrapper.prototype.initNodeData = function() {
      var applicationName, applicationNameUnderscored, componentName, componentNameUnderscored;
      if (this.hasComponent()) {
        componentNameUnderscored = this.componentName;
        componentName = this._camelize(this.componentName);
        applicationNameUnderscored = null;
        applicationName = null;
      } else {
        applicationNameUnderscored = this.componentName;
        applicationName = this._camelize(this.componentName);
        componentNameUnderscored = null;
        componentName = null;
      }
      return new NodeData({
        el: this.el,
        $el: this.$el,
        isApplicationLayout: this.isLayout(),
        isApplicationPart: !this.hasComponent(),
        isComponentPart: this.hasComponent(),
        applicationId: !this.hasComponent() ? this.layoutId : null,
        nodeName: this._camelize(this.nodeName),
        nodeNameUnderscored: this.nodeName,
        applicationName: applicationName,
        applicationNameUnderscored: applicationNameUnderscored,
        componentName: componentName,
        componentNameUnderscored: componentNameUnderscored
      });
    };

    NodeWrapper.prototype.unload = function() {
      var _ref;
      if ((_ref = this._hooks()) != null) {
        if (typeof _ref.unload === "function") {
          _ref.unload(this.nodeData);
        }
      }
      delete this.nodeData;
      return delete this.node;
    };

    NodeWrapper.prototype.hasComponent = function() {
      return this._hasComponent || (this._hasComponent = Vtree.config().hasComponent(this.$el));
    };

    NodeWrapper.prototype.layout = function() {
      return this._layout || (this._layout = this.isLayout() ? {
        name: this.layoutUnderscoredName(),
        id: layoutId
      } : this.node.parent != null ? this.node.parent.nodeWrapper.layout() : {
        name: SECRET_KEY,
        id: 0
      });
    };

    NodeWrapper.prototype.isLayout = function() {
      return this._isLayout != null ? this._isLayout : this._isLayout = Vtree.config().isLayout(this.$el);
    };

    NodeWrapper.prototype.layoutUnderscoredName = function() {
      return this._layoutUnderscoredName != null ? this._layoutUnderscoredName : this._layoutUnderscoredName = Vtree.config().layoutUnderscoredName(this.$el);
    };

    NodeWrapper.prototype.nodeUnderscoredName = function() {
      return this._nodeUnderscoredName != null ? this._nodeUnderscoredName : this._nodeUnderscoredName = Vtree.config().nodeUnderscoredName(this.$el);
    };

    NodeWrapper.prototype._hooks = function() {
      return Vtree.hooks();
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

  modula["export"]('vtree/node_wrapper', NodeWrapper);

}).call(this);

(function() {
  var Hooks, Node, NodeWrapper, NodesCache, TreeManager, Vtree;

  Vtree = modula.require('vtree');

  NodesCache = modula.require('vtree/vtree_nodes_cache');

  Node = modula.require('vtree/node');

  NodeWrapper = modula.require('vtree/node_wrapper');

  Hooks = modula.require('vtree/hooks');

  TreeManager = (function() {
    function TreeManager() {
      this.initNodeHooks();
      this.initialNodes = [];
      this.nodesCache = new NodesCache();
    }

    TreeManager.prototype.initNodeHooks = function() {
      this.hooks = new Hooks;
      this.hooks.onInit(_.bind(this.addNodeIdToElData, this));
      this.hooks.onInit(_.bind(this.addRemoveEventHandlerToEl, this));
      this.hooks.onActivation(_.bind(this.addNodeWrapper, this));
      this.hooks.onUnload(_.bind(this.unloadView, this));
      return this.hooks.onUnload(_.bind(this.deleteNodeWrapper, this));
    };

    TreeManager.prototype.createTree = function() {
      this.setInitialNodes();
      this.setParentsForInitialNodes();
      this.setChildrenForInitialNodes();
      return this.activateInitialNodes();
    };

    TreeManager.prototype.setInitialNodes = function() {
      var $els, i, node, _i, _ref, _results;
      $els = $(Vtree.config().selector);
      this.initialNodes = [];
      _results = [];
      for (i = _i = 0, _ref = $els.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        node = new Node($els.eq(i), this.hooks);
        this.nodesCache.add(node);
        _results.push(this.initialNodes.push(node));
      }
      return _results;
    };

    TreeManager.prototype.setParentsForInitialNodes = function() {
      return this.setParentsForNodes(this.initialNodes);
    };

    TreeManager.prototype.setChildrenForInitialNodes = function() {
      return this.setChildrenForNodes(this.initialNodes);
    };

    TreeManager.prototype.setParentsForNodes = function(nodes) {
      var $parentEl, node, nodeId, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        node = nodes[_i];
        $parentEl = node.$el.parent().closest(Vtree.config().selector);
        if ($parentEl.length === 0) {
          _results.push(this.nodesCache.addAsRoot(node));
        } else {
          nodeId = $parentEl.data('vtree-node-id');
          _results.push(node.parent = this.nodesCache.getById(nodeId));
        }
      }
      return _results;
    };

    TreeManager.prototype.setChildrenForNodes = function(nodes) {
      var node;
      if (!nodes.length) {
        return;
      }
      node = nodes.shift();
      node.setChildren(nodes);
      return this.setChildrenForNodes(nodes);
    };

    TreeManager.prototype.activateInitialNodes = function() {
      return this.activateRootNodes(this.initialNodes);
    };

    TreeManager.prototype.activateRootNodes = function(nodes) {
      var node, rootNodes, _i, _len, _results;
      rootNodes = this.nodesCache.showRootNodes();
      _results = [];
      for (_i = 0, _len = rootNodes.length; _i < _len; _i++) {
        node = rootNodes[_i];
        _results.push(this.activateNode(node));
      }
      return _results;
    };

    TreeManager.prototype.activateNode = function(node) {
      var childNode, _i, _len, _ref, _results;
      node.activate();
      _ref = node.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        childNode = _ref[_i];
        _results.push(this.activateNode(childNode));
      }
      return _results;
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
      var childNode, tempChildren, _i, _len, _results;
      tempChildren = _.clone(node.children);
      _results = [];
      for (_i = 0, _len = tempChildren.length; _i < _len; _i++) {
        childNode = tempChildren[_i];
        this.removeChildNodes(childNode);
        childNode.remove();
        _results.push(this.nodesCache.removeById(childNode.id));
      }
      return _results;
    };

    TreeManager.prototype.refresh = function(refreshedNode) {
      var $el, $els, i, newNodes, node, nodeId, _i, _ref;
      $els = refreshedNode.$el.find(Vtree.config().selector);
      newNodes = [refreshedNode];
      for (i = _i = 0, _ref = $els.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        $el = $els.eq(i);
        if (nodeId = $el.data('vtree-node-id')) {
          node = this.nodesCache.getById(nodeId);
        } else {
          node = new Node($els.eq(i), this.hooks);
          this.nodesCache.add(node);
        }
        newNodes.push(node);
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
      return node.nodeWrapper = new NodeWrapper(node);
    };

    TreeManager.prototype.unloadView = function(node) {
      var _ref;
      return (_ref = node.nodeWrapper) != null ? typeof _ref.unload === "function" ? _ref.unload() : void 0 : void 0;
    };

    TreeManager.prototype.deleteNodeWrapper = function(node) {
      return delete node.nodeWrapper;
    };

    return TreeManager;

  })();

  modula["export"]('vtree/tree_manager', TreeManager);

}).call(this);

(function() {
  var Launcher, TreeManager, Vtree;

  Vtree = modula.require('vtree');

  TreeManager = modula.require('vtree/tree_manager');

  Launcher = (function() {
    function Launcher() {}

    Launcher.launch = function() {
      this.initTreeManager();
      this.initRemoveEvent();
      return this.initRefreshEvent();
    };

    Launcher.initTreeManager = function() {
      if (this.isTreeManagerInitialized()) {
        return;
      }
      this.setTreeManagerAsInitialized();
      return this.treeManager = new TreeManager();
    };

    Launcher.initRemoveEvent = function() {
      if (this.isRemoveEventInitialized()) {
        return;
      }
      this.setRemoveEventAsInitialized();
      return $.event.special.remove = {
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

    Launcher.initRefreshEvent = function() {
      if (this.isRefreshEventInitialized()) {
        return;
      }
      this.setRefreshEventAsInitialized();
      return $('body').on('refresh', '*', (function(_this) {
        return function(e) {
          var $elWithNode, node, nodeId;
          e.stopPropagation();
          $elWithNode = $(e.currentTarget).closest(Vtree.config().selector);
          nodeId = $elWithNode.data('vtree-node-id');
          while ($elWithNode.length && !nodeId) {
            $elWithNode = $elWithNode.parent().closest(Vtree.config().selector);
            nodeId = $elWithNode.data('vtree-node-id');
          }
          if (!nodeId) {
            return;
          }
          node = _this.treeManager.nodesCache.getById(nodeId);
          return _this.treeManager.refresh(node);
        };
      })(this));
    };

    Launcher.createViewsTree = function() {
      return this.treeManager.createTree();
    };

    Launcher.isTreeManagerInitialized = function() {
      return this._isTreeManagerInitialized || (this._isTreeManagerInitialized = false);
    };

    Launcher.setTreeManagerAsInitialized = function() {
      return this._isTreeManagerInitialized = true;
    };

    Launcher.isRemoveEventInitialized = function() {
      return this._isRemoveEventInitialized || (this._isRemoveEventInitialized = false);
    };

    Launcher.setRemoveEventAsInitialized = function() {
      return this._isRemoveEventInitialized = true;
    };

    Launcher.isRefreshEventInitialized = function() {
      return this._isRefreshEventInitialized || (this._isRefreshEventInitialized = false);
    };

    Launcher.setRefreshEventAsInitialized = function() {
      return this._isRefreshEventInitialized = true;
    };

    return Launcher;

  })();

  modula["export"]('vtree/launcher', Launcher);

}).call(this);

(function() {
  var DOM;

  DOM = (function() {
    function DOM() {}

    DOM.html = function($el, html) {
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
      if ($el[0] === document.body) {
        return;
      }
      $el.before($inserterdEl);
      return $el.parent().trigger('refresh');
    };

    DOM.after = function($el, $inserterdEl) {
      if ($el[0] === document.body) {
        return;
      }
      $el.after($inserterdEl);
      return $el.parent().trigger('refresh');
    };

    DOM.remove = function($el) {
      return $el.remove();
    };

    return DOM;

  })();

  modula["export"]('vtree/dom', DOM);

  window.Vtree.DOM = DOM;

}).call(this);
