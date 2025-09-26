
enum FeedType {
  breastMilk, // ĸ��
  formulaMilk, // �䷽��
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
        return "ĸ��";
      case FeedType.formulaMilk:
        return "�䷽��";
    }
  }
}
