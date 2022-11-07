HTMLWidgets.widget({

  name: 'plotscaper',
  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
        el.classList.add("graphicDiv")
        this.scene = new PLOTSCAPE.Scene(el, new PLOTSCAPE.DataFrame(x.data),
                                          {layout : x.layout})

        if (!x.types) return
        const typeArray = Array.isArray(x.types) ? x.types : [x.types]
        typeArray.forEach((e, i) => {
          const mapping = x.mappings[i]
          const mappingArray = Object.keys(mapping).map(e => [e, mapping[e]])
          this.scene.addPlotWrapper(e, new PLOTSCAPE.Mapping(...mappingArray))
        })

        console.log(x)

        x.premark.indices.forEach((e, i) => {
          this.scene.globals.marker.updateCurrent(e, x.premark.membership[i])
          this.scene.globals.marker.mergeCurrent(true)
        })


      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size
        console.log(this.scene)
        this.scene.resize()

      }

    };
  }
});
