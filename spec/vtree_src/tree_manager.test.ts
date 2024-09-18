/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const $ = require('jquery');
const _ = require('underscore');
const Launcher = require('src/vtree_src/launcher');
const Node = require('src/vtree_src/node');
const TreeManager = require('src/vtree_src/tree_manager');
const Configuration = require('src/configuration');
const nodesForRefresh = require('../fixtures/nodes_for_refresh');
const nodesWithDataView = require('../fixtures/nodes_with_data_view');

describe('TreeManager', function() {

  describe('Node callbacks', function() {
    before(function() {
      this.config = new Configuration();
      this.launcherHooks = Launcher.hooks();
      Launcher.initRemoveEvent();
      return sinon.spy(TreeManager.prototype, 'initNodeHooks');
    });

    it('initializes hooks for view nodes when creating instance', function() {
      this.treeManager = new TreeManager(this.config, this.launcherHooks);
      return expect(this.treeManager.initNodeHooks).to.be.calledOnce;
    });

    beforeEach(function() {
      return this.$el = $('<div />');
    });

    describe('.initNodeHooks', function() {
      it('saves new Hooks object in @hooks', function() {
        this.treeManager = new TreeManager(this.config, this.launcherHooks);
        return expect(this.treeManager.hooks.constructor).to.match(/Hooks/);
      });

      it('adds @addNodeIdToElData init hook', function() {
        sinon.spy(TreeManager.prototype, 'addNodeIdToElData');
        this.treeManager = new TreeManager(this.config, this.launcherHooks);
        const node = new Node(this.$el, this.treeManager.hooks);
        return expect(this.treeManager.addNodeIdToElData).to.be.calledOnce;
      });

      it('adds @addRemoveEventHandlerToEl init hook', function() {
        this.treeManager = new TreeManager(this.config, this.launcherHooks);
        sinon.spy(this.treeManager, 'addRemoveEventHandlerToEl');
        const node = new Node(this.$el, this.treeManager.hooks);
        return expect(this.treeManager.addRemoveEventHandlerToEl).to.be.calledOnce;
      });

      it('adds @addNodeWrapper activation hook', function() {
        this.treeManager = new TreeManager(this.config, this.launcherHooks);
        sinon.spy(this.treeManager, 'addNodeWrapper');
        const node = new Node(this.$el, this.treeManager.hooks);
        node.activate();
        return expect(this.treeManager.addNodeWrapper).to.be.calledOnce;
      });

      it('adds @unloadNode unload hook', function() {
        sinon.spy(TreeManager.prototype, 'unloadNode');
        this.treeManager = new TreeManager(this.config, this.launcherHooks);
        const node = new Node(this.$el, this.treeManager.hooks);
        node.unload();
        return expect(this.treeManager.unloadNode).to.be.calledOnce;
      });

      return it('adds @deleteNodeWrapper unload hook', function() {
        sinon.spy(TreeManager.prototype, 'deleteNodeWrapper');
        this.treeManager = new TreeManager(this.config, this.launcherHooks);
        const node = new Node(this.$el, this.treeManager.hooks);
        node.unload();
        return expect(this.treeManager.deleteNodeWrapper).to.be.calledOnce;
      });
    });

    describe('.addNodeIdToElData', () => it("adds nodeId to node's $element", function() {
      const $el = $('<div />');
      const node = new Node($el);
      this.treeManager.addNodeIdToElData(node);

      return expect($el.data('vtree-node-id')).to.be.eql(node.id);
    }));

    describe('.addRemoveEventHandlerToEl', () => it('adds calls @treemanager.removeNode with $el node provided', function() {
      const $el = $('<div />');
      const node = new Node($el, this.treeManager.hooks);
      sinon.spy(this.treeManager, 'removeNode');
      node.$el.remove();
      return expect(this.treeManager.removeNode).to.be.calledOnce;
    }));

    describe('.addNodeWrapper', () => it('initializes NodeWrapper instance', function() {
      const $el = $('<div />');
      const node = new Node($el);
      this.treeManager.addNodeWrapper(node);

      expect(node.nodeWrapper.constructor).to.match(/NodeWrapper/);
      return expect(node.nodeWrapper.launcherHooks).to.eq(this.launcherHooks);
    }));

    describe('.unloadNode', () => it('unloads NodeWrapper instance', function() {
      const node = {};
      node.nodeWrapper = {unload: sinon.spy()};
      this.treeManager.unloadNode(node);
      return expect(node.nodeWrapper.unload).to.be.calledOnce;
    }));

    return describe('.deleteNodeWrapper', () => it('deletes NodeWrapper instance from corresponding Node', function() {
      const node = {nodeWrapper: {}};
      this.treeManager.deleteNodeWrapper(node);
      return expect(node.nodeWrapper).to.be.undefined;
    }));
  });

  return describe('Constructor and tree building behavior', function() {
    beforeEach(function() {
      this.config = new Configuration();
      this.launcherHooks = Launcher.hooks();
      return this.treeManager = new TreeManager(this.config, this.launcherHooks);
    });

    describe('.constructor', function() {
      it('creates NodesCache instance in @nodesCache', function() {
        return expect(this.treeManager.nodesCache.constructor).to.match(/NodesCache/);
      });

      return it('has empty @initialNodes list', function() {
        expect(this.treeManager.initialNodes).to.be.an('array');
        return expect(this.treeManager.initialNodes).to.be.eql([]);
    });
  });

    describe('.createTree', function() {
      it('creates nodes for initial dom state', function() {
        sinon.spy(this.treeManager, 'setInitialNodes');
        this.treeManager.createTree();
        return expect(this.treeManager.setInitialNodes).to.be.calledOnce;
      });

      it('sets parents for initial nodes', function() {
        sinon.spy(this.treeManager, 'setParentsForInitialNodes');
        this.treeManager.createTree();
        return expect(this.treeManager.setParentsForInitialNodes).to.be.calledOnce;
      });

      it('sets children for initial nodes', function() {
        sinon.spy(this.treeManager, 'setChildrenForInitialNodes');
        this.treeManager.createTree();
        return expect(this.treeManager.setChildrenForInitialNodes).to.be.calledOnce;
      });

      return it('activates initial nodes', function() {
        sinon.spy(this.treeManager, 'activateInitialNodes');
        this.treeManager.createTree();
        return expect(this.treeManager.activateInitialNodes).to.be.calledOnce;
      });
    });


    return describe('Tree building behavior', function() {
      beforeEach(function() {
        this.$els = $(nodesWithDataView());

        $('body').empty();
        return $('body').append(this.$els);
      });

      describe('.setInitialNodes', function() {

        it('initialized Node objects for each element for specified "app" and "view" selectors', function() {
          this.treeManager.setInitialNodes();

          return Array.from(this.treeManager.initialNodes).map((node) =>
            expect(node.constructor).to.match(/Node/));
        });

        it('has nodes pointed to corresponding dom elements in @initialNodes list', function() {
          const $els = $('body').find(this.config.selector);
          const expectedElsArray = _.toArray($els);

          this.treeManager.setInitialNodes();
          const initialNodesEls = _.map(this.treeManager.initialNodes, node => node.el);
          return expect(initialNodesEls).to.be.eql(expectedElsArray);
        });

        it('provides @hooks to nodes constructor', function() {
          this.treeManager.setInitialNodes();
          const firstNode = this.treeManager.initialNodes[0];
          return expect(firstNode.hooks).to.be.equal(this.treeManager.hooks);
        });

        return it('saves nodes to NodesCache', function() {
          sinon.spy(this.treeManager.nodesCache, 'add');
          this.treeManager.setInitialNodes();
          return expect(this.treeManager.nodesCache.add.callCount).to.be.eql(4);
        });
      });

      describe('.setParentsForInitialNodes', () => it('sets parents for initial nodes', function() {
        sinon.spy(this.treeManager, 'setParentsForNodes');
        this.treeManager.setInitialNodes();
        const {
          initialNodes
        } = this.treeManager;

        this.treeManager.setParentsForInitialNodes();
        expect(this.treeManager.setParentsForNodes).to.be.calledOnce;
        return expect(this.treeManager.setParentsForNodes.lastCall.args[0]).to.be.equal(initialNodes);
      }));

      describe('.setChildrenForInitialNodes', () => it('sets children for initial nodes', function() {
        sinon.spy(this.treeManager, 'setChildrenForNodes');
        this.treeManager.setInitialNodes();
        const {
          initialNodes
        } = this.treeManager;

        this.treeManager.setChildrenForInitialNodes();
        return expect(this.treeManager.setChildrenForNodes.firstCall.args[0]).to.be.equal(initialNodes);
      }));

      describe('Tree setup and activation', function() {
        beforeEach(function() {
          this.treeManager.setInitialNodes();
          this.nodes = this.treeManager.initialNodes;

          const $component = $('#component1');
          const $view1 = $('#view1');
          const $view2 = $('#view2');
          const $view3 = $('#view3');

          const componentNodeId = $component.data('vtree-node-id');
          const view1NodeId = $view1.data('vtree-node-id');
          const view2NodeId = $view2.data('vtree-node-id');
          const view3NodeId = $view3.data('vtree-node-id');

          this.appNode = this.treeManager.nodesCache.getById(componentNodeId);
          this.view1Node = this.treeManager.nodesCache.getById(view1NodeId);
          this.view2Node = this.treeManager.nodesCache.getById(view2NodeId);
          return this.view3Node = this.treeManager.nodesCache.getById(view3NodeId);
        });

        describe('.setParentsForNodes', function() {
          beforeEach(function() {
            return this.treeManager.setParentsForNodes(this.nodes);
          });

          it('looks for closest view dom element and sets it as parent for provided nodes', function() {
            expect(this.view1Node.parent).to.be.equal(this.appNode);
            expect(this.view2Node.parent).to.be.equal(this.appNode);
            return expect(this.view3Node.parent).to.be.equal(this.view2Node);
          });

          it('sets null reference to node parent if have no parent', function() {
            return expect(this.appNode.parent).to.be.null;
          });

          return it('adds node to cache as root if have no parent', function() {
            return expect(this.treeManager.nodesCache.showRootNodes()).to.be.eql([this.appNode]);
        });
      });

        describe('.setChildrenForNodes', function() {
          beforeEach(function() {
            this.treeManager.setParentsForNodes(this.nodes);
            return this.treeManager.setChildrenForNodes(this.nodes);
          });

          return it('sets children for provided nodes', function() {
            expect(this.appNode.children).to.be.eql([this.view1Node, this.view2Node]);
            expect(this.view1Node.children).to.be.eql([]);
            expect(this.view2Node.children).to.be.eql([this.view3Node]);
            return expect(this.view3Node.children).to.be.eql([]);
        });
      });

        describe('.activateNode', function() {
          beforeEach(function() {
            this.treeManager.setParentsForNodes(this.nodes);
            this.treeManager.setChildrenForNodes(this.nodes);
            return this.treeManager.activateNode(this.appNode);
          });

          it("recursively activates provided node and it's children nodes", function() {
            expect(this.appNode.isActivated()).to.be.true;
            expect(this.view1Node.isActivated()).to.be.true;
            expect(this.view2Node.isActivated()).to.be.true;
            return expect(this.view3Node.isActivated()).to.be.true;
          });

          return it('activates nodes in proper order', function() {
            expect(this.appNode.activate).to.be.calledBefore(this.view1Node.activate);
            expect(this.view1Node.activate).to.be.calledBefore(this.view2Node.activate);
            return expect(this.view2Node.activate).to.be.calledBefore(this.view3Node.activate);
          });
        });

        describe('.activateInitialNodes', () => it('activates root view nodes in initial nodes list', function() {
          sinon.spy(this.treeManager, 'activateRootNodes');
          const {
            initialNodes
          } = this.treeManager;

          this.treeManager.setParentsForNodes(this.nodes);
          this.treeManager.setChildrenForNodes(this.nodes);
          this.treeManager.activateInitialNodes(this.nodes);

          expect(this.treeManager.activateRootNodes).to.be.calledOnce;
          return expect(this.treeManager.activateRootNodes.lastCall.args[0]).to.be.equal(initialNodes);
        }));

        describe('.activateRootNodes', () => it('searches for root nodes in provided nodes list and activates them', function() {
          this.treeManager.setParentsForNodes(this.nodes);
          this.treeManager.setChildrenForNodes(this.nodes);
          this.treeManager.activateRootNodes(this.nodes);
          return expect(this.appNode.isActivated()).to.be.true;
        }));

        describe('.removeNode', function() {
          beforeEach(function() {
            this.treeManager.setParentsForNodes(this.nodes);
            return this.treeManager.setChildrenForNodes(this.nodes);
          });

          it('does nothing if node is already removed', function() {
            sinon.spy(this.view3Node, 'remove');
            const removeCallsCount = this.view3Node.remove.callCount;

            this.view3Node.remove();
            this.treeManager.removeNode(this.view3Node);
            return expect(this.view3Node.remove.callCount).to.be.eql(removeCallsCount + 1);
          });

          it("deattaches node from it's parent", function() {
            const {
              parent
            } = this.view3Node;
            expect(parent.children.indexOf(this.view3Node) > -1).to.be.true;

            this.treeManager.removeNode(this.view3Node);
            return expect(parent.children.indexOf(this.view3Node) > -1).to.be.false;
          });

          it('removes provided node', function() {
            this.treeManager.removeNode(this.view3Node);
            return expect(this.view3Node.isRemoved()).to.be.true;
          });

          it('removes child nodes', function() {
            sinon.spy(this.treeManager, 'removeChildNodes');
            this.treeManager.removeNode(this.appNode);

            expect(this.treeManager.removeChildNodes).to.be.called;
            return expect(this.treeManager.removeChildNodes.firstCall.args[0]).to.be.eql(this.appNode);
          });

          it('at first removes child nodes', function() {
            sinon.spy(this.appNode, 'remove');
            sinon.spy(this.view1Node, 'remove');

            this.treeManager.removeNode(this.appNode);
            return expect(this.view1Node.remove).to.be.calledBefore(this.appNode.remove);
          });

          it('removes node from nodesCache', function() {
            const nodeId = this.appNode.id;
            expect(this.treeManager.nodesCache.getById(nodeId)).to.be.equal(this.appNode);

            this.treeManager.removeNode(this.appNode);
            return expect(this.treeManager.nodesCache.getById(nodeId)).to.be.undefined;
          });

          return describe('OnRemove event handling behavior', function() {
            it('being called whenever dom element with node being removed from DOM', function() {
              sinon.spy(this.treeManager, 'removeNode');
              $('#component1').remove();
              return expect(this.treeManager.removeNode.callCount).to.be.eql(4);
            });

            return it('being called in proper order', function() {
              let node;
              const nodes = [this.appNode, this.view1Node, this.view2Node, this.view3Node];
              for (node of Array.from(nodes)) {
                sinon.spy(node, 'remove');
              }

              $('#component1').remove();

              for (node of Array.from(nodes)) {
                expect(node.remove).to.be.calledOnce;
              }

              expect(this.view3Node.remove).to.be.calledBefore(this.view2Node.remove);
              expect(this.view1Node.remove).to.be.calledBefore(this.view2Node.remove);
              expect(this.view1Node.remove).to.be.calledBefore(this.appNode.remove);
              return expect(this.view2Node.remove).to.be.calledBefore(this.appNode.remove);
            });
          });
        });

        return describe('.removeChildNodes', function() {
          beforeEach(function() {
            this.treeManager.setParentsForNodes(this.nodes);
            this.treeManager.setChildrenForNodes(this.nodes);

            sinon.spy(this.appNode, 'remove');
            sinon.spy(this.view1Node, 'remove');
            sinon.spy(this.view2Node, 'remove');
            sinon.spy(this.view3Node, 'remove');

            return this.treeManager.removeChildNodes(this.appNode);
          });

          it("recursively removes provided node's children", function() {
            expect(this.view1Node.remove).to.be.calledOnce;
            expect(this.view2Node.remove).to.be.calledOnce;
            return expect(this.view3Node.remove).to.be.calledOnce;
          });

          it('removes children nodes in proper order', function() {
            expect(this.view1Node.remove).to.be.calledBefore(this.view2Node.remove);
            return expect(this.view3Node.remove).to.be.calledBefore(this.view2Node.remove);
          });

          return it('removes children nodes from nodes cache', function() {
            expect(this.treeManager.nodesCache.getById(this.view1Node.id)).to.be.undefined;
            expect(this.treeManager.nodesCache.getById(this.view2Node.id)).to.be.undefined;
            return expect(this.treeManager.nodesCache.getById(this.view3Node.id)).to.be.undefined;
          });
        });
      });

      return describe('Node refreshing behavior', function() {
        beforeEach(function() {
          this.treeManager.createTree();
          this.$component = $('#component1');
          const $view1 = $('#view1');
          const $view2 = $('#view2');
          const $view3 = $('#view3');

          this.$newEls = $(nodesForRefresh());

          const componentNodeId = this.$component.data('vtree-node-id');
          const view1NodeId = $view1.data('vtree-node-id');
          const view2NodeId = $view2.data('vtree-node-id');
          const view3NodeId = $view3.data('vtree-node-id');

          this.appNode   = this.treeManager.nodesCache.getById(componentNodeId);
          this.view1Node = this.treeManager.nodesCache.getById(view1NodeId);
          this.view2Node = this.treeManager.nodesCache.getById(view2NodeId);
          return this.view3Node = this.treeManager.nodesCache.getById(view3NodeId);
        });

        return describe('.refresh', function() {
          beforeEach(function() {
            this.$component.append(this.$newEls);
            this.newNodesList = [];
            this.treeManager.refresh(this.appNode);

            return (() => {
              const result = [];
              for (let el of Array.from('component2 view4 view5 view6 view7 view8 view9'.split(' '))) {
                const id = $('#' + el).data('vtree-node-id');
                this[el + 'Node'] = this.treeManager.nodesCache.getById(id);
                result.push(this.newNodesList.push(this[el + 'Node']));
              }
              return result;
            })();
          });

          it('has nodes initialized for new view elements', function() {
            const $els = this.$newEls.wrap('<div />').parent().find(this.config.selector);
            const expectedElsArray = $els.toArray();
            const newElsArray = expectedElsArray.map(el => {
              const id = $(el).data('vtree-node-id');
              return this.treeManager.nodesCache.getById(id).el;
            });

            return expect(newElsArray).to.be.eql(expectedElsArray);
          });

          it('sets correct parents for new nodes', function() {
            expect(this.view1Node.parent).to.be.equal(this.appNode);
            expect(this.view2Node.parent).to.be.equal(this.appNode);
            expect(this.view3Node.parent).to.be.equal(this.view2Node);
            expect(this.view4Node.parent).to.be.equal(this.appNode);
            expect(this.view5Node.parent).to.be.equal(this.view4Node);
            expect(this.view6Node.parent).to.be.equal(this.view5Node);
            expect(this.view7Node.parent).to.be.equal(this.view4Node);
            expect(this.component2Node.parent).to.be.equal(this.view4Node);
            expect(this.view8Node.parent).to.be.equal(this.component2Node);
            return expect(this.view9Node.parent).to.be.equal(this.component2Node);
          });

          it('sets correct children for new nodes', function() {
            expect(this.appNode.children).to.be.eql([this.view1Node, this.view2Node, this.view4Node]);
            expect(this.view1Node.children).to.be.eql([]);
            expect(this.view2Node.children).to.be.eql([this.view3Node]);
            expect(this.view3Node.children).to.be.eql([]);
            expect(this.view4Node.children).to.be.eql([this.view5Node, this.view7Node, this.component2Node]);
            expect(this.view5Node.children).to.be.eql([this.view6Node]);
            expect(this.view6Node.children).to.be.eql([]);
            expect(this.view7Node.children).to.be.eql([]);
            expect(this.component2Node.children).to.be.eql([this.view8Node, this.view9Node]);
            expect(this.view8Node.children).to.be.eql([]);
            return expect(this.view9Node.children).to.be.eql([]);
        });

          return it('activates new nodes', function() {
            return Array.from(this.newNodesList).map((node) =>
              expect(node.isActivated()).to.be.true);
          });
        });
      });
    });
  });
});
