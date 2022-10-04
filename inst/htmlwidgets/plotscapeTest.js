HTMLWidgets.widget({

  name: 'plotscapeTest',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
        el.classList.add("graphicDiv")
        el.innerText = PLOTSCAPE.mean(x.data);
        const scene = new PLOTSCAPE.Scene(el, new PLOTSCAPE.DataFrame(x.data))

        console.log(x.dims[0])

        const typeArray = Array.isArray(x.types) ? x.types : [x.types]
        typeArray.forEach((e, i) => {
          const mapping = x.mappings[i]
          const dims = x.dims[i]
          const mappingArray = Object.keys(mapping).map(e => [e, mapping[e]])
          scene.addPlotWrapper(e, new PLOTSCAPE.Mapping(...mappingArray), dims)
        })

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
