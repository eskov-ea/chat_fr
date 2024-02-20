final RegExp forwardRegExp = RegExp(r'(?<=from:)[а-яА-Я\s]*(?=:end)');
final RegExp forwardRegExpReplacement = RegExp(r'from:[а-яА-Я\s]*:end');

String forwardMessage(String text, String author) {
  return "from:$author:end$text";
}

String? getForwardedMessageStatus(String json) {
  try {
    final match = forwardRegExp.firstMatch(json);
    if (match == null || match.group(0) == null) return null;
    return match.group(0);
  } catch(err, stackTrace) {
    return null;
  }
}

String replaceForwardSymbol(String json) {
  return json.replaceAll(forwardRegExpReplacement, '');
}