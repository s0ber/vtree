Vtree
=====
[![Build Status](https://travis-ci.org/s0ber/vtree.png?branch=master)](https://travis-ci.org/s0ber/vtree)

Vtree is a small library for managing data, attached to DOM elements. Your question will be: "Why I need this? I have data-attributes, and JQuery's ```.data``` method."

I can't give simple answer. But take a look at example, and you'll understand everything.


Let's say we have such HTML:

```html
<html>
  <div data-app="my_app">
    <header data-view="header"></header>
    <section data-app="content">
      <article data-view="item"></article>
      <article data-view="item"></article>
      <article data-view="item"></article>
    </section>
    <footer data-view="footer"></footer>
  </div>
</html>
```

As you see, some DOM-elements are marked with ```data-app``` and ```data-view``` attributes. This elements are some kind of important nodes. Those may be wrapper nodes of different kind of widgets, or a sets of widgets.

With Vtree you can easily initialize, for example, Backbone views, based on this data-attributes.

```coffee
MyApp = {}
MyApp.Views = {}
MyApp.Views.Layout = class extends Backbone.View
MyApp.Views.Header = class extends Backbone.View
MyApp.Views.Footer = class extends Backbone.View

Content = {}
Content.Views = {}
Content.Views.Layout = class extends Backbone.View
Content.Views.Item = class extends Backbone.View

Vtree.onNodeInit (node) ->
  viewConstructor =
    if node.isApplicationLayout
      window[node.applicationName]['Layout']
    else
      window[node.applicationName][node.nodeName]

  view = new viewConstructor($el: node.$el)
  node.setData('view', view)

Vtree.onNodeUnload (node) ->
  view = node.getData('view')
  view.unload()

```

Here we have created a simple front-end architecture in few lines of code. Elements with ```data-app``` specify nodes, which are elements for **Layout** views. This view is being initialized from namespace, which is related to ```data-app``` attribute value. All nested views will be automatically initialized from this namespace, because Vtree keeps track of node position in DOM tree (i.e. each node knows under which namespace it is positioned).

Other advantage of Vtree, is that it works great with DOM manipulations. Let's say you've removed DOM element. If this element is a Vtree node, then, ```onNodeUnload``` hook will be triggered. At this moment, you can get access to data, which you've previously saved to this node. In our example it is reference to Backbone-view. Here, we can perform some unloading logic. We just need to specify ```.unload``` method in bb-view, and it'll be called automatically whenever related DOM-element will be removed.

Also, Vtree gives you more methods for dealing with DOM. You can manipulate DOM with them, and be sure, that all you views will be initialized automatically. So, you recieve some HTML from your server. You paste it into DOM. You don't need to do anything else. All bb-views, associated with this html, will be initialized automatically.

I'll describe Vtree API below, and won't write anything more. If you are interested, you can create really greate apps, based on it. If not, it'll also work for very simple applications.

In general, the main idea of this library — I don't want to know what I need to initialize. I wan't to get pure html from server, insert it into DOM, and all other work, related to initialization of corresponding JS — should be made automatically.
