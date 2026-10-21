{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: { canvasKitBaseUrl: 'canvaskit/' },
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine({
        canvasKitBaseUrl: 'canvaskit/',
      });
      await appRunner.runApp();
    } catch (error) {
      console.error('No se pudo iniciar Lira', error);
      window.liraLoadingError();
    }
  },
}).catch(function (error) {
  console.error('No se pudo cargar Lira', error);
  window.liraLoadingError();
});
