class News {
  String _id = '';
  String _title = '';
  String _author = '';
  String _content = '';
  bool _active = false;
  String _img = '';
  String _createdAt = '';
  String _updatedAt = '';

  String get id {
    return _id;
  }

  String get title {
    return _title;
  }

  String get author {
    return _author;
  }

  String get content {
    return _content;
  }

  bool get active {
    return _active;
  }

  String get img {
    return _img;
  }

  String get createdAt {
    return _createdAt;
  }

  String get updatedAt {
    return _updatedAt;
  }
}