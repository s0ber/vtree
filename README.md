Vtree
=====
[![Build Status](https://travis-ci.org/s0ber/vtree.png?branch=master)](https://travis-ci.org/s0ber/vtree)

Simple library for automated initialization of backbone views.

The main purpose of this library is parsing given HTML and then initializing set of views related to this HTML.

This library also provides dom manipulations methods, which helps to automatically initialize views when html is being inserted into DOM dynamically.

Let's say we have such HTML:

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

**Vtree** will initialize views based on ```[data-app]``` and ```[data-view]``` attributes. Actually, instances of next classes will be created in specified order:

- MyAppComponent.LayoutView
- MyAppComponent.HeaderView
- ContentComponent.LayoutView
- ContentComponent.ItemView
- ContentComponent.ItemView
- ContentComponent.ItemView
- MyAppComponent.FooterView

Component is a wrapper for a set of views, but component also has it's own view, called *layout* view. All views, located inside of a DOM element with ```[data-app]``` will be initialized from associated namespace.

I.e. if element has ```[data-app="Search"]```, at first, *SearchComponent.LayoutView* will be initialized, and all inner views will be initialized from *SearchComponent* namespace unless other inner namespaces are specified.

Views are being initialized in an order corresponding to it's place in a DOM tree. Actually, **Vtree** constructs tree of *ViewNode* objects, and each node in this tree represents DOM-node, on which backbone view should be initialized.

When changing any part of DOM tree, corresponding branch of views tree will be rebuilded and new views for new DOM-elements will be initialized (and, moreover, views for removed DOM nodes will be unloaded).

That's the basic functionality, but it is more complicated and can be easily overwritten.

In general, the main idea of this library — I don't want to know what I need to initialize. I wan't to get pure html from server, insert it into DOM, and all other work, related to initialization of related JS — should be made automatically.
