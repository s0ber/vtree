/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const VtreeNodesCache = require('src/vtree_src/vtree_nodes_cache');

describe('VtreeNodesCache', function() {

  beforeEach(function() {
    return this.nodesCache = new VtreeNodesCache;
  });

  describe('Initial state of cache', function() {

    describe('.show', () => it('returns empty hash by default', function() {
      const nodesHash = this.nodesCache.show();
      expect(nodesHash).to.be.an('object');
      return expect(nodesHash).to.be.eql({});
  }));

    return describe('.showRootNodes', () => it('returns empty list by default', function() {
      const rootNodesList = this.nodesCache.showRootNodes();
      expect(rootNodesList).to.be.an('array');
      return expect(rootNodesList).to.be.eql([]);
  }));
});

  return describe('Cache management actions', function() {

    beforeEach(function() {
      this.node = {id: 1, whatever: 'content'};
      return this.secondNode = {id: 2, whatever: 'more content'};
    });

    describe('.add', () => it('adds node to nodes hash', function() {
      this.nodesCache.add(this.node);
      expect(this.nodesCache.show()).to.be.eql({1: this.node});

      this.nodesCache.add(this.secondNode);
      return expect(this.nodesCache.show()).to.be.eql({1: this.node, 2: this.secondNode});
  }));

    describe('.addAsRoot', () => it('adds node to root nodes list', function() {
      this.nodesCache.add(this.node);
      this.nodesCache.addAsRoot(this.node);
      expect(this.nodesCache.showRootNodes()).to.be.eql([this.node]);

      this.nodesCache.add(this.secondNode);
      this.nodesCache.addAsRoot(this.secondNode);
      return expect(this.nodesCache.showRootNodes()).to.be.eql([this.node, this.secondNode]);
  }));

    describe('.getById', () => it("returns node by it's index", function() {
      this.nodesCache.add(this.node);

      const returnedNode = this.nodesCache.getById(this.node.id);
      return expect(returnedNode).to.be.equal(this.node);
    }));

    describe('.removeById', function() {
      it('removes node from nodes hash by provided id', function() {
        this.nodesCache.add(this.node);
        this.nodesCache.add(this.secondNode);
        this.nodesCache.removeById(2);

        const nodesHash = this.nodesCache.show();
        return expect(nodesHash).to.be.eql({1: this.node});
    });

      return it('removes node from root nodes list by provided id', function() {
        this.nodesCache.add(this.node);
        this.nodesCache.add(this.secondNode);

        this.nodesCache.addAsRoot(this.node);
        this.nodesCache.addAsRoot(this.secondNode);
        this.nodesCache.removeById(1);

        const rootNodesList = this.nodesCache.showRootNodes();
        return expect(rootNodesList).to.be.eql([this.secondNode]);
    });
  });

    return describe('.clear', function() {
      it('clears nodes hash', function() {
        this.nodesCache.add(this.node);
        this.nodesCache.add(this.secondNode);
        this.nodesCache.clear();

        const nodesHash = this.nodesCache.show();
        expect(nodesHash).to.be.an('object');
        return expect(nodesHash).to.be.eql({});
    });

      return it('clears root nodes list', function() {
        this.nodesCache.add(this.node);
        this.nodesCache.add(this.secondNode);
        this.nodesCache.addAsRoot(this.node);
        this.nodesCache.addAsRoot(this.secondNode);

        this.nodesCache.clear();

        const rootNodesList = this.nodesCache.showRootNodes();
        expect(rootNodesList).to.be.an('array');
        return expect(rootNodesList).to.be.eql([]);
    });
  });
});
});
