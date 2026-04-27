String? readEnv(String key) {
  switch (key) {
    case 'CR_API_TOKEN':
      const v = String.fromEnvironment('CR_API_TOKEN');
      return v.isEmpty ? null : v;
    case 'CR_API_BASE_URL':
      const v = String.fromEnvironment('CR_API_BASE_URL');
      return v.isEmpty ? null : v;
  }
  return null;
}
