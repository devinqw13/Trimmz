extension DateCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year && this.month == other.month
           && this.day == other.day;
  }

  bool isAfterTime(DateTime other) {
    DateTime x = DateTime(
      this.year,
      this.month,
      this.day,
      other.hour,
      other.minute,
      other.second,
      other.millisecond,
      other.millisecond
    );

    return this.isAfter(x);
  }

  bool isBeforeTime(DateTime other) {
    DateTime x = new DateTime(
      this.year,
      this.month,
      this.day,
      other.hour,
      other.minute,
      other.second,
      other.millisecond,
      other.millisecond
    );

    return this.isBefore(x);
  }
}