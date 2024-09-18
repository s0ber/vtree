/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Configuration = require('src/configuration');
const Vtree = require('src/vtree');
const Hooks = require('src/vtree_src/hooks');

const Launcher = {
  launch: sinon.spy(),
  createViewsTree: sinon.spy(),
  hooks() { return this._hooks != null ? this._hooks : (this._hooks = new Hooks()); }
};

describe('Vtree', function() {

  before(function() {
    this.initialLauncher = Vtree._launcher;
    return Vtree._launcher = (() => Launcher);
  });

  after(function() {
    return Vtree._launcher = this.initialLauncher;
  });

  describe('.initNodes', () => it("calls Launcher's launch and createViewsTree functions", function() {
    Vtree.initNodes();
    expect(Launcher.launch).to.be.calledOnce;
    return expect(Launcher.createViewsTree).to.be.calledOnce;
  }));

  describe('.getInitCallbacks', () => it('returns empty list by default', () => expect(Vtree.getInitCallbacks()).to.be.eql([])));

  describe('.onNodeInit', () => it('adds initialization callback to onInit callbacks', function() {
    const callback = function() {};
    const secondCallback = function() {};
    Vtree.onNodeInit(callback);
    expect(Vtree.getInitCallbacks()).to.be.eql([callback]);
    Vtree.onNodeInit(secondCallback);
    return expect(Vtree.getInitCallbacks()).to.be.eql([callback, secondCallback]);
}));

  describe('.getUnloadCallbacks', () => it('returns empty list by default', () => expect(Vtree.getUnloadCallbacks()).to.be.eql([])));

  describe('.onNodeUnload', () => it('adds unload callback to onUnload callbacks', function() {
    const callback = function() {};
    const secondCallback = function() {};
    Vtree.onNodeUnload(callback);
    expect(Vtree.getUnloadCallbacks()).to.be.eql([callback]);
    Vtree.onNodeUnload(secondCallback);
    return expect(Vtree.getUnloadCallbacks()).to.be.eql([callback, secondCallback]);
}));

  return describe('.configure', () => it('extends configuration data with provided options', function() {
    const config = new Configuration;
    Vtree.config = () => config;
    Vtree.configure({
      viewSelector: '.test_view_selector',
      componentSelector: '.test_component_selector'
    });

    expect(Vtree.config().viewSelector).to.be.equal('.test_view_selector');
    return expect(Vtree.config().componentSelector).to.be.equal('.test_component_selector');
  }));
});
