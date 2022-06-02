void printDebug(Object object) async {
  final defaultPrintLength = 1020;
  if (object != null) {
    final log = object.toString();
    var start = 0;
    var endIndex = defaultPrintLength;
    final logLength = log.length;
    var tmpLogLength = log.length;
    while (endIndex < logLength) {
      print(log.substring(start, endIndex));
      endIndex += defaultPrintLength;
      start += defaultPrintLength;
      tmpLogLength -= defaultPrintLength;
    }
    if (tmpLogLength > 0) {
      print(log.substring(start, logLength));
    }
  }
}