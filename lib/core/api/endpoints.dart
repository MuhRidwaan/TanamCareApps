class Endpoints {
  // 1. Modul Autentikasi [cite: 5]
  static const String register = '/register'; // POST [cite: 7]
  static const String login = '/login'; // POST [cite: 10]
  static const String user = '/user'; // GET [cite: 14]
  static const String updateProfile = '/user/update'; // PUT
  static const String logout = '/logout'; // POST [cite: 21]

  // 2. Modul Master Data [cite: 23]
  static const String species = '/species'; // GET [cite: 25]
  static const String issues = '/issues'; // GET [cite: 29]

  // 3. Modul Kebun Saya [cite: 35]
  static const String myPlants = '/my-plants'; // GET & POST [cite: 37, 40]

  // 4. Modul Monitoring [cite: 50]
  static const String logs = '/logs'; // POST [cite: 53]
  static const String careLogs = '/care-logs'; // POST [cite: 57]
}
