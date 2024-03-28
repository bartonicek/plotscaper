HTMLWidgets.widget({

  name: 'plotscaper',
  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        const spec = {};
        const { data, types, plots, layout } = x

        for (const [k, v] of Object.entries(types)) {
          spec[k] = plotscape.col(v);
        }

        const parsedData = plotscape.parseColumns(data, spec);
        const scene = plotscape.newScene(el, parsedData)

        for (const v of Object.values(plots)) {
          const { type, encoding } = v

          const selectfn = (object) => {
            const result = {}
            for (const [k, v] of Object.entries(encoding)) {
              result[k] = object[v]
            }
            return result
          }

          scene.addPlotByKey(type, selectfn)
        }

        if (layout) scene.setLayout(layout)
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
