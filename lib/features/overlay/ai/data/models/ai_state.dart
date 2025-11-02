class AIState {
  final String? aiContent;
  final String? aiLink;
  final String? navigation;
  final bool isCardVisible;
  final bool isFirstAppearance;

  AIState({
    this.aiContent,
    this.aiLink,
    this.navigation,
    this.isCardVisible = false,
    this.isFirstAppearance = true,
  });

  AIState copyWith({
    String? aiContent,
    String? aiLink,
    String? navigation,
    bool? isCardVisible,
    bool? isFirstAppearance,
  }) {
    return AIState(
      aiContent: aiContent ?? this.aiContent,
      aiLink: aiLink ?? this.aiLink,
      navigation: navigation ?? this.navigation,
      isCardVisible: isCardVisible ?? this.isCardVisible,
      isFirstAppearance: isFirstAppearance ?? this.isFirstAppearance,
    );
  }
}