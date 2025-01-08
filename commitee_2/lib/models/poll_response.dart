class PollResponse {
  final String userId;
  final String userName;
  final String response;

  PollResponse({
    required this.userId,
    required this.userName,
    required this.response,
  });

  PollResponse copyWith({
    String? userId,
    String? userName,
    String? response,
  }) {
    return PollResponse(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      response: response ?? this.response,
    );
  }
}