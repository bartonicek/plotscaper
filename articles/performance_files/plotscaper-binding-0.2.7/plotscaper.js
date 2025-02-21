HTMLWidgets.widget({

  name: 'plotscaper',
  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {
        const { data, queue, options } = x;

        const scene = plotscape.Scene.of(data, options);
        plotscape.Scene.append(el, scene);

        for (const msg of queue) {
          plotscape.Scene.handleMessage(scene, msg);
        };

        window.plotscape.currentScene = scene;
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
