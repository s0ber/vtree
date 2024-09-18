/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const $ = require('jquery');
const Vtree = require('src/vtree');
const DOM = require('src/vtree_src/dom');
const nodesForRefresh = require('../fixtures/nodes_for_refresh');
const nodesWithDataView = require('../fixtures/nodes_with_data_view');

describe('DOM', function() {

  beforeEach(function() {
    this.$els = $(nodesWithDataView());
    return this.$newEls = $(nodesForRefresh());
  });

  describe('.html', function() {
    beforeEach(function() {
      this.$el = this.$els.find('#view3');
      this.html = this.$newEls.wrap('<div/>').parent().html();

      sinon.spy(this.$el, 'trigger');
      return DOM.html(this.$el, this.html);
    });

    it('sets html to element', function() {
      return expect(this.$el.html()).to.be.eql(this.html);
    });

    return it('triggers refresh event on $el', function() {
      expect(this.$el.trigger).to.be.calledOnce;
      return expect(this.$el.trigger.args[0][0]).to.be.eql('refresh');
    });
  });

  describe('.append', function() {
    beforeEach(function() {
      this.$parentEl = this.$els;
      this.$el = this.$newEls;
      sinon.spy(this.$parentEl, 'trigger');

      return DOM.append(this.$parentEl, this.$el);
    });

    it('appends $el to $parentEl', function() {
      return expect(this.$parentEl.children().last()[0]).to.be.eql(this.$el[0]);
  });

    return it('triggers refresh event on $parentEl', function() {
      expect(this.$parentEl.trigger).to.be.calledOnce;
      return expect(this.$parentEl.trigger.args[0][0]).to.be.eql('refresh');
    });
  });

  describe('.prepend', function() {
    beforeEach(function() {
      this.$parentEl = this.$els;
      this.$el = this.$newEls;
      sinon.spy(this.$parentEl, 'trigger');

      return DOM.prepend(this.$parentEl, this.$el);
    });

    it('prepends $el to $parentEl', function() {
      return expect(this.$parentEl.children()[0]).to.be.eql(this.$el[0]);
  });

    return it('triggers refresh event on $parentEl', function() {
      expect(this.$parentEl.trigger).to.be.calledOnce;
      return expect(this.$parentEl.trigger.args[0][0]).to.be.eql('refresh');
    });
  });

  describe('.before', function() {
    beforeEach(function() {
      this.$el = this.$els.find('#view3');
      this.$insertedEl = this.$newEls;

      this.$parentEl = this.$el.parent();
      this.spyFn = sinon.spy();
      this.$parentEl.on('refresh', this.spyFn);

      return DOM.before(this.$el, this.$insertedEl);
    });

    it('inserts $insertedEl before $el', function() {
      return expect(this.$el.prev()[0]).to.be.eql(this.$insertedEl[0]);
  });

    return it('triggers refresh event on $parentEl', function() {
      return expect(this.spyFn).to.be.calledOnce;
    });
  });

  describe('.after', function() {
    beforeEach(function() {
      this.$el = this.$els.find('#view3');
      this.$insertedEl = this.$newEls;

      this.$parentEl = this.$el.parent();
      this.spyFn = sinon.spy();
      this.$parentEl.on('refresh', this.spyFn);

      return DOM.after(this.$el, this.$insertedEl);
    });

    it('inserts $insertedEl after $el', function() {
      return expect(this.$el.next()[0]).to.be.eql(this.$insertedEl[0]);
  });

    return it('triggers refresh event on $parentEl', function() {
      return expect(this.spyFn).to.be.calledOnce;
    });
  });

  describe('.remove', () => it('removes element from DOM', function() {
    const $el = this.$els.find('#view3');
    DOM.remove($el);
    return expect(this.$els.find('#view3').length).to.be.equal(0);
  }));

  return describe('Async DOM modifying', function() {

    before(function() {
      const $els = $(nodesWithDataView());
      const $newEls = $(nodesForRefresh());

      $('body').empty().append($els);

      this.dfd = new $.Deferred();
      this.firstTestFn = sinon.spy();
      this.secondTestFn = sinon.spy();

      this.Vtree = Vtree;
      this.Vtree.hooks()._reset();

      return this.Vtree.onNodeInit(node => {
        // update DOM when first view is initializing
        if (node.isComponentIndex && (node.componentName === 'TestComponent')) {
          return this.Vtree.DOM.appendAsync($('#component1'), $newEls);
        } else if (node.nodeName === 'TestView3') {
          return this.firstTestFn();
        } else if (node.nodeName === 'TestView9') {
          this.secondTestFn();
          return this.dfd.resolve();
        }
      });
    });

    after(function() {
      return this.Vtree.hooks()._reset();
    });

    return it('modifies DOM asynchrounously', function() {
      this.Vtree.initNodesAsync();
      return this.dfd.done(() => {
        expect(this.firstTestFn).to.be.calledOnce;
        expect(this.secondTestFn).to.be.calledOnce;
        return expect(this.firstTestFn).to.be.calledBefore(this.secondTestFn);
      });
    });
  });
});

