/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Vtree = require('src/vtree');
const $ = require('jquery');
const nodesForRefresh = require('./fixtures/nodes_for_refresh');
const nodesWithDataView = require('./fixtures/nodes_with_data_view');

const ERROR_MESSAGE = "You can't start initializing new nodes";

describe('Initializing nodes while other nodes initializing', function() {
  beforeEach(function() {
    Vtree.hooks()._reset();
    return $('body').html(nodesWithDataView);
  });

  after(() => Vtree.hooks()._reset());

  context('not trying to modify DOM in the middle of initial nodes initialization', function() {
    beforeEach(() => Vtree.onNodeInit(function(node) {}));

    return it('does not throw Vtree error', () => expect(() => Vtree.initNodes()).not.to.throw(ERROR_MESSAGE));
  });

  context('trying to modify DOM in the middle of initial nodes initialization', function() {
    beforeEach(() => Vtree.onNodeInit(function(node) {
      if (node.nodeName === 'TestView2') { return Vtree.DOM.html($('#component1'), nodesForRefresh); }
    }));

    return it('throws Vtree error', () => expect(() => Vtree.initNodes()).to.throw(ERROR_MESSAGE));
  });

  context('trying to asynchronously modify DOM in the middle of initial nodes initialization', function() {
    beforeEach(() => Vtree.onNodeInit(function(node) {
      if (node.nodeName === 'TestView2') { return Vtree.DOM.htmlAsync($('#component1'), nodesForRefresh); }
    }));

    return it('does not throw Vtree error', () => expect(() => Vtree.initNodes()).not.to.throw(ERROR_MESSAGE));
  });

  context('not trying to modify DOM in the middle of subsequent nodes initialization', function() {
    beforeEach(() => Vtree.onNodeInit(function(node) {}));

    return it('does not throw Vtree error', () => expect(function() {
      Vtree.initNodes();
      return Vtree.DOM.html($('#component1'), nodesForRefresh);
    }).not.to.throw(ERROR_MESSAGE));
  });

  context('trying to modify DOM in the middle of subsequent nodes initialization', function() {
    beforeEach(() => Vtree.onNodeInit(function(node) {
      if (node.nodeName === 'TestView7') { return Vtree.DOM.html($('#component2'), '<div>TEST HTML</div>'); }
    }));

    return it('throws Vtree error', () => expect(function() {
      Vtree.initNodes();
      return Vtree.DOM.html($('#component1'), nodesForRefresh);
    }).to.throw(ERROR_MESSAGE));
  });

  return context('trying to asynchronously modify DOM in the middle of subsequent nodes initialization', function() {
    beforeEach(() => Vtree.onNodeInit(function(node) {
      if (node.nodeName === 'TestView7') { return Vtree.DOM.htmlAsync($('#component2'), '<div>TEST HTML</div>'); }
    }));

    return it('does not throw Vtree error', () => expect(function() {
      Vtree.initNodes();
      return Vtree.DOM.html($('#component1'), nodesForRefresh);
    }).not.to.throw(ERROR_MESSAGE));
  });
});
