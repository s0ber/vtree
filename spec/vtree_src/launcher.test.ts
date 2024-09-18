/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const $ = require('jquery');
const Launcher = require('src/vtree_src/launcher');
const nodesWithDataView = require('../fixtures/nodes_with_data_view');
const Configuration = require('src/configuration');

describe('Launcher', function() {
  describe('.initRemoveEvent', () => it('creates custom jquery event, which being triggered when element being removed from DOM', function() {
    Launcher.initRemoveEvent();
    const fnSpy = sinon.spy();
    const $el = $('<div />');
    const $el2 = $('<div />');

    $('body').append($el).append($el2);
    $el.on('remove', fnSpy);
    $el2.on('remove', fnSpy);
    $el.remove();
    $el2.remove();

    return expect(fnSpy).to.be.calledTwice;
  }));

  describe('.launch', function() {
    beforeEach(function() {
      return this.config = new Configuration();
    });

    it('initializes TreeManager instance', function() {
      sinon.spy(Launcher, 'initTreeManager');
      Launcher.launch(this.config);
      expect(Launcher.initTreeManager).to.be.calledOnce;
      expect(Launcher.treeManager.config).to.eq(this.config);
      return expect(Launcher.treeManager.launcherHooks).to.eq(Launcher.hooks());
    });

    it('initializes custom jquery remove event', function() {
      sinon.spy(Launcher, 'initRemoveEvent');
      Launcher.launch(this.config);
      return expect(Launcher.initRemoveEvent).to.be.calledOnce;
    });

    return it('initializes custom jquery refresh event', function() {
      sinon.spy(Launcher, 'initRefreshEvent');
      Launcher.launch(this.config);
      return expect(Launcher.initRefreshEvent).to.be.calledOnce;
    });
  });

  describe('.initTreeManager', () => it('saves reference to new TreeManager instance in @treeManager', function() {
    const config = new Configuration();
    Launcher.initTreeManager(config);
    return expect(Launcher.treeManager.constructor).to.match(/TreeManager/);
  }));

  describe('.createViewsTree', () => it('creates view tree with help of @treeManager', function() {
    sinon.spy(Launcher.treeManager, 'createTree');
    Launcher.createViewsTree();
    return expect(Launcher.treeManager.createTree).to.be.calledOnce;
  }));

  return describe('.initRefreshEvent', function() {
    it('creates custom jquery refresh event', function() {
      Launcher.initRefreshEvent();
      return expect(Launcher.isRefreshEventInitialized).to.be.true;
    });

    return describe('Custom jquery refresh event', function() {
      before(function() {
        Launcher.initRefreshEvent();
        this.treeManager = Launcher.treeManager;
        return sinon.spy(this.treeManager, 'refresh');
      });

      beforeEach(function() {
        $('body').empty().append($(nodesWithDataView()));
        return this.treeManager.createTree();
      });

      it("calls tree manager's refresh event", function() {
        const initCallCount = this.treeManager.refresh.callCount;
        const $el = $('body').find('#component1');
        $el.trigger('refresh');
        return expect(this.treeManager.refresh.callCount).to.be.eql(initCallCount + 1);
      });

      it('looks for closest element with initialized node', function() {
        const $elWithoutView = $('body').find('#no_view');
        const $closestWithView = $('body').find('#component1');
        $elWithoutView.trigger('refresh');

        const node = this.treeManager.refresh.lastCall.args[0];
        return expect(node.el).to.be.equal($closestWithView[0]);
    });

      return it('refreshes element if it has node', function() {
        const $el = $('body').find('#view2');
        $el.trigger('refresh');

        const node = this.treeManager.refresh.lastCall.args[0];
        return expect(node.el).to.be.equal($el[0]);
    });
  });
});
});
