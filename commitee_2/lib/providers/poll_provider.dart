import 'package:flutter/foundation.dart';
import '../models/poll.dart';
import '../models/user.dart';
import '../models/poll_response.dart';

class PollProvider with ChangeNotifier {
  final List<Poll> _polls = [];

  List<Poll> get polls => _polls;

  List<Poll> get activePolls => _polls.where((poll) => poll.isActive).toList();

  void addPoll(Poll poll) {
    _polls.add(poll);
    notifyListeners();
  }

  void updatePoll(Poll updatedPoll) {
    final index = _polls.indexWhere((p) => p.id == updatedPoll.id);
    if (index != -1) {
      _polls[index] = updatedPoll;
      notifyListeners();
    }
  }

  void removePoll(String pollId) {
    _polls.removeWhere((p) => p.id == pollId);
    notifyListeners();
  }

  void togglePollStatus(String pollId) {
    final index = _polls.indexWhere((p) => p.id == pollId);
    if (index != -1) {
      final poll = _polls[index];
      final updatedPoll = poll.copyWith(
        isActive: !poll.isActive,
        lastUpdated: DateTime.now(),
      );
      _polls[index] = updatedPoll;
      notifyListeners();
    }
  }

  List<PollResponse> getPollResponses(String pollId) {
    final poll = _polls.firstWhere((p) => p.id == pollId);
    List<PollResponse> responses = [];
    
    for (var option in poll.options) {
      for (var userId in option.votes) {
        responses.add(PollResponse(
          userId: userId,
          userName: "User $userId", // You might want to fetch actual user names
          response: option.text,
        ));
      }
    }
    
    return responses;
  }

  bool hasUserVoted(String pollId, String userId) {
    final poll = _polls.firstWhere((p) => p.id == pollId);
    return poll.options.any((option) => option.votes.contains(userId));
  }

  Future<void> vote(String pollId, String optionId, User user) async {
    try {
      final pollIndex = _polls.indexWhere((p) => p.id == pollId);
      if (pollIndex != -1) {
        final poll = _polls[pollIndex];
        if (!poll.isActive) throw Exception("Poll is not active");
        
        final optionIndex = poll.options.indexWhere((o) => o.id == optionId);
        if (optionIndex != -1 && !hasUserVoted(pollId, user.id)) {
          final updatedOptions = List<PollOption>.from(poll.options);
          updatedOptions[optionIndex] = updatedOptions[optionIndex].copyWith(
            votes: [...updatedOptions[optionIndex].votes, user.id],
          );
          
          _polls[pollIndex] = poll.copyWith(
            options: updatedOptions,
            lastUpdated: DateTime.now(),
          );
          notifyListeners();
        } else {
          throw Exception("User has already voted");
        }
      } else {
        throw Exception("Poll not found");
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> createPoll({
    required String title,
    required String description,
    required List<String> options,
    required String createdBy,
  }) async {
    final newPoll = Poll(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      options: options.map((option) => PollOption(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: option,
      )).toList(),
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
    
    _polls.add(newPoll);
    notifyListeners();
  }

  Future<void> deletePoll(String pollId) async {
    try {
      _polls.removeWhere((poll) => poll.id == pollId);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> editPoll(String pollId, {
    required String title,
    required String description,
    required List<String> options,
  }) async {
    try {
      final index = _polls.indexWhere((poll) => poll.id == pollId);
      if (index != -1) {
        final oldPoll = _polls[index];
        _polls[index] = Poll(
          id: pollId,
          title: title,
          description: description,
          options: options.map((option) => PollOption(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: option,
          )).toList(),
          createdBy: oldPoll.createdBy,
          createdAt: oldPoll.createdAt,
          lastUpdated: DateTime.now(),
        );
        notifyListeners();
      } else {
        throw Exception("Poll not found");
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}