/// SRSレビューの評価
enum Rating {
  again('again', 'もう一度'),
  hard('hard', '難しい'),
  good('good', '良い'),
  easy('easy', '簡単');

  const Rating(this.value, this.label);

  final String value;
  final String label;

  static Rating fromValue(String value) {
    return Rating.values.firstWhere(
      (rating) => rating.value == value,
      orElse: () => Rating.good,
    );
  }
}
