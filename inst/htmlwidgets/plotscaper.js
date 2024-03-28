HTMLWidgets.widget({

  name: 'plotscaper',
  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        console.log(x)
        const spec = {};

        for (const [k, v] of Object.entries(x.types)) {
          spec[k] = plotscape.col(v);
        }

        const data = plotscape.parseColumns(x.data, spec);

        // TODO: code to render the widget, e.g.
        el.innerText = x.message;

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
