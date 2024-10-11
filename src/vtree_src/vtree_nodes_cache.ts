import type Node from './node'

export default class VtreeNodesCache {
  private nodes: Record<string, Node> = {}
  private rootNodes: Node[] = []

  show() {
    return this.nodes
  }

  showRootNodes() {
    return this.rootNodes;
  }

  getById(id: string) {
    return this.nodes[id];
  }

  add(node: Node) {
    this.nodes[node.id] = node;
  }

  addAsRoot(node: Node) {
    if (this.nodes[node.id] == null) {
      throw new Error('Trying to add node as root, but node is not cached previously');
    }
    this.rootNodes.push(node);
  }

  removeById(id: string) {
    let nodeIndex = this.rootNodes.indexOf(this.nodes[id])
    if (nodeIndex !== -1) {
      this.rootNodes.splice(nodeIndex, 1)
    }
    delete this.nodes[id]
  }

  clear() {
    this.nodes = {}
    this.rootNodes = []
  }
}
