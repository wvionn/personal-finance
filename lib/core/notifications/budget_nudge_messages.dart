import 'dart:math';

/// Passive-aggressive / sarcastic reminders — rotate by day so it stays fresh.
class BudgetNudgeMessages {
  static final _rnd = Random();

  static const _afternoon = [
    "Lunch break? Cute. Your wallet still has zero proof you exist.",
    "It's 12–2. The 'later' you promised your budget? Still waiting. Iconic.",
    "Noon check-in: money doesn't track itself. I know, news to nobody.",
    "Catat uang hari ini atau... ya udah, pura-pura aja kalau hidup gratis.",
    "Your transaction list is so empty it's basically minimalist art. Wrong app for that.",
  ];

  static const _afternoonLate = [
    "Still in the afternoon window. Still avoiding one honest tap? Bold.",
    "Biaya hidup nggak libur. Kamu sih boleh aja, kan?",
    "The afternoon shift called — your expenses didn't clock in. Again.",
  ];

  static const _evening = [
    "8pm club: either you're logging spending or you're cosplaying amnesia.",
    "Malam ini uangmu di mana? Oh right — *nowhere in this app*.",
    "Evening budget review. Attendees: 0. Drama: surprisingly high.",
    "Stop scrolling. Start one row in Pengeluaran. I dare you.",
  ];

  static const _night = [
    "9–10pm: perfect hour to pretend tomorrow-you will fix today's mess.",
    "Still nothing logged tonight? The guilt is complimentary. The overdraft isn't.",
    "Your future self just rolled their eyes. Loudly.",
    "One entry before sleep. Unless peace of mind is overrated for you.",
  ];

  static const _idleNoTx = [
    "Zero transactions today… you forgot, or you're training for secrecy?",
    "Hari ini kosong. Keren. *Salah jenis kerennya.*",
    "No entries today. The void says hi. It misses you. Weirdly.",
    "There's no transaction today... you forget???",
    "Budget who? Anyway, your graph is starving. Feed it.",
  ];

  static String afternoon(int daySeed) => _afternoon[daySeed % _afternoon.length];

  static String afternoonLate(int daySeed) =>
      _afternoonLate[daySeed % _afternoonLate.length];

  static String evening(int daySeed) => _evening[daySeed % _evening.length];

  static String night(int daySeed) => _night[daySeed % _night.length];

  static String idleRandom() => _idleNoTx[_rnd.nextInt(_idleNoTx.length)];
}
