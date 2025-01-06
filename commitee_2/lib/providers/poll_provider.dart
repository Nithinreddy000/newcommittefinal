import 'package:flutter/foundation.dart';
import '../models/poll.dart';
import '../models/user.dart';

class PollProvider extends ChangeNotifier {
  final List<Poll> _polls = [];

  List<Poll> get polls => _polls;

  void addPoll(Poll poll) {
    _polls.add(poll);
    notifyListeners();
  }

  List<PollResponse> getPollResponses(String pollId) {
    final poll = _polls.firstWhere((p) => p.id == pollId);
    List<PollResponse> responses = [];
    
    for (var option in poll.options) {
      for (var userId in option.votes) {
        responses.add(PollResponse(
          userId: userId,
          userName: "User $userId", // You might want to fetch actual user names
          text: option.text,
        ));
      }
    }
    
    return responses;
  }

  bool hasUserVoted(String pollId, String userId) {
    final poll = _polls.firstWhere((p) => p.id == pollId);
    return poll.options.any((option) => option.votes.contains(userId));
  }

  void vote(String pollId, String optionId, User user) {
    final pollIndex = _polls.indexWhere((p) => p.id == pollId);
    if (pollIndex != -1) {
      final poll = _polls[pollIndex];
      final optionIndex = poll.options.indexWhere((o) => o.id == optionId);
      if (optionIndex != -1 && !hasUserVoted(pollId, user.id)) {
        poll.options[optionIndex].votes.add(user.id);
        notifyListeners();
      }
    }
  }

  void createPoll({
    required String title,
    required String description,
    required String createdBy,
    required List<String> optionTexts,
  }) {
    final poll = Poll(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      options: optionTexts.map((text) => PollOption(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
      )).toList(),
    );
    
    addPoll(poll);
  }
} 