enum SocialAuthTypes {
  google(name: 'Google'),
  facebook(name: 'Facebook'),
  apple(name: 'Apple');

  final String name;

  const SocialAuthTypes({required this.name});
}
