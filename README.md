Vtree
=====
[![Build Status](https://travis-ci.org/s0ber/vtree.png?branch=master)](https://travis-ci.org/s0ber/vtree)

Vtree is a small library, which helps to build great front-end architectures.

Your question will be: "Why I need this? I have lots of frameworks. Isn't it just another one?"

I can't give simple answer. **Vtree** is not a framework, it is just a library, which helps you to initialize javascript code on your html. It is your responsibility to think of how you are going to do this. You can initialize *Backbone* views, or you can render some parts of your application with custom renderer, like *React.js*. When using **Vtree**, you are not tightened with framework limitations.

The main goal of **Vtree** is to give you an instrument, which will help you to make your javascript code modular, reusable and scalable.


Let's say we have such HTML:

```html
<html>
  <body data-view="page#body">
    <header data-view="page#header"></header>
    <section data-component="page#items_list">
      <article data-view="item"></article>
      <article data-view="item"></article>
      <article data-view="item"></article>
    </section>
    <footer data-view="page#footer"></footer>
  </body>
</html>
```

As you see, some DOM-elements are marked with ```data-view``` and ```data-component``` attributes. Those elements are important nodes. Those may be wrapper nodes for different kinds of widgets, or for sets of widgets (we call such sets of widgets "**components**").

With **Vtree** you can easily initialize, for example, Backbone views, based on those data-attributes.

```coffee
Page = {}

Page.Views = {}
Page.Views.Body = class extends Backbone.View
Page.Views.Header = class extends Backbone.View
Page.Views.Footer = class extends Backbone.View

Page.ItemsList = {}
Page.ItemsList.Views = {}
Page.ItemsList.Views.Index = class extends Backbone.View
Page.ItemsList.Views.Item = class extends Backbone.View

Vtree.onNodeInit (node) ->
  NodeNamespace = window[node.namespaceName]
  
  ViewConstructor =
    if node.isStandAlone
      NodeNamespace.Views[node.nodeName]
    else
      NodeNamespace[node.componentName].Views[node.nodeName]

  view = new ViewConstructor($el: node.$el)
  node.setData('view', view)

Vtree.onNodeUnload (node) ->
  view = node.getData('view')
  view.unload?()

$ ->
  Vtree.initNodes()
```

Here we have created a simple front-end architecture in few lines of code. Elements with ```data-view``` specify nodes, which are main elements for Backbone views. You should specify a namespace before ```#``` sign, and then you can initialize those views from this namespace.

But as you see above, some nodes don't have namespace specified, and here is where **Vtree** magic comes in. When namespace is not specified, **Vtree** thinks, that this node is here not for a stand-alone independent view (or widget, you can call it as you wish), but this node is a part of some complicated component. And **Vtree** automatically finds matching component, based on it position in DOM. As you see here, ```data-view="item"``` elements are located under **page#items_list** component, and **Vtree** node will have this reference. And you'll be able to initialize this view from a right namespace. In our example it is ```Page.ItemsList.Views.Item```. The main component node, which we call **component index node**, is also can have related Backbone view. As you'll see later, associated view ```Page.ItemsList.Views.Index``` will be initialized for this node.

But that is not the only magic. All nodes, which are child nodes for a component, share a unique **componentId**. And you can share some data between all of those nodes, based on this **componentId**. I won't describe what exact data you can share, but this is a good way to share interface state (*viewModel*), or some data models, common to all parts of the component.

Other advantage of **Vtree**, is that it works great with DOM manipulations. Let's say you've removed element from DOM. If this element is a **Vtree** node, then, ```onNodeUnload``` hook will be triggered. At this moment, you can get access to data, which you've previously saved to this node. In our example it is reference to Backbone view. Here, we can perform some unloading logic. We just need to specify ```.unload``` method in bb-view, and it'll be called automatically whenever related DOM-element will be removed.

Also, **Vtree** gives you more methods for dealing with DOM. You can manipulate DOM with them, and be sure, that all your views will be initialized automatically. So, you receive some HTML from server. You paste it into DOM. You don't need to do anything else. All Backbone views, associated with this html, will be initialized automatically.

I'll describe **Vtree** API below, and won't write anything more. If you are interested, you can create really great apps, based on it. If not, it'll also work for very simple applications.

In general, the main idea of this library — I don't want to know what I need to initialize. I want to get pure html from server, insert it into DOM, and all other work, related to initialization of corresponding JS — should be made automatically.

## Vtree hooks

We can get access to ```data-view``` and ```data-component``` nodes on DOM ready or whenever those nodes are being added to or removed from DOM. We should call ```Vtree.initNodes()``` on DOM ready to initialize all initial nodes. When node initialized or removed from DOM, hook functions will be called. We can add any number of those hooks with ```Vtree.onNodeInit``` and ```Vtree.onNodeUnload``` methods. When those hooks are called, very important argument is passed to them.

This argument is an instance of **NodeData** class, which will be described next.

## NodeData class
Each **Vtree** node has **NodeData** instance, associated with it. This object contains some very important information and few methods. Here are they.

### isComponentIndex
**[true|false]**

If DOM-element has ```data-component``` specified, then this element is a wrapper for set of ```data-view``` elements. If you think of this set of views as of complicated component, than, the wrapper element for this set of views is an index element of the whole component. So, if **Vtree** node is a component index node, than this property will be ```true```.

### isComponentPart
**[true/false]**

As you see, we have different kinds of nodes. Some of them are parts of components, i.e. they don't make much sense alone.

But we can specify nodes, which are not parts of components, but are nodes for stand-alone views. And we can put them under any namespace. We can do it like this:

````html
<div id="my_element" data-view="ui#select" ></div>
````

Here ```data-view``` value is something, which consists of two parts. The first part is a namespace, and the second is an actual view name. What is namespace? It's just a place, where we can put all such independent views. (We should also put all components in namespaces.) In this case, such nodes won't be *component parts*, because we can use them in any part of our project, it doesn't matter under which component they are located. And such nodes will have **isComponentPart** equal to **false**.

### isStandAlone
**[true/false]**

So, views, which we have described above, are not parts of components, but stand-alone views. Or independent views. For example, we can have **UI** namespace, which will have a number of different widgets, which can be used anywhere in our application. Such nodes will have **isStandAlone** equal to **true**.

### componentId
**[Integer]**

If current node is a component part, then, nodes, located under different component index nodes, will have different **componentId**'s. Let's say we have such html:

````html
<div data-component="app#my_simple_component">
  <div data-view="widget"></div>
  <div data-view="another_widget"></div>
</div>
<div data-component="app#my_simple_component">
  <div data-view="widget"></div>
  <div data-view="another_widget"></div>
</div>
````

As you see, we have two component nodes here, which points to the same namespace. It's a problem, because, for example, we want to share different states between component views. **componentId** will help us, because nodes positioned under different *component index nodes* will have different **componentId**.

Stand-alone views will have **componentId** equal to **null**.

### componentIndexNode
**[NodeData]**

If current node is a component part, then, reference to this component's index node will be returned. In all other cases (i.e. if node *is a* component index node or a node is a stand-alone node), **null** will be returned.

### nodeName
**[String]**

This is just camelized name of the node:

````html
<!-- nodeName is 'Index' -->
<div data-component="app#my_simple_component">
  <!-- nodeName is 'Widget' -->
  <div data-view="widget"></div>
    <!-- nodeName is 'AnotherWidget' -->
  <div data-view="another_widget"></div>
</div>
<!-- nodeName is 'Select' -->
<div data-view="ui#select">
</div>
````

### componentName
**[String]**

The same as **nodeName**, but for component name (is **null** if it is stand-alone node):

````html
<!-- componentName is 'MySimpleComponent' -->
<div data-component="app#my_simple_component">
  <!-- componentName is 'MySimpleComponent' -->
  <div data-view="widget"></div>
    <!-- applicationName is 'MySimpleComponent' -->
  <div data-view="another_widget"></div>
</div>
<!-- componentName is null -->
<div data-view="ui#select">
</div>
````

### namespaceName
**[String]**

Namespace name. For stand-alone nodes it will be namespace, specified in ```data-view``` attribute before ```#``` sign. For component index nodes it will be the same — namespace, specified in ```data-component``` attribute before ```#``` sign. For component child nodes it will be component's namespace:

````html
<!-- namespaceName is 'App' -->
<div data-component="app#my_simple_component">
  <!-- namespaceName is 'App' -->
  <div data-view="widget"></div>
    <!-- namespaceName is 'App' -->
  <div data-view="another_widget"></div>
</div>
<!-- namespaceName is 'Ui' -->
<div data-view="ui#select">
</div>
````

### nodeNameUnderscored
**[String]**

The same as **nodeName**, but in underscored form.

### componentNameUnderscored
**[String]**

The same as **componentName**, but in underscored form.

### namespaceNameUnderscored
**[String]**

The same as **namespaceName**, but in underscored form.

### setData(name, value)

This method will save some data, associated with this node. This data then can be available in unload hook. For example, we can initialize backbone view, and save reference to it. And then we'll get access to this view to unload it.

### getData(name)

This method returns data, previously attached to this node.


## Vtree.DOM

Those are methods for DOM manipulations. When changing DOM with them, dynamically added and removed nodes will be hooked for initializing and unloading Backbone views (or whatever). Async versions of all of those methods are available (just add **Async** to the method name).

### Vtree.DOM.html($el, html)

Sets **html** for **$el** and rebuilds vtree.

### Vtree.DOM.append($parentEl, $el)

Appends **$el** to **$parentEl** and rebuilds vtree.

### Vtree.DOM.prepend($parentEl, $el)

Prepends **$el** to **$parentEl** and rebuilds vtree.

### Vtree.DOM.before($el, $insertedEl)

Inserts **$insertedEl** before **$el** and rebuilds vtree.

### Vtree.DOM.after($el, $insertedEl)

Inserts **$insertedEl** after **$el** and rebuilds vtree.

### Vtree.DOM.remove($el)

Removes **$el** and rebuilds vtree.

## That's it

Thanks for reading this doc, and for using **Vtree**.
