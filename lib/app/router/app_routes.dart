enum AppRoute {
  app('/app'),
  home('/home'),
  discovery('/discovery'),
  profile('/profile'),
  details('/details'),
  settings('/settings');

  final String path;
  const AppRoute(this.path);
}
