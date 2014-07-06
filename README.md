Vtree
=====
[![Build Status](https://travis-ci.org/s0ber/vtree.png?branch=master)](https://travis-ci.org/s0ber/vtree)

Vtree is a small library for managing data, attached to DOM elements.

Your question will be: "Why I need this? I have data-attributes, and JQuery's ```.data``` method."

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

As you see, some DOM-elements are marked with ```data-app``` and ```data-view``` attributes. Those elements are some kind of important nodes. Those may be wrapper nodes for different kind of widgets, or for sets of widgets.

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

Vtree.initNodes()

```

Here we have created a simple front-end architecture in few lines of code. Elements with ```data-app``` specify nodes, which are elements for **Layout** views. Thise views are being initialized from namespace, which is related to ```data-app``` attribute value. All nested views will be automatically initialized from this namespace, because Vtree keeps track of node position in DOM tree (i.e. each node knows under which namespace it is positioned).

Other advantage of Vtree, is that it works great with DOM manipulations. Let's say you've removed DOM element. If this element is a Vtree node, then, ```onNodeUnload``` hook will be triggered. At this moment, you can get access to data, which you've previously saved to this node. In our example it is reference to Backbone view. Here, we can perform some unloading logic. We just need to specify ```.unload``` method in bb-view, and it'll be called automatically whenever related DOM-element will be removed.

Also, Vtree gives you more methods for dealing with DOM. You can manipulate DOM with them, and be sure, that all your views will be initialized automatically. So, you recieve some HTML from your server. You paste it into DOM. You don't need to do anything else. All bb views, associated with this html, will be initialized automatically.

I'll describe Vtree API below, and won't write anything more. If you are interested, you can create really greate apps, based on it. If not, it'll also work for very simple applications.

In general, the main idea of this library — I don't want to know what I need to initialize. I want to get pure html from server, insert it into DOM, and all other work, related to initialization of corresponding JS — should be made automatically.

## Vtree hooks

We can get access to ```data-app``` and ```data-view``` nodes whenever those nodes are being added or removed from DOM. We do it with hooks. We can add any number of those hooks with ```Vtree.onNodeInit``` and ```Vtree.onNodeUnload``` methods. Those methods recieves hooks (callbacks), with very important argument, passed to them.

This argument is an instance of NodeData class, which will be described next.

## NodeData class
Each Vtree node has NodeData instance, associated with it. This object contains some very important information and few methods. Here are they.

### isApplicationLayout
**[true|false]**

If DOM-element has ```data-app``` specified, then this element is a wrapper for set of ```data-view``` elements. If you think of this set of widgets as of application, than, the main element of this application is a layout for this application. So, if vtree node is an application layout, than this property will be ```true```.

### isApplicationPart
**[true/false]**

As you'll see, we have different kind of widgets. Some of them are parts of applications, i.e. they don't make much sense alone. In our example all such views are like that.

But we can specify views, which are not part of application, but are stand-alone views, which we can put inside any namespace. We can do it like this:

````html
<div id="my_element" data-view="ui#select" ></div>
````

Here ```data-view``` value is something, which consists of two parts. The first part is a namespace, and the second is an actual view name. What is namespace? It's just a place, where we can put all such independent views. In this case, such nodes won't be *application part*, because we can use them in any part of our project, it doesn't matter inside which layout they are located. And such views will have **isApplicationPart** equal to **false**.

### isComponentPart
**[true/false]**

So, views, which we haved described above, are not parts of applications, but parts of components. Components are just set of independent views. For example, we can have **UI** component, which will have a number of different widgets, which can be used anywhere in our application. Such nodes will have **isComponentPart** equal to **true**.

### applicationId
**[Integer]**

If our current node is **isApplicationPart**, than, nodes, located under different layouts, will have different applicationIds. Let's say we have such html:

````html
<div data-app="my_simple_app">
  <div data-view="widget"></div>
  <div data-view="another_widget"></div>
</div>
<div data-app="my_simple_app">
  <div data-view="widget"></div>
  <div data-view="another_widget"></div>
</div>

````

As you see, we have two layout views, which point to the same namespace. It's a problem, because, for example, we want to bind all views from one namespace with some BB-models. **applicationId** will help us, because views from different layouts will have different **applicationId**.

Component views will have **applicationId** equal to **null**.

### nodeName
**[String]**

This is just camelized name of widjet:

````html
<!-- nodeName is 'Layout' -->
<div data-app="my_simple_app">
  <!-- nodeName is 'Widget' -->
  <div data-view="widget"></div>
    <!-- nodeName is 'AnotherWidget' -->
  <div data-view="another_widget"></div>
</div>
<!-- nodeName is 'Select' -->
<div data-view="ui#select">
</div>
````

### applicationName
**[String]**

The same as **nodeName**, but for application name (is **null** if node is a component part):

````html
<!-- applicationName is 'MySimpleApp' -->
<div data-app="my_simple_app">
  <!-- applicationName is 'MySimpleApp' -->
  <div data-view="widget"></div>
    <!-- applicationName is 'MySimpleApp' -->
  <div data-view="another_widget"></div>
</div>
<!-- applicationName is null -->
<div data-view="ui#select">
</div>
````

### componentName
**[String]**

The same as **nodeName**, but for component name (is **null** if node is an application part):

````html
<!-- componentName is null -->
<div data-app="my_simple_app">
  <!-- componentName is null -->
  <div data-view="widget"></div>
    <!-- componentName is null -->
  <div data-view="another_widget"></div>
</div>
<!-- componentName is 'Ui' -->
<div data-view="ui#select">
</div>
````

### nodeNameUnderscored
**[String]**

The same as **nodeName**, but in underscored form.

### applicationNameUnderscored
**[String]**

The same as **applicationName**, but in underscored form.

### componentNameUnderscored
**[String]**

The same as **componentName**, but in underscored form.

### setData(name, value)

This method will save some data, associated with this node. This data then can be available in unload hook. For example, we can initialize backbone view, and save reference to it. And then we'll get access to this view to unload it.

### getData(name)

This method returns data, previously attached to this node.


## Vtree.DOM

Those are methods for DOM manipulations. With them, dynamicaly added nodes will be hooked.

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
