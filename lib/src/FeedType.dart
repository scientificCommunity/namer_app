
enum FeedType {
  breastMilk, // Ä¸Èé
  formulaMilk, // Åä·½ÄÌ
}

extension FeedTypeExt on FeedType {
  int get value {
    switch (this) {
      case FeedType.breastMilk:
        return 1;
      case FeedType.formulaMilk:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case FeedType.breastMilk:
        return "Ä¸Èé";
      case FeedType.formulaMilk:
        return "Åä·½ÄÌ";
    }
  }
}
