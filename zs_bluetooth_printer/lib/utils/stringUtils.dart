class StringUtils {

  static bool empty(dynamic str) {
    if (!(str is String)) {
      return true;
    }
    if (null == str || str.length == 0) {
      return true;
    }
    String s = str.replaceAll(" ", "");
    return s.length == 0;
  }

  static String appendOfSpace(String s1, String s2) {
    if (empty(s1) == false && empty(s2) == false) {
      return s1 + " " + s2;
    }

    if (empty(s1) == false) {
      return s1;
    }

    if (empty(s2) == false) {
      return s2;
    }

    return "";
  }
}
