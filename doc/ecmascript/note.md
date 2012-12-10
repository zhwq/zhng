## note-1-ecmascript-bound-functions

* Purposes
    * Bound this value
    * Partial application
* Implementation features
* Constructor with various number of arguments
* Summary
* Additional literature

As we know, ECMA-262-5 standardized bind method of the Function.prototype. The source of the current version of this method is "Prototype.js" library, although, the stardardizd version has several differences. This approach is well known and was successfully used in ES3, so the main purpose of the current node is to show the technical details and differences(which can cause confusing) of the ES5 implementation.

### Purposes
The current implementation of the Function.prototype.bind has two purposes, which are the static bound this value and the partial application of a function. Let's consider them.

### Bound this value
The main purpose of the bind method is to statically bind a this value for subsequent calls of a function.
As we considered in the [ECMA-262-3. Chapter3. This](http://dmitrysoshnikov.com/ecmascript/chapter-3-this/), a this value can vary in every function call. So, the main purpose of the bind is to fix this "issue" which can appear e.g. when we attach a method of an object as every handler of some DOM element. Using a bound function we can always have a correct this value in the event's handling.

    var widget = {
      state: {},
      onClick: function onWidgetClick(event) {
        if (this.state.active) {
          // ...
        }
      }
    };
  document.getElementById('widget').onclick = widget.onClick.bind(widget);

I used simple click event attaching in the example above- vie onclick method, but on practice you can better use multiple listeners pattern using addEventListener or attacheEvent. However the goal of the example is to show how this value is predefined and bount to the widget object inside the onclick method, and this.state property is available.

### Partical function
Another purpose of the current "bind" implementation is a curring( or closer to mathematics - a partical application of a function).
